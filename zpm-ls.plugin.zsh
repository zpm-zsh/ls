#!/usr/bin/env zsh

# Standarized $0 handling, following:
# https://z-shell.github.io/zsh-plugin-assessor/Zsh-Plugin-Standard
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
local _DIRNAME="${0:h}"

# exa based
if (( $+commands[exa] && ! ${+ZSH_LS_PREFER_LS} )); then
  typeset -g exa_params; exa_params=('--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color=auto')

  if [[ `uname` == "Darwin" ]]; then
    exa_params+="-I'.DS_Store'"
  fi

  if ((! ${+ZSH_LS_DISABLE_GIT})); then
    exa_params+=('--git')
  fi

  function ls(){
    exa ${exa_params} $@
  }
  compdef ls=exa

  function l(){
    exa --git-ignore ${exa_params} $@
  }
  compdef l=exa

  function la(){
    exa -a ${exa_params} $@
  }
  compdef la=exa

  function ll(){
    exa --header --long ${exa_params} $@
  }
  compdef ll=exa

  function lla(){
    exa -a --header --long ${exa_params} $@
  }
  compdef lla=exa

  # Exa-enabled only
  # ----------------
  # accepts argument of # for depth
  function tree(){
    # if # provided
    if [[ $1 =~ '^[0-9]+$' ]]; then
      exa -T -L $1 ${exa_params} ${@:2}
    # no # provided (max-depth)
    else
      exa -T ${exa_params} ${@}
    fi
  }
  compdef tree=exa

  # accepts argument of # for depth
  function treea(){
    # if # provided
    if [[ $1 =~ '^[0-9]+$' ]]; then
      exa -T -L $1 ${exa_params} ${@:2}
    # no # provided (max-depth)
    else
      exa -a -T ${exa_params} ${@}
    fi
  }
  compdef treea=exa

# ls + gls based
else
  typeset -g _ls
  _ls=(=ls)

  typeset -g _ls_params
  _ls_params=('-hF')

  if [[ `uname` != "Darwin" ]] || [[ $+commands[gls] ]]; then
    _ls_params+=('--group-directories-first' '--time-style=long-iso' '--quoting-style=literal')
    if [[ $+commands[gls] ]]; then
      _ls=(=gls)
    fi
  fi

  if ${_ls[@]} --hyperlink >/dev/null 2>&1 ; then
    _ls_params+=('--hyperlink')
  fi

  if [[ "$CLICOLOR" != "0" ]]; then
    _ls_params+=('--color')
  fi

  if (( $+commands[grc] )); then
    _grc=('grc' "--config=${_DIRNAME}/conf.ls" )
  fi

  function ls(){
    $_ls ${_ls_params} -C $@
  }
  compdef ls=ls

  function l(){
    $_ls ${_ls_params} -C $@
  }
  compdef l=ls

  function la(){
    $_ls ${_ls_params} -C -A $@
  }
  compdef la=ls

  function ll(){
    if [[ "$CLICOLOR" != "0" ]]; then
      $_grc $_ls ${_ls_params} -l $@
    else
      $_ls -l $@
    fi
  }
  compdef ll=ls

  function lla() {
    if [[ "$CLICOLOR" != "0" ]]; then
      $_grc $_ls ${_ls_params} -l -a $@
    else
      $_ls -l -a $@
    fi
  }
fi

