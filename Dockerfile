FROM alpine:latest

COPY --from=golang:1.13-alpine /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"

# Lsyncd
RUN apk add --no-cache lsyncd bash git

RUN git clone https://github.com/jwilder/dockerize \
 && cd dockerize \
 && go build \
 && ls | grep -v '.go' \
 && chmod +x dockerize \
 && mv dockerize /usr/bin/

# Entrypoint to easily enter in the container and run additionnal scripts on startup
COPY ./lsyncd-entrypoint.sh /
RUN mkdir /lsyncd-entrypoint.d \
 && chmod +x /lsyncd-entrypoint.sh

COPY ./lsyncd.conf.tpl /

CMD [ "dockerize", "-template", "/lsyncd.conf.tpl", "-template", "/lsyncd.conf.tpl:/lsyncd.conf", "lsyncd", "-nodaemon", "/lsyncd.conf" ]
ENTRYPOINT ["/lsyncd-entrypoint.sh"]
