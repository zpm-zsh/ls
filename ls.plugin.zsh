#!/usr/bin/env zsh

if command -v exa >/dev/null; then
  # Use exa
  exa_params=('--git' '--icons' '--classify' '--group-directories-first' '--time-style=long-iso' '--group')
  
  function ls(){
    exa $exa_params $@
  }
  compdef ls=exa
  
  function l(){
    exa '--git-ignore' $exa_params $@
  }
  compdef l=exa
  
  function la(){
    exa $exa_params  $@
  }
  compdef la=exa
  
  function ll(){
    
    exa --header --long $exa_params $@
  }
  compdef ll=exa
  
else
  
  if ! =ls --version >/dev/null 2>&1 ; then
    echo This plugin doesn\'t support BSD ls, please install GNU ls
    return -1
  fi
  
  _ls=(=ls)
  
  if (( $+commands[gls] )); then
    _ls=(=gls)
  fi
  
  if $_ls --hyperlink >/dev/null 2>&1 ; then
    _hyperlink='--hyperlink'
  fi
  
  _ls_params=('-hF' '--group-directories-first' '--time-style=+%Y-%m-%d %H:%M' '--quoting-style=literal')
  
  function _is_ls_colored(){
    if [[ "$CLICOLOR" = 1 ]]; then
      echo "--color $_hyperlink"
    fi
  }
  
  if command -v grc >/dev/null; then
    _grc=("grc" "--config=${${(%):-%x}:a:h}/conf.ls" )
  fi
  
  function ls(){
    $_ls $(_is_ls_colored) -C $@
  }
  compdef ls=ls
  
  function l(){
    $_ls $(_is_ls_colored) -C $@
  }
  compdef l=ls
  
  function la(){
    $_ls $(_is_ls_colored)  -C -A $@
  }
  compdef la=ls
  
  function ll(){
    
    if [[ "$CLICOLOR" = 1 ]]; then
      $_grc  $_ls $(_is_ls_colored) -l $@
    else
      $_ls -l $@
    fi
  }
  compdef ll=ls
  
  
  
fi

