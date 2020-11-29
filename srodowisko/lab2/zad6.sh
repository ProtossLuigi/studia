#!/bin/bash
cd 244942_temp
mkdir test
svn add test
cd test
echo aaa > a.txt
echo bbb > b.txt
svn add a.txt b.txt
svn commit -m "added files"
svn rm b.txt
svn commit -m "removed b"
echo bbb >> a.txt
svn mv a.txt b.txt
svn commit -m "changed a to b"
echo ccc >> b.txt
svn mv b.txt c.txt
svn commit -m "changed b to c"
touch b.txt
svn add b.txt
svn commit -m "re-added b"
svn update
svn log -v b.txt
svn log -v c.txt
svn log -v .
svn diff -r 80:HEAD c.txt@HEAD
