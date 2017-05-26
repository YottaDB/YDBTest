$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$!								!
$!	Copyright 2002, 2014 Fidelity Information Services, Inc	!
$!								!
$!	This source code contains the intellectual property	!
$!	of its copyright holder(s), and is made available	!
$!	under a license.  If you do not know the terms of	!
$!	the license, please stop and do not read further.	!
$!								!
$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$GDE << gde_1 >& dbcreate.out
change -region DEFAULT -record_size=500
change -region DEFAULT -key_size=125
ch -seg DEFAULT -f=tst_working_dir/mumps.dat
gde_1
