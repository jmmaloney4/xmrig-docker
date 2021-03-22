FROM nvidia/cuda:11.2.2-devel-ubuntu20.04@sha256:66af04302040b76bc04dc69bb7216f31d488938caa09dde95a22517ae97bdf25

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
RUN shasum --check --ignore-missing ./SHA256SUMS

RUN tar -xvf ./xmrig-6.10.0-linux-static-x64.tar.gz

RUN git clone https://github.com/xmrig/xmrig-cuda.git
WORKDIR /opt/xmrig/xmrig-cuda/
RUN cmake . -DCMAKE_BUILD_TYPE=Release -DCUDA_LIB=/usr/local/cuda/lib64 -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda -DCUDA_INCLUDE_DIRS=/usr/local/cuda/include
RUN make

ENTRYPOINT ["xmrig-6.10.0/xmrig"]