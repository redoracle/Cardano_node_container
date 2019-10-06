FROM debian:stable
MAINTAINER RedOracle

# Metadata params
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
      org.label-schema.docker.cmd='docker run --rm redoracle/cardano-node-docker' \
      org.label-schema.docker.cmd.devel='docker run --rm -ti redoracle/cardano-node-docker' \
      org.label-schema.docker.debug='docker logs $CONTAINER' \
      io.github.offensive-security.docker.dockerfile="Dockerfile" \
      io.github.offensive-security.license="GPLv3" \
      MAINTAINER="RedOracle <info@redoracle.com>"
      
# One layer execution:

VOLUME /datak
    
ENV DEBIAN_FRONTEND noninteractive \
ENV=/etc/profile \
USER=root \
PATH=/root/red-jor-test/:/bin:/sbin:/usr/bin:/usr/sbin:$PATH 

RUN set -x \

    #Set the root password to impossible \
    && sed -i -e 's/^root::/root:*:/' /etc/shadow \
    
    #Update and upgrading the system with requirements \
    && apt-get -yqq update \                                                       
    && apt-get -yqq dist-upgrade \
    && apt-get -yqq install curl wget bash build-essential libssl-dev pkg-config npm git vim watch\
    
    #Create a directory to store our testnet node \
    && mkdir -p ~/red-jor-test \                                               
    && cd ~/red-jor-test \
    
    #Download IOHK scripts \
    && wget https://raw.githubusercontent.com/input-output-hk/shelley-testnet/master/scripts/createAddress.sh \
    && wget https://raw.githubusercontent.com/input-output-hk/shelley-testnet/master/scripts/createStakePool.sh \
    && wget https://raw.githubusercontent.com/input-output-hk/shelley-testnet/master/scripts/send-money.sh \
    && wget https://raw.githubusercontent.com/input-output-hk/shelley-testnet/master/scripts/delegate-account.sh \
    && wget https://raw.githubusercontent.com/input-output-hk/shelley-testnet/master/scripts/send-certificate.sh \ 
    
    # JTools Download https://github.com/clio-one/cardano-on-the-rocks/tree/master/scripts/Jormungandr \
    && wget https://raw.githubusercontent.com/clio-one/cardano-on-the-rocks/master/scripts/Jormungandr/jtools.sh \
    && sed -i -e 's/8080/3101/' jtools.sh \
    && sed -i -e 's/^BASE_FOLDER=~\/jormungandr\//BASE_FOLDER=~\/red-jor-test\//'  jtools.sh \
    && echo "/root/red-jor-test/jcli rest v0 node stats get --host \"http://127.0.0.1:3101/api\"" > stats.sh \
    && chmod +x *.sh \
    && wget https://github.com/input-output-hk/jormungandr/releases/download/v0.5.5/jormungandr-v0.5.5-x86_64-unknown-linux-gnu.tar.gz \
    && tar xzvf jormungandr-v0.5.5-x86_64-unknown-linux-gnu.tar.gz \
    && rm jormungandr-v0.5.5-x86_64-unknown-linux-gnu.tar.gz \                
    
    #RustUP Installation and other rquirements # https://github.com/input-output-hk/js-chain-libs \
    && curl https://sh.rustup.rs -sSf > rustup_inst.sh \        
    && sh rustup_inst.sh -y \
    && . $HOME/.cargo/env \
    && rustup install stable \
    && curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf > wasm.sh \
    && sh wasm.sh \
    && rm rustup_inst.sh wasm.sh \
    && git clone https://github.com/input-output-hk/js-chain-libs.git \
    && cd js-chain-libs \
    && git submodule init \
    && git submodule update \
    && wasm-pack build \
    && wasm-pack pack \
    
    # Faucet examples \
    # https://github.com/input-output-hk/js-chain-libs/tree/master/examples/faucet \
    # https://github.com/input-output-hk/js-chain-libs \
    # https://github.com/input-output-hk/shelley-testnet/wiki/JavaScript-SDK:---How-to-install-the-example-faucet-app%3F \
    # Very important https://github.com/input-output-hk/shelley-testnet/wiki/How-to-setup-a-Jormungandr-Networking--node-(--v0.5.0) \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
    
CMD ["bash"]

EXPOSE 8443 3100 3000 3101
