#! /usr/local/bin/tcsh -f
source $gtm_tst/$tst/u_inref/cre_coll_sl.csh

# create a db and fill in some local variables to test local collation

$gtm_tst/com/dbcreate.csh mumps 2 125 500
$GTM << \aaa  >& local_polm.out
w "Current local collation=",$$get^%LCLCOL,!
if '$$set^%LCLCOL(1) W "Local collation cannot be changed",!
set ^prefix=""
d in2^mixfill("set",15)
d in2^mixfill("ver",15)
d in2^numfill("set",1,2)      
d in2^numfill("ver",1,2)      
zwr AGLOBALVAR1
zwr BGLOBALVAR1
ZWR morefill
h
\aaa
$gtm_tst/com/dbcheck.csh -extr
$gtm_tst/$tst/u_inref/check_local_polm.csh
