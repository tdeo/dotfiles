LANG=en_US.UTF-8

zmodload zsh/zprof
setopt share_history

autoload -Uz compinit && compinit
setopt no_auto_menu
setopt HIST_IGNORE_ALL_DUPS

_rake () {
  ((leeway=60 * 60 * 12))
  ((updated_at=$(date +%s) - $leeway))
  current=$(date +%s)
  [[ -f .rake_tasks_updated_at~ ]] && updated_at=$(cat .rake_tasks_updated_at~)

  line_count=$(cat .rake_tasks~ | wc -l)
  if [[ $updated_at -le (( $current - $leeway )) ]] || [[ $line_count -lt 10 ]]; then
    setopt local_options no_notify no_monitor
    (echo $current > .rake_tasks_updated_at~ &&
      rake --silent --all --tasks | cut -d " " -f 2 > .rake_tasks_tmp~ &&
      mv .rake_tasks_tmp~ .rake_tasks~) &
  fi
  compadd $(cat .rake_tasks~)
}
compdef _rake rake

_yarn () {
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

export HOMEBREW_AUTO_UPDATE_SECS="$((7 * 24 * 60 * 60))"

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

alias code='f() { mkdir -p "$(dirname "$@")"; touch "$@"; open -a "Cursor" "$@"; }; f'

source $HOME/.environment_setup

if [ -f "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh" ]; then
    source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
    PS1='$(kube_ps1)'$PS1
    kubeoff
fi

if [ -f $HOME/compta/jeancaisse/docker.env ]; then
  source $HOME/compta/jeancaisse/docker.env
fi

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# add CloudyPad CLI PATH
export PATH=$PATH:/Users/thierry/.cloudypad/bin

# Scaleway CLI autocomplete initialization.
# eval "$(scw autocomplete script shell=zsh)"
