FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex; \
    apt-get update \
    && apt-get install -y \
        dbus-x11 \
        expect \
        sudo \
        vim \
        bash \
	apt-utils \
        net-tools \
        novnc \
        xfce4 \
	socat \
        x11vnc \
	xvfb \
        supervisor \
        curl \
        git \
        wget \
        g++ \
	unzip \
        ssh \
	chromium-browser \
        terminator \
        htop \
        gnupg2 \
	locales \
	openssh-server \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*
RUN dpkg-reconfigure locales

#RUN sudo apt-get update && sudo apt-get install -y obs-studio
#RUN sudo apt-get update && sudo apt-get install -y alsa alsa-tools

#remove xscreensave
RUN apt-get -y purge autoremove xscreensaver

COPY . /app
RUN chmod +x /app/conf.d/websockify.sh
RUN chmod +x /app/run.sh
RUN chmod +x /app/expect_vnc.sh
#RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list
RUN echo "deb [trusted=yes] http://deb.anydesk.com/ all main"  >> /etc/apt/sources.list
RUN wget --no-check-certificate https://dl.google.com/linux/linux_signing_key.pub -P /app
RUN wget --no-check-certificate -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY -O /app/anydesk.key
#RUN wget --no-check-certificate -q https://xpra.org/gpg.asc -O- | apt-key add -
RUN apt-key add /app/anydesk.key
RUN apt-key add /app/linux_signing_key.pub
RUN set -ex; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
#        google-chrome-stable \
	anydesk


ENV UNAME pacat

#RUN apt-get update \ && DEBIAN_FRONTEND=noninteractive apt-get install --yes pulseaudio-utils

RUN apt-get update
RUN apt-get upgrade
RUN apt-get install -y software-properties-common
RUN apt-get update
RUN add-apt-repository ppa:x2go/stable
RUN apt-get install -y x2goserver x2goserver-xsession

#install xpra
RUN apt-get update
RUN wget -q https://xpra.org/gpg.asc -O- | sudo apt-key add -
RUN echo "deb [trusted=yes] https://xpra.org/ bionic main"  >> /etc/apt/sources.list
#RUN cd /etc/apt/sources.list.d;wget $REPOFILE
RUN apt update;apt install xpra

#install xrdp dependency pakages
RUN apt-get update \ && DEBIAN_FRONTEND=noninteractive apt-get -y install xserver-xorg-core
RUN apt-get update \ && DEBIAN_FRONTEND=noninteractive apt-get -y install xserver-xorg-input-all

#Installing Xrdp
RUN apt-get -qy install xrdp -y && sudo service xrdp restart

# Set up the user
RUN sudo useradd -m Area69Lab && sudo adduser Area69Lab sudo && echo 'Area69Lab:Area69Lab' | sudo chpasswd

    
#Installing Ngrok
RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -O /usr/bin/ngrok.zip && unzip /usr/bin/ngrok.zip

#RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

#RUN echo xfce4-session >~/.xsession
#RUN echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" 

EXPOSE 3389 22 9001

CMD ["/app/run.sh"]
