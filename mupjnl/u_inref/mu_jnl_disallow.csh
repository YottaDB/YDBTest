#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information		#
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
# related to C9C02-001922
echo "Will test various disallowed mupip parameter sets."
echo "Since all commands in this script are disallowed, none will run,"
echo "hence no database is necessary "
echo "=============================================================="
set echo

#DISALLOW NOT (recover OR verify OR show OR extract OR rollback)
$MUPIP journal							#RECOVER VERIFY SHOW EXTRACT ROLLBACK

#DISALLOW recover and rollback
$MUPIP journal -recover -rollback				#RECOVER ROLLBACK			#BYPASSOK("-rollback")

#DISALLOW NOT (forward OR backward)
$MUPIP journal -recover						#FORWARD BACKWARD

#DISALLOW forward AND backward
$MUPIP journal -recover -forward -backward			#FORWARD BACKWARD

#DISALLOW since AND forward
$MUPIP journal -recover -forward -since=\"0 00:00:01\"		#SINCE FORWARD

#DISALLOW lookback_limit AND forward
$MUPIP journal -recover -forward -lookback_limit=\"time=0 00:00:01\"	#LOOKBACK_LIMIT FORWARD

#DISALLOW checktn AND backward
$MUPIP journal -recover -backward -checktn			#CHECKTN BACKWARD

#DISALLOW resync AND fetchresync
$MUPIP journal -rollback -back -resync=1 -fetchresync=2		#RESYNC FETCHRESYNC			#BYPASSOK("-rollback")

#DISALLOW (resync OR fetchresync OR online) AND NOT(rollback)
$MUPIP journal -recover -resync=1 -back -lost=x.lost		#RESYNC ROLLBACK
$MUPIP journal -recover -fetchresync=1 -back -lost=x.lost	#RESYNC FETCHRESYNC ROLLBACK
$MUPIP journal -recover -online -back -lost=x.lost		#RESYNC FETCHRESYNC ONLINE ROLLBACK

#DISALLOW (fetchresync OR online) AND forward
$MUPIP journal -rollback -fetchresync=1 -forward		#FETCHRESYNC FORWARD			#BYPASSOK("-rollback")
$MUPIP journal -rollback -online -forward			#FETCHRESYNC ONLINE FORWARD		#BYPASSOK("-rollback")

#DISALLOW rsync_strm AND NOT(resync)
$MUPIP journal -rollback -backward -rsync_strm=1		#RSYNC_STRM RESYNC			#BYPASSOK("-rollback")

#DISALLOW rsync_strm AND forward
$MUPIP journal -rollback -forward -resync=2 -rsync_strm=1	#RSYNC_STRM FORWARD			#BYPASSOK("-rollback")

#DISALLOW losttrans AND NOT(recover OR rollback OR extract)
$MUPIP journal -show -losttrans=1 -back				#LOSTTRANS RECOVER ROLLBACK
$MUPIP journal -verify -losttrans=1 -back			#LOSTTRANS RECOVER ROLLBACK

#DISALLOW brokentrans AND NOT(recover OR rollback OR extract)
$MUPIP journal -show -brokentrans=mumps.brk -back		#BROKENTRANS RECOVER ROLLBACK
$MUPIP journal -verify -brokentrans=mumps.brk -back		#BROKENTRANS RECOVER ROLLBACK

#DISALLOW full AND (recover OR rollback)
$MUPIP journal -recover -extract -full -forward			#FULL RECOVER
$MUPIP journal -rollback -extract -full -forward		#FULL RECOVER ROLLBACK			#BYPASSOK("-rollback")

#DISALLOW detail AND NOT extract
$MUPIP journal -show -detail -forward				#DETAIL EXTRACT

#DISALLOW after and NOT forward
$MUPIP journal -show -after=\"-- 18:00:00\" -back		#AFTER FORWARD

#DISALLOW after and (recover OR rollback)
$MUPIP journal -recover -after=\"-- 18:00:00\" -forward		#AFTER RECOVER
$MUPIP journal -rollback -after=\"-- 18:00:00\" -forward	#AFTER RECOVER ROLLBACK			#BYPASSOK("-rollback")

#DISALLOW lookback_limit AND NOT (verify OR recover OR extract OR show)
$MUPIP journal -rollback -backward -lookback								#BYPASSOK("-rollback")

#DISALLOW apply_after_image and NOT (recover or rollback)
$MUPIP journal -verify -backward -apply_after_image		#APPLY_AFTER_IMAGE ROLLBACK RECOVER
$MUPIP journal -show -backward -apply_after_image		#APPLY_AFTER_IMAGE ROLLBACK RECOVER
$MUPIP journal -extract -backward -apply_after_image		#APPLY_AFTER_IMAGE ROLLBACK RECOVER

#DISALLOW redirect AND NOT recover
$MUPIP journal -rollback -backward -redirect="bgdbb.dat=test.dat"	#REDIRECT RECOVER		#BYPASSOK("-rollback")
$MUPIP journal -extract -backward -redirect="bgdbb.dat=test.dat"	#REDIRECT RECOVER
$MUPIP journal -verify -backward -redirect="bgdbb.dat=test.dat"		#REDIRECT RECOVER
$MUPIP journal -show -backward -redirect="bgdbb.dat=test.dat"		#REDIRECT RECOVER

#DISALLOW redirect AND backward
$MUPIP journal -recover -backward -redirect="(bgdbb.dat=test.dat)"	#REDIRECT BACKWARD

#DISALLOW backward AND NEG chain
$MUPIP journal -recover -backward -nochain			#BACKWARD CHAIN

#DISALLOW rollback AND (after OR lookback_limit)
$MUPIP journal -rollback -after=\"1 0:18:00\" -forward		#AFTER RECOVER ROLLBACK			#BYPASSOK("-rollback")
$MUPIP journal -rollback -extract -backward -lookback_limit	#ROLLBACK AFTER LOOKBACK_LIMIT		#BYPASSOK("-rollback")

#DISALLOW (global OR user OR id OR process OR transaction) AND (recover OR rollback OR verify)
$MUPIP journal -recover -global=\"^a\" -backward
$MUPIP journal -rollback -global=\"^a\" -backward							#BYPASSOK("-rollback")
$MUPIP journal -verify -global=\"^a\" -backward
$MUPIP journal -recover -user=gtmtest -backward
$MUPIP journal -rollback -user=gtmtest -backward							#BYPASSOK("-rollback")
$MUPIP journal -verify -user=gtmtest -backward
$MUPIP journal -recover -id=1234 -backward
$MUPIP journal -rollback -id=1234 -backward								#BYPASSOK("-rollback")
$MUPIP journal -verify -id=1234 -backward
$MUPIP journal -recover -transaction=kill -backward
$MUPIP journal -rollback -transaction=kill -backward							#BYPASSOK("-rollback")
$MUPIP journal -verify -transaction=kill -backward

unset echo
echo "=============================================================="

unsetenv test_replic
$gtm_tst/com/dbcreate.csh . 2
echo "Turn journaling on..."
$gtm_tst/com/jnl_on.csh
set echo
#-file-list should not be * for -REDIRECT
$MUPIP journal -recover -forward -redirect="bgdbb.dat=test.dat" "*"
#%GTM-I-STARFILE, Star argument cannot be be specified with REDIRECT qualifier,
#%YDB-E-MUPCLIERR,

#-file-list should be * for ROLLBACK
$MUPIP journal -rollback -back -lost=1 a.mjl								#BYPASSOK("-rollback")
unset echo
$gtm_tst/com/dbcheck.csh

#Star qualifier should be specified for ROLLBACK
#%YDB-E-MUNOACTION, MUPIP unable to perform requested action
