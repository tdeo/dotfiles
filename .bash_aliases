alias stiq='echo "binet de teubis"'
alias BôBar='echo "Mythe, mec !"'

#Raccourcis
alias TDB='cd /home/thierry/workspace/TDB'
alias nano='nano -c'
alias fucking='sudo'
alias g++11='g++ -W -Wall -std=c++11 -o myprog '
alias git?='git branch;git status'
alias git='LANG=en_US git'
alias cv='if `which cv`; then watch -n0.02 cv -q; fi; if `which progress`; then watch -n0.02 progress -q; fi'

function process () { ps -u thierry -o user,pid,%cpu,%mem,time,command | grep $1 | grep -v 'grep' ;}
function telecom () { cd ~/workspace/Telecom/"$1" ; ls;}
function polytechnique () { cd ~/workspace/X/"$1" ; ls;}
function .. ()  { cd ../"$1" ; ls; }
parse_git_branch() { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'; }
git_tag_prefix() { git tag | tail -n1 | sed -e 's/\([0-9.]\{1,\}\.\)\([0-9]\{1,\}\)$/\1/g'; }
git_tag_suffix() { git tag | tail -n1 | sed -e 's/\([0-9.]\{1,\}\.\)\([0-9]\{1,\}\)$/\2/g'; }
function subl_git_modified_files() { git status | gsed -e '/modified/!d' -e 's/\smodified:   //' | xargs subl; }

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

GREP=$(which ggrep &> /dev/null && echo 'ggrep' || echo 'grep')

#pricematch
PM_ROOT="$HOME/pricematch/"
function v () {
  cd $PM_ROOT/devtools/vagrant;
  if [ $# == 1 ]; then
    vagrant $1;
  fi;
}
function pm () { cd $PM_ROOT/"$1" ; ls;}
alias sync_from_prod="time php $PM_ROOT/pricematch-platform/htdocs/index.php tasks sync_from_prod"
function rspec() { if [ $# -eq 0 ]; then bin/rspec spec/; return; fi; bin/rspec $@; }
alias admin_bundle='pkill -9 -f spring; rm bin/*; bundle install --binstubs && bundle clean && gem install git-up && rm bin/rails bin/rake && bundle exec rake rails:update:bin && bin/spring binstub --all'
alias rubocop='bundle exec rubocop -c $PM_ROOT/devtools/rubocop/rubocop.yml'
alias nose='PYTHON_ENV=test python algo.py test'
alias perseus='python $PM_ROOT/devtools/perseus/perseus.py'
alias pricematch-db="cd $PM_ROOT/admin && git up && sleep 0.1 && bin/rake db:migrate && bin/rake db:migrate RAILS_ENV=test && cd -"
alias pricematch-up='find $PM_ROOT -type d -name .git | xargs -n 1 dirname | sort | grep -v 'platform' | while read line; do echo $line && cd $line && git up; done'
function admin_grep () { $GREP -nR $1 . --exclude-dir={vendor,coverage,fixtures,\.git,doc,dynamodb,public,log} --color=auto; }
function algo_grep () { $GREP -nR $1 . --exclude=*.pyc --color=auto; }
function ssh-worker () { ssh ubuntu@172.30.3."$1" -p26 -i $HOME/.ssh/deploy3.pem; }
alias caches='for f in `ls /tmp/ | grep sync_from_prod`; do
if [ -f /tmp/$f/config.json ];
then
  echo $f;
  cat /tmp/$f/config.json;
  echo "";
fi
if [ -f /tmp/$f/test.json ];
then
  echo "$f: test";
fi
done;'

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

