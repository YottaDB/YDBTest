#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 2
$GTM << GTM_EOF
for i=0:1:100  s ^test(i)=i
for i=0:1:100  s ^A(i)=i
tstart ():serial
s ^test(i)=i+1
s ^A(i)=i+1
k ^test(0)
k ^A(0)
tcommit
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
