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

alias docker-cleanup='docker ps -q | xargs docker kill; docker ps -aq | xargs docker rm; docker images -q --filter dangling=true | xargs docker rmi; docker volume prune -f'

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
