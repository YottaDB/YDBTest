#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
echo ENTERING SOCKET SERVER2
#
#
$GTM << \doserver2
d ^server2(0)
h 3
d ^server2(2)
h 3
d ^server2(4)
h
\doserver2
#
#
echo LEAVING SOCKET SERVER2
#
#
