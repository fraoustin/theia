# FROM theia-python-docker https://github.com/theia-ide/theia-apps/blob/master/theia-python-docker/Dockerfile
ARG NODE_VERSION=10-buster
FROM node:${NODE_VERSION}

# Install Python 3 from source
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y make build-essential libssl-dev \
    && apt-get install -y libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    && apt-get install -y libncurses5-dev  libncursesw5-dev xz-utils tk-dev \
    && wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz \
    && tar xvf Python-3.7.0.tgz \
    && cd Python-3.7.0 \
    && ./configure \
    && make -j8 \
    && make install

RUN apt-get update \
    && apt-get install -y python-dev python-pip \
    && pip install --upgrade pip --user \
    && apt-get install -y python3-dev python3-pip \
    && pip3 install --upgrade pip --user \
    && pip install python-language-server flake8 autopep8 \
    && apt-get install -y yarn \
    && apt-get clean \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

RUN mkdir -p /home/theia \
    && mkdir -p /home/project
WORKDIR /home/theia

RUN wget https://raw.githubusercontent.com/theia-ide/theia-apps/master/theia-python-docker/latest.package.json
RUN mv latest.package.json package.json
ARG GITHUB_TOKEN
RUN yarn --cache-folder ./ycache && rm -rf ./ycache && \
     NODE_OPTIONS="--max_old_space_size=4096" yarn theia build ; \
    yarn theia download:plugins

# END theia-python-docker

# end install Python 2
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y python-dev python-pip \
    && pip install --upgrade pip \
    && pip install colorconsole \
    && apt -y autoremove \
    && apt-get clean \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# Install Python 3 from source
ARG PYTHON_VERSION=3.8.3
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y make build-essential libssl-dev \
    && apt-get install -y libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    && apt-get install -y libncurses5-dev  libncursesw5-dev xz-utils tk-dev \
    && wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && mv Python-${PYTHON_VERSION}.tgz /opt \
    && cd /opt \
    && tar xvf Python-${PYTHON_VERSION}.tgz \
    && rm Python-${PYTHON_VERSION}.tgz \
    && cd Python-${PYTHON_VERSION} \
    && ./configure \
    && make -j8 \
    && make install \
    && update-alternatives --install /usr/bin/python python /usr/local/bin/python3 1 \
    && apt -y autoremove \
    && apt-get clean \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

RUN pip3 install --upgrade pip \
    && pip3 install python-language-server flake8 autopep8 flask colorconsole pylint requests httpie Flask-Login Flask-SQLAlchemy

# install  pythonrc and PYTHONSTARTUP
COPY settings/bashrc /root/.bashrc
COPY settings/pythonrc /root/.pythonrc

# Install Docker client
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs)  stable" \
    && apt-get update \
    && apt-get install docker-ce-cli \
    && apt -y autoremove \
    && apt-get clean \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# update git
ARG GIT_VERSION=2.26.0
RUN apt-get remove -y git \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev \
    && apt-get install -y make \
    && apt -y autoremove \
    && apt-get clean \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

RUN wget https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz \
    && mv git-${GIT_VERSION}.tar.gz /opt \
    && cd /opt \
    && tar zxvf git-${GIT_VERSION}.tar.gz \
    && rm git-${GIT_VERSION}.tar.gz \
    && cd git-${GIT_VERSION} \
    && make prefix=/usr/local all \
    && make prefix=/usr/local install \
    && ln -s /opt/git-${GIT_VERSION} /opt/git \
    && ln -s /opt/git/git /usr/bin/git

# install  gitconfig
COPY settings/gitconfig /root/.gitconfig

# install vim
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y vim \
    && apt -y autoremove \
    && apt-get clean \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*


# add extension theia
RUN mkdir /home/theia/plugins/vscode-builtin-theme-atomlight
COPY ./extensions/vscode-builtin-theme-atomlight/* /home/theia/plugins/vscode-builtin-theme-atomlight/
RUN mkdir /home/theia/plugins/vscode-colorize
COPY ./extensions/vscode-colorize/* /home/theia/plugins/vscode-colorize/
RUN mkdir /home/theia/plugins/vscode-docker-explorer
COPY ./extensions/vscode-docker-explorer/* /home/theia/plugins/vscode-docker-explorer/

# change icon docker explorer
COPY img/container-off.png /home/theia/plugins/vscode-docker-explorer/resources/container-off.png
COPY img/container-on.png /home/theia/plugins/vscode-docker-explorer/resources/container-on.png
COPY img/image.png /home/theia/plugins/vscode-docker-explorer/resources/image.png

# configuration Theia
COPY settings/settings.json /root/.theia/settings.json
COPY settings/keymaps.json /root/.theia/keymaps.json

#font and icon
COPY www/JetBrainsMono-Regular.woff2 /home/theia/lib/JetBrainsMono-Regular.woff2
COPY www/CascadiaMono.ttf /home/theia/lib/CascadiaMono.ttf
COPY www/cascadiamono-webfont.woff2 /home/theia/lib/cascadiamono-webfont.woff2
COPY www/index.html /home/theia/lib/index.html
COPY img/theia.png /home/theia/lib/theia.png
COPY img/git.png /home/theia/lib/git.png
COPY img/debug.png /home/theia/lib/debug.png

# clean
RUN apt-get -y remove python3 python3.5 \
    && apt -y autoremove \
    && apt-get clean \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* 

RUN mkdir -p /root/projects

EXPOSE 3000
VOLUME ["/root/projects", ]

ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins
ENTRYPOINT [ "yarn", "theia", "start", "/home/project", "--hostname=0.0.0.0" ]
