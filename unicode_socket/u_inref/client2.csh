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
echo ENTERING SOCKET CLIENT2
#
#
$GTM << \doclient2
d ^client2
s ^client2done=1
h
\doclient2
#
#
echo LEAVING SOCKET CLIENT2
#
#
