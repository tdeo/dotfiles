LANG=en_US.UTF-8

setopt share_history

autoload -Uz compinit && compinit
setopt no_auto_menu


_rake () {
  week_num=$(date +%W)
  if [[ ! -f .rake_tasks_$week_num~ ]]; then
    rm .rake_tasks* 2>/dev/null
    rake --silent --all --tasks | cut -d " " -f 2 > .rake_tasks_$week_num~
  fi
  compadd $(cat .rake_tasks_$week_num~)
}
compdef _rake rake

_yarn() {
  compadd $(cat package.json  | jq -r '.scripts | keys | join(" ")')
}
compdef _yarn yarn

PATH="$HOME/.git_scripts:$PATH:/usr/local/bin";
export EDITOR="subl"

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
alias ".."="cd ../; ls"

export PATH="$(brew --prefix)/opt/grep/libexec/gnubin:$PATH"
export PATH="$(brew --prefix)/opt/findutils/libexec/gnubin:$PATH"
export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
export PATH=".git/safe/../../bin:$PATH"

export VERNIER_OUTPUT="$HOME/Downloads/foo.json"
export NODE_OPTIONS="--max_old_space_size=16384"
