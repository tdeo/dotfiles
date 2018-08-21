#Raccourcis
alias nano='nano -c'
alias g++11='g++ -W -Wall -std=c++11 -o myprog '
alias git?='git branch && git status'
alias git='LANG=en_US git'
alias cv='if `which cv`; then watch -n0.02 cv -q; fi; if `which progress`; then watch -n0.02 progress -q; fi'

alias otp="watch -n0.1 $HOME/otp.sh"

function .. ()  { cd ../"$1" ; ls; }
function ... ()  { cd ../../"$1" ; ls; }

modified_files() { git status | $SED -e '/modified/!d' -e 's/\smodified:   //'; }

function push() {
  if [ $# -ne 1 ]; then
    $ECHO "push <branch>";
    return;
  fi;
  for i in `seq 1 10`; do
    git up;
    git checkout $1;
    git push origin $1 && break;
  done;
}

alias docker-cleanup='docker ps -q | xargs docker kill; docker ps -aq | xargs docker rm; docker images -q --filter dangling=true | xargs docker rmi; docker volume prune -f'
# GIT automation
git_tag_prefix() { git tag | $GREP "^[0-9]\+\(\.[0-9]\+\)*$" | tail -n1 | $SED -e 's/\([0-9.]\{1,\}\.\)\([0-9]\{1,\}\)$/\1/g'; }
git_tag_suffix() { git tag | $GREP "^[0-9]\+\(\.[0-9]\+\)*$" | tail -n1 | $SED -e 's/\([0-9.]\{1,\}\.\)\([0-9]\{1,\}\)$/\2/g'; }
next_tag() {
  a=$(git_tag_suffix);
  version=$((a+1));
  tag=$(git_tag_prefix)$version;
  $ECHO $tag;
}

function merge() {
  branch=$(git_branch);
  if [ $# -lt 2 ]; then
    $ECHO "merge <master> <dev> [auto|<tag>]";
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
