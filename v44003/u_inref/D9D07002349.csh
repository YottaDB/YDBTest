#!/usr/local/bin/tcsh -f
#
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh mumps
#
##### THE FOLLOWING SECTION IS DISABLED BECAUSE IT IS EXTENSIVELY CHECKED IN 64BITTN/DSE_COMMANDS SUBTEST ######
#echo '*************************************'
#echo 'check the range of change -fileheader'
#$DSE ch -fi -curr=0
#$DSE dump -fi |& grep "Current transaction"
#$DSE ch -fi -curr=1
#$DSE dump -fi |& grep "Current transaction"
#$DSE ch -fi -curr=7fffffff
#$DSE dump -fi |& grep "Current transaction"
#$DSE ch -fi -curr=80000000
#$DSE dump -fi |& grep "Current transaction"
#$DSE ch -fi -curr=80000001
#$DSE dump -fi |& grep "Current transaction"
#$DSE ch -fi -curr=fffffffe
#$DSE dump -fi |& grep "Current transaction"
#$DSE ch -fi -curr=ffffffff
#$DSE dump -fi |& grep "Current transaction"
#$DSE ch -fi -curr=1
#
### THE FOLLOWING SECTION IS MOVED TO 64BITTN/DSE_COMMANDS SUBTEST ####
#echo '************************************'
#echo 'check the range of change -block -tn'
#
#$DSE << dse_eof 
#ch -bl=0 -tn=0
#dump -bl=0 -header
#ch -bl=0 -tn=1
#dump -bl=0 -header
#ch -bl=0 -tn=7fffffff
#dump -bl=0 -header
#ch -bl=0 -tn=80000000
#dump -bl=0 -header
#ch -bl=0 -tn=80000001
#dump -bl=0 -header
#ch -bl=0 -tn=fffffffe
#dump -bl=0 -header
#ch -bl=0 -tn=ffffffff
#dump -bl=0 -header
#
#### WE WILL HAVE THIS SECTION ALONE HERE ####
$DSE <<dse_eof
eval -d -n=2147483647
eval -d -n=2147483648
eval -d -n=4294967295
eval -d -n=18446744073709551616
eval -d -n=18446744073709551617
eval -d -n=49
eval -d -n="-1"
eval -d -n="-10"
eval -d -n="-7fffffff"
eval -d -n="-80000000"

eval -h -n=7fffffff
eval -h -n=80000000
eval -h -n=ffffffff
eval -h -n=10000000000000000
eval -h -n="-1"
eval -h -n="-7fffffff"
eval -h -n="-80000000"

dse_eof
$gtm_tst/com/dbcheck.csh
