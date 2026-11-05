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
GTM-9833 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE197637833)

\$STORAGE reports the correct value when there is a restriction on the data segment limit (RLIMIT_DATA) of a process. Previously, \$STORAGE inappropriately returned 2GiB in such a case. (GTM-9833)

CAT_EOF
echo

echo '# $STORAGE is the data segment size limit (RLIMIT_DATA) minus the memory YottaDB has allocated,'
echo '# which $ZREALSTOR reports, so $STORAGE+$ZREALSTOR should equal the limit in bytes.'

set i = 1
foreach size (16384 32768 65536 131072)
	@ bytes = $size * 1024
	echo
	echo "# Case ${i}: Set the data segment size limit (RLIMIT_DATA) to $size KiB"
	echo '# Run [$gtm_dist/mumps -run %XCMD '"'"'write "$STORAGE+$ZREALSTOR=",$storage+$zrealstor,!'"'"']'
	echo "# Expect ${bytes}. Previously, 2147483647."
	( limit datasize $size ; $gtm_dist/mumps -run %XCMD 'write "$STORAGE+$ZREALSTOR=",$storage+$zrealstor,!' )
	@ i = $i + 1
end
