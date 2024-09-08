# Lock to a particular Ubuntu image
FROM ubuntu:24.04
LABEL authors="Riaz Arbi,Gordon Inggs"

# BASE ==========================================
# Set the timezone
ENV TZ="Africa/Johannesburg" \
    LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm

# Let's make it a bit more functional

# Delete user 1000 - added in 24.04
RUN userdel -r ubuntu

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get clean && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    vim \
    nano \
    jq \
    htop \
    bash \
    cmake \
    make \
    gcc \
    wget \
    apt-utils \
    git \
    sudo \
    locales \
    dnsutils \
    curl \
    screen \
    tmux \
    python3 \
    python3-pip \
# Jupyter-specific
 && DEBIAN_FRONTEND=noninteractive \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    fonts-liberation \
    npm \
    libffi-dev \
# R-specific
    libapparmor1 \
    libedit2 \
    lsb-release \
    psmisc \
    libssl3 \
    gnupg \
    apt-transport-https \
# Set python3 to default
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
 && rm -rf /tmp/*

RUN locale-gen  en_US.utf8 \
 && /usr/sbin/update-locale LANG=en_US.UTF-8 \   
 && dpkg-reconfigure --frontend=noninteractive locales \
 && update-locale

RUN echo $TZ > /etc/timezone \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y tzdata \
 && rm /etc/localtime \
 && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata \
# DRIVERS =======================================================
# JAVA
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    default-jre \
    default-jdk \
    # ODBC
    gnupg2 \
    unixodbc-dev \
    #unixodbc-bin \
    unixodbc \
    libaio1t64 \
    alien 
    # Microsoft driver
RUN wget https://packages.microsoft.com/keys/microsoft.asc -O microsoft.asc && \
    apt-key add microsoft.asc && \
    wget https://packages.microsoft.com/config/ubuntu/20.04/prod.list -O prod.list && \
    cp prod.list /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y \
    msodbcsql17 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* 
    # Oracle driver
RUN wget -q https://github.com/cityofcapetown/docker_datascience/raw/master/base/drivers/oracle-instantclient-basic-21.4.0.0.0-1.el8.x86_64.rpm \
 && wget -q https://github.com/cityofcapetown/docker_datascience/raw/master/base/drivers/oracle-instantclient-odbc-21.4.0.0.0-1.el8.x86_64.rpm \ 
 && alien -i oracle-instantclient-basic-21.4.0.0.0-1.el8.x86_64.rpm \
 && alien -i oracle-instantclient-odbc-21.4.0.0.0-1.el8.x86_64.rpm \
 && rm oracle-instantclient-basic-21.4.0.0.0-1.el8.x86_64.rpm \
 && rm oracle-instantclient-odbc-21.4.0.0.0-1.el8.x86_64.rpm \
 && ldconfig \
 && echo "[Oracle Driver 21.4]\nDescription=Oracle Unicode driver\nDriver=/usr/lib/oracle/21/client64/lib/libsqora.so.21.1\nUsageCount=1\nFileUsage=1" \
  >> /etc/odbcinst.ini \
 && rm -rf /tmp/*

# Set LD library path
ENV LD_LIBRARY_PATH /usr/lib/oracle/21/client64/lib/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

# PYTHON ======================================================================
# Infrastructure-dependent prerequisites
RUN python3 -m pip install minio --break-system-packages \
 && python3 -m pip install pyhdb --break-system-packages \
 && python3 -m pip install pandas --break-system-packages \
 && python3 -m pip install pyarrow --break-system-packages \
 && python3 -m pip install python-magic --break-system-packages \
 && python3 -m pip install pyhive[presto] --break-system-packages \
 && python3 -m pip install trino --break-system-packages \
 && python3 -m pip install presto-python-client --break-system-packages \
 && python3 -m pip install exchangelib --break-system-packages \
 && rm -rf /tmp/*
 
 
