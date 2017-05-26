#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Skip sprgde file generation/use for versions prior to V61000
if ( `expr "V61000" ">" $gtm_verno` ) then
	exit
endif

if ("GT.CM" == $test_gtm_gtcm) then
	# Spanning regions not supported with GT.CM
	exit
endif

# gtm_test_spanreg = Decimal 0 = Binary 00 => Do NOT use existing .sprgde files; Do NOT generate .sprgde files
# gtm_test_spanreg = Decimal 1 = Binary 01 => Do     use existing .sprgde files; Do NOT generate .sprgde files
# gtm_test_spanreg = Decimal 2 = Binary 10 => Do NOT use existing .sprgde files; Do     generate .sprgde files
# gtm_test_spanreg = Decimal 3 = Binary 11 => Do     use existing .sprgde files; Do     generate .sprgde files
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	# Use existing .sprgde file (if any)
	source $gtm_tst/com/findsprgdefilename.csh	# sets the var "sprgdeindir" and "sprgdefile" accordingly
	if (-e $sprgdeindir/$sprgdefile) then
		echo "! Using pre-existing GDE command file $sprgdefile. ls -l output of this file follows"
		echo "! "`ls -l $sprgdeindir/$sprgdefile`
		cat $sprgdeindir/$sprgdefile
	endif
endif
