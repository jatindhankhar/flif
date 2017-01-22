#!/bin/bash

# Kill Unicorn 
cat $HOME/flif_app/tmp/pids/unicorn.pid | xargs kill -QUIT

echo "Killed Unicorn"

unicorn -c $HOME/flif_app/unicorn.rb -E development -D

echo "Restarted Unicorn "
