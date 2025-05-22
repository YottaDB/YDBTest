#################################################################
#                                                               #
# Copyright (c) 2021-2025 YottaDB LLC and/or its subsidiaries.  #
# All rights reserved.                                          #
#                                                               #
# This source code contains the intellectual property           #
# of its copyright holder(s), and is made available             #
# under a license.  If you do not know the terms of             #
# the license, please stop and do not read further.             #
#                                                               #
#################################################################
# Instructions
# - docker build -f docker/Dockerfile -t ydbtest .
# - docker run --init -it -v <local directory>:/testarea1/ --cap-add PERFMON --rm ydbtest -t r132
#
# Other options:
# Pass a YDBTest Volume to use
# - docker run --init -it -v <local directory>:/testarea1/ -v <full path to YDBTest>:/YDBTest --cap-add PERFMON --rm ydbtest -t r132
# Run a shell as the gtmtest user
# - docker run --init -it -v <local directory>:/testarea1/ --cap-add PERFMON --rm ydbtest -shell
# Run a shell as root
# - docker run --init -it -v <local directory>:/testarea1/ --cap-add PERFMON --rm ydbtest -rootshell

# When the following line changes, remove the lines installing a custom version of gawk below
ARG OS_VSN=bookworm
FROM debian:${OS_VSN}

VOLUME /testarea1
VOLUME /testarea2
VOLUME /testarea3
VOLUME /YDBTest

ARG DEBIAN_FRONTEND=noninteractive
# psmisc for fuser
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    file \
                    less \
                    cmake \
                    make \
                    gcc \
                    pkg-config \
                    git \
                    tcsh \
                    less \
                    libconfig-dev \
                    libelf-dev \
                    libgcrypt-dev \
                    libgpg-error-dev \
                    libgpgme11-dev \
                    libicu-dev \
                    libncurses-dev \
                    libssl-dev \
                    libreadline-dev \
                    zlib1g-dev \
                    lsof \
                    bc \
                    unzip \
                    wget \
                    ca-certificates \
                    gawk \
                    psmisc \
                    ksh \
                    vim \
                    rsyslog \
                    locales \
                    strace \
                    expect \
                    elfutils \
                    net-tools \
                    netcat-traditional \
                    gdb \
                    valgrind \
                    python3 \
                    python3-venv \
                    python3-dev \
                    python3-setuptools \
                    libffi-dev \
                    curl \
                    iproute2 \
                    openjdk-17-jdk \
                    golang \
                    screen \
                    sudo \
                    bison \
                    flex \
                    libsodium-dev \
                    lsb-release \
                    rsync \
                    linux-perf \
                    libcurl4-openssl-dev \
                    netbase \
                    clang \
                    openssh-server \
                    jq \
                    && \
                    apt-get clean

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
# gtmtest1 is the ssh user
RUN ln -s /usr/bin/tcsh /usr/local/bin/tcsh && \
    groupadd gtc && \
    useradd gtmtest -g gtc -G adm,sudo -m -s /usr/local/bin/tcsh && \
    useradd gtmtest1 -g gtc -G adm,sudo -m -s /usr/local/bin/tcsh
# Allow gtmtest as a member of the sudo group to use sudo with no password for the sudo tests
RUN echo "%sudo\tALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/gtmtest-sudo

# Install Rust
RUN su - gtmtest -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
ENV PATH="/home/gtmtest/.cargo/bin:${PATH}"

# Install Gawk 5.2.2, as 5.2.1 has a bug: https://lists.gnu.org/archive/html/bug-gawk/2023-02/msg00015.html
RUN wget https://ftp.gnu.org/gnu/gawk/gawk-5.2.2.tar.gz && \
    tar xvf gawk-5.2.2.tar.gz && \
    rm gawk-5.2.2.tar.gz && \
    cd gawk-5.2.2/ && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -r gawk-5.2.2/

# Get the source code for YottaDB and Plugins
RUN git clone https://gitlab.com/YottaDB/DB/YDB.git /Distrib/YottaDB
RUN git clone --depth 1 https://gitlab.com/YottaDB/Util/YDBPosix.git /Distrib/YDBPosix
RUN git clone --depth 1 https://gitlab.com/YottaDB/Util/YDBEncrypt.git /Distrib/YDBEncrypt
RUN mkdir -p /Distrib/ji_plugin && \
        wget https://sourceforge.net/projects/fis-gtm/files/Plugins/GTMJI/1.0.4/ji_plugin_1.0.4.tar.gz && \
        tar xzf ji_plugin_1.0.4.tar.gz -C /Distrib/ji_plugin && rm ji_plugin_1.0.4.tar.gz
RUN mkdir -p /Distrib/posix_plugin_r2 && \
        wget https://sourceforge.net/projects/fis-gtm/files/Plugins/posix/r2/posix_plugin_r2.tar.gz && \
        tar xzf posix_plugin_r2.tar.gz -C /Distrib/posix_plugin_r2 && \
        rm ../posix_plugin_r2.tar.gz
COPY com/set_java_paths.csh /usr/library/gtm_test/set_java_paths.csh
# serverconf.txt file is needed for installing GTMJI Plugin so we need to copy it into the conatainer first.
# Otherwise build_and_install_yottadb.csh script will fail.
COPY docker/serverconf.txt /usr/library/gtm_test/T999/docker/serverconf.txt
COPY docker/build_and_install_yottadb.csh /usr/library/gtm_test/build_and_install_yottadb.csh
# build_and_install_yottadb.csh <folder in /usr/library> <git tag in YDB> <dbg/pro>
RUN /usr/library/gtm_test/build_and_install_yottadb.csh V71000 V7.1-000 pro

# v6 DB
RUN /usr/library/gtm_test/build_and_install_yottadb.csh V63014_R138 r1.38 pro
RUN /usr/library/gtm_test/build_and_install_yottadb.csh V63014_R138 r1.38 dbg

# gtm_curpro: bump up (when r2.04 is released) by changing the next 4 lines
ENV gtm_curpro=V70005_R202
RUN /usr/library/gtm_test/build_and_install_yottadb.csh V70005_R202 r2.02 pro
RUN /usr/library/gtm_test/build_and_install_yottadb.csh V70005_R202 r2.02 dbg
RUN ln -s /usr/library/R202 /usr/library/V70005_R202

# Needs to be the last one to enable the lastest source tree to be available for sudo tests
RUN /usr/library/gtm_test/build_and_install_yottadb.csh V999_R999 master dbg

COPY --chown=gtmtest:gtc . /usr/library/gtm_test/T999/
RUN ln -s /usr/library/gtm_test/T999/docker/cshrc ~/.cshrc && \
    ln -s /usr/library/gtm_test/T999/docker/version.csh ~/version.csh && \
    ln -s /usr/library/gtm_test/T999/docker/cshrc ~gtmtest/.cshrc && \
    ln -s /usr/library/gtm_test/T999/docker/version.csh ~gtmtest/version.csh && \
    ln -s /usr/library/gtm_test/T999/docker/cshrc ~gtmtest1/.cshrc && \
    ln -s /usr/library/gtm_test/T999/docker/version.csh ~gtmtest1/version.csh
RUN ln -s /usr/library/gtm_test/T999/docker/serverconf.txt /usr/library/gtm_test/serverconf.txt
RUN ln -s /usr/library/gtm_test/T999/docker/tstdirs.csh /usr/library/gtm_test/tstdirs.csh

RUN /usr/library/gtm_test/T999/docker/setup_gpg.csh

# Set-up $ggdata
RUN mkdir /usr/library/gtm_test/ggdata && chown gtmtest:gtc /usr/library/gtm_test/ggdata

# https://stackoverflow.com/questions/56609182/openthread-environment-docker-rsyslogd-imklog-cannot-open-kernel-log-proc-km
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

# SSH gtmuser -> gtmuser1 set-up
#     gtmuser -> gtmuser set-up (for replication tests)
RUN mkdir /run/sshd && \
    su - gtmtest -c 'mkdir ~/.ssh/' && su - gtmtest1 -c 'mkdir ~/.ssh/' && \
    su - gtmtest -c 'ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa' && \
    cp ~gtmtest/.ssh/id_rsa.pub ~gtmtest1/.ssh/authorized_keys && \
    chmod 600 ~gtmtest1/.ssh/authorized_keys && chown gtmtest1:gtc ~gtmtest1/.ssh/authorized_keys && \
    cp ~gtmtest/.ssh/id_rsa.pub ~gtmtest/.ssh/authorized_keys && \
    chmod 600 ~gtmtest/.ssh/authorized_keys && chown gtmtest:gtc ~gtmtest/.ssh/authorized_keys

WORKDIR /home/gtmtest
ENTRYPOINT ["/usr/library/gtm_test/T999/docker/run.csh"]
