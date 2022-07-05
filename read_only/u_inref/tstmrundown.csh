#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "*** Test for mupip command RUNDOWN ***"
echo ""
echo "*** TSTMRUNDOWN ***"
echo ""
# create_multi_jnl_db.csh used instead of dbcreate.csh
set verbose

$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
d in0^sfill("set",1,$1)
h
bbb
chmod 666 *.dat *.mjl

chmod.csh rwrw
echo "mupip rundown -reg * "
$MUPIP rundown -reg "*" | & sort -f
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
d in0^sfill("set",1,$1)
h
bbb
chmod.csh rwro
echo "mupip rundown -reg * "
$MUPIP rundown -reg "*" | & sort -f
mipcmanage
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
d in0^sfill("set",1,$1)
h
bbb
chmod.csh rorw
echo "mupip rundown -reg * "
$MUPIP rundown -reg "*" | & sort -f	# rundown cannot clean ipcs since .dat is read-only
chmod.csh rwrw				# give write permissions and retry rundown
$MUPIP rundown -reg "*" | & sort -f
mipcmanage				# now check ipc status
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM << bbb
d in0^sfill("set",1,$1)
h
bbb
chmod.csh roro
echo "mupip rundown -reg * "
$MUPIP rundown -reg "*" | & sort -f	# rundown cannot clean ipcs since .dat is read-only
chmod.csh rwrw				# give write permissions and retry rundown
$MUPIP rundown -reg "*" | & sort -f
mipcmanage				# now check ipc status
$gtm_tst/com/dbcheck.csh

\rm -f *.dat *.mjl mumps.gld
