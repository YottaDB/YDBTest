#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test that undefined lvn in SET lvn=$FNUMBER stays undefined if $FNUMBER errors out (FNARGINC error).'
echo '# Expect LVUNDEF for x in zwrite output below. Without YDB#830 fixes, it used to show up as 0.'
$GTM << GTM_EOF
set x=\$fnumber("abcd","PT")
zwrite x
GTM_EOF

echo '# Test that defined lvn in SET lvn=$FNUMBER stays unmodified if $FNUMBER errors out (FNARGINC error).'
echo '# Expect x=20.45 in zwrite output below. Without YDB#830 fixes, it used to show up as 0.'
$GTM << GTM_EOF
set x=20.45
set x=\$fnumber("abcd","PT")
zwrite x
GTM_EOF

