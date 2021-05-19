#!/bin/bash
websockify --web /usr/share/novnc $PORT localhost:5900
./ngrok authtoken 1qww1vtgs981PJoLNO3Ri18mT6k_45M7fN2hA5atSQSb6uVWm
./ngrok tcp 3389
