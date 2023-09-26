#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
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

echo "max_strlen subtest"
echo "string larger than 1 MB will give error"
echo "Test if zhow v:a and zwr work after the error"

$GTM << aa
use \$principal:(wrap)
set a=0
write \$\$^longstr(1048577),!
zshow "v":a
zwr
h
aa
#
echo "Test for various string related functions with long string"

$GTM << EOF
use \$principal:(wrap)
d ^fnlgstr
EOF

$GTM << aa >& zshow.txt
use \$principal:(wrap)
d ^crelgstr
zshow "B"
zshow "C"
zshow "D"
zshow "V"
zshow "*"
aa

$GTM << aa
d ^shrnkfil("zshow.txt")
aa

echo "End of the subtest"
