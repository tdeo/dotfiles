GREP=$(which ggrep &> /dev/null && echo 'ggrep' || echo 'grep')
SED=$(which gsed &> /dev/null && echo 'gsed' || echo 'sed')

#Raccourcis
alias nano='nano -c'
alias g++11='g++ -W -Wall -std=c++11 -o myprog '
alias git?='git branch;git status'
alias git='LANG=en_US git'
alias cv='if `which cv`; then watch -n0.02 cv -q; fi; if `which progress`; then watch -n0.02 progress -q; fi'
alias b='bundle exec'

function digits() { echo $@ | $SED "s/[^0-9]//g";  }

function process () { ps -u thierry -o user,pid,%cpu,%mem,time,command | $GREP $1 | $GREP -v 'grep' ;}
function telecom () { cd ~/workspace/Telecom/"$1" ; ls;}
function polytechnique () { cd ~/workspace/X/"$1" ; ls;}
function .. ()  { cd ../"$1" ; ls; }

modified_files() { git status | $SED -e '/modified/!d' -e 's/\smodified:   //'; }
function rspec_modified_files() { modified_files | $GREP "^spec/" | $GREP -v "/factories/" | xargs bin/rspec; }
function subl_modified_files() { modified_files | xargs subl; }

function push() {
  if [ $# -ne 1 ]; then
    echo "push <branch>";
    return;
  fi;
  for i in `seq 1 10`; do
    git up;
    git checkout $1;
    git push origin $1 && break;
  done;
}

alias docker-cleanup='docker ps -q | xargs docker kill; docker ps -aq | xargs docker rm; docker images -q --filter dangling=true | xargs docker rmi; docker volume prune -f'
function docker-admin() {
  if [ $# -eq 0 ]; then
    docker exec -it `docker ps -qa --filter ancestor=docker_admin` bash;
  else
    docker exec -it `docker ps -qa --filter ancestor=docker_admin` $@;
  fi;
}

# GIT automation
parse_git_branch() { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'; }
git_tag_prefix() { git tag | grep "^[0-9]\+\(\.[0-9]\+\)*$" | tail -n1 | sed -e 's/\([0-9.]\{1,\}\.\)\([0-9]\{1,\}\)$/\1/g'; }
git_tag_suffix() { git tag | grep "^[0-9]\+\(\.[0-9]\+\)*$" | tail -n1 | sed -e 's/\([0-9.]\{1,\}\.\)\([0-9]\{1,\}\)$/\2/g'; }
next_tag() {
  a=$(git_tag_suffix);
  version=$((a+1));
  tag=$(git_tag_prefix)$version;
  echo $tag;
}

function merge() {
  branch=$(parse_git_branch);
  if [ $# -lt 2 ]; then
    echo "merge <master> <dev> [auto|<tag>]";
    return;
  fi;
  (git branch | $GREP "\b$1\b" &> /dev/null);
  branch_exists=$?;
  git fetch --tags;
  git checkout $1;
  git merge $2;
  git push origin $1;
  if [ $# -ge 3 ]; then
    if [ $3 == 'auto' ]; then
      a=$(next_tag);
      git tag $a; git push origin $a;
    else
      git tag $3; git push origin $3;
    fi;
  fi;
  git checkout $branch;
  if [ $branch_exists -gt 0 ]; then
    git branch -D $1;
  fi;
}

# pricematch
PM_ROOT="$HOME/pricematch"
if [ -d $HOME/vagrant/pricematch ]; then
  PM_ROOT="$HOME/vagrant/pricematch"
fi
function pm () { cd $PM_ROOT/"$1" ; ls;}
function admin_grep () { $GREP -nR "$*" . --exclude-dir={vendor,coverage,fixtures,\.git,doc,dynamodb,public,log,migrate,tmp} --exclude="*.sql" --color=auto; }
function algo_grep () { $GREP -nR "$*" . --exclude=*.pyc --exclude-dir={notebooks,\.git} --color=auto; }

alias ocdqs='oc login https://containers1.fab4.dqs.booking.com:8443 --username=$USER'
alias ocprodams4='oc login https://containers1.ams4.prod.booking.com:8443 --username=$USER'
alias ocprodfab4='oc login https://containers1.fab4.prod.booking.com --username=$USER'
