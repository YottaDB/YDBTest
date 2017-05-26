#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# the script checks the journaled data for database regions set with stdnullcoll & nostdnullcoll qualifiers.
#
# create database with two regions
$GDE << GDE_EOF
add -name a* -region=AREG
add -region AREG -dyn=ASEG -null_subscripts=ALWAYS -stdnullcoll
add -segment ASEG -file=a.dat
change -region default -dyn=default -null_subscripts=ALWAYS -nostdnullcoll
exit
GDE_EOF

if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif

$MUPIP create  >>&! mpcreate.out
# turn on journaling
$MUPIP set -journal=enable,on,before -reg AREG
$MUPIP set -journal=enable,on,before -reg DEFAULT
if ($status) then
        echo "TEST-E-JOURNAL ERROR from $MUPIP JOURNAL"
        exit 3
endif
# set some globals
$GTM << GTM_EOF
do two^varfill
zwrite ^aforavariable,^iamdefault
halt
GTM_EOF

# extract the journaled data
$MUPIP journal -extract=mumps.mjf -forward mumps.mjl,a.mjl
if ($status) then
        echo "TEST-E-EXTRACT ERROR from $MUPIP JOURNAL"
        exit 3
endif
# pullout the globals from mjf file
cat mumps.mjf | $grep "\^" | sed 's/.*\^/\^/g' | sort >&journvar.out
#
# extract the database to verify against the journaled data
$MUPIP extract db.glo >& extr.out
# pullout the globals from glo file
$tst_awk '/^\^/ {start=1} start {print}' db.glo | sort >& dbvar.out
diff dbvar.out journvar.out
# verfiy the data extracted from the database as against the mjf file. # for a sure check, also verify the count of globals.
# in this case it is 8.
#
if ($status || 8 != `cat mumps.mjf | $grep "\^" | sed 's/.*\^/\^/g' |wc -l`) then
	echo "TEST-E-ERROR data incosistency in journaling"
else
	echo ""
	echo "JOURNAL RECOVERY SUCCESSFUL"
endif
#
