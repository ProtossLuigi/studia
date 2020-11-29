#!/bin/bash
svn checkout https://repo.cs.pwr.edu.pl/244942 --depth empty
cd 244942
svn update --set-depth empty srodowisko-programisty
svn update --set-depth empty srodowisko-programisty/lab2
svn update --set-depth immediates srodowisko-programisty/lab2/tests
tree
cd srodowisko-programisty/lab2/tests/a
svn update --set-depth infinity a
svn update --set-depth immediates b
svn update --set-depth empty ab
tree
svn log -r 38 -v
