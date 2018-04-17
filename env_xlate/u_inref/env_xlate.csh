#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# prepare the databases:
#setenv GTM "$gtm_exe/mumps -direct"
#setenv gtm_tst $gtm_test/V990/
#setenv test_reorg "NON_REORG"
#setenv tst env_xlate
#setenv gtmroutines ". /usr/library/V990/dbg $gtm_tst/env_xlate/inref"
#unsetenv ydb_env_translate
#setenv tst_working_dir `pwd`
#rm *.o
#rm *.so

source $gtm_tst/com/unset_ydb_env_var.csh ydb_env_translate gtm_env_translate
setenv compile  "$gt_cc_compiler $gtt_cc_shl_options $gt_cc_option_debug -I$gtm_dist -I$gtm_tst/com"
if ( "hp-ux"  == "$gtm_test_osname" && $gtm_test_machtype == "ia64") then
	setenv compile 	"$compile +W 2550 "
endif
setenv syslibs "-lc"
setenv link	"$gt_ld_shl_linker $gt_ld_shl_options"

ipcs -a > ipcs1.out
$gtm_tst/com/dbcreate.csh a
setenv gtmgbldir a.gld
if ($?gtm_env_translate || $?ydb_env_translate) then
	echo "ERROR. it should not be defined"
else
	echo "ydb_env_translate is not defined"
endif

echo  -n
$GTM << EOF
s ^GBL="THIS IS A"
h
EOF

mkdir datbak ; mv a.dat a.gld datbak/		# Since dbcreate below will rename. So move it away temporarily
$gtm_tst/com/dbcreate.csh b
setenv gtmgbldir b.gld
$GTM << EOF
s ^GBL="THIS IS B"
h
EOF

mv b.dat b.gld datbak/
$gtm_tst/com/dbcreate.csh mumps
setenv gtmgbldir mumps.gld
$GTM << EOF
s ^GBL="THIS IS MUMPS"
h
EOF

if ( "os390" == $gtm_test_osname ) then
	# Save the normal LIBPATH and append the desired paths for call ins to work
	set old_libpath=${LIBPATH}
	setenv LIBPATH ${tst_working_dir}:${gtm_exe}:.:${LIBPATH}
	setenv link "$link $tst_ld_yottadb"
endif

mv datbak/* .					# Move back the backed up files (to prevent dbcreate renaming them)
# no ydb_env_translate defined
echo "#########################################################################################"
echo "ydb_env_translate is not defined. No environment translation."
echo ""
$gtm_exe/mumps -run notdef

# bad ydb_env_translate definition
echo "#########################################################################################"
echo "ydb_env_translate is defined, but library does not exist."
echo ""
set xlate = "$tst_working_dir/foo.bad"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_env_translate gtm_env_translate $xlate
echo "ydb_env_translate = "$xlate
$gtm_exe/mumps -run notdef >& notdef1_log
# to get a different reference file for each platform
$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk notdef1_log $gtm_tst/$tst/outref/notdef1.txt > notdef1.cmp
diff notdef1_log notdef1.cmp >! /dev/null
if ($status) then
	echo "FAILED. Check notdef1_log and notdef1.cmp."
	echo "diff notdef1_log notdef1.cmp:"
	diff notdef1_log notdef1.cmp
else
	echo "PASSED"
endif
endif

# good definition, bad dll (gtm_env_xlate not there)
echo "#########################################################################################"
echo "ydb_env_translate is defined, but there is no gtm_env_xlate function in it."
echo ""
set xlate = "$tst_working_dir/liboops${gt_ld_shl_suffix}"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_env_translate gtm_env_translate $xlate
echo "ydb_env_translate = "$xlate
$compile $gtm_tst/$tst/inref/gtm_env_oops.c
$link ${gt_ld_option_output}liboops${gt_ld_shl_suffix} gtm_env_oops.o $syslibs >& link0.log
if ($status) cat link0.log
$gtm_exe/mumps -run notdef  >& notdef2_log
$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk notdef2_log $gtm_tst/$tst/outref/notdef2.txt > notdef2.cmp
diff notdef2_log notdef2.cmp >! /dev/null
if ($status) then
	echo "FAILED. Check notdef2_log and notdef2.cmp."
	echo "diff notdef2_log notdef2.cmp:"
	diff notdef2_log notdef2.cmp
else
	echo "PASSED"
endif
endif



#A good DLL, at last
echo "#########################################################################################"
echo "A good DLL at last..."
echo ""
setenv a `pwd`/a.gld
set xlate = "$tst_working_dir/libxlate${gt_ld_shl_suffix}"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_env_translate gtm_env_translate $xlate
echo "ydb_env_translate = "$xlate
$compile $gtm_tst/$tst/inref/gtm_env_xlate.c
$link ${gt_ld_option_output}libxlate${gt_ld_shl_suffix} gtm_env_xlate.o $syslibs >& link1.log
echo $status
$gtm_exe/mumps -run basic
$gtm_exe/mumps -run null^basic
$gtm_exe/mumps -run err1^basic
$gtm_exe/mumps -run err2^basic
$gtm_exe/mumps -run err3^basic
$gtm_exe/mumps -run err4^basic
$gtm_exe/mumps -run err5^basic
$gtm_exe/mumps -run err6^basic



echo "#########################################################################################"
echo "Now the SQ translation routine"
echo ""
mkdir first
mv *.o first
mv *${gt_ld_shl_suffix} first
set xlate = "$tst_working_dir/libxlatesq${gt_ld_shl_suffix}"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_env_translate gtm_env_translate $xlate
echo "ydb_env_translate = "$xlate
echo $gtmgbldir

if ("linux" == $gtm_test_osname) then
	set lversion=`uname -r`
	set ltemp_ver=`echo $lversion | sed 's/./& /g'`
	if ($ltemp_ver[3] == "2"  && $ltemp_ver[1] == "2") then
		setenv compile "$compile -DNeedInAddrPort"
	endif
endif

$compile $gtm_tst/$tst/inref/gtm_env_xlate_sq.c >& gtm_env_xlate_sq.out
set compstat = $status
if ($compstat) cat gtm_env_xlate_sq.out
$link ${gt_ld_option_output}libxlatesq${gt_ld_shl_suffix} gtm_env_xlate_sq.o $syslibs >& link2.log
echo "The status of the link is: " $status
unsetenv gtm_gblxlate
echo "undefined environment variable (gtm_gblxlate)..."
$gtm_exe/mumps -run tg^sq
echo ""
echo "bad file name for gtm_gblxlate..."
rm *.o
setenv gtm_gblxlate      "$gtm_tst/$tst/inref/notthere.dat"
echo "gtm_gblxlate = $gtm_gblxlate"
$gtm_exe/mumps $gtm_tst/$tst/inref/sq.m
$gtm_exe/mumps -run tg^sq
$gtm_exe/mumps -run tg^sq

echo ""
echo "Now the correct gtm_gblxlate..."
setenv gtm_gblxlate 	"$gtm_tst/$tst/inref/table.dat"
echo "gtm_gblxlate = $gtm_gblxlate"
$gtm_exe/mumps -run t1^sq
$gtm_exe/mumps -run t2^sq
$gtm_exe/mumps -run t3^sq
$gtm_exe/mumps -run tg^sq
$gtm_exe/mumps -run var

echo ""
echo "Now let's test an error - no-existent host"
echo ""
setenv gtm_gblxlate 	"$gtm_tst/$tst/inref/table_bad.dat"
echo "gtm_gblxlate = $gtm_gblxlate"
$gtm_exe/mumps -run tg^sq

echo ""
setenv gtm_gblxlate 	"$gtm_tst/$tst/inref/table.dat"
echo "gtm_gblxlate = $gtm_gblxlate"
echo "Now let's test LOCKS..."
$gtm_exe/mumps -run locks
echo ""
echo "#####################################################################################"
cat othloc.mje
echo "Output of the job (othloc.mjo):"
echo "#####################################################################################"
cat othloc.mjo

echo "#####################################################################################"
$gtm_exe/mumps -run merge
$gtm_tst/com/dbcheck.csh a
$gtm_tst/com/dbcheck.csh b
$gtm_tst/com/dbcheck.csh mumps

if ( "os390" == $gtm_test_osname ) then
	# Restore the normal LIBPATH
	setenv LIBPATH $old_libpath
endif
