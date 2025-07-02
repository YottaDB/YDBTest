#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
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

# dbcreate.csh called by callers.
if (! $?count) setenv count 1
set echoline = "echo ---------------------------------------------------------------"
set outfile = output_${count}.out
# set onoff and wait as c002472.m saw them:
if (! -e options.csh) echo "TEST-F-TSSERT, it should have been created"
source options.csh
rm -f options.csh
echo $onoff >! onoff.out


# analyze the PBLK records if the set's were spaced with hang's
if (0 < $sleeptime) then
	####################################################################################
	#Analyze journal extract files
	$echoline
	echo "#remove prior journal extract files..."
	rm -f *.mjf* >&! /dev/null
	echo "#do a fresh exract..."
	if (-e extract.out) mv extract.out extract_`date +%H_%M_%S`.out
	foreach file (*.mjl)
		$MUPIP journal -extract -detail -forward -fences=none $file >>&! extract.out
	end
	$grep -E ".-[EFW]-" extract.out >& /dev/null
	if (! $status) then
		$echoline
		echo "TEST-E-FAIL, Some error occured in extract"
		$echoline
		$grep -E ".-[EFW]-" extract.out
	endif
	foreach mjffile (*.mjf)
		echo "#---------------------------------------" 	>>! $outfile
		echo "#Info for ${mjffile}:"				>>! $outfile
		set cntset = `$grep "SET" $mjffile | wc -l `
		set cntepoch = `$grep "EPOCH" $mjffile | wc -l `
		set cntepochll = 0
		set ll = 25	# lower limit
		if ($cntepoch > $ll) set cntepochll = 1
		set cntpblk = `$grep "PBLK" $mjffile | wc -l `
		echo "SET count   (for ${mjffile}): $cntset" 			>>! $outfile
		echo "EPOCH count (for ${mjffile}): x, x>${ll}: $cntepochll"	>>! $outfile
		echo "PBLK count  (for ${mjffile}): $cntpblk" 			>>! $outfile
	end

endif
####################################################################################
$echoline
echo "#Analyze the block TN information..."
if (-e dse_dump_block.out) mv dse_dump_block.out dse_dump_block_`date +%H_%M_%S`.out
# the way the updates are, block numbers 3 and 5 will be updated everytime
# if the database layout changes for some reason, change these dump commands
echo "#---------------------------------------" 				>>! $outfile
echo "# block TN information"							>>! $outfile
$DSE << EOF >&! dse_dump_block.out
dump -bl=3
dump -bl=5
find -reg=DEFAULT
dump -bl=3
find -reg=BREG
dump -bl=3
find -reg=CREG
dump -bl=3
dump -bl=5
find -reg=DREG
dump -bl=3
EOF
$grep -E "Error|-E-" dse_dump_block.out  >! /dev/null
if (! $status) then
	$echoline
	echo "TEST-E-FAIL"
	$grep "Error" dse_dump_block.out
	$echoline
endif
$grep -E "Region|TN" dse_dump_block.out	| sed 's/   .*   / /g' >>! $outfile

####################################################################################
$echoline
echo "#Analyze DSE dump -fileheader information..."
echo "#---------------------------------------" 				>>! $outfile
echo "#DSE dump -fileheader information"					>>! $outfile
if (-e dse_dump_file.out) mv dse_dump_file.out dse_dump_file_`date +%H_%M_%S`.out
$DSE << EOF >&! dse_dump_file.out
dump -file -all
find -reg=DEFAULT
dump -file -all
find -reg=BREG
dump -file -all
find -reg=CREG
dump -file -all
find -reg=DREG
dump -file -all
EOF
$grep "Error" dse_dump_block.out  >! /dev/null
if (! $status) then
	$echoline
	echo "TEST-E-FAIL"
	$grep "Error" dse_dump_block.out
	$echoline
endif
# Search for GVSTAT information
$grep -E "Region| SET  : # of | GET  : # of | NTW  : # of | TTW  : # of " dse_dump_file.out >! transaction.out
cat transaction.out >>! $outfile

echo "TEST-I-OUTPUT, Relevant information is in $outfile"
$gtm_tst/com/dbcheck.csh
####################################################################################
#take a copy of things
set bak = bak${count}
mkdir $bak
mv *.out *.gld *.dat *.mj* $bak
@ counttmp = $count + 1
setenv count $counttmp
$echoline
