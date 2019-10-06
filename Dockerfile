FROM FROM debian:stable
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
      org.label-schema.vendor='RedOracle Security' \
      org.label-schema.schema-version='1.0' \
      org.label-schema.docker.cmd='docker run --rm redoracle/cardano-node-docker' \
      org.label-schema.docker.cmd.devel='docker run --rm -ti redoracle/cardano-node-docker' \
      org.label-schema.docker.debug='docker logs $CONTAINER' \
      io.github.offensive-security.docker.dockerfile="Dockerfile" \
      io.github.offensive-security.license="GPLv3" \
      MAINTAINER="RedOracle <info@redoracle.com>"
      
# One layer execution:

VOLUME /datak
    
ENV DEBIAN_FRONTEND noninteractive

RUN set -x \

    #Set the root password to impossible \
    && sed -i -e 's/^root::/root:*:/' /etc/shadow \
    
    #Update and upgrading the system with requirements \
    && apt-get -yqq update \                                                       
    && apt-get -yqq dist-upgrade \
    && apt-get -yqq install curl wget bash build-essential libssl-dev pkg-config npm vim\
    
    #Create a directory to store our experiments \
    && mkdir -p ~/red-jor-test \                                               
    && cd ~/red-jor-test \
    && wget https://github.com/input-output-hk/jormungandr/releases/download/v0.5.5/jormungandr-v0.5.5-x86_64-unknown-linux-gnu.tar.gz \
    && tar xzvf jormungandr-v0.5.5-x86_64-unknown-linux-gnu.tar.gz \
    && rm jormungandr-v0.5.5-x86_64-unknown-linux-gnu.tar.gz \
    
    #Get the source code \
    #&& git clone https://github.com/input-output-hk/jormungandr \              
    #&& cd jormungandr \
    #&& git submodule update --init --recursive \
    #Install and make the executables available in the PATH \
    #&& cargo install --force --path jormungandr \                              
    #&& cargo install --force --path jcli \
    #Make scripts exectuable
    #&& chmod +x ./scripts/bootstrap \                   
    
    #RustUP Installation and other rquirements # https://github.com/input-output-hk/js-chain-libs
    && curl https://sh.rustup.rs -sSf > rustup_inst.sh \        
    && sh rustup_inst.sh -y \
    && . $HOME/.cargo/env \
    && rustup install stable
    
    && curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf > wasm.sh \
    && sh wasm.sh 
    && rm rustup_inst.sh wasm.sh \
    
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
CMD ["bash"]

EXPOSE 80 443 8443 3100 3000 3101
