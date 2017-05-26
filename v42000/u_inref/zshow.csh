#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << EOF
d sub33^zshow
d sub32^zshow
d sub31^zshow
d sub30^zshow
d gbl64^zshow
if ""'=\$reference write !,"\$REFERENCE should be empty, but is: ",\$reference
EOF
$gtm_tst/com/dbcheck.csh
