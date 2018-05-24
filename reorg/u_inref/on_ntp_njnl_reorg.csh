#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Enabling this setting slows down solaris massively. We have seen it take over 5 hours.
if ("sunos" == "$gtm_test_osname") then
	unsetenv gtmdbglvl
        echo "# Disable gtmdbglvl because it slows down solaris massively" >> settings.csh
	echo "unsetenv gtmdbglvl" >> settings.csh
endif
set shorthost = $HOST:ar
# on pfloyd, eotf + the regular reorgs slows down the mumps updates noticeably. The subtest takes over 5 hours to run.

if ($shorthost =~ {pfloyd}) then
	setenv gtm_test_do_eotf 0
endif

$gtm_exe/mumps $gtm_tst/com/pfill.m
$gtm_tst/com/dbcreate.csh "mumps" 8 255 1000
$GTM << \aaa
w "do ^manygbls"  do ^manygbls
w "do in0^dbfill(""set"")"  do in0^dbfill("set")
w "do in0^dbfill(""ver"")"  do in0^dbfill("ver")
w "do in0^dbfill(""kill"")"  do in0^dbfill("kill")
w "do in1^dbfill(""set"")"  do in1^dbfill("set")
w "do in1^dbfill(""ver"")"  do in1^dbfill("ver")
w "do in1^dbfill(""kill"")"  do in1^dbfill("kill")
w "do in2^dbfill(""set"")"  do in2^dbfill("set")
w "do in2^dbfill(""ver"")"  do in2^dbfill("ver")
w "do ^rinttp(1)"  do ^rinttp(1)
w "do ^rinttp(2)"  do ^rinttp(2)
w "do ^rinttp(3)"  do ^rinttp(3)
w "do in0^pfill(""kill"",1)"  do in0^pfill("kill",1)
w "do in2^dbfill(""kill"")"  do in2^dbfill("kill")
w "do fill3^myfill(""set"")"  do fill3^myfill("set")
w "do fill3^myfill(""ver"")"  do fill3^myfill("ver")
w "do fill3^myfill(""kill"")"  do fill3^myfill("kill")
w "do fill4^myfill(""set"")"  do fill4^myfill("set")
w "do fill4^myfill(""ver"")"  do fill4^myfill("ver")
w "do fill4^myfill(""kill"")"  do fill4^myfill("kill")
w "do in4^sfill(""set"",1,8)"  do in4^sfill("set",1,8)
w "do in4^sfill(""ver"",1,8)"  do in4^sfill("ver",1,8)
w "do in4^sfill(""kill"",1,8)"  do in4^sfill("kill",1,8)
h
\aaa
$gtm_tst/com/dbcheck.csh "-extract"
