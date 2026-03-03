LANG=en_US.UTF-8

zmodload zsh/zprof
setopt share_history

autoload -Uz compinit && compinit
setopt no_auto_menu

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.


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
  if [[ -f .rake_tasks~ ]]; then
    compadd $(cat .rake_tasks~)
  fi
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
alias groot="cd $(git root)"

function .. ()  { cd ../"$1"; ls }
function _.. ()  { 
  compadd $(cd ../; ls -d */) 
}
compdef _.. ..

alias code='f() { dirname "$@" | xargs mkdir -p; touch "$@"; open -a "Cursor" "$@"; }; f'

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
