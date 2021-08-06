#################################################################
#                                                               #
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
# This source code contains the intellectual property           #
# of its copyright holder(s), and is made available             #
# under a license.  If you do not know the terms of             #
# the license, please stop and do not read further.             #
#                                                               #
#################################################################
ARG OS_VSN=buster
FROM debian:${OS_VSN}

VOLUME /testarea1
VOLUME /YDB
VOLUME /YDBTest

ARG DEBIAN_FRONTEND=noninteractive
# psmisc for fuser
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    file \
                    cmake \
                    make \
                    gcc \
                    pkg-config \
                    git \
                    tcsh \
                    libconfig-dev \
                    libelf-dev \
                    libgcrypt-dev \
                    libgpg-error-dev \
                    libgpgme11-dev \
                    libicu-dev \
                    libncurses-dev \
                    libssl-dev \
                    zlib1g-dev \
                    tcsh \
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
                    netcat \
                    gdb \
                    valgrind \
                    && \
                    apt-get clean

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
RUN ln -s /usr/bin/tcsh /usr/local/bin/tcsh && \
    groupadd gtc && \
    useradd gtmtest -G gtc,adm -m -s /usr/local/bin/tcsh
COPY --chown=gtmtest:gtc . /usr/library/gtm_test/T999/
RUN ln -s /usr/library/gtm_test/T999/docker/cshrc ~/.cshrc && \
    ln -s /usr/library/gtm_test/T999/docker/cshrc ~gtmtest/.cshrc
RUN /usr/library/gtm_test/T999/docker/build_and_install_yottadb.csh
RUN chown gtmtest:gtc /testarea1/
RUN ln -s /usr/library/gtm_test/T999/docker/serverconf.txt /usr/library/gtm_test/serverconf.txt
# https://stackoverflow.com/questions/56609182/openthread-environment-docker-rsyslogd-imklog-cannot-open-kernel-log-proc-km
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf
WORKDIR /home/gtmtest
ENTRYPOINT ["/usr/library/gtm_test/T999/docker/run.csh"]
