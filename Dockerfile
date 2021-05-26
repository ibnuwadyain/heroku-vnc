FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        dbus-x11 \
        expect \
        sudo \
        nano \
	vim \
        bash \
	apt-utils \
        net-tools \
        novnc \
        lxqt \
        sddm \
#       xfce4 \
#	xfce4-goodies \
	lightdm \
	gedit \
	socat \
        x11vnc \
	xvfb \
        supervisor \
        curl \
        git \
        wget \
        g++ \
	unzip \
	xterm \
	ufw \
	iproute2 \
        ssh \
	chromium-browser \
        terminator \
        htop \
        gnupg2 \
	locales \
	openssh-server \
	x11-xserver-utils \
#	pulseaudio \
#	pulseaudio-utils \
#	xfce4-pulseaudio-plugin \
	open-vm-tools \
	open-vm-tools-desktop \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*
RUN dpkg-reconfigure locales


#RUN sudo apt-get update && sudo apt-get install -y obs-studio
RUN sudo apt-get update && sudo apt-get install -y alsa alsa-tools

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

RUN sed -i -E 's/^; autospawn =.*/autospawn = yes/' /etc/pulse/client.conf \
    && [ -f /etc/pulse/client.conf.d/00-disable-autospawn.conf ] && sed -i -E 's/^(autospawn=.*)/# \1/' /etc/pulse/client.conf.d/00-disable-autospawn.conf || :

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y software-properties-common
RUN apt-get update
RUN add-apt-repository ppa:x2go/stable
RUN apt-get install -y x2goserver x2goserver-xsession

#install xpra
RUN apt-get update
RUN wget -q https://xpra.org/gpg.asc -O- | sudo apt-key add -
RUN echo "deb [trusted=yes] https://xpra.org/ bionic main"  >> /etc/apt/sources.list
#RUN cd /etc/apt/sources.list.d;wget $REPOFILE
RUN apt update;apt install -y xpra

#install xrdp dependency pakages
RUN apt update;apt install -y xserver-xorg-core
RUN apt update;apt install -y xserver-xorg-input-all

#Installing Xrdp
RUN apt-get -qy install xrdp -y && sudo service xrdp restart
    
#Installing Ngrok
RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -O /usr/bin/ngrok.zip && unzip /usr/bin/ngrok.zip

#RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh


#RUN echo xfce4-session >~/.xsession
#RUN echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" 

RUN sed -i.bak '/fi/a #xrdp multiple users configuration \n xfce4-session \n' /etc/xrdp/startwm.sh

EXPOSE 3389 22 9001

RUN ufw allow 3389/tcp
RUN sudo service xrdp restart

# Set up the user
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    mkdir -p "/home/${UNAME}" && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    gpasswd -a ${UNAME} audio

#remove xscreensaver
#RUN apt-get autoremove --purge -y xscreensaver
#RUN sudo touch /usr/local/bin/gdmflexiserver
#RUN sudo echo "#!/bin/bash dm-tool switch-to-greeter"  >> /usr/local/bin/gdmflexiserver
#RUN sudo chmod +x /usr/local/bin/gdmflexiserver

# Set up the user
RUN sudo echo "root:qwqw1826" | chpasswd
RUN sudo useradd -m a69bb && sudo adduser a69bb sudo && echo 'a69bb:qwqw1826' | sudo chpasswd
RUN xrdp
RUN mkdir /.ngrok2
RUN echo > /.ngrok2/ngrok.yml
RUN echo "authtoken: 1qww1vtgs981PJoLNO3Ri18mT6k_45M7fN2hA5atSQSb6uVWm" >> /.ngrok2/ngrok.yml
RUN ./ngrok
CMD ["/app/run.sh"]
