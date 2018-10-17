#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

foreach cmdfile ($gtm_tst/$tst/inref/gde*.cmd)
	set file = "$cmdfile:t:r"
	echo "# Testing $file"
	setenv gtmgbldir "${file}.gld"
	# Make NOSTDNULLCOLL as the default region template as this test relies on that. Hence the NOSTDNULLCOLL usage below.
	$GDE << GDE_EOF >& $file.outx
	change -region DEFAULT -nostdnullcoll
	template -region -nostdnullcoll
	@$cmdfile
	exit
GDE_EOF

	set reference = "$gtm_tst/$tst/outref/$file.txt"
	$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk $file.outx $reference >&! $file.cmp
	diff $file.cmp $file.outx >& $file.diff
	if ($status) then
		echo " FAILED. See $file.diff"
	else
		rm -f $file.diff
		echo "# $file PASSED"
	endif
	if (-e $gtmgbldir) then
		echo "# Checking if gde show -commands produce identical .gld file"
		set cmdfile = "${file}_show.cmd"
		$GDE show -commands -file="$cmdfile" >&! ${file}_showcmd.out
		$GDE << GDE_EOF >&! ${file}_showallold.out
		log -on="${file}_old.log"
		show -all
		log -off
GDE_EOF

		mv $gtmgbldir ${gtmgbldir}.bak
		$GDE @$cmdfile >&! ${file}_createnew.out
		$GDE << GDE_EOF >&! ${file}_showallnew.out
		log -on="${file}_new.log"
		show -all
		log -off
GDE_EOF

		$gtm_tst/com/gdeshowdiff.csh ${file}_old.log ${file}_new.log
		if ( $status) then
			echo "gde show -commands, failed to create identical global directory file"
			echo "check $cmdfile , ${file}_old.log and ${file}_new.log"
		endif
	endif
end
