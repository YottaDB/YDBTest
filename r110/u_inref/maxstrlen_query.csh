#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# Test that $query(lvn) never returns a string whose length is > MAX_STRLEN (1Mb)'
echo ""
echo '# Test of $query(lvn,1)'
$GTM << GTM_EOF
	set z="1" for i=1:1:16 kill x set x(z,z)="",z=\$query(x) write "i = ",i," : \$zlength(z)=",\$zlength(z),!
GTM_EOF

echo '# Test of $query(lvn,-1)'
$GTM << GTM_EOF
	set z="1" for i=1:1:16 kill x set x(z,z)="",z=\$query(x("z"),-1) write "i = ",i," : \$zlength(z)=",\$zlength(z),!
GTM_EOF

