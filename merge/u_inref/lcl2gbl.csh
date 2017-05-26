#!/usr/local/bin/tcsh -f
setenv test_reorg "NON_REORG"  
source $gtm_tst/com/dbcreate.csh mumps 4 255 1000
$gtm_exe/mumps -dir << aaa
set cnt=1
f i=1001:1:1005 for j=1000:1:1005 set cnt=cnt+1 s var1(i,"ind"_i,j)="BBB"_cnt
set var1(1003,"ind"_1003)="BBB"_1003
zwr var1
MERGE ^new2("NEWVAR")=var1
zwr ^new2
MERGE ^new1("aaa","bbbb","cccc")=var1(1003,"ind1003")
zwr ^new1
MERGE ^new1("kkk")=var1(1001,"ind1001")
zwr ^new1
MERGE ^new1("aaa")=var1(1004)
zwr ^new1
MERGE ^new1("aaa")=var1(1005)
zwr ^new1
MERGE ^new1("lll")=var1(1001,"ind1001")
zwr ^new1
MERGE ^new1("lll0")=var1(1001,"ind1001",1002)
MERGE ^new1("lll")=var1(1003,"ind1003",1002)
zwr ^new1
set var1longnamevariableswork4merge(1,2,3)="long local to global"
set var1long(1,2,3)="should not use this shorter variable"
MERGE ^new1longnamevariableswork4merge("aaa")=var1longnamevariableswork4merge(1,2,3)
MERGE:1 ^new1longnamevariableswork4merge("bbb")=var1longnamevariableswork4merge(1,2,3)
set longvar="^new1longnamevariableswork4merge"
MERGE @longvar@("ccc")=var1longnamevariableswork4merge(1,2,3)
zwr ^new1longnamevariableswork4merge
halt
aaa
$gtm_tst/com/dbcheck.csh -extr
