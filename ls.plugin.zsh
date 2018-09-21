#!/usr/bin/env zsh


if ! =ls --version >/dev/null 2>&1 ; then
  echo This plugin doesn\'t support BSD ls, please install GNU ls
  return -1
fi

_LS=(=ls -hF --group-directories-first --color --time-style=+%Y-%m-%d\ %H:%M)

if (( $+commands[gls] )); then
  _LS=(=gls -hF --group-directories-first --color --time-style=+%Y-%m-%d\ %H:%M)
fi

if (( $+commands[grc] )); then
  _LS=("grc" "--config=${${(%):-%x}:a:h}/conf.ls" $_LS)
fi


function ls(){
  $_LS -ClxB  $@
}
compdef ls=ls

function l(){
  $_LS -ClxB  $@
}
compdef l=ls

function ll(){
  $_LS -l  $@
}
compdef ll=ls

function lsd(){
  $_LS -l -d $@ *(-/DN)
}
compdef lsd=ls

function la(){
  $_LS  -ClxB  -A $@
}
compdef la=ls
