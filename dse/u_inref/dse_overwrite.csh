#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
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

# Test dse -overwrite command

echo "TEST DSE - OVERWRITE COMMAND "
#create a global directory with two regions -- DEFAULT, REGX
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv gtm_test_use_V6_DBs 0   # Disable V6 DB mode as it causes changes in output of DSE commands (block #s/versions, offsets, etc)
$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# test the basic overwrite command
# additionally test that dse is able to update database even if db is frozen

$MUPIP freeze -on DEFAULT
$DSE << DSE_EOF

find -reg=DEFAULT
overwrite -block=3 -data="datahave" -off=45
dump -bl=3 -off=33 -hea

DSE_EOF
$MUPIP freeze -off DEFAULT

# try giving too small and too large offsets

$DSE << DSE_EOF

find -reg=DEFAULT
overwrite -block=3 -data="king" -off=0
overwrite -block=3 -data="king" -off=2933

DSE_EOF

# try with block zero
# additionally test that errors while dumping -bl=0 do not leave dse holding the crit lock unintentionally

$DSE << DSE_EOF

find -reg=DEFAULT
save -bl=0
overwrite -data="as" -off=10
crit -all
dump -bl=0
crit -all
restore -bl=0 -ver=1

DSE_EOF

# do same test as above except use crit -seize before that; in this case, dse should keep holding onto crit
# also test that even if we dont do crit -release, dse halts out fine.

$DSE << DSE_EOF
crit -seize
save -bl=0
overwrite -data="as" -off=10
dump -bl=0
crit -all
restore -bl=0 -ver=1
DSE_EOF

# miss the data component value

$DSE << DSE_EOF

find -reg=DEFAULT
find -bl=3
overwrite -data="" -offset=45

DSE_EOF

# miss one of the qualifiers

$DSE << DSE_EOF

find -reg=DEFAULT
find -bl=3
overwrite -data="king"
overwrite -offset=23

DSE_EOF

echo "# Test that MUPIP JOURNAL EXTRACT shows the DSE commands as AIMG records"
# Extracting from mumps.mjl and a.mjl
if ($?test_replic == 1) then
	foreach mjl( *.mjl )
		$ydb_dist/mupip journal -extract -detail -forward $mjl >>& extr_report.txt
		cat $mjl:r.mjf | grep "AIMG" | awk -F\\ '{print "AIMG "$11}'
	end
endif

# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
