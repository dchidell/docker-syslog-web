FROM alpine:3.11 as build
LABEL maintainer="David Chidell (dchidell@cisco.com)"

FROM build as webproc
ENV WEBPROC_VERSION 0.3.0
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_linux_amd64.gz
RUN apk add --no-cache curl
RUN curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc
RUN chmod +x /usr/local/bin/webproc

FROM build as syslog
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
RUN apk --no-cache add syslog-ng
ENTRYPOINT ["webproc","--on-exit","restart","-c","/etc/syslog-ng/syslog-ng.conf","--","syslog-ng","-F"]
EXPOSE 514/udp 514 8080
