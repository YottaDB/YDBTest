#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-8371 [nars] SIG-11 in $QUERY(lvn) after ZSHOW "V":lvn when no variables exist
#

foreach value ("x" "x(1)" "x(1,2,3,4)")
	echo "Test ZSHOW V:$value"
	$GTM << GTM_EOF
		ZSHOW "V":$value
		write "\$query($value) = ",\$query($value),!
GTM_EOF

end
