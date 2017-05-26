#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cd repl2ndary
setenv gtm_repl_instance "makedmp.instance.secrepl.inst"
$gtm_dist/mumps -run makedmpd
# find core file
set coreid = `ls -1 core*`
# write core fileid to file so basic.csh knows which one is the mumps core in the 2ndry
echo $coreid > ../mumps2ndary.coreid
