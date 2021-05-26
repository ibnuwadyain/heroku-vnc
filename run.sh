#!/bin/bash

sudo useradd -m a69bb && sudo adduser a69bb sudo && echo 'a69bb:qwqw1826' | sudo chpasswd

set -ex
mkdir -p ~/.vnc ~/.config/xfce4
tar -xvf /app/panel.tar -C ~/.config/xfce4
rm -rf /usr/share/icons/Adwaita
cp -r /usr/share/icons/Humanity-Dark /usr/share/icons/Adwaita

mkdir -p /Desktop
cat << EOF >  /Desktop/Chromium.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Chromium
Comment=Access the Internet
Exec=/usr/bin/chromium-browser --no-sandbox --disable-dev-shm-usage
Icon=chromium-browser
Path=
Terminal=false
StartupNotify=true
EOF

cat << EOF >  /Desktop/AnyDesk.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=AnyDesk
Comment=
Exec=/usr/bin/anydesk
Icon=anydesk
Path=
Terminal=false
StartupNotify=true
EOF

cat << EOF >  /Desktop/Swicth_to_Chinese_input.sh
#!/bin/bash
im-config -s ibus
ibus-setup
EOF

cat << EOF >  /Desktop/Readme.txt
Step 1: Excute Swicth_to_Chinese_input.sh on Deskop to switch input method.
Step 2: Select 'Input Method', then click add button, choose Chinese and Pinyin icon to add.
Step 3: Now it can support Chinese, Enjoy!
EOF

chmod +x /Desktop/AnyDesk.desktop
chmod +x /Desktop/Chromium.desktop
chmod +x /Desktop/Swicth_to_Chinese_input.sh
exec supervisord -c /app/supervisord.conf

exec xrdp
exec echo "authtoken: 1qww1vtgs981PJoLNO3Ri18mT6k_45M7fN2hA5atSQSb6uVWm" >> /.ngrok2/ngrok.yml
exec ./ngrok
