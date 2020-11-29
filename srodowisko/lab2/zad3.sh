#!/bin/bash
cd 244942/srodowisko-programisty/lab1
./zad1.sh ..
svn propset svn:executable on zad1.sh
./zad1.sh ..
svn commit -m ""
