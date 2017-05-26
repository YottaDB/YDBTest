#! /usr/local/bin/tcsh -f
echo "incrgv5  - REC2BIG  error "
source $gtm_tst/com/dbcreate.csh mumps 3 -t=$gtm_tst/$tst/u_inref/incrgv5.gde
$GTM << \aa
s ^a=0 f i=1:1:10001 if $increment(^a)#100=0 write ^a,!
s ^b=0 f i=1:1:10001 if $increment(^b)#100=0 write ^b,!
s ^x=0 f i=1:1:10001 if $increment(^x)#100=0 write ^x,!
\aa
$gtm_tst/com/dbcheck.csh
echo "End of incrgv5"

