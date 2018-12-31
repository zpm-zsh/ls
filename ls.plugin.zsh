#!/usr/bin/env zsh


if ! =ls --version >/dev/null 2>&1 ; then
  echo This plugin doesn\'t support BSD ls, please install GNU ls
  return -1
fi

_LS=(=ls)

if (( $+commands[gls] )); then
  _LS=(=gls)
fi

_LS=($_LS -hF --hyperlink --group-directories-first --time-style=+%Y-%m-%d\ %H:%M)

function _is_ls_colored(){
  if [[ "$CLICOLOR" = 1 ]]; then
    echo "--color"
  fi
}

if (( $+commands[grc] )); then
  _GRC=("grc" "--config=${${(%):-%x}:a:h}/conf.ls" )
fi

function ls(){
  $_LS $(_is_ls_colored) -C $@
}
compdef ls=ls

function l(){
  $_LS $(_is_ls_colored) -C $@
}
compdef l=ls

function la(){
  $_LS $(_is_ls_colored)  -C -A $@
}
compdef la=ls

function ll(){
  $_GRC $_LS $(_is_ls_colored) -l $@
}
compdef ll=ls
