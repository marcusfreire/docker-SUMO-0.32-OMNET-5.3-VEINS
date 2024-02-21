# Use a imagem base do Ubuntu 20.04
FROM ubuntu:16.04
FROM openjdk:8

LABEL maintainer="Marcus Freire mfreire.e@gmail.com"

#Dependências do sistema
RUN apt-get update -y
RUN apt-get install -y python3-dev python3-pip build-essential

# Evitar perguntas durante a instalação do pacote
ENV DEBIAN_FRONTEND=noninteractive

#Instalando dependencias
RUN apt-get update && apt-get install -y xauth unzip wget vim \
	build-essential gcc g++ bison flex perl tcl-dev tk-dev blt \
	libxml2-dev zlib1g-dev default-jre doxygen graphviz gdb \
	openmpi-bin libopenmpi-dev libpcap-dev autoconf \
	automake libtool libproj-dev  libfox-1.6-dev libgdal-dev \
	libxerces-c-dev \
        qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools\
	libqt5opengl5-dev openscenegraph \
	libopenscenegraph-dev \
	libgeos-dev software-properties-common \
	openssl libssl-dev

# Não Instalado: 
# RUN add-apt-repository -y ppa:ubuntugis/ppa &&\
        # apt-get update && apt-get -y install libwebkitgtk-1.0-0 qt4-dev-tools libgdal1-dev osgearth osgearth-data openscenegraph-plugin-osgearth libosgearth-dev

#SUMO-0.32
RUN mkdir /src && cd /src && \
        wget https://sourceforge.net/projects/sumo/files/sumo/version%200.32.0/sumo-src-0.32.0.tar.gz && \
        tar -xzf sumo-src-0.32.0.tar.gz && rm sumo-src-0.32.0.tar.gz

ENV SUMO_HOME="/src/sumo-0.32.0"

RUN cd ${SUMO_HOME} &&\
	./configure && \
	make && \
	make install && \
	cd .. && rm -rf sumo*

ENV PATH="${SUMO_HOME}/bin:${PATH}" 

#OMNET++

RUN cd /src && \
        wget https://github.com/omnetpp/omnetpp/releases/download/omnetpp-5.3/omnetpp-5.3-src-linux.tgz &&\
        tar -xzf omnetpp-5.3-src-linux.tgz && rm omnetpp-5.3-src-linux.tgz

ENV PATH="/src/omnetpp-5.3/bin:${PATH}"

RUN cd /src/omnetpp-5.3/ &&\
    ./configure WITH_OSG=no WITH_OSGEARTH=no &&\
    make -j $(nproc) MODE=debug base && make -j $(nproc) MODE=release base

#Install Veins
RUN cd /src && \
        git clone -b veins-5.1 https://github.com/sommer/veins.git && \
        cd veins/ &&\
        ./configure && make -j $(nproc)

#Install INET 3.6.5
RUN cd /src && \
        wget https://github.com/inet-framework/inet/releases/download/v3.6.5/inet-3.6.5-src.tgz &&\
        tar -xzf inet-3.6.5-src.tgz && rm inet-3.6.5-src.tgz

RUN cp /usr/lib/x86_64-linux-gnu/libssl.so /src/veins/src/.
RUN cp /usr/lib/x86_64-linux-gnu/libcrypto.so /src/veins/src/.
# COPY ./entrypoint.sh /src/

#Diretório do usuário docker
RUN mkdir -p /src/repository/
WORKDIR /src/repository/

ENV DISPLAY=host.docker.internal:0.0

VOLUME [ "/src/repository/" ]

# RUN chmod +x /src/entrypoint.sh

# ENTRYPOINT ["sh", "/src/entrypoint.sh"]

CMD ["bash"]