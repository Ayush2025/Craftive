#!/usr/bin/env bash

sudo chown craftive:users /home/craftive

cd ~;

source ~/.bashrc

set -e;

echo "[start-tmux.sh] Installing node dependencies"
pushd ~/craftive/exporter/
yarn install
popd

tmux -2 new-session -d -s craftive

tmux rename-window -t craftive:0 'exporter'
tmux select-window -t craftive:0
tmux send-keys -t craftive 'cd craftive/exporter' enter C-l
tmux send-keys -t craftive 'rm -f target/app.js*' enter C-l
tmux send-keys -t craftive 'clojure -M:dev:shadow-cljs watch main' enter

tmux split-window -v
tmux send-keys -t craftive 'cd craftive/exporter' enter C-l
tmux send-keys -t craftive './scripts/wait-and-start.sh' enter

tmux new-window -t craftive:1 -n 'backend'
tmux select-window -t craftive:1
tmux send-keys -t craftive 'cd craftive/backend' enter C-l
tmux send-keys -t craftive './scripts/start-dev' enter

tmux -2 attach-session -t craftive
