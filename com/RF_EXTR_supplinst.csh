#!/usr/local/bin/tcsh
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

echo "# RF_EXTR_supplinst.csh : Consider updates that can be in only in the supplementary instance side if appropriate"	>>&! $rfextr_debuglog
set extractx = $1
set extracty = $2

set inst_numx = `echo $extractx | sed 's/\(.*\)_.*_.*_.*_.*/\1/' | sed 's/[a-zA-Z]*//'`
set inst_numy = `echo $extracty | sed 's/\(.*\)_.*_.*_.*_.*/\1/' | sed 's/[a-zA-Z]*//'`
set is_suppx = `eval echo '$'gtm_test_msr_SUPP$inst_numx`
set is_suppy = `eval echo '$'gtm_test_msr_SUPP$inst_numy`
set ret = 1

if ("trg" == "$extractx:e") then
	# imptp.csh randomly installs or deletes the trigger triggernameforinsertsanddels
	# depending on the randomnes, it might be present in any side (not just the supplementary side)
	# remove that trigger before comparing
	$grep -vE "triggernameforinsertsanddels" $extractx >&! ${extractx}.tmp
	$grep -vE "triggernameforinsertsanddels" $extracty >&! ${extracty}.tmp
	set extractx = ${extractx}.tmp
	set extracty = ${extracty}.tmp
endif

# Check if a supplementary instance is involved with a non-supplementary instance.
# In that case, we need to discard all updates that were generated on a supplementary instance
# To make things simple, we consider that the supplementary instance should only have additional entries.
# So if values differ or some entries are missing, it is a failure.
# Note : Technically values can differ, but none of our tests (mostly imptp) updates the same global
# with different values in the two sides. If such a test comes up, it needs to be handled
if (("TRUE" == "$is_suppx" || "TRUE" == "$is_suppy") && ("$is_suppx" != "$is_suppy")) then
	if ("TRUE" == "$is_suppx") then
		set ldiff = $extractx
		set rdiff = $extracty
	else
		set ldiff = $extracty
		set rdiff = $extractx
	endif
	echo "# $ldiff is the supplementary side"				>>&! $rfextr_debuglog
	set difffile = "${ldiff}_${rdiff}_supplinst_glodiff"
	diff $ldiff $rdiff >&! $difffile
	if (0 == $status) then
		set ret = 0
	else
		# Extract ldiff only lines and rdiff only lines into two files, removing the < and >
		set ldiff_only = "${difffile}_${ldiff:r}_extract"
		set rdiff_only = "${difffile}_${rdiff:r}_extract"
		set suppl_diff = "${difffile}_${rdiff:r}_only"
		$grep '^< ' $difffile | cut -b 3- | sort >&! $ldiff_only
		$grep '^> ' $difffile | cut -b 3- | sort >&! $rdiff_only
		# Ignore common lines (-3) and lines only in ldiff i.e suppl side (-1)
		comm -13 $ldiff_only $rdiff_only >&! $suppl_diff
		# If there are lines that are not common and not unique to rdiff, extract failed
		if (! -z $suppl_diff) then
			set ret = 1
			echo "$rdiff (non-suppl) has entries that isn't found in $ldiff (suppl)"	>>&! $rfextr_debuglog
			echo "Check $ldiff_only, $rdiff_only, & $suppl_diff"				>>&! $rfextr_debuglog
		else
			set ret = 0
		endif
	endif
else
	echo "# None of the sides are supplementary."				>>&! $rfextr_debuglog
endif

exit $ret
