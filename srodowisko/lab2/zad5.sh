#!/bin/bash
cd 244942_temp
touch lock_test1
touch lock_test2
svn add lock_test1 lock_test2
svn lock lock_test1
svn lock lock_test2
svn commit -m "locked"
svn unlock lock_test1
svn commit -m "unlocked"
svn lock lock_test1
svn commit -m "locked again"
cd ../244942
svn update
svn rm lock_test1
svn commit -m "trying to remove locked"
svn unlock --force https://repo.cs.pwr.edu.pl/244942/lock_test1
svn rm lock_test1
svn commit -m "remove 1"
svn lock --force lock_test2
svn rm lock_test2
svn commit -m "remove 2"
svn update
svn log -l 6 -v
