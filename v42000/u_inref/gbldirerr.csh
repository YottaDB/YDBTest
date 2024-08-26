#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtmgbldir gtmgbldir.gld
$GDE << GDE_EOF
exit
GDE_EOF
#
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif

$MUPIP create
#
$GTM << GTM_EOF
s ^val("one")=1
h
GTM_EOF
#
setenv gtmgbldir ""
$GTM << GTM_EOF
s ^val("two")=2
h
GTM_EOF
#
unsetenv gtmgbldir
$GTM << GTM_EOF
s ^val("three")=3
h
GTM_EOF
#
setenv gtmgbldir gtmgbldir.gld
$GTM << GTM_EOF
s ^val("four")=4
set \$zgbldir="foo.gld"
s ^val("five")=5
h
GTM_EOF
#
setenv gtmgbldir foo.gld
$GTM << GTM_EOF
s ^val("six")=6
set \$zgbldir="gtmgbldir.gld"
s ^val("seven")=7
h
GTM_EOF
#
setenv gtmgbldir gtmgbldir.gld
$GTM << GTM_EOF
zwr ^val
h
GTM_EOF
#
echo "Now test mupip functions:"
echo "setenv gtmgbldir foo.gld"
setenv gtmgbldir foo.gld
$MUPIP backup DEFAULT bak.dat
$MUPIP integ -reg "*"
$MUPIP freeze -on "*"
$MUPIP rundown -reg "*"
$MUPIP set -journal=enable,on,before -reg "*"
#
echo "unsetenv gtmgbldir"
unsetenv gtmgbldir
$MUPIP backup DEFAULT bak.dat
$MUPIP integ -reg "*"
$MUPIP freeze -on "*"
$MUPIP rundown -reg "*"
$MUPIP set -journal=enable,on,before -reg "*"
