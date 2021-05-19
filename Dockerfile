FROM ubuntu:18.04 as builder
MAINTAINER Daniel Guerra

ENV DEBIAN_FRONTEND=noninteractive

# Install packages

ENV DEBIAN_FRONTEND noninteractive
RUN sed -i "s/# deb-src/deb-src/g" /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -yy upgrade
ENV BUILD_DEPS="git autoconf pkg-config libssl-dev libpam0g-dev \
    libx11-dev libxfixes-dev libxrandr-dev nasm xsltproc flex \
    bison libxml2-dev dpkg-dev libcap-dev"
RUN apt-get -yy install  sudo apt-utils software-properties-common $BUILD_DEPS


# Build xrdp

WORKDIR /tmp
RUN apt-get source pulseaudio
RUN apt-get build-dep -yy pulseaudio
WORKDIR /tmp/pulseaudio-11.1
RUN dpkg-buildpackage -rfakeroot -uc -b
WORKDIR /tmp
RUN git clone --branch devel --recursive https://github.com/neutrinolabs/xrdp.git
WORKDIR /tmp/xrdp
RUN ./bootstrap
RUN ./configure
RUN make
RUN make install
WORKDIR /tmp
RUN  apt -yy install libpulse-dev
RUN git clone --recursive https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
WORKDIR /tmp/pulseaudio-module-xrdp
RUN ./bootstrap && ./configure PULSE_DIR=/tmp/pulseaudio-11.1
RUN make
RUN mkdir -p /tmp/so
RUN cp src/.libs/*.so /tmp/so

FROM ubuntu:18.04
ARG ADDITIONAL_PACKAGES=""
ENV ADDITIONAL_PACKAGES=${ADDITIONAL_PACKAGES}
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt install -y software-properties-common
RUN add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner" && apt update
RUN apt -y full-upgrade && apt install -y \
  adobe-flashplugin \
  browser-plugin-freshplayer-pepperflash \
  ca-certificates \
  crudini \
  firefox \
  less \
  locales \
  openssh-server \
  pulseaudio \
  pulseaudio-utils \
  sudo \
  supervisor \
  uuid-runtime \
  vim \
  novnc \
  chromium-browser \
  bash \
  ssh \
  socat \
  net-tools \
  dbus-x11 \
  vlc \
  wget \
  xauth \
  xautolock \
  xfce4 \
  xfce4-clipman-plugin \
  xfce4-cpugraph-plugin \
  xfce4-netload-plugin \
  xfce4-screenshooter \
  xfce4-taskmanager \
  xfce4-terminal \
  xfce4-xkb-plugin \
  xorgxrdp \
  xprintidle \
  xrdp \
  $ADDITIONAL_PACKAGES && \
  apt-get remove -yy xscreensaver && \
  apt-get autoremove -yy && \
  rm -rf /var/cache/apt /var/lib/apt/lists && \
  mkdir -p /var/lib/xrdp-pulseaudio-installer
COPY --from=builder /tmp/so/module-xrdp-source.so /var/lib/xrdp-pulseaudio-installer
COPY --from=builder /tmp/so/module-xrdp-sink.so /var/lib/xrdp-pulseaudio-installer
ADD bin /usr/bin
ADD etc /etc
ADD autostart /etc/xdg/autostart
#ADD pulse /usr/lib/pulse-10.0/modules/



COPY . /app
RUN chmod +x /app/conf.d/websockify.sh
RUN chmod +x /app/run.sh
RUN chmod +x /app/expect_vnc.sh
#RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list
RUN echo "deb [trusted=yes] http://deb.anydesk.com/ all main"  >> /etc/apt/sources.list
#RUN echo "deb [trusted=yes] https://xpra.org/ bionic main"  >> /etc/apt/sources.list
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
#        xpra


ENV UNAME pacat

RUN apt-get update
RUN apt-get upgrade
RUN apt-get install -y software-properties-common
RUN apt-get update
RUN add-apt-repository ppa:x2go/stable
RUN apt-get install -y x2goserver x2goserver-xsession
RUN apt-get update
RUN git clone https://github.com/Xpra-org/xpra; cd xpra \
    python3 ./setup.py install
    
#Installing Xrdp
#RUN apt-get -qy install xrdp -y && sudo service xrdp restart

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
    
#Installing Ngrok
RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -O /usr/bin/ngrok.zip && unzip /usr/bin/ngrok.zip

#RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

RUN echo xfce4-session >~/.xsession
RUN echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" 

EXPOSE 3389 22 9001

CMD ["/app/run.sh"]
