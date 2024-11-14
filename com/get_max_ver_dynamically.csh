#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#  Find the maximum applicable version depending on the paramater passed

if ($1 == "") then
	echo "TEST-E-NOPARAM Must pass the switch for which the maximum version is to be found"
	exit 1
endif

set cnt = $numvers
set curr_ver = $tst_ver
switch ($1)
	case "dbminver_mismatch":
		# Need the awkward gdsdbver*.h because the enum in gdsdbver.h was pushed into gdsdbver_sp.h starting V63000
		alias getlabel '$tst_awk '"'"'/GDSMVLAST/{if(length(min)){print min;exit}} /GDSMV[567][0-9]+[A-Z]*/{sub(/ENUM_ENTRY./,"",$1);sub(/[^0-9A-Z]*,$/,"",$1);min=$1}'"'"' $gtm_root/\!:1/inc/gdsdbver*.h'
	breaksw
	case "shlib_mismatch":
	case "obj_mismatch":
		alias getlabel 'sed -n '"'"'s/#[ 	]*define[ 	]*OBJ_UNIX_LABEL[ 	]*\([0-9][0-9]*\).*/\1/p'"'"' $gtm_root/\!:1/inc/objlabel.h'
	breaksw
	case "gld_mismatch":
		alias getlabel '$tst_awk '"'"'/#define GDE_LABEL_LITERAL/ {gsub(/[()"]/," ") ; print $NF}'"'"' $gtm_root/\!:1/inc/gbldirnam.h'
	breaksw
endsw
set curr_label=`getlabel $curr_ver`
while ($cnt > 0)
	set test_ver = $actualverlist[$cnt]
	set prev_label=`getlabel $test_ver`
	if ( $curr_label != $prev_label ) then
		break
	else
		@ cnt = $cnt - 1
	endif
end
if ($cnt != 0) then
	set maximum = $test_ver
else
	echo "RANDOMVER-E-CANNOTRUN : Could not determine previous version matching the given criteria. Exiting.."
	exit -1
endif
