#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

#trigzintrpt
#
#trigzintrpt, verify correct trigger behavior when contained in $zinterrupt
#

$gtm_tst/com/dbcreate.csh mumps 1

cat > trigzintrpt.trg << TFILE
+^a -command=set -xecute="set ^b=\$ZTVALUE-1 set ^c=\$ZTVALUE+1 set ^save=\$ZJOBEXAM()"
TFILE

cat > trigintrpt.m << MPROG
trigintrpt
	; define \$ZINTERRUPT to execute \$ZJOBEXAM and modify ^a to fire a trigger
	set \$ZINTERRUPT="if \$ZJOBEXAM()'="""" set ^a=4"
	write \$ZINTERRUPT,!
	; modify ^a to fire the trigger output of \$ZINTERRUPT
	set ^a=3
	write "After direct set of ^a to 3, ^a= ",^a," ^b= ",^b," ^c= ",^c,!
	; check to see if valid file zshow file was created
	if ^save'["YDB_JOBEXAM" write "\$ZJOBEXAM = ",^save,!
	; cleanup globals
	zsystem "mupip intrpt "_\$job
	write "After modification of ^a in \$ZINTERRUPT, ^a= ",^a," ^b= ",^b," ^c= ",^c,!
	; check to see if valid file zshow file was created
	if ^save'["YDB_JOBEXAM" write "\$ZJOBEXAM = ",^save,!
	quit
MPROG
$load trigzintrpt.trg "" -noprompt
$show

$echoline
echo "output from trigintrpt M routine"
$echoline
echo ""

$gtm_exe/mumps -run trigintrpt

echo ""
$echoline
echo ""

$echoline
echo 'extract relevant trigger information from the 3 YDB_JOBEXAM... files created by $ZJOBEXAM'
$echoline
echo ""
set cnt = 1
while ($cnt < 4)
	$tst_awk '/TLEVEL=|ZTLEVEL|ZTOLDVAL|ZTRIGGEROP=|ZTVALUE=/{printf "%s ",$1}' YDB_JOBEXAM*_$cnt
	echo ""
	@ cnt = $cnt + 1
end
echo ""
$echoline
echo ""
$gtm_tst/com/dbcheck.csh -extract

# do the following if its replic
# we expect the extracts to be different, because the ^save is a copy of the local version of \$ZJOBEXAM
# which is fired via triggers on both machines.  There will only be 2 YDB_JOBEXAM... files in the remote directory
# as the second one on the primary is caused by \$ZINTERRUPT which will not occur on the secondary.  That code
# in turn sets ^a to 4 which will then fire the trigger on both systems.  This will result in the 3rd YDB_JOBEXAM...
# file on the primary and the second one on the secondary.  We will expect the first 3 lines in the .glo files
# to be the same.
if ($?test_replic == 1) then
	echo ""
	$echoline
	echo "test that the globals (other than ^save) are the same on primary and secondary"
	$echoline
	$head -n 3 pri*.glo > pri.out
	$head -n 3 sec*.glo > sec.out
	diff pri.out sec.out
endif
