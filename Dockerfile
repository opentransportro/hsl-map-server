FROM node:6-stretch
MAINTAINER OpenTransport version: 0.1

ENV FONTSTACK_PASSWORD ""
ENV ROMANIA_OTP_URL api.opentransport.ro/routing/v1/routers/romania/index/graphql
ENV WORK=/opt/map-server
ENV NODE_OPTS ""

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y git unzip pngquant libgl1-mesa-glx libgl1-mesa-dri xserver-xorg-video-dummy libgles2-mesa libstdc++6

RUN mkdir -p ${WORK}
WORKDIR ${WORK}

COPY yarn.lock ${WORK}
COPY package.json ${WORK}
RUN yarn install

COPY . ${WORK}

# RUN curl https://tm.opentransport.ro/tiles.mbtiles > romania.mbtiles
# RUN curl https://hslstoragekarttatuotanto.blob.core.windows.net/tiles/tiles.mbtiles > finland.mbtiles
EXPOSE 8080

RUN chmod -R 777 ${WORK}

RUN mkdir /.forever && chmod -R 777 /.forever
#USER 9999

ADD run.sh /usr/local/bin/


CMD /usr/local/bin/run.sh
