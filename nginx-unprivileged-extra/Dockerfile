FROM lorf/nginx-unprivileged-src:stable AS build

# TODO:
#  * https://github.com/sergey-dryabzhinsky/nginx-rtmp-module ?
#  * debug build
RUN set -x && \
    sed -i 's/$/ non-free/' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y ffmpeg libssl-dev libxml2-dev libfdk-aac-dev && \
    cd /usr/src && \
    git clone --depth 1 https://github.com/vozlt/nginx-module-vts && \
    git clone --depth 1 https://github.com/arut/nginx-rtmp-module && \
    git clone --depth 1 https://github.com/kaltura/nginx-vod-module && \
    git clone -b AuthV2 --depth 1 https://github.com/anomalizer/ngx_aws_auth && \
    # ngx_aws_auth master needs a patch currently to process internal subrequests, see:
    # https://github.com/kaltura/nginx-vod-module/issues/717
    #git clone --depth 1 https://github.com/anomalizer/ngx_aws_auth && \
    cd /usr/src/nginx && \
    ./configure --with-compat \
        --add-dynamic-module=../nginx-module-vts \
        --add-dynamic-module=../nginx-rtmp-module \
        --add-dynamic-module=../nginx-vod-module --with-file-aio --with-threads --with-cc-opt="-O3" \
        --add-dynamic-module=../ngx_aws_auth \
        # Workaround https://github.com/arut/nginx-rtmp-module/issues/1520
        --with-cc-opt="-Wimplicit-fallthrough=0" && \
    make modules

FROM nginxinc/nginx-unprivileged:stable

USER root

RUN apt-get update && \
    apt-get install -y ffmpeg && \
    rm -rf /var/cache/apt/lists/* && \
    mkdir -p /usr/share/nginx/rtmp && \
    sed -i \
        -e '1i# Load dynamic modules\ninclude modules-conf.d\/*.conf;' \
        -e '1i# Global config\ninclude global-conf.d\/*.conf;' \
        -e '$a\\n# RTMP module config\ninclude rtmp.conf;' \
        /etc/nginx/nginx.conf && \
    mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.orig
COPY --from=build \
    /usr/src/nginx/objs/ngx_http_vhost_traffic_status_module.so \
    /usr/src/nginx/objs/ngx_rtmp_module.so \
    /usr/src/nginx/objs/ngx_http_vod_module.so \
    /usr/src/nginx/objs/ngx_http_aws_auth_module.so \
    /usr/lib/nginx/modules/
COPY --from=build /usr/src/nginx-rtmp-module/stat.xsl /usr/share/nginx/rtmp/
COPY --from=build /usr/src/nginx-rtmp-module/test /usr/share/nginx/rtmp/test
COPY --from=build /usr/src/nginx-vod-module/static /usr/share/nginx/vod-html
COPY rtmp.conf /etc/nginx/
COPY conf.d /etc/nginx/conf.d
COPY modules-conf.d /etc/nginx/modules-conf.d
COPY global-conf.d /etc/nginx/global-conf.d
COPY rtmp-conf.d /etc/nginx/rtmp-conf.d
COPY testloop /usr/share/nginx/rtmp/testloop
ADD http://techslides.com/demos/sample-videos/small.mp4 /usr/share/nginx/rtmp/testloop/
COPY run.sh .
RUN mkdir -p /data/video && \
    chown nginx:nginx /data/video && \
    chmod 0750 /data/video && \
    chmod 0644 /usr/share/nginx/rtmp/testloop/small.mp4

EXPOSE 9108
EXPOSE 1935
EXPOSE 8081

USER nginx
CMD ["./run.sh"]
