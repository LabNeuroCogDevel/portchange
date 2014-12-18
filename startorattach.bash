#!/usr/bin/env bash
export TERM=xterm-256color 

# wait for network to come online, need to be able to access ngrok.com
count=1
while ! ping -c1 ngrok.com && [ $count -lt 10000 ]; do sleep 2;let count++; done


# start if not started
tmux list-sessions |grep '^ngrok:' || ( 
      tmux new-session -s ngrok -n ngrok -d '~lncd/src/ngrok/ngrok --authtoken "nAs5WyXo66pUGKXUvCat" --proto=tcp 22 ';
      #tmux new-session -s ngrok -d;
      #tmux new-window -t ngrok -n ngrok -d '~lncd/src/ngrok/ngrok --authtoken "nAs5WyXo66pUGKXUvCat" --proto=tcp 22 ';
      # give time for server to start
      sleep 5
)
cmd="ssh lncd@$(curl 127.0.0.1:4040/http/in 2>/dev/null |perl -lne 'print $& if /ngrok.com:\d+/'|sed 's/:/ -p /')"
echo $cmd > cmd
git diff cmd --exit-code || (git add cmd; git commit -am 'update on reboot'; git push)

echo "tmux attach -t ngrok # to view/kill"
echo "$cmd # to connect"
