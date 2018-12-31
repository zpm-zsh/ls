#!/usr/bin/env zsh


if ! =ls --version >/dev/null 2>&1 ; then
  echo This plugin doesn\'t support BSD ls, please install GNU ls
  return -1
fi


_LS=(ls)

if (( $+commands[gls] )); then
  _LS=(gls)
fi

_LS=($_LS -hF --group-directories-first --color --time-style=+%Y-%m-%d\ %H:%M)


if (( $+commands[grc] )); then
  _GRC=("grc" "--config=${${(%):-%x}:a:h}/conf.ls" )
fi


function ls(){
  $_LS -ClxB  $@
}
compdef ls=ls

function l(){
  $_LS -ClxB  $@
}
compdef l=ls

function lsd(){
  $_LS -l -d $@ *(-/DN)
}
compdef lsd=ls

function la(){
  $_LS  -ClxB  -A $@
}
compdef la=ls

function ll(){
  $_GRC $_LS -l  $@
}
compdef ll=ls
