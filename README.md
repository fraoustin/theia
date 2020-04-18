# Theia Ide

It's a docker image with Theia Ide.

I add

- python 3.8
- module python flake8 flask autopep8 colorconsole pylint
- pythonrc with coloration
- git 2.26
- specific git config
- specific bashrs with coloration terminal
- docker client
- extension docker-explorer
- extension theme Atom
- extension colorize
- shortcut crtl+f1 for toggle menu
- shortcut crtl+f2: switch between editor and terminal
- shortcut crtl+left or right: switch between tab
- JetBrainsMono as font in theia


## Usage direct

run image fraoustin/theia

    docker run -d --rm -p 3000:3000 -v /var/run/docker.sock:/var/run/docker.sock -v <localpath>:/project --name theia fraoustin /theia

you can access to ihm with url http://127.0.0.1:3000/

## Usage with login

you can docker-compose

    git clone https://github.com/fraoustin/theia.git
    cd theia/login
    docker-compose up -d

user default is *user* and password default is *pass* (you can change in docker-compose.yml)

you use http://localhost/ for access login ihm


## External library

- theia on https://theia-ide.org/
- siimple.xyz on http://siimple.xyz

