#!/usr/bin/env zsh

# Standarized $0 handling, following:
# https://z-shell.github.io/zsh-plugin-assessor/Zsh-Plugin-Standard
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
local _DIRNAME="${0:h}"

if (( $+functions[zpm] )); then
  zpm load zpm-zsh/helpers
fi

# Remove any existiong function of safe-compdef
if (( $+functions[safe-compdef] )); then
  unset -f safe-compdef
fi

# Define a safe-compdef function to avoid errors if the completion function does not exist
# This is useful for plugins that may not have been loaded yet
# or if the completion function is not available in the current context.
# It checks if the function exists in the fpath or if it can be found with whence.
# If it exists, it will set the completion definition for the given binary.
# If it does not exist, it will not set the completion definition and will not throw an error.
# Usage: safe-compdef <binary> <function>
# Example: safe-compdef ls lsd
function safe-compdef() {
  local bin=$1
  local fn=$2

  if [[ -n "$fn" && -f "${fpath[(r)*/_${fn}]}" ]]; then
    compdef "$bin=$fn"
  elif whence -w "_$fn" &>/dev/null; then
    compdef "$bin=$fn"
  fi
}


# Remove any existing alias of ls
if [[ $(alias ls) ]]; then
  unalias ls
fi

if [[ -z "$ZSH_LS_BACKEND" ]]; then
  if [[ ! -z "$ZSH_LS_PREFER_LS" ]]; then
    ZSH_LS_BACKEND='ls'
  elif (( $+commands[lsd] )); then
    ZSH_LS_BACKEND='lsd'
  elif (( $+commands[eza] )); then
    ZSH_LS_BACKEND='eza'
  elif (( $+commands[exa] )); then
    ZSH_LS_BACKEND='exa'
  else
    ZSH_LS_BACKEND='ls'
  fi
fi

if [[ "$ZSH_LS_BACKEND" == "lsd" ]]; then
  typeset -g lsd_params; lsd_params=()

  function ls() {
    lsd ${lsd_params} $@
  }
  safe-compdef ls lsd

  function l() {
    lsd ${lsd_params} $@
  }
  safe-compdef l lsd

  function la() {
    lsd -a ${lsd_params} $@
  }
  safe-compdef la lsd

  function ll() {
    lsd --header --long ${lsd_params} $@
  }
  safe-compdef ll lsd

  function lla() {
    lsd --header --long -a ${lsd_params} $@
  }
  safe-compdef lla lsd

  function lt() {
    lsd --tree ${lsd_params} $@
  }
  safe-compdef lt lsd

  function lta() {
    lsd --tree -a ${lsd_params} $@
  }
  safe-compdef lta lsd
elif [[ "$ZSH_LS_BACKEND" == "exa" || "$ZSH_LS_BACKEND" == "eza" ]]; then
  typeset -g exa_params; exa_params=('--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group' '--color=auto')

  if ((! ${+ZSH_LS_DISABLE_GIT})); then
    exa_params+=('--git')
  fi

  function ls() {
    $ZSH_LS_BACKEND ${exa_params} $@
  }
  safe-compdef ls $ZSH_LS_BACKEND

  function l() {
    $ZSH_LS_BACKEND --git-ignore ${exa_params} $@
  }
  safe-compdef l $ZSH_LS_BACKEND

  function la() {
    $ZSH_LS_BACKEND -a ${exa_params} $@
  }
  safe-compdef la $ZSH_LS_BACKEND

  function ll() {
    $ZSH_LS_BACKEND --header --long ${exa_params} $@
  }
  safe-compdef ll $ZSH_LS_BACKEND

  function lla() {
    $ZSH_LS_BACKEND --header --long -a ${exa_params} $@
  }
  safe-compdef lla $ZSH_LS_BACKEND

  function lt() {
    $ZSH_LS_BACKEND --tree ${exa_params} $@
  }
  safe-compdef lt $ZSH_LS_BACKEND

  function lta() {
    $ZSH_LS_BACKEND --tree -a ${exa_params} $@
  }
  safe-compdef lta $ZSH_LS_BACKEND
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

  if [[ "$CLICOLOR" != "0" && -z "$NO_COLOR" ]]; then
    _ls_params+=('--color')
  fi

  if (( $+commands[grc] )); then
    _grc=('grc' "--config=${_DIRNAME}/conf.ls" )
  fi

  function ls() {
    $_ls ${_ls_params} -C $@
  }
  safe-compdef ls ls

  function l() {
    $_ls ${_ls_params} -C $@
  }
  safe-compdef l ls

  function la() {
    $_ls ${_ls_params} -C -A $@
  }
  safe-compdef la ls

  function ll() {
    if [[ "$CLICOLOR" != "0" ]]; then
      $_grc $_ls ${_ls_params} -l $@
    else
      $_ls -l $@
    fi
  }
  safe-compdef ll ls

  function lla() {
    if [[ "$CLICOLOR" != "0" ]]; then
      $_grc $_ls ${_ls_params} -l -a $@
    else
      $_ls -l -a $@
    fi
  }
  safe-compdef lla ls

  function lt() {
    tree $@
  }

  function lta() {
    tree -a $@
  }
  safe-compdef lt tree

fi
