ARG NODE_VERSION=10
FROM node:${NODE_VERSION}

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
ARG PYTHON_VERSION=3.8.2
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y make build-essential libssl-dev \
    && apt-get install -y libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    && apt-get install -y libncurses5-dev  libncursesw5-dev xz-utils tk-dev \
    && wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
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
    && pip3 install python-language-server flake8 autopep8 flask colorconsole pylint

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


# install theia
RUN mkdir -p /home/theia \
    && mkdir -p /project
WORKDIR /home/theia

ARG version=latest
ADD $version.package.json ./package.json
ARG GITHUB_TOKEN
RUN yarn --cache-folder ./ycache && rm -rf ./ycache && \
     NODE_OPTIONS="--max_old_space_size=4096" yarn theia build ; \
    yarn theia download:plugins

# add extension
RUN mkdir /home/theia/plugins/vscode-builtin-theme-atomlight
COPY ./extensions/vscode-builtin-theme-atomlight/* /home/theia/plugins/vscode-builtin-theme-atomlight/
RUN mkdir /home/theia/plugins/vscode-colorize
COPY ./extensions/vscode-colorize/* /home/theia/plugins/vscode-colorize/
RUN mkdir /home/theia/plugins/vscode-docker-explorer
COPY ./extensions/vscode-docker-explorer/* /home/theia/plugins/vscode-docker-explorer/

# change icon docker explorer
COPY img/container-off.png /home/theia/plugins/vscode-docker-explorer/extension/resources/container-off.png
COPY img/container-on.png /home/theia/plugins/vscode-docker-explorer/extension/resources/container-on.png
COPY img/image.png /home/theia/plugins/vscode-docker-explorer/extension/resources/image.png

# configuration Theia
COPY settings/settings.json /root/.theia/settings.json
COPY settings/keymaps.json /root/.theia/keymaps.json

#font and icon
COPY www/JetBrainsMono-Regular.woff2 /home/theia/lib/JetBrainsMono-Regular.woff2
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

EXPOSE 3000
VOLUME ["/project",]

ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins
ENTRYPOINT [ "yarn", "theia", "start", "--hostname=0.0.0.0" ]
#ENTRYPOINT [ "yarn", "theia", "start", "/project", "--hostname=0.0.0.0" ]

# todo
# add button disconnect and crtl+q
# create un electron qu'avec theia
# optimize size of img