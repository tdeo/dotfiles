if [ -f ~/.bash_completion ]; then
    . ~/.bash_completion
fi

alias nano='nano -c'
alias t='true'
alias g++11='g++ -O3 -W -Wall -std=c++11 -o myprog '
alias cv='if `which cv`; then watch -n0.02 cv -q; fi; if `which progress`; then watch -n0.02 progress -q; fi'

alias otp="watch -n0.1 $HOME/otp.sh"

function .. ()  {
  cd ../"$1"
  ls
}
complete -F _.. ..

alias pubip='dig +short myip.opendns.com @resolver1.opendns.com'

alias curl='curl -w "\n"'
alias tree='tree --dirsfirst'

alias review-apps='heroku apps -A | grep jeanjacque | cut -d " " -f1'

alias grep="grep -p"

function docker-cleanup() {
  docker image prune -f --filter "until=24h"
  docker container prune -f --filter "until=24h"
  docker volume prune -f --filter "label!=keep"
  docker network prune -f --filter "until=24h"
}

function docker-total-wipe() {
  docker ps -q | xargs docker kill
  docker ps -aq --filter status=exited | xargs docker rm
  docker images -q --filter dangling=true | xargs docker rmi
}

alias nodemon='ee npm run nodemon'

function load_dotenv () {
  env=${DOTENV:-development}
  env_vars="$(cat .env 2> /dev/null) $(cat ".env.${env}" 2> /dev/null)"
  echo $env_vars
}

function ee () {
  eval $(load_dotenv) eval "$@"
}

function ec2 () {
  if [ $# -eq 0 ]; then
    aws ec2 describe-instances | jq -r '.Reservations[].Instances[].NetworkInterfaces[].PrivateDnsName'
  else
    aws ec2 describe-instances --filters "Name=tag:Name,Values=*$1*" | jq -r '.Reservations[].Instances[].NetworkInterfaces[].PrivateDnsName'
  fi
}

function c () {
  ruby -e "puts $*"
}

alias dc='docker-compose'
alias dcr='dc down && dc up -d && dc logs -f'
alias jc='docker-compose exec jeancaisse'
alias jr='docker-compose exec jeanratus'
alias wds='bundle && yarn && bin/webpack-dev-server'
