#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$gtm_tst/com/dbcreate.csh mumps 1

# Testing the new ISVs
# 1. View ISVs outside of the trigger
# 2. Validate ability to write ISV outside of trigger
# 3. View ISVs inside of the trigger
# 4. Validate ability to write ISV inside of trigger

echo "Checks ISVs outside of the trigger"

# 0. Ensure that the ISV short and long names resolve correctly
echo "Check ISV name resolution"
$tst_awk '/^.set .ZT/ {isv=$2; sub(/=.*$/,"",isv);print isv}' $gtm_tst/$tst/inref/inspectISV.m > isv.list
$convert_to_gtm_chset isv.list
$gtm_exe/mumps $gtm_tst/$tst/inref/genisvtestcases.m
$gtm_exe/mumps -run genisvtestcases
$gtm_exe/mumps isv.m |& $grep -c '%GTM-E-SVNOSET'
if ($?test_replic == 1) then
	if ($tst_org_host == $tst_remote_host) then
		cp isv.m $SEC_SIDE/
	else
		$rcp isv.m "$tst_remote_host":$SEC_SIDE/
	endif
endif

touch -t "200001010000.00" *.m >& /dev/null

# 1. View ISVs outside of the trigger
echo "====================================================="
echo "1. View ISV"
$gtm_exe/mumps $gtm_tst/$tst/inref/twork.m
$gtm_exe/mumps -run twork

# 2. Validate ability to write ISV outside of trigger
echo "====================================================="
echo "2. ISV compile"
$gtm_exe/mumps $gtm_tst/$tst/inref/inspectISV.m
echo "====================================================="
echo "2.5 ISV Inspection"
$gtm_exe/mumps -run inspectISV

# 3. View ISVs inside of the trigger
echo "====================================================="
echo "3. View ISVs inside of the trigger"
cat > view.trg << TFILE
-*
+^isv -command=S -xecute="do ^twork" -name=isvtwork
+^isv2 -command=S -xecute="do ^twork" -name=isv2twork -delim=\$char(58)
+^isv3 -command=S -xecute="do ^twork" -delim=\$char(32) -piece=2:4;6 -name=isv3pdelimtwork
+^isv4 -command=S -xecute="do ^twork set \$ZTVAlue=42 do ^twork" -name=isv4xecute
+^isv -command=S -xecute="do ^isv" -name=isvisv
+^isv2 -command=S -xecute="do ^isv" -name=isv2isv -delim=\$char(58)
+^isv3 -command=S -xecute="do ^isv" -delim=\$char(32) -piece=2:4;6 -name=isv3pdelimisv
+^isv4 -command=S -xecute="do ^isv" -name=isv4isv
TFILE
$load view.trg "" -noprompt
echo "3.1"
$GTM << DONUT
set ^etrapquiet=1
kill ^isv set ^isv=42
kill ^isv set ^isv=42
set ^isv=420
DONUT

echo "3.2"
$GTM << DONUT
kill ^isv2
set ^isv2="1:2:3:4:5:6:7:8:9"
DONUT

echo "3.3"
$GTM << DONUT
kill ^isv3
set ^isv3="1 2 3 4 5 6 7 8 9 SET ONLY"
DONUT

echo "3.4"
$GTM << DONUT
kill ^isv4
set ^isv4=99 zwrite ^isv4
set ^isv4="The meaning of life and everything" zwrite ^isv4
set ^isv5="I have not triggered because I don't have a trigger NO SHOW"
DONUT

# 4. Validate ability to write ISV inside of trigger
# applies to $etrap, $ztwormhole, $ztslate and $ztvalue only
echo "====================================================="
echo "4. ISV Inspection inside trigger"
cat > isv.trg << TFILE
+^isv -command=S,K -xecute="do ^inspectISV" -name=isvinspect
+^isv2 -command=S,ZK -xecute="do ^inspectISV" -delim=\$char(58) -name=isv2deliminspect
+^isv3 -command=S,K -xecute="do ^inspectISV" -delim=\$char(32) -piece=2:4;6 -name=isv3pdeliminspect
+^isv4 -command=S,ZK -xecute="do ^inspectISV" -name=isv4inspect
;+^isv5 -command=K -xecute="do ^inspectISV" -name=isv5inspect
TFILE
$convert_to_gtm_chset isv.trg
$GTM << DONUT
; Gratuitous use of ztrigger
set file="isv.trigout"
set trigline="+^isv5 -command=K -xecute=""do ^inspectISV"" -name=isv5inspect"
open file:newversion
use file
if '\$ztrigger("file","isv.trg") use \$p write "Failed to load isv.trg",!
use file
if '\$ztrigger("item",trigline) use \$p write "Failed to load trigger for ^isv5",!
close file
DONUT
echo "4"
$GTM << DONUT
set ^isv5="I will trigger only KILL NO SHOW"
zkill ^isv5
kill ^isv5
set ^isv5="I will trigger only KILL"
kill ^isv5
DONUT
echo "4.1"
$GTM << DONUT
kill ^isv set ^isv=99
kill ^isv set ^isv=54
set ^isv=42
write \$test,\$char(9),\$Reference
zwrite ^isv
do ^twork
DONUT

echo "4.2"
$GTM << DONUT
kill ^isv2
set ^isv2="1:2:3:4:5:6:7:8:9"
write \$test,\$char(9),\$Reference
zwrite ^isv2
do ^twork
zkill ^isv2
DONUT

echo "4.3"
$GTM << DONUT
zkill ^isv3
set ^isv3="1 2 3 4 5 6 7 8 9"
write \$test,\$char(9),\$Reference
zwrite ^isv3
do ^twork
kill ^isv3
DONUT

echo "4.4"
$GTM << DONUT
kill ^isv4
set ^isv4=99
zwrite ^isv4
set ^isv4="The meaning of life and everything"
zwrite ^isv4
write \$test,\$char(9),\$Reference
do ^twork
zkill ^isv4
DONUT

$gtm_tst/com/dbcheck.csh -extract
