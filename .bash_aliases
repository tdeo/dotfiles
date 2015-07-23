alias stiq='echo "binet de teubis"'
alias BôBar='echo "Mythe, mec !"'

#Raccourcis
alias TDB='cd /home/thierry/workspace/TDB'
alias nano='nano -c'
alias fucking='sudo'
alias g++11='g++ -W -Wall -std=c++11 -o myprog '
alias git?='git branch;git status'
alias git='LANG=en_US git'
alias cv='watch -n0,2 cv -q'

function process () { ps -u thierry -o user,pid,%cpu,%mem,time,command | grep $1 | grep -v 'grep' ;}
function telecom () { cd ~/workspace/Telecom/"$1" ; ls;}
function polytechnique () { cd ~/workspace/X/"$1" ; ls;}
function .. ()  { cd ../"$1" ; ls; }
function cdl () { cd "$1" ; ls; }
function ... () { cd ../../"$1" ; ls; }
function .... () { cd ../../../"$1" ; ls; }
function ..2 () { cd ../../"$1" ; ls; }
function ..3 () { cd ../../../"$1" ; ls; }
function search () { grep -rn "$1" .; }
function fname() { find . -iname "*$@*"; }
parse_git_branch() { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'; }
git_tag_prefix() { git tag | tail -n1 | sed -e 's/\([0-9.]\{1,\}\.\)\([0-9]\{1,\}\)$/\1/g'; }
git_tag_suffix() { git tag | tail -n1 | sed -e 's/\([0-9.]\{1,\}\.\)\([0-9]\{1,\}\)$/\2/g'; }

next_tag() {
  a=$(git_tag_suffix);
  version=$((a+1));
  tag=$(git_tag_prefix)$version;
  echo $tag;
}

function push() { if [ $# -ne 1 ]; then echo "push <branch>"; return; fi; git up; git checkout $1; git push origin $1; }
function merge() {
  branch=$(parse_git_branch);
  if [ $# -lt 2 ]; then
    echo "merge <master> <dev> [auto|<tag>]";
    return;
  fi;
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
}

#Connexions ssh
alias enst='ssh tdeo@ssh.enst.fr'
alias tiresias='ssh -L 1234:tiresias:8080 tdeo@ssh.enst.fr'

#pricematch
PM_ROOT="/Users/tdeo/pricematch/"
function pm () { cd $PM_ROOT/"$1" ; ls;}
alias sync_from_prod="time php $PM_ROOT/pricematch-platform/htdocs/index.php tasks sync_from_prod"
function rspec() { if [ $# -eq 0 ]; then bin/rspec spec/; return; fi; bin/rspec $@; }
alias rubocop='bundle exec rubocop -c $PM_ROOT/devtools/rubocop/rubocop.yml'
alias nose='python algo.py test'
alias perseus='python $PM_ROOT/devtools/perseus/perseus.py'
alias algo='python $PM_ROOT/algo/algo.py'
alias pricematch-db="cd $PM_ROOT/admin && git up && sleep 0.1 && bin/rake db:migrate && bin/rake db:migrate RAILS_ENV=test && cd -"
alias pricematch-locales="perseus locales synchronize -r $PM_ROOT/www/locales/en.yml"
alias pricematch-up='find /home/thierry/pricematch/ -type d -name .git | xargs -n 1 dirname | sort | grep -v 'platform' | while read line; do echo $line && cd $line && git up; done'
alias pricematch-website="cd $PM_ROOT/www; sleep 0.1; shotgun -p 9293 & grunt watch &"

#logiciels installes manuellement
alias eclipse='/opt/eclipse/eclipse'

#calculette
=() {
    calc="$@"
    # Uncomment the below for (p → +) and (x → *)
    #calc="${calc//p/+}"
    #calc="${calc//x/*}"
    echo -ne "$calc\n quit" | gcalccmd | sed 's:^> ::g'
}

