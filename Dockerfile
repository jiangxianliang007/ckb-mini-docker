FROM nervos/ckb as ckb-orig
USER root

RUN set -eux; \
    apt-get update; \
    apt-get install -y \
        binutils ; \
    strip /bin/ckb

FROM ubuntu:bionic
LABEL description="Nervos CKB is a public permissionless blockchain, the common knowledge layer of Nervos network."
LABEL maintainer="Nervos Core Dev <dev@nervos.org>"

RUN groupadd -g 1000 ckb \
 && useradd -m -u 1000 -g ckb -s /bin/sh ckb \
 && mkdir -p /var/lib/ckb

WORKDIR /var/lib/ckb

COPY --from=ckb-orig \
     /usr/lib/x86_64-linux-gnu/libssl.so.* \
     /usr/lib/x86_64-linux-gnu/libcrypto.so.* \
     /usr/lib/x86_64-linux-gnu/

COPY --from=ckb-orig /bin/ckb /bin/ckb
COPY ./check.sh /bin/check-ckb
RUN /bin/ckb init --chain dev --force \
 && chown -R ckb:ckb /var/lib/ckb \
 && chmod 755 /var/lib/ckb
USER ckb

#EXPOSE 8114 8115
#VOLUME ["/var/lib/ckb"]
ENTRYPOINT ["/bin/ckb"]
