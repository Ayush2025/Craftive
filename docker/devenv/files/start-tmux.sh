#!/usr/bin/env bash

sudo chown craftive:users /home/craftive

cd ~;

source ~/.bashrc

echo "[start-tmux.sh] Installing node dependencies"
pushd ~/craftive/frontend/
corepack install;
yarn install;
yarn playwright install chromium
popd
pushd ~/craftive/exporter/
corepack install;
yarn install
yarn playwright install chromium
popd

tmux -2 new-session -d -s craftive

tmux rename-window -t craftive:0 'frontend watch'
tmux select-window -t craftive:0
tmux send-keys -t craftive 'cd craftive/frontend' enter C-l
tmux send-keys -t craftive 'yarn run watch' enter

tmux new-window -t craftive:1 -n 'frontend shadow'
tmux select-window -t craftive:1
tmux send-keys -t craftive 'cd craftive/frontend' enter C-l
tmux send-keys -t craftive 'yarn run watch:app' enter

tmux new-window -t craftive:2 -n 'frontend storybook'
tmux select-window -t craftive:2
tmux send-keys -t craftive 'cd craftive/frontend' enter C-l
tmux send-keys -t craftive 'yarn run watch:storybook' enter

tmux new-window -t craftive:3 -n 'exporter'
tmux select-window -t craftive:3
tmux send-keys -t craftive 'cd craftive/exporter' enter C-l
tmux send-keys -t craftive 'rm -f target/app.js*' enter C-l
tmux send-keys -t craftive 'clojure -M:dev:shadow-cljs watch main' enter

tmux split-window -v
tmux send-keys -t craftive 'cd craftive/exporter' enter C-l
tmux send-keys -t craftive './scripts/wait-and-start.sh' enter

tmux new-window -t craftive:4 -n 'backend'
tmux select-window -t craftive:4
tmux send-keys -t craftive 'cd craftive/backend' enter C-l
tmux send-keys -t craftive './scripts/start-dev' enter

tmux -2 attach-session -t craftive
