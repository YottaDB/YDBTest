#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2003, 2014 Fidelity Information Services, Inc	#
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
# C9D06-002309
# Note that some of the behavior below is not intended. We need to fix them.
# 	TR created::C9D10-002424 GTM should behave uniformly when some regions have errors but others do not
unsetenv GTM_BAKTMPDIR
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh a.dat mumps.dat ./dir1/a.dat ./dir1/mumps.dat ./dir2/mumps.dat ./dir2/a.dat>& create_key_file_dbload.out
	rm -rf *.gld >&/dev/null
endif
set verbose
\mkdir ./back1 ; \mkdir ./back2 ; \mkdir ./back3
echo "#"
echo "Test case 1 : Global directory not present : database not present : directory not present"
echo "#"
$MUPIP create
$MUPIP set -journal=enable,on,before -reg "*"
$MUPIP reorg
$MUPIP backup "*" backup.dat
$MUPIP integ -r "*"
$MUPIP set  -reg DEFAULT -exten=100
$MUPIP rundown -reg "*"
cp $gtm_tst/$tst/inref/extr.glo .
unset verbose
if ($?gtm_chset) then
	if ($gtm_chset == "UTF-8") then
		# Make extract file compatible with UTF-8 load
		mv extr.glo extr.glo1
		sed 's/GT.M MUPIP EXTRACT/& UTF-8/g' extr.glo1 > extr.glo
	endif
endif
set verbose
$MUPIP load extr.glo
$MUPIP extr extr.gbl1
$MUPIP fr -on "*"
$MUPIP fr -off "*"
echo "#"
echo "Test case 2 : Global directory present : database not present : dir1 not present but dir2 present"
echo "#"
\mkdir ./dir2
$GDE << xyz
change -segment DEFAULT -file_name=./dir1/mumps.dat
add -name a* -region=areg
add -name A* -region=areg
add -region areg -d=aseg
add -segment aseg -file_name=./dir2/a.dat
exit
xyz
$MUPIP create
$MUPIP set -journal=enable,on,before -reg "*"
$MUPIP reorg
$MUPIP backup "*" ./back1
$MUPIP integ -r "*"
$MUPIP set  -reg DEFAULT -exten=100
$MUPIP rundown -reg "*"
## For C9D10-002424 I cannot load : Layek  10/16/2003
### $MUPIP load $gtm_tst/$tst/inref/extr.glo
$MUPIP extr extr.gbl2
$MUPIP fr -on "*"
$MUPIP fr -off "*"
echo "#"
echo "Test case 3 : Global directory present : database not present : dir2 was present and now dir1 present"
echo "#"
mkdir ./dir1
$MUPIP create
$MUPIP set -journal=enable,on,before -reg "*" >& mupip_set_jnl.out
sort -f mupip_set_jnl.out
$GTM <<xyz
for i=1:1:10 s ^b(i)=i
for i=1:1:10 s ^c(i)=i
for i=1:1:10 s ^a(i)=i
h
xyz
$MUPIP reorg
$MUPIP backup "*" -nonewj ./back2 >& mupip_backup_nonewj.out
sort -f mupip_backup_nonewj.out
$MUPIP integ -r "*" >& mupip_integ_r.out
sort -f mupip_integ_r.out
$MUPIP set  -reg DEFAULT -exten=100
$MUPIP rundown -reg "*" >& mupip_rundown_r.out
sort -f mupip_rundown_r.out
$MUPIP load extr.glo
$MUPIP extr extr.gbl3
$MUPIP freeze -on "*" >& mupip_freeze_on.out
sort -f mupip_freeze_on.out
$MUPIP freeze -off "*" >& mupip_freeze_off.out
sort -f mupip_freeze_off.out
$GTM <<xyz
for i=1:1:10 s ^b(i)=i
for i=1:1:10 s ^c(i)=i
for i=1:1:10 s ^a(i)=i
h
xyz
echo "#"
echo "Test case 4 : File specification related"
echo "#"
$MUPIP integ a''d/mumps.dat
# set nonomatch to force the last parameter to be passed to mupip on all platforms
set nonomatch
$MUPIP backup "*" -nonewj .a..?..b.c/backup.dat
unset nonomatch
unset verbose
echo 'setenv ydb_baktmpdir ./bo$goue_name'
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_baktmpdir GTM_BAKTMPDIR ./bo'$'goue_name
set verbose
$MUPIP backup "*" -nonewj ./back3
unset verbose
echo 'setenv ydb_baktmpdir ./back3/mumps$$'
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_baktmpdir GTM_BAKTMPDIR ./back3/mumps'$$'
set verbose
$MUPIP backup "*" -nonewj ./back3 >& mupip_backup_nonewj_1.outx
sort -f mupip_backup_nonewj_1.outx
echo "#"
echo "Test Case 5: MUPIP JOURNAL"
echo "#"
rm -f ./dir1/*.dat
rm -f ./dir2/*.dat
$MUPIP journal -recover -for ./dir2/a.mjl,./dir1/mumps.mjl
$MUPIP crea
rm -f ./dir1/*.dat;
$MUPIP journal -recover -for ./dir2/a.mjl
$GTM <<xyz
ZWR ^a,^b,^c
h
xyz
$MUPIP integ ./dir2/a.dat
unset verbose
source $gtm_tst/com/unset_ydb_env_var.csh ydb_baktmpdir GTM_BAKTMPDIR
