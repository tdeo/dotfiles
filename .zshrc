LANG=en_US.UTF-8

zmodload zsh/zprof
setopt share_history

autoload -Uz compinit && compinit
setopt no_auto_menu
setopt HIST_IGNORE_ALL_DUPS

_rake () {
  week_num=$(date +%W)
  if [[ ! -f .rake_tasks_$week_num~ ]]; then
    rm .rake_tasks* 2>/dev/null
    rake --silent --all --tasks | cut -d " " -f 2 > .rake_tasks_$week_num~
  fi
  compadd $(cat .rake_tasks_$week_num~)
}
compdef _rake rake

_yarn () {
  cat package.json
  compadd $(cat package.json  | jq -r '.scripts | keys | join("\n")')
}
compdef _yarn yarn

PATH="$HOME/.git_scripts:$PATH:/usr/local/bin";
export EDITOR="code"
export PSQL_EDITOR='code -w'

setopt PROMPT_SUBST
git_branch() { git rev-parse --abbrev-ref HEAD 2> /dev/null; }
git_sha() { git rev-parse --short HEAD 2> /dev/null; }
PROMPT='%B\
%F{blue}%~%f \
%F{green}$(git_branch)%b \
$(git_sha)%f \
%B%F{cyan}%*%f \
%#%b '

alias ls="ls --color=auto"
alias ll="ls -alh"
alias "git?"="git branch; git status"
alias "."="source"
alias subl="code"

function .. ()  { cd ../"$1"; ls }
function _.. ()  { 
  compadd $(cd ../; ls -d */) 
}
compdef _.. ..

alias code='f() { touch "$@"; open -a "Cursor" "$@"; }; f'

source $HOME/.environment_setup

if [ -f $HOME/compta/jeancaisse/.env.local ]; then
  source $HOME/compta/jeancaisse/.env.local
fi

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# add CloudyPad CLI PATH
export PATH=$PATH:/Users/thierry/.cloudypad/bin

# Scaleway CLI autocomplete initialization.
eval "$(scw autocomplete script shell=zsh)"
