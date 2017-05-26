#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2004, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# check mupip binary load on multiple databases with different nullcollation.
###########################################################################
# ----- extract file obtained from GT.M null collation------ #
###########################################################################
# the output of this test relies on dse dump -file output, therefore let's not change the block version:
setenv gtm_test_mupip_set_version "disable"
# Note down gtm_test_spanreg value at test entry. Use it only in subtests that have stdnullcoll in ALL regions.
# For the remaining tests, use a value of 0 instead.
set spanreg = $gtm_test_spanreg

# Disable spanning-regions testing for this test scenario as it involves non-standard null collation in at least one region
setenv gtm_test_spanreg 0
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates (done in set_up_db.csh) done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 3 200
$DSE << dse_eof
change -fileheader -null_subscripts=ALWAYS
find -region=BREG
change -fileheader -null_subscripts=ALWAYS
find -region=DEFAULT
change -fileheader -null_subscripts=ALWAYS
exit
dse_eof
# default collation order is nostdnullcoll(i.e. GT.M null collation)
$GTM << gtm_eof
do three^varfill
write "all globals should collate same as GT.M null collation",!
zwrite ^aregvar,^bregvar,^cregvar
halt
gtm_eof
$gtm_tst/com/dbcheck.csh
$MUPIP extract -format=bin extr1.bin >& extr1.out

# Disable spanning-regions testing for this test scenario as it involves non-standard null collation in at least one region
setenv gtm_test_spanreg 0
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates (done in set_up_db.csh) done in the same subtest
rm -f a.dat b.dat mumps.dat
$gtm_tst/com/dbcreate.csh mumps 3 200
# alter AREG alone to M.std collation
$DSE << dse_eof
change -fileheader -stdnullcoll=true -null_subscripts=ALWAYS
dump -fileheader
find -region=BREG
change -fileheader -null_subscripts=ALWAYS
dump -fileheader
find -region=DEFAULT
change -fileheader -null_subscripts=ALWAYS
dump -fileheader
exit
dse_eof
$MUPIP load -format=bin extr1.bin >& load1.out
if ($status) then
        echo "TEST-E-LOAD ERROR"
endif
# check for collating order
$GTM << gtm_eof
write "AREG should collate as M.std. rest as GT.M null collation.",!
zwrite ^aregvar,^bregvar,^cregvar
halt
gtm_eof
$gtm_tst/com/dbcheck.csh

###########################################################################
# ----- extract file obtained from M std collation------ #
###########################################################################
rm -f a.dat b.dat mumps.dat
# Enable spanning-regions testing for this test scenario as it involves standard null collation in ALL regions.
setenv gtm_test_spanreg $spanreg
setenv gtm_test_sprgde_id "ID3"	# to differentiate multiple dbcreates (done in set_up_db.csh) done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 3 200
# make all reg collation to be M.std.
$DSE << dse_eof
change -fileheader -null_subscripts=ALWAYS -stdnullcoll=true
find -region=BREG
change -fileheader -null_subscripts=ALWAYS -stdnullcoll=true
find -region=DEFAULT
change -fileheader -null_subscripts=ALWAYS -stdnullcoll=true
exit
dse_eof
$GTM << gtm_eof
do three^varfill
write "all globals should collate same as M.std",!
zwrite ^aregvar,^bregvar,^cregvar
halt
gtm_eof
$MUPIP extract -format=bin extr2.bin >& extr2.out
$gtm_tst/com/dbcheck.csh

rm -f a.dat b.dat mumps.dat
# Disable spanning-regions testing for this test scenario as it involves non-standard null collation in at least one region
setenv gtm_test_spanreg 0
setenv gtm_test_sprgde_id "ID4"	# to differentiate multiple dbcreates (done in set_up_db.csh) done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 3 200
# alter BREG alone to M.std collation
$DSE << dse_eof
change -fileheader -null_subscripts=ALWAYS
dump -fileheader
find -region=BREG
change -fileheader -stdnullcoll=true -null_subscripts=ALWAYS
dump -fileheader
find -region=DEFAULT
change -fileheader -null_subscripts=ALWAYS
dump -fileheader
exit
dse_eof
$MUPIP load -format=bin extr2.bin >& load2.out
if ($status) then
        echo "TEST-E-LOAD ERROR"
        exit 3
endif
$GTM << gtm_eof
write "BREG should collate as M.std. rest as GT.M null collation.",!
zwrite ^aregvar,^bregvar,^cregvar
halt
gtm_eof
#
$gtm_tst/com/dbcheck.csh
#
