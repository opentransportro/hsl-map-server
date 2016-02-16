FROM node:4
MAINTAINER Reittiopas version: 0.1

ARG FONTSTACK_PASSWORD

ENV WORK=/opt/hsl-map-server
WORKDIR ${WORK}

RUN echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y git unzip \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y -t jessie-backports libgl1-mesa-glx libgl1-mesa-dri xserver-xorg-video-dummy

RUN mkdir -p ${WORK}

RUN npm install tessera \
  tilejson \
  tilelive-http \
  tilelive-otp-stops \
  tilelive-hsl-parkandride \
  mbtiles \
  tilelive-xray \
  forever

RUN curl https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/finland.mbtiles > finland.mbtiles

ADD xorg.conf ${WORK}/xorg.conf

RUN npm install https://github.com/hannesj/tilelive-gl.git

RUN npm install https://github.com/HSLdevcom/hsl-map-style.git

RUN cd ${WORK}/node_modules/hsl-map-style && \
  unzip -P ${FONTSTACK_PASSWORD} fontstack.zip && \
  sed -i -e "s#http://localhost:3000/#file://${WORK}/node_modules/hsl-map-style/#" hsl-gl-map-v8.json

COPY config.js ${WORK}/

EXPOSE 8088

#RUN chown -R 9999:9999 ${WORK}
#USER 9999

CMD Xorg -dpi 96 -nolisten tcp -noreset +extension GLX +extension RANDR +extension RENDER -logfile ./10.log -config ./xorg.conf :10 & \
  sleep 15 && \
  DISPLAY=":10" node_modules/.bin/forever start -c "node --harmony" \
  node_modules/tessera/bin/tessera.js --port 8088 --config config.js \
  -r ${WORK}/node_modules/tilelive-otp-stops/ \
  -r ${WORK}/node_modules/tilelive-gl/ \
  -r ${WORK}/node_modules/tilelive-hsl-parkandride \
  && sleep 10 && node_modules/.bin/forever --fifo logs 0