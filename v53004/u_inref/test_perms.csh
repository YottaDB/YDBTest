#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Set up and test permissions of file and IPC creation based on passed options

# Valid command line arguments:
#
#	perm=<###>		permissions for database file, in octal
#	isowner			run as owner of the database
#	ingroup or setgid	run in group of the database, statically or using setgid
#	isroot			run as root
#	owneringroup		set database group and owner so that owner is a member of the group
#	gtmrestrict		set libyottadb so that only owner and group members can use it

# Disable autorelink since we manually modify gtmroutines below
set gtm_test_autorelink_dirs = 0
source $gtm_tst/com/set_gtmroutines.csh $gtm_chset:s/-//

echo "Options:              ${argv[*]:q}"

# set a variable for each command line argument so we can get the value of them with $arg
# or test for their existence with $?arg.
foreach opt ( ${argv[*]:q} )
	eval set "$opt"
end

if (! $?perm || $perm == "") then
	echo "${0:t}: perm option must be set to file permissions"
	exit 1
endif

set perm_exec=`$tst_awk -v perm=$perm 'BEGIN {p = strtonum("0" perm); printf "0%o\n", or(p, and(p, 0444) / 4) }'`

set IGS=$gtm_com/IGS

# If we are working on a new IGS, compile and use that; otherwise, use the existing one.
# When using doall/rununix, add "-env work_dir=$work_dir" to the command line.
if ( $?work_dir) then
	if ( -f $work_dir/tools/library/usr_library_com/IGS.c ) then
		if ( ! -x `pwd`/IGS ) then
			cp $work_dir/tools/library/usr_library_com/IGS.c .
			$gt_cc_compiler $gtt_cc_shl_options $gt_cc_option_I $gt_cc_option_DDEBUG $gt_cc_option_debug $gt_cc_option_nooptimize IGS.c
			$gt_ld_linker $gt_ld_options_common $gt_ld_option_output IGS IGS.o >& IGS_link.out
			$IGS `pwd`/IGS "IGSCHOWN"
		endif
		set IGS=`pwd`/IGS
	endif
endif

set libyottadb="$gtm_dist/libyottadb.$libext"

set DEF_USER=gtcusr1
set DEF_GROUP=gtc
set INDEFGROUP_USER=gtcusr2		# not in DEFUSERNOTIN_GROUP
#set INDEFGROUP_USER=gtmtest1		# not in DEFUSERNOTIN_GROUP, alternate for when gtcusr2 unavailable
set NOTINDEFGROUP_USER=notgtc
set NOTINDEFGROUPUSER_GROUP=gtcnot
set DEFUSERNOTIN_GROUP=gtcnot
set ROOT_USER=root
set ROOT_GROUP=root
	if ($gtm_test_osname =~ {aix,osf1}) set ROOT_GROUP=system
set ROOTINDEFUSERNOTIN_GROUP=$ROOT_GROUP
set ROOTNOTIN_GROUP=gtc
set ROOTNOTINDEFUSERIN_GROUP=gtc
set ROOTANDDEFUSERNOTIN_GROUP=gtcnot

###
### Create and set permissions on database file
###

if (-f mumps.dat) rm -f mumps.dat
if (-f mumps.gld) rm -f mumps.gld

if (! -f "mumps_sav.dat" || ! -f "mumps_sav.gld") then
	$GDE exit >& gde.log
	$gtm_exe/mupip create >& create.log
	$gtm_exe/mumps -r '%XCMD' 'set ^a=1' >& set.log
	mv $gtmgbldir mumps_sav.gld
	mv mumps.dat mumps_sav.dat
endif

cp mumps_sav.dat mumps.dat
cp mumps_sav.gld $gtmgbldir
chmod $perm mumps.dat
chmod a+rwx .

set objdir="mumps.dat.objdir"		# magic name: allows IGS to chown it

###
### Select owner and group for database file
###

# handle non-independent flags
if ($?isowner && $?ingroup && ! $?owneringroup) set owneringroup
if ($?isowner && ! $?ingroup && $?owneringroup) set ingroup

if ($?isowner && $?isroot && $?ingroup && $?owneringroup) then
	set fileowner=$ROOT_USER filegroup=$ROOTINDEFUSERNOTIN_GROUP
#else if ($?isowner && $?isroot && $?ingroup && ! $?owneringroup)	# can't happen
#else if ($?isowner && $?isroot && ! $?ingroup && $?owneringroup)	# can't happen
else if ($?isowner && $?isroot && ! $?ingroup && ! $?owneringroup) then
	set fileowner=$ROOT_USER filegroup=$ROOTNOTIN_GROUP
else if ($?isowner && ! $?isroot && $?ingroup && $?owneringroup) then
	set fileowner=$DEF_USER filegroup=$DEF_GROUP
#else if ($?isowner && ! $?isroot && $?ingroup && ! $?owneringroup)	# can't happen
#else if ($?isowner && ! $?isroot && ! $?ingroup && $?owneringroup)	# can't happen
else if ($?isowner && ! $?isroot && ! $?ingroup && ! $?owneringroup) then
	set fileowner=$DEF_USER filegroup=$DEFUSERNOTIN_GROUP
else if (! $?isowner && $?isroot && $?ingroup && $?owneringroup) then
	set fileowner=$DEF_USER filegroup=$DEF_GROUP
else if (! $?isowner && $?isroot && $?ingroup && ! $?owneringroup) then
	set fileowner=$DEF_USER filegroup=$ROOTINDEFUSERNOTIN_GROUP
else if (! $?isowner && $?isroot && ! $?ingroup && $?owneringroup) then
	set fileowner=$DEF_USER filegroup=$ROOTNOTINDEFUSERIN_GROUP
else if (! $?isowner && $?isroot && ! $?ingroup && ! $?owneringroup) then
	set fileowner=$DEF_USER filegroup=$ROOTANDDEFUSERNOTIN_GROUP
else if (! $?isowner && ! $?isroot && $?ingroup && $?owneringroup) then
	set fileowner=$INDEFGROUP_USER filegroup=$DEF_GROUP
else if (! $?isowner && ! $?isroot && $?ingroup && ! $?owneringroup) then
	set fileowner=$NOTINDEFGROUP_USER filegroup=$DEF_GROUP
else if (! $?isowner && ! $?isroot && ! $?ingroup && $?owneringroup) then
	set fileowner=$NOTINDEFGROUP_USER filegroup=$NOTINDEFGROUPUSER_GROUP
else if (! $?isowner && ! $?isroot && ! $?ingroup && ! $?owneringroup) then
	set fileowner=$INDEFGROUP_USER filegroup=$DEFUSERNOTIN_GROUP
else
	echo "${0:t}: unsupported combination of options"
	exit 1
endif

$IGS mumps.dat CHOWN $fileowner $filegroup

echo -n "DB File Permissions:  "

set file_awk_cmd = '{ user = $3; group = $4 }'
set file_awk_cmd = "$file_awk_cmd"' $3 == "'${DEF_USER}'"					{ user = "defuser" }'
set file_awk_cmd = "$file_awk_cmd"' $3 == "'${INDEFGROUP_USER}'"				{ user = "idguser" }'
set file_awk_cmd = "$file_awk_cmd"' $3 == "'${NOTINDEFGROUP_USER}'"				{ user = "nidguser" }'
set file_awk_cmd = "$file_awk_cmd"' $4 == "'${ROOT_GROUP}'"					{ group = "rootgroup" }'
set file_awk_cmd = "$file_awk_cmd"' $0 ~ /(^$|-E-(OBJFILERR|ZLINKFILE|ENO))/			{ next }'
set file_awk_cmd = "$file_awk_cmd"' $0 ~ /%YDB-E-OBJFILERR/					{ gsub(/%YDB-E-OBJFILERR.*/, "") }'
set file_awk_cmd = "$file_awk_cmd"' $0 ~ /%YDB-E-ZLNOOBJECT/					{ gsub(/%YDB-E-ZLNOOBJECT, /, "") }'
set file_awk_cmd = "$file_awk_cmd"' $0 ~ /mumps.(mjl|dat)|'$objdir'|ydb-relinkctl/		{ print $1 "," user "," group }'
set file_awk_cmd = "$file_awk_cmd"' $0 !~ /mumps.(mjl|dat)|'$objdir'|ydb-relinkctl/'
set file_awk_cmd = "$file_awk_cmd"'		{ gsub(/,'${ROOTINDEFUSERNOTIN_GROUP}';/, ",rootgroup;") ;'
set file_awk_cmd = "$file_awk_cmd"'		  gsub(/,'${ROOTINDEFUSERNOTIN_GROUP}'$/, ",rootgroup") ;'
set file_awk_cmd = "$file_awk_cmd"'		  print }'

ls -l mumps.dat | $tst_awk "$file_awk_cmd"

###
### Set group restriction
###

if ($?gtmrestrict) then
	chmod o-x $libyottadb
endif

###
### Check Permissions
###

echo -n "IPC Permissions:      "

if ($?isroot && $?setgid) then
	set runas_user=$ROOT_USER
	set runas_group=$filegroup
else if ($?isroot && ! $?setgid) then
	set runas_user=$ROOT_USER
	set runas_group=$ROOTINDEFUSERNOTIN_GROUP
else if (! $?isroot && $?setgid) then
	set runas_user=$DEF_USER
	set runas_group=$filegroup
else
	set runas_user=$DEF_USER
	set runas_group=$DEF_GROUP
endif

$IGS mumps.dat GETIPCPERM $runas_user $runas_group |& $tst_awk "$file_awk_cmd"

echo -n "New File Permissions: "

echo "Options:              ${argv[*]:q}" >>& mkjnl.logx

echo $IGS mumps.dat MKJNL $runas_user $runas_group >>& mkjnl.logx
$IGS mumps.dat MKJNL $runas_user $runas_group >>& mkjnl.logx

echo "=====" >>& mkjnl.logx

if (-f mumps.mjl) then
	ls -l mumps.mjl |& $tst_awk "$file_awk_cmd"
else
	echo "mumps.mjl not created"
endif

###
### Autorelink
###

if ( $gtm_test_os_machtype !~ HOST_{HP-UX_IA64,LINUX_IX86} ) then
	# Force object files into subdirectory with autorelink enabled
	mkdir -p $objdir
	chmod $perm_exec $objdir
	chmod a+x $objdir
	$IGS $objdir CHOWN $fileowner $filegroup
	eval 'set newroutines="${gtmroutines:s@.@./'${objdir}'*@}"'

	echo -n "Relink ObjDir Permissions:       "
	env gtmroutines="$newroutines" getipcperm_opt="objdirperm" $IGS mumps.dat GETIPCPERM $runas_user $runas_group |& $tst_awk "$file_awk_cmd"
	echo -n "Relink Control File Permissions: "
	env gtmroutines="$newroutines" getipcperm_opt="rctlfileperm" $IGS mumps.dat GETIPCPERM $runas_user $runas_group |& $tst_awk "$file_awk_cmd"
	echo -n "Relink IPC Permissions:          "
	env gtmroutines="$newroutines" getipcperm_opt="rctlipcperm" $IGS mumps.dat GETIPCPERM $runas_user $runas_group |& $tst_awk "$file_awk_cmd"

	$IGS $objdir CHOWN $USER gtc
	chmod a+rwx $objdir
endif

###
### Cleanup
###

rm -rf mumps.*

if ($?gtmrestrict) then
	chmod o+x $libyottadb
endif
