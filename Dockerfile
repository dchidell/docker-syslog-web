FROM alpine:3.14 as build
LABEL maintainer="David Chidell (dchidell@cisco.com)"

FROM build as webproc
ENV WEBPROCVERSION 0.4.0
ENV WEBPROCURL https://github.com/jpillora/webproc/releases/download/v$WEBPROCVERSION/webproc_"$WEBPROCVERSION"_linux_amd64.gz
RUN apk add --no-cache curl
RUN curl -sL $WEBPROCURL | gzip -d - > /usr/local/bin/webproc
RUN chmod +x /usr/local/bin/webproc

FROM build as syslog
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
RUN apk --no-cache add syslog-ng
ENTRYPOINT ["webproc","-o","restart","-c","/etc/syslog-ng/syslog-ng.conf","--","syslog-ng","-F"]
EXPOSE 514/udp 514 8080
