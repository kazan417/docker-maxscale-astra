FROM registry.astralinux.ru/astra/ubi18:latest
COPY maxscale_24.02.4~1.8-x86-64-1_amd64.deb /
ARG UID=1380900000
ARG GID=1380900000
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r maxscale -g ${GID} && useradd -u ${UID} -c "systemuser for mariadb service" -r -g maxscale maxscale -d /var/lib/maxscale

#RUN adduser maxscale 
RUN set -eux; \
        apt-get update; \
        DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        /maxscale_24.02.4~1.8-x86-64-1_amd64.deb && \
        rm -rf /var/lib/apt/lists/*; 
EXPOSE 8989 3306 4008
RUN  chown maxscale /var/{lib,run,log,cache}/maxscale
COPY entry-maxscale.sh /usr/local/bin
RUN chmod a+rx /usr/local/bin/entry-maxscale.sh
COPY maxscale.cnf /etc/
RUN chown maxscale /etc/maxscale.cnf
ENTRYPOINT ["entry-maxscale.sh"]
USER maxscale
VOLUME /var/lib/maxscale
CMD ["maxscale","--nodaemon", "--log=stdout"]

