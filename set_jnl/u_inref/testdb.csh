#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$GTM << aaa
d in0^sfill("set",1,1)
aaa
$gtm_tst/com/dbcheck_base.csh -nosprgde	# since parent script does a dbcheck at the very end and that will generate sprgde file
