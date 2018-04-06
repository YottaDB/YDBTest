#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Mir Layek Ali # 5/17/99
# Following two lines are to compile the dbfill programs in advance.
# It is a known problem that if several process tries to
#   compile a M routine simultaneously, GTM gives problem
# Specially in HP we found problems
$gtm_exe/mumps $gtm_tst/com/dbfill.m
$gtm_exe/mumps $gtm_tst/com/pfill.m
#
setenv gtm_poollimit 0 # Setting gtm_poollimit will cause some transactions to restart. Not desirable in this test.
setenv gtm_test_sprgde_id "test0"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$GTM << xyz
w "do test0^tprollbk",!  do test0^tprollbk
h
xyz
$gtm_tst/com/dbcheck.csh "-extract"

################################################################################

setenv gtm_test_sprgde_id "test1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP set -reg "*" -journal=enable,on,before >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
for i=1:1:1000 s ^x(i)=i
h
xyz
$GTM << xyz
w "do test1^tprollbk",!  do test1^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst1^tprollbk",!  do chktst1^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chktst1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP journal -recover -forwa mumps.mjl >&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst1^tprollbk",!  do chktst1^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "test2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$GTM << xyz
w "do test2^tprollbk",!  do test2^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
################################################################################

setenv gtm_test_sprgde_id "test3"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP set -reg "*" -journal=enable,on,before >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
for i=1:1:1000 s ^x(i)=i
h
xyz
$GTM << xyz
w "do test3^tprollbk",!  do test3^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst3^tprollbk",!  do chktst3^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chktst3"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP journal -recover -forwa mumps.mjl >&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst3^tprollbk",!  do chktst3^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "test4"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do test4^tprollbk",!  do test4^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst4^tprollbk",!  do chktst4^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chktst4"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst4^tprollbk",!  do chktst4^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "test5"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
for i=1:1:1000 s ^x(i)=\$j(i,150)
h
xyz
$GTM << xyz
w "do test5^tprollbk",!  do test5^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst5^tprollbk",!  do chktst5^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chktst5"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst5^tprollbk",!  do chktst5^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "test6"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do test6^tprollbk",!  do test6^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst6^tprollbk",!  do chktst6^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chktst6"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst6^tprollbk",!  do chktst6^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "test7"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do test7^tprollbk",!  do test7^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst7^tprollbk",!  do chktst7^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chktst7"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst7^tprollbk",!  do chktst7^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "test8"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do test8^tprollbk",!  do test8^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst8^tprollbk",!  do chktst8^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chktst8"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst8^tprollbk",!  do chktst8^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
setenv gtm_test_sprgde_id "test9"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$GTM << xyz
w "do test9^tprollbk",!  do test9^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
################################################################################

setenv gtm_test_sprgde_id "test10"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do test10^tprollbk",!  do test10^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst10^tprollbk",!  do chktst10^tprollbk
h
xyz

setenv gtm_test_sprgde_id "chktst10"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst10^tprollbk",!  do chktst10^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
setenv gtm_test_sprgde_id "test11"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 200 480 512
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
s ^x=1
f i=1:1:1000 s ^x(1,i,\$j(i,170))=\$j(i,170)
h
xyz

$GTM << xyz
w "do test11^tprollbk",!  do test11^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst11^tprollbk",!  do chktst11^tprollbk
h
xyz

setenv gtm_test_sprgde_id "chktst11"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 200 480 512
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chktst11^tprollbk",!  do chktst11^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "undooff"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 255 480 512
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do undooff^tprollbk",!  do undooff^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chkundo^tprollbk",!  do chkundo^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chkundo1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 255 480 512
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chkundo^tprollbk",!  do chkundo^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "undo"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 255 480 512
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do creundo^tprollbk",!  do creundo^tprollbk
h
xyz

$GTM << xyz
w "do killundo^tprollbk",!  do killundo^tprollbk
h
xyz

$GTM << xyz
w "do undooff^tprollbk",!  do undooff^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chkundo^tprollbk",!  do chkundo^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chkundo2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 255 480 512
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chkundo^tprollbk",!  do chkundo^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "stress0"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do stress0^tprollbk",!  do stress0^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chkstr0^tprollbk",!  do chkstr0^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chkstr0"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chkstr0^tprollbk",!  do chkstr0^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "stress1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do stress1^tprollbk",!  do stress1^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chkstr1^tprollbk",!  do chkstr1^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chkstr1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chkstr1^tprollbk",!  do chkstr1^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "stress2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do stress2^tprollbk",!  do stress2^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chkstr2^tprollbk",!  do chkstr2^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chkstr2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chkstr2^tprollbk",!  do chkstr2^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "stress3"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do stress3^tprollbk",!  do stress3^tprollbk
h
xyz
$gtm_tst/com/dbcheck.csh "-extract"
$MUPIP journal -recover -back mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
cp mumps.dat database.bak
cp mumps.mjl jnl.bak
$GTM << xyz
w "do chkstr3^tprollbk",!  do chkstr3^tprollbk
h
xyz

source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "chkstr3"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$MUPIP journal -recover -forwa mumps.mjl	>&! jnl_recover_${gtm_test_sprgde_id}.out
$grep YDB-S-JNLSUCCESS jnl_recover_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do chkstr3^tprollbk",!  do chkstr3^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh
################################################################################

\rm *.mjl*
source $gtm_tst/com/bakrestore_test_replic.csh
setenv gtm_test_sprgde_id "lock0"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$GTM << xyz
w "do lock0^tprollbk",!  do lock0^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
################################################################################

setenv gtm_test_sprgde_id "lock1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 100 1024
$GTM << xyz
w "do lock1^tprollbk",!  do lock1^tprollbk
h
xyz

$gtm_tst/com/dbcheck.csh "-extract"
################################################################################
if ($LFE == "L") exit

\rm *.mjl*
setenv gtm_test_sprgde_id "tprlbk1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 9 125 1000 1024 500 8192
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do ^tprlbk1",!
do ^tprlbk1
h
xyz
$grep -i fail *.mjo*

$gtm_tst/com/dbcheck.csh "-extract"
################################################################################

\rm *.mjl*
setenv gtm_test_sprgde_id "tprlbk2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 9 125 1000 1024 500 8192
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do ^tprlbk2",!
do ^tprlbk2
h
xyz
$grep -i fail *.mjo*

$gtm_tst/com/dbcheck.csh "-extract"
################################################################################

\rm *.mjl*
setenv gtm_test_sprgde_id "tprlbk3"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 9 125 1000 1024 500 8192
$MUPIP set -reg "*" -journal=enable,on,before	 >&! jnl_on_${gtm_test_sprgde_id}.out
$GTM << xyz
w "do ^tprlbk3(3)",!
do ^tprlbk3(3)
h
xyz
$grep -i fail *.mjo*

################################################################################

$gtm_tst/com/dbcheck.csh "-extract"
unsetenv sub_test
