#################################################################
#                                                               #
# Copyright (c) 2021-2024 YottaDB LLC and/or its subsidiaries.       #
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
# - docker run --init -it -v <local directory>:/testarea1/ --rm ydbtest -t r132
#
# Other options:
# Pass a YDBTest Volume to use
# - docker run --init -it -v <local directory>:/testarea1/ -v <full path to YDBTest>:/YDBTest --rm ydbtest -t r132
# Run a shell as the gtmtest user
# - docker run --init -it -v <local directory>:/testarea1/ --rm ydbtest -shell
# Run a shell as root
# - docker run --init -it -v <local directory>:/testarea1/ --rm ydbtest -rootshell
ARG OS_VSN=bookworm
FROM debian:${OS_VSN}

VOLUME /testarea1
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
                    && \
                    apt-get clean

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
RUN ln -s /usr/bin/tcsh /usr/local/bin/tcsh && \
    groupadd gtc && \
    useradd gtmtest -G gtc,adm -m -s /usr/local/bin/tcsh
COPY com/set_java_paths.csh /usr/library/gtm_test/set_java_paths.csh
COPY docker/build_and_install_yottadb.csh /usr/library/gtm_test/build_and_install_yottadb.csh
RUN git clone https://gitlab.com/YottaDB/DB/YDB.git /Distrib/YottaDB/V999_R999
RUN /usr/library/gtm_test/build_and_install_yottadb.csh
COPY --chown=gtmtest:gtc . /usr/library/gtm_test/T999/
RUN ln -s /usr/library/gtm_test/T999/docker/cshrc ~/.cshrc && \
    ln -s /usr/library/gtm_test/T999/docker/cshrc ~gtmtest/.cshrc
RUN ln -s /usr/library/gtm_test/T999/docker/serverconf.txt /usr/library/gtm_test/serverconf.txt
RUN ln -s /usr/library/gtm_test/T999/docker/tstdirs.csh /usr/library/gtm_test/tstdirs.csh
RUN /usr/library/gtm_test/T999/docker/setup_gpg.csh
# https://stackoverflow.com/questions/56609182/openthread-environment-docker-rsyslogd-imklog-cannot-open-kernel-log-proc-km
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf
WORKDIR /home/gtmtest
ENTRYPOINT ["/usr/library/gtm_test/T999/docker/run.csh"]
