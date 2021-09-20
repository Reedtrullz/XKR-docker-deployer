FROM ubuntu as builder

ENV CC=gcc-8
ENV CXX=g++-8


RUN apt-get update && apt-get install -y \
        software-properties-common &&\
    add-apt-repository -y \
        ppa:ubuntu-toolchain-r/test &&\
    apt-get update && apt-get install -y \
        aptitude && \
    aptitude install -y \
        build-essential g++-8 gcc-8 git libboost-all-dev python-pip &&\
    pip install \
        cmake

RUN git clone -b master --single-branch https://github.com/kryptokrona/kryptokrona &&\
    cd kryptokrona &&\
    mkdir build &&\
    cd build &&\
    cmake .. &&\
    make -j8

RUN cd kryptokrona/build/src &&\
    ./kryptokrona --version

FROM ubuntu
COPY --from=builder kryptokrona/build/src/kryptokrona kryptokrona
CMD echo "Using p2p port ${P2P_PORT} and rpc port ${RPC_PORT}" &&\
    ./kryptokrona --enable-cors=* --enable-blockexplorer --p2p-external-port ${P2P_PORT} --rpc-bind-ip=0.0.0.0 --rpc-bind-port=${RPC_PORT} --fee-amount ${FEE_AMOUNT} --fee-address ${FEE_ADDR}
