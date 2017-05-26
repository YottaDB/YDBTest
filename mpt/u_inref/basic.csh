#!/usr/local/bin/tcsh -f
# Encryprion cannot support access method MM, so explicitly running the test with NON_ENCRYPT when acc_meth is MM
if ("MM" == $acc_meth) then
        setenv test_encryption NON_ENCRYPT
endif
$GTM << \xyyzx
w "do ^pct",!     do ^pct
w "do ^mptdat",!  do ^mptdat
w "do ^mptnum",!  do ^mptnum
w "   test of %fl ",!  do ^%FL
mpt*

fl.log
w "   test of %rd ",!  do ^%RD
mpt*

w "   test of %ro ",!  do ^%RO
mptpgm

ro.log


w "   test of %rsel ",! do ^%RSEL

w "   test of %rsel ",! do ^%RSEL
mp*

h
\xyyzx
$gtm_tst/com/dbcreate.csh . 3
$GTM << xzyyx
w "do ^mptglo",!  do ^mptglo


*


*


*


^%

h
xzyyx
$gtm_tst/com/dbcheck.csh  -extract
