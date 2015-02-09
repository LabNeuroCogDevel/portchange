#!/usr/bin/env bash
export TERM=xterm-256color 

set -x

cd $(dirname $0)

# wait for network to come online, need to be able to access ngrok.com
count=1
while ! /sbin/ping -c1 ngrok.com && [ $count -lt 10000 ]; do sleep 2;let count++; done

# try 10 times to get the port
# exit loop when we get it
# exit script if we never get the port
for i in 1..10; do 
   hostandport="$(curl 127.0.0.1:4040/http/in 2>/dev/null |perl -lne 'print $& if /ngrok.com:\d+/'|sed 's/:/ -p /')"
   [ -n "$hostandport" ] && break
   sleep 2
done
[ -z "$hostandport" ] && echo "could not get ngrok port address!" && exit 1


# start if not started
tmux list-sessions |grep '^ngrok:' || ( 
      tmux new-session -s ngrok -n ngrok -d '~lncd/src/ngrok/ngrok --authtoken "nAs5WyXo66pUGKXUvCat" --proto=tcp 22 ';
      #tmux new-session -s ngrok -d;
      #tmux new-window -t ngrok -n ngrok -d '~lncd/src/ngrok/ngrok --authtoken "nAs5WyXo66pUGKXUvCat" --proto=tcp 22 ';
      # give time for server to start
      sleep 5
)
cmd="ssh -AY lncd@$hostandport #$(date +%F\ %H:%M)"
echo "tmux attach -t ngrok # to view/kill"
echo "$cmd # to connect"

# if same port, will print
sameportis=$( perl -lne '$c{$&}+=1 if /\d{5,}/; END{print grep {$c{$_}>1} keys %c} ' <(echo $cmd) cmd )
[ -n "$sameportis" ] && continue

echo $cmd > cmd
git diff --exit-code cmd || (git add cmd; git commit -am 'update on reboot'; git push)

