#!/usr/bin/env bash

set -e

EMSDK_QUIET=1 . /usr/local/emsdk/emsdk_env.sh;

usermod -u ${EXTERNAL_UID:-1000} craftive;

cp /root/.bashrc /home/craftive/.bashrc
cp /root/.vimrc /home/craftive/.vimrc
cp /root/.tmux.conf /home/craftive/.tmux.conf

chown -R craftive:users /home/craftive
rsync -ar --chown=craftive:users /usr/local/cargo/ /home/craftive/.cargo/

export PATH="/home/craftive/.cargo/bin:$PATH"
export CARGO_HOME="/home/craftive/.cargo"

exec "$@"
