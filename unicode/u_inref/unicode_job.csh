#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$switch_chset UTF-8
set unidir="αβγ我ＡＢＧ玻璃而傷"
set cur_dir=`pwd`
setenv gtmgbldir "$cur_dir/ＡＢＣＤ.ＥＦＧ"

if ($gtm_test_qdbrundown) then
	echo "template -region -qdbrundown"		>>&! testspecific.gde
	echo "change -region DEFAULT -qdbrundown"	>>&! testspecific.gde
endif
cat >> testspecific.gde << CAT_EOF
change -segment DEFAULT -file_name=$cur_dir/ＡＢＣＤ.db
CAT_EOF

$GDE @testspecific.gde >&! gde.out
# Explicitly invoke create_key_file.csh since dbcreate.csh is not used.
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file.out
	# Need gtmcrypt_config to point to absolute path as ujob.m (below) is executed from a different directory.
	setenv gtmcrypt_config $PWD/gtmcrypt.cfg
endif

$MUPIP create
mkdir $unidir
\cp $gtm_tst/$tst/inref/ujob.m $unidir
#
$GTM << GTM_EOF
write "do ^unicodeJob",!
do ^unicodeJob
h
GTM_EOF
$MUPIP integ -reg "*" >& tmp.mupip
$grep "errors" tmp.mupip
if ($status != 0) cat tmp.mupip
#
#
echo cat ＡＢＣＤＥＦＧ.out : Expect No Error
cat ＡＢＣＤＥＦＧ.out
echo cat 乴亐亯仑件伞佉佷.job2 : Expect Errors
cat 乴亐亯仑件伞佉佷.job2
echo cat ＡＢＣＤＥＦＧ.job3 : Expect Errors
cat ＡＢＣＤＥＦＧ.job3
echo cat αβγ我ＡＢＧ玻璃而傷/ujob.mjo : Expect Errors
cat αβγ我ＡＢＧ玻璃而傷/ujob.mjo
echo cat αβγ我ＡＢＧ玻璃而傷/ujob.mje : Expect No Error
cat αβγ我ＡＢＧ玻璃而傷/ujob.mje
echo cat ujob.mjo : Expect No Error
cat ujob.mjo
echo cat ujob.mje : Expect No Error
cat ujob.mje
echo cat ḀḁḂḃḄḅḆḇ.jpidout.* : Expect No Error
cat ḀḁḂḃḄḅḆḇ.jpidout.*
echo cat ḀḁḂḃḄḅḆḇ.jpiderr.* : Expect Errors
cat ḀḁḂḃḄḅḆḇ.jpiderr.*
#

# make sure all the jobs have finished before quitting.
set allpids=`cat *pid $unidir/*pid | tr '\012' " "`
foreach pid ($allpids)
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 120
	if ($status) then
		echo "TEST-E-ERROR process $pid did not die."
	endif
end
echo "Done checking background jobs for completion"
