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
pwd
mkdir bak
cd bak
mkdir bak
mkdir baktmp
mkdir tmpdir
cd ..
setenv gtmgbldir `pwd`/mumps.gld
cp $gtm_tst/$tst/u_inref/gde_$acc_meth.txt gde_base.txt

sed "s,PWD,`pwd`,g" gde_base.txt > gde.txt
setenv test_specific_gde  gde.txt
$gtm_tst/com/dbcreate_base.csh .
