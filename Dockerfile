FROM nvidia/cuda:9.2-devel@sha256:d3a52f50fe3b99ac6da7ed4b2f92edf9b0eb661654000daeb61f1ad342102770

ENV TZ=America/Chicago DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get install -y git cmake

RUN mkdir /opt/xmrig
WORKDIR /opt/xmrig

ADD https://raw.githubusercontent.com/xmrig/xmrig/master/doc/gpg_keys/xmrig.asc xmrig.asc

RUN gpg --import xmrig.asc

ADD https://github.com/xmrig/xmrig/releases/download/v6.10.0/SHA256SUMS SHA256SUMS
ADD https://github.com/xmrig/xmrig/releases/download/v6.10.0/SHA256SUMS.sig SHA256SUMS.sig
ADD https://github.com/xmrig/xmrig/releases/download/v6.10.0/xmrig-6.10.0-linux-static-x64.tar.gz xmrig-6.10.0-linux-static-x64.tar.gz

RUN gpg --verify SHA256SUMS.sig SHA256SUMS
RUN mv SHA256SUMS SHA256SUMS.1
RUN grep "xmrig-6.10.0-linux-static-x64.tar.gz" SHA256SUMS.1 > SHA256SUMS
RUN shasum --check ./SHA256SUMS

RUN tar -xvf ./xmrig-6.10.0-linux-static-x64.tar.gz

RUN mkdir /config/
RUN cp xmrig-6.10.0/config.json /config/config.json

RUN git clone https://github.com/xmrig/xmrig-cuda.git
WORKDIR /opt/xmrig/xmrig-cuda/
RUN cmake . -DCMAKE_BUILD_TYPE=Release -DCUDA_LIB=/usr/local/cuda/lib64 -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda -DCUDA_INCLUDE_DIRS=/usr/local/cuda/include
RUN make

ENTRYPOINT ["/opt/xmrig/xmrig-6.10.0/xmrig", "-c", "/config/config.json"]