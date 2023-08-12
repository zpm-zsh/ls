#!/usr/bin/env zsh

# Standarized $0 handling, following:
# https://z-shell.github.io/zsh-plugin-assessor/Zsh-Plugin-Standard
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
local _DIRNAME="${0:h}"

# Remove any existing alias of ls
if [[ $(alias ls) ]]; then
  unalias ls
fi

if [[ -z "$ZSH_LS_BACKEND" ]]; then
  if [[ ! -z "$ZSH_LS_PREFER_LS" ]]; then
    ZSH_LS_BACKEND='ls'
  elif (( $+commands[lsd] )); then
    ZSH_LS_BACKEND='lsd'
  elif (( $+commands[exa] )); then
    ZSH_LS_BACKEND='exa'
  else
    ZSH_LS_BACKEND='ls'
  fi
else
  ZSH_LS_BACKEND='ls'
fi

if [[ "$ZSH_LS_BACKEND" == "lsd" ]]; then
  typeset -g lsd_params; lsd_params=()

  function ls() {
    lsd ${lsd_params} $@
  }
  compdef ls=lsd

  function l() {
    lsd ${lsd_params} $@
  }
  compdef l=lsd

  function la() {
    lsd -a ${lsd_params} $@
  }
  compdef la=lsd

  function ll() {
    lsd --header --long ${lsd_params} $@
  }
  compdef ll=lsd
elif [[ "$ZSH_LS_BACKEND" == "exa" ]]; then
  typeset -g exa_params; exa_params=('--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color=auto')

  if ((! ${+ZSH_LS_DISABLE_GIT})); then
    exa_params+=('--git')
  fi

  function ls() {
    exa ${exa_params} $@
  }
  compdef ls=exa

  function l() {
    exa --git-ignore ${exa_params} $@
  }
  compdef l=exa

  function la() {
    exa -a ${exa_params} $@
  }
  compdef la=exa

  function ll() {
    exa --header --long ${exa_params} $@
  }
  compdef ll=exa
else
  typeset -g _ls
  _ls=(=ls)

  if (( $+commands[gls] )); then
    _ls=(=gls)
  fi

  typeset -g _ls_params
  _ls_params=('-hF' '--group-directories-first' '--time-style=+%Y-%m-%d %H:%M' '--quoting-style=literal')

  if ${_ls[@]} --hyperlink >/dev/null 2>&1 ; then
    _ls_params+=('--hyperlink')
  fi

  if [[ "$CLICOLOR" != "0" ]]; then
    _ls_params+=('--color')
  fi

  if (( $+commands[grc] )); then
    _grc=('grc' "--config=${_DIRNAME}/conf.ls" )
  fi

  function ls() {
    $_ls ${_ls_params} -C $@
  }
  compdef ls=ls

  function l() {
    $_ls ${_ls_params} -C $@
  }
  compdef l=ls

  function la() {
    $_ls ${_ls_params} -C -A $@
  }
  compdef la=ls

  function ll() {
    if [[ "$CLICOLOR" != "0" ]]; then
      $_grc $_ls ${_ls_params} -l $@
    else
      $_ls -l $@
    fi
  }
  compdef ll=ls
fi

