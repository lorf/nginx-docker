#!/bin/sh

set -xe

while :; do
    ffmpeg -v warning -re -stream_loop -1 -i /usr/share/nginx/rtmp/testloop/small.mp4 -threads 2 -vcodec libx264 -vprofile baseline -acodec aac -ar 44100 -ab 256k -r 25 -s 640x360 -f flv -strict -2 rtmp://localhost/hls/test || true
done &

while :; do
    ffmpeg -v warning -re -stream_loop -1 -i /usr/share/nginx/rtmp/testloop/small.mp4 -threads 2 -vcodec libx264 -vprofile baseline -acodec aac -ar 44100 -ab 256k -r 25 -s 640x360 -f flv -strict -2 rtmp://localhost/dash/test || true
done &

nginx -g 'daemon off;'
