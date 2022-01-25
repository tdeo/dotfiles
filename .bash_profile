if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi
if [ -f ~/.bash_completion ]; then . ~/.bash_completion; fi

export BASH_SILENCE_DEPRECATION_WARNING=1
export PATH="/usr/local/sbin:$PATH"
PHP_AUTOCONF="/usr/local/bin/autoconf"

if [ -f ~/.profile ]; then . ~/.profile; fi

BREW_PREFIX=$(which brew &> /dev/null && brew --prefix || echo '')

if [ -f $BREW_PREFIX/etc/bash_completion ]; then
  . $BREW_PREFIX/etc/bash_completion
fi

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH=$PATH:/Users/tdeo/Library/Android/sdk/platform-tools

[[ -s $BREW_PREFIX/etc/profile.d/autojump.sh ]] && . $BREW_PREFIX/etc/profile.d/autojump.sh

if [ -f ~/.direnvrc ]; then
  . ~/.direnvrc
fi

export PATH="bin:$HOME/.pyenv/bin:$PATH"
if which pyenv &> /dev/null; then
  eval "$(pyenv init -)"
  # eval "$(pyenv virtualenv-init -)"
fi

if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  cd .
  source "$HOME/.rvm/scripts/rvm"
fi

if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
export PATH="bin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

. /opt/homebrew/opt/asdf/libexec/asdf.sh

. /opt/homebrew/opt/asdf/etc/bash_completion.d/asdf.bash

export GOPATH="$HOME/go/"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOPATH:$GOBIN"

export PATH="./bin/:$PATH"
