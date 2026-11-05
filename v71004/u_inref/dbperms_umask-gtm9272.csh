#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-9272 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE197637272)

MUPIP CREATE gives database files permissions based on the umask setting of the target directory. Previously new database files always took 0666 as their permission regardless umask setting. (GTM-9272)

CAT_EOF
echo


echo "## Test MUPIP CREATE applies the umask to the permissions of mumps.dat."
echo "## Previously, mumps.dat would be created with permissions 666 in all cases."
set masks = "027 022 000"
set expected = "640 644 666"
set i = 1
foreach mask ($masks)
	echo
	echo "# Set umask: $mask"
	umask $mask
	echo "# Create directory: tmp$mask"
	set dir = "tmp$mask"
	mkdir $dir
	cd $dir
	echo "# Show directory permissions:"
	stat -c "%a" .
	echo "# Create a database"
	$gtm_dist/mumps -r GDE exit >& gde.out
	$gtm_dist/mupip create >& mupip.out
	echo "# Show database permissions. Expect `echo -n $expected | cut -d ' ' -f $i`. Previously, was 666."
	stat -c "%a" mumps.dat
	cd ..
	@ i = $i + 1
end
