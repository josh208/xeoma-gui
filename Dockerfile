# phusion/baseimage as FROM image.
FROM phusion/baseimage:0.9.22
MAINTAINER Josh McAllister <"josh208@gmail.com">

CMD ["/sbin/my_init"]

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV TZ=America/Boise
ENV SCREEN_RESOLUTION 1024x768
ENV DISPLAY :0

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install libasound2 so we can have audio from cameras.
RUN apt-get update && apt-get -y upgrade && \
	apt-get install -y libasound2 \
	xvfb \
	x11vnc \
	supervisor \
	fluxbox \
	net-tools \
	git-core \ 
	git

#House cleaning
RUN apt-get autoclean

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
	
# Download and configure the latest release
 RUN curl -o /root/xeoma_linux64.tgz http://felenasoft.com/xeoma/downloads/xeoma_linux64.tgz
 RUN tar -xvzf /root/xeoma_linux64.tgz -C /root
 RUN /root/xeoma.app -install -hiddenmode
 RUN rm /root/xeoma_linux64.tgz
 RUN touch /root/firstrun

# Change work directory to add novnc files
WORKDIR /root/
ADD noVNC-0.6.2 /root/novnc/
RUN ln -s /root/novnc/vnc_auto.html /root/novnc/index.html 

# Set up start up scripts
 RUN mkdir -p /etc/service/xeoma/run
 RUN curl -o /etc/service/xeoma/run/xeoma.sh https://raw.githubusercontent.com/jknight2014/xeoma-docker/master/xeoma.sh
 RUN chmod +x /etc/service/xeoma/run

 VOLUME /usr/local/Xeoma

# Clean up APT when done.
 RUN apt-get clean
 RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose Xeomas remote access port. 
 EXPOSE 8090 8080 5900
