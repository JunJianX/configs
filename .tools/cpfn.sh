#!/bin/bash

FULL_PATH=$(cd $(dirname $1);pwd)
#echo $FULL_PATH
echo $FULL_PATH/$1>~/.tools/FULLpath.txt
#echo $PWD/$1|xclip -selection c
#echo $1>>~/.tools/FULLpath.txt
