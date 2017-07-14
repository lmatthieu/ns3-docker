FROM ubuntu:14.04
MAINTAINER Matthieu Lagacherie <matthieu.lagacherie __AT__ gmail __DOT__ com>

RUN locale-gen fr_FR.UTF-8 && \
    echo 'LANG="fr_FR.UTF-8"' > /etc/default/locale

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

# Install miniconda Python distribution
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.3.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH

# Install python packages
RUN conda install -y notebook
RUN conda install -y pandas
RUN conda install -y matplotlib
RUN conda install -y networkx

# Install ns3 dependencies
RUN apt-get install --yes python-software-properties
RUN apt-get install --yes software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update
RUN apt-get install --yes wget make clang-3.5 python-dev
RUN apt-get install --yes libgsl0-dev
RUN apt-get install --yes gcc-5 g++-5 cgdb
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5

# Compile ns3
RUN mkdir /opt/ns
WORKDIR /opt/ns
RUN wget https://www.nsnam.org/release/ns-allinone-3.26.tar.bz2
RUN tar xjf ns-allinone-3.26.tar.bz2

WORKDIR /opt/ns/ns-allinone-3.26
RUN ./build.py --enable-examples --enable-tests

WORKDIR /opt/ns/ns-allinone-3.26/ns-3.26
RUN ./test.py core

# Install NetAnim
RUN apt-get install --yes netanim

EXPOSE 8888

CMD /bin/bash
