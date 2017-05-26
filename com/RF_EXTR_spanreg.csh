#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a helper script of RF_EXTR.csh.
# The primary and secondary might have different spanning regions configuration
# In that case the contents of the extract files will not be in the same order
# To avoid sorting large extract files, sort two sides of the diff file and see if they are the same

echo "# RF_EXTR_spanreg.csh : Consider differences in ordering due to spanning regions"	>>&! $rfextr_debuglog
set extfile1 = "$1"
set extfile2 = "$2"

if ( -e ${extfile1}_${extfile2}_supplinst_glodiff || -e ${extfile2}_${extfile1}_supplinst_glodiff) then
	echo "# RF_EXTR_supplinst.csh would have already taken care of sorting the glo files already. Skipping this check again"	>>&! $rfextr_debuglog
	exit 1
endif
# Switch to M mode, as multibyte unicode chars and diff dont work well in UTF-8 Mode
if ($?gtm_chset) then
	if ("UTF-8" == "$gtm_chset") then
		set switchbackchset = "$gtm_chset"
		$switch_chset M >>&! rf_extr_switch_chset.out
	endif
endif
set tmpdifffile = "${extfile1}_${extfile2}_spanreg_glodiff"
set extfile1_only = "${tmpdifffile}_${extfile1:r}_extract"
set extfile2_only = "${tmpdifffile}_${extfile2:r}_extract"
diff $extfile1 $extfile2 >&! $tmpdifffile
$grep "^< " $tmpdifffile | cut -b 3- | sort > $extfile1_only
$grep "^> " $tmpdifffile | cut -b 3- | sort > $extfile2_only
$tst_cmpsilent $extfile1_only $extfile2_only
if ($status) then
	set diffstat = 1
	echo "$extfile1 and $extfile2 failed despite a sort "			>>&! $rfextr_debuglog
	echo "Check $tmpdifffile, $extfile1_only and $extfile2_only"		>>&! $rfextr_debuglog
else
	set diffstat = 0
endif
if ($?switchbackchset) then
	$switch_chset $switchbackchset >>&! rf_extr_switch_chset.out
	unsetenv switchbackchset
endif
exit $diffstat
