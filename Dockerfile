FROM lsiobase/nginx:3.10

# set version label
ARG BUILD_DATE
ARG VERSION
ARG RUTORRENT_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# copy patches
COPY patches/ /defaults/patches/

# install packages
RUN \echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	g++ \
	libffi-dev \
	openssl-dev \
	python3-dev && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache --upgrade \
	bind-tools \
	curl \
	fcgi \
	ffmpeg \
	geoip \
	gzip \
	libffi \
	mediainfo \
	openssl \
	php7 \
	php7-cgi \
	php7-curl \
	php7-fpm \
	php7-json  \
	php7-mbstring \
	php7-pear \
	php7-zip \
	procps \
	python3 \
	rtorrent \
	screen \
	sox \
	unrar \
	unzip \
	wget \
	zip && \
 echo "**** install pip packages ****" && \
 pip3 install --no-cache-dir -U \
	cfscrape \
	cloudscraper && \

 echo "**** install rutorrent ****" && \
 curl -o \
 /tmp/rutorrent.tar.gz -L \
	"https://github.com/Novik/rutorrent/archive/v3.9.tar.gz" && \
 mkdir -p \
	/app/rutorrent \
	/defaults/rutorrent-conf && \
 tar xf \
 /tmp/rutorrent.tar.gz -C \
	/app/rutorrent --strip-components=1 && \
 mv /app/rutorrent/conf/* \
	/defaults/rutorrent-conf/ && \
 rm -rf \
	/defaults/rutorrent-conf/users && \
 
# mkdir /usr/share/webapps/rutorrent/plugins/theme/themes && \
 cd /app/rutorrent/plugins/theme/themes && \
 git clone git://github.com/phlooo/ruTorrent-MaterialDesign.git MaterialDesign && \

 echo "**** patch snoopy.inc for rss fix ****" && \
 cd /app/rutorrent/php && \
 patch < /defaults/patches/snoopy.patch && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/etc/nginx/conf.d/default.conf \
	/root/.cache \
	/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 80
VOLUME /config /downloads
