FROM debian:stable
MAINTAINER RedOracle

ARG BUILD_DATE
ARG VERSION
ARG VCS_URL
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.name='Cardano Node by Redoracle' \
      org.label-schema.description='UNOfficial Cardano Node docker image' \
      org.label-schema.usage='https://www.redoracle.com/docker/' \
      org.label-schema.url='https://www.redoracle.com/' \
      org.label-schema.vendor='Red0racle S3curity' \
      org.label-schema.schema-version='1.0' \
      org.label-schema.docker.cmd='docker run -dit redoracle/cardano-node-docker' \
      org.label-schema.docker.cmd.devel='docker run --rm -ti redoracle/cardano-node-docker' \
      org.label-schema.docker.debug='docker logs $CONTAINER' \
      io.github.offensive-security.docker.dockerfile="Dockerfile" \
      io.github.offensive-security.license="GPLv3" \
      MAINTAINER="RedOracle <info@redoracle.com>"

WORKDIR /root

VOLUME /datak

RUN set -x \
    && sed -i -e 's/^root::/root:*:/' /etc/shadow \
    && apt-get -yqq update \                                                       
    && apt-get -yqq dist-upgrade \
    && apt-get -yqq install curl wget busybox bash python3.7 python3-dev python3-pip python3-requests python3-cryptography python3-tabulate build-essential libssl-dev tmux cmake g++ pkg-config git neofetch vim-common libwebsockets-dev libjson-c-dev npm watch jq watch net-tools geoip-bin geoip-database && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \    
    && pip3 install pprint \
    && pip3 install ruamel.yaml \
    && pip3 install db-sqlite3 \
    && pip3 install pycrypto 

RUN git clone https://github.com/Kodex-Data-Systems/Casper.git \
    && mkdir -p /root/jormungandr/tools \   
    && cd /root/jormungandr \
    && wget https://raw.githubusercontent.com/clio-one/cardano-on-the-rocks/master/scripts/Jormungandr/jtools.sh \
    && git clone https://github.com/rdlrt/Alternate-Jormungandr-Testnet.git \
    && mv Alternate-Jormungandr-Testnet/scripts/jormu-helper-scripts ./scripts \
    && rm -rf Alternate-Jormungandr-Testnet \
    && wget https://raw.githubusercontent.com/input-output-hk/jormungandr-nix/master/scripts/janalyze.py \
    && sed -i -e 's/8081/3101/' jtools.sh \
    && sed -i -e 's/3001/3101/' janalyze.py \
    && cd /tmp/ \
    && git clone https://github.com/tsl0922/ttyd.git \
    && cd ttyd && mkdir build && cd build \
    && cmake .. \
    && make && make install 
    
RUN echo "ttyd -p 9001 -R tmux new -A -s ttyd &" >> ~/jormungandr/tools/web_interface_tmux.sh \
    && echo "tmux source ~/.tmux.conf" >> ~/jormungandr/tools/web_interface_tmux.sh \
    && echo "tmux -u attach" >> ~/jormungandr/tools/web_interface_tmux.sh \
    && cp /usr/share/doc/tmux/example_tmux.conf ~/.tmux.conf \
    && echo "set -g @plugin 'tmux-plugins/tmux-resurrect'" >> ~/.tmux.conf \
    && echo "set -g @resurrect-save 'S'" >> ~/.tmux.conf \
    && echo "set -g @resurrect-restore 'R'" >> ~/.tmux.conf \
    && echo "set -g @plugin 'tmux-plugins/tmux-continuum'" >> ~/.tmux.conf \
    && echo "set -g @colors-solarized 'dark'" >> ~/.tmux.conf \
    && echo "set -g default-terminal \"xterm-256color\"" >> ~/.tmux.conf \
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
    && echo "run-shell '~/.tmux/plugins/tpm/resurrect.tmux'" >> ~/.tmux.conf \
    && echo "run -b '~/.tmux/plugins/tpm/tpm'" >> ~/.tmux.conf \
    && cd ~/jormungandr/ \
    && echo "busybox httpd -p 0.0.0.0:8203 -f -v -h /datak/myBusybox/www/ -c /datak/myBusybox/httpd.conf &" >  ~/jormungandr/tools/prtgSens.sh \
    && echo "/root/jormungandr/jcli rest v0 node stats get --host \"http://127.0.0.1:3101/api\"" > ~/jormungandr/tools/jstats.sh \
    && echo "/root/jormungandr/jcli rest v0 utxo get --host \"http://127.0.0.1:3101/api\"" > ~/jormungandr/tools/jstatx.sh \
    && echo "/root/jormungandr/jcli rest v0 shutdown get --host \"http://127.0.0.1:3101/api\"" > ~/jormungandr/tools/jshutdown.sh \
    && echo "neofetch --ascii --source ~/jormungandr/cardano.ascii --color_blocks off --memory_display infobar" > ~/jormungandr/tools/Cardanofetch.sh \
    && echo "HASH=\$(cat /datak/genesis-hash.txt); JORGN=\$(until RUST_BACKTRACE=FULL /root/jormungandr/jormungandr --config /datak/node-config.yaml --genesis-block-hash \$HASH; do echo \"Jormungandr crashed with exit code \$?.  Respawning..\" >&2; sleep 1; done);" >> ~/jormungandr/tools/start-node.sh \
    && echo "HASH=\$(cat /datak/genesis-hash.txt); JORGP=\$(until RUST_BACKTRACE=FULL /root/jormungandr/jormungandr --config /datak/node-config.yaml --secret /datak/pool/Stakelovelace/secret.yaml --genesis-block-hash \$HASH; do echo \"Jormungandr crashed with exit code \$?.  Respawning..\" >&2; sleep 1; done);" >> ~/jormungandr/tools/start-pool.sh \ 
    && echo "for i in \$(netstat -anl  | grep tcp | grep EST |  awk '{print \$ 5}' | cut -d ':' -f 1 | sort | uniq); do GEO=\$(geoiplookup \$i | sed -r 's/^GeoIP Country Edition://g'); echo \"\$i     \t \$GEO\"; done" > ~/jormungandr/tools/watch_node.sh \
    && chmod +x ~/jormungandr/tools/*.sh \
    && chmod +x ~/jormungandr/scripts/*.sh \
    && ln -s ~/jormungandr/jtools.sh /usr/local/bin/jtools \
    && ln -s ~/jormungandr/tools/jstats.sh /usr/local/bin/jstats \
    && ln -s ~/jormungandr/tools/jstatx.sh /usr/local/bin/jstatx \
    && ln -s ~/jormungandr/tools/jshutdown.sh /usr/local/bin/jshutdown \
    && ln -s ~/jormungandr/tools/jshutdown.sh /usr/local/bin/stop-node \
    && ln -s ~/jormungandr/tools/start-node.sh /usr/local/bin/start-node \
    && ln -s ~/jormungandr/tools/start-pool.sh /usr/local/bin/start-pool \
    && ln -s ~/jormungandr/tools/watch_node.sh /usr/local/bin/watch_node \
    && ln -s ~/jormungandr/jcli /usr/local/bin/jcli \
    && ln -s ~/jormungandr/jormungandr /usr/local/bin/jormungandr \
    && wget https://www.redoracle.com/cardano.ascii \
    && wget https://github.com/input-output-hk/jormungandr/releases/download/v0.8.0-rc8/jormungandr-v0.8.0-rc8-x86_64-unknown-linux-gnu.tar.gz \
    && Dwnjorf="jormungandr-v0.8.0-rc8-x86_64-unknown-linux-gnu.tar.gz" \
    && tar xzvf $Dwnjorf \
    && rm $Dwnjorf \                
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  

ENV \
DEBIAN_FRONTEND noninteractive \
LANG C.UTF-8 \
ENV=/etc/profile \
USER=root \
PATH=/root/jormungandr/:/root/jormungandr/scripts:/root/jormungandr/tools:/bin:/sbin:/usr/bin:/usr/sbin:$PATH 


EXPOSE 9001 3000 3101
