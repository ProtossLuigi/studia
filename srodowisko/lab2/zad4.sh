#!/bin/bash
cd 244942_temp
mkdir externals
svn add externals
svn propset svn:externals "info https://repo.cs.pwr.edu.pl/info/" externals
svn commit -m "added externals"
cd ..
svn co https://repo.cs.pwr.edu.pl/244942 --ignore-externals
cd 244942
ls externals
svn update
ls externals
svn log -r 42 -v
