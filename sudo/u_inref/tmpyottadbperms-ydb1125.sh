#!/usr/bin/bash
#################################################################
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

source_directory="/Distrib/YottaDB/$gtm_verno/$tst_image/yottadb_r*"

echo "# Unset environment variables set by the test system that prevent"
echo "# ydb_env_set from using the installation in the test directory"
dirname="test$1"
. $ydb_dist/ydb_env_unset >> ydb_env_unset$dirname.outx 2>&1
unset ydb_log gtm_log
unset ydb_tmp gtm_tmp
unset ydb_routines gtmroutines
unset ydb_gbldir gtmgbldir
unset ydb_chset gtm_chset

echo "# Set test case variables"
install_dir="$(pwd)/$dirname"
install_group=$2
relname=$tmp_relname
test_vars="test$1-vars.out"
tmpdir=$3
echo '# Get the initial permissions of $ydb_tmp, if it exists'
if [ "undef" = "$tmpdir" ]; then
	tmp_parent_dir="/tmp/yottadb"
	unset ydb_tmp gtm_tmp
	if [ -d "/tmp/yottadb/$tmp_relname" ]; then
		tmp_ls_init=$($gtm_tst/com/lsminusl.csh -L /tmp/yottadb | grep "$tmp_relname")
		tmp_perms_init=$(echo $tmp_ls_init | cut -d" " -f 1)
	fi
elif [ "rel" = "$tmpdir" ]; then
	tmp_parent_dir="$PWD/tmp_$1"
	export ydb_tmp="$tmp_parent_dir/$relname"
	export gtm_tmp=$ydb_tmp
	if [ -d "$ydb_tmp" ]; then
		tmp_ls_init=$($gtm_tst/com/lsminusl.csh -L $tmp_parent_dir | grep "$relname")
		tmp_perms_init=$(echo $tmp_ls_init | cut -d" " -f 1)
	fi
else
	tmp_parent_dir="$PWD"
	export ydb_tmp="$tmp_parent_dir/tmp_$1"
	export gtm_tmp=$ydb_tmp
	if [ -d "$ydb_tmp" ]; then
		tmp_ls_init=$($gtm_tst/com/lsminusl.csh -L $tmp_parent_dir | grep "tmp_$1")
		tmp_perms_init=$(echo $tmp_ls_init | cut -d" " -f 1)
	fi
fi

echo '# Get the initial permissions of $ydb_tmp/.. if it exists'
if [ "rel" = "$tmpdir" ]; then
	tmp_parent_perms_init="----------"
else
	if [ "$tmp_parent_dir" = "/tmp/yottadb" ] && [ ! -d "$tmp_parent_dir" ]; then
		tmp_parent_perms_init="drwxrwxrwt"
	else
		tmp_parent_perms_init=$($sudostr -E $gtm_tst/com/lsminusl.csh -L "$tmp_parent_dir/.." | grep $(basename $tmp_parent_dir) | cut -d" " -f 1)
	fi
fi

echo "# Record test case variable values for later reference"
echo "USER=$USER" > $test_vars
echo "relname=$relname" >> $test_vars
echo "tmpdir=$tmpdir" >> $test_vars
echo "install_dir=$install_dir" >> $test_vars
echo "install_group=$install_group" >> $test_vars
echo "ydb_tmp=$ydb_tmp" >> $test_vars
echo "gtm_tmp=$gtm_tmp" >> $test_vars
echo "sudostr=$sudostr" >> $test_vars

echo -n "# Run ydbinstall/ydbinstall.sh: "
if [ "nogroup" = "$install_group" ]; then
	echo "without --group-restriction"
	# Use --linkexec to reduce instance of failures in concurrently running tests that access /usr/local/bin
	$sudostr -E $source_directory/ydbinstall --installdir $install_dir --overwrite-existing --utf8 --linkexec $install_dir
else
	echo "with --group-restriction --group $install_group"
	# Use --linkexec to reduce instance of failures in concurrently running tests that access /usr/local/bin
	$sudostr -E $source_directory/ydbinstall --installdir $install_dir --overwrite-existing --utf8 --group-restriction --group $install_group --linkexec $install_dir
fi

echo "# Invoke ydb_env_set as $USER"
. $install_dir/ydb_env_set >> ydb_env_set$dirname.outx 2>&1
echo "ydb_tmp=$ydb_tmp" >> $test_vars
echo "gtm_tmp=$gtm_tmp" >> $test_vars

echo '# Get the permissions of $ydb_dist/yottadb, for later validation of $ydb_tmp/yottadb/<rel> permissions'
ydbperms=$($gtm_tst/com/lsminusl.csh -L $ydb_dist/yottadb | cut -d" " -f 1)
echo "ydbperms=$ydbperms" >> $test_vars

echo '# Get the permissions of $ydb_tmp'
if [ "$tmpdir" = "undef" ] || [ "$tmpdir" = "rel" ]; then
	tmp_ls=$($sudostr -E $gtm_tst/com/lsminusl.csh -L $ydb_tmp/.. | grep $relname)
else
	tmp_ls=$($sudostr -E $gtm_tst/com/lsminusl.csh -L $ydb_tmp/.. | grep $(basename $ydb_tmp))
fi
tmp_perms=$(echo $tmp_ls | cut -d" " -f 1)
echo "tmp_ls=$tmp_ls" >> $test_vars
echo "tmp_perms=$tmp_perms" >> $test_vars

echo '# Get the permissions of $ydb_tmp/..'
if [ "$tmpdir" = "undef" ]; then
	tmp_parent_ls=$($sudostr -E $gtm_tst/com/lsminusl.csh -L $ydb_tmp/../.. | grep yottadb)
elif [ "$tmpdir" = "rel" ]; then
	tmp_parent_ls=$($sudostr -E $gtm_tst/com/lsminusl.csh -L $ydb_tmp/../.. | grep "tmp_$1")
else
	tmp_parent_ls=$($sudostr -E $gtm_tst/com/lsminusl.csh -L $ydb_tmp/../.. | grep install)
fi
tmp_parent_perms=$(echo $tmp_parent_ls | cut -d" " -f 1)
echo "tmp_parent_ls=$tmp_parent_ls" >> $test_vars
echo "tmp_parent_perms=$tmp_parent_perms" >> $test_vars
echo "tmp_ls_init=$tmp_ls_init" >> $test_vars
echo "tmp_perms_init=$tmp_perms_init" >> $test_vars
echo "tmp_parent_perms_init=$tmp_parent_perms_init" >> $test_vars
echo "tmp_parent_dir=$tmp_parent_dir" >> $test_vars

echo '# Get the group of $ydb_tmp'
tmp_group=$(echo $tmp_ls | cut -d" " -f 4)
echo "tmp_group=$tmp_group" >> $test_vars
# Confirm permissions of $ydb_tmp/..
# Use elif and duplicate code to workaround lack of support for the following conditional logic:
# [ "$tmpdir" = "rel" || [ "$tmpdir" = "undef" && "$USER" = "root" ]]
resultmsg='PASS: $ydb_tmp/.. has the correct permissions'
if [ "$tmpdir" = "rel" ]; then
	echo '# Confirm the permissions of $ydb_tmp/.. are [drwxrwxrwt], or unchanged:'
	if [ "$tmp_parent_perms" != 'drwxrwxrwt' ]; then
		if [ "$USER" = "root" ]; then
			resultmsg="FAIL: \$ydb_tmp/.. has permissions [$tmp_parent_perms], but [drwxrwxrwt] expected."
		elif [ "$tmp_parent_perms" != "$tmp_parent_perms_init" ]; then
			resultmsg="FAIL: \$ydb_tmp/.. permissions [$tmp_parent_perms], but initially had [$tmp_parent_perms_init]. No change expected."
		fi
	fi
	echo $resultmsg
elif [ "$tmpdir" = "undef" ] && [ "$USER" = "root" ]; then
	echo '# Confirm the permissions of $ydb_tmp/.. are [drwxrwxrwt]:'
	if [ "$tmp_parent_perms" != 'drwxrwxrwt' ]; then
		resultmsg="FAIL: \$ydb_tmp/.. has permissions [$tmp_parent_perms], but [drwxrwxrwt] expected."
	fi
	echo $resultmsg
else
	echo "# Confirm the permissions of \$ydb_tmp/.. are [drwxrwxrwt], or unchanged:"
	if [ -n "$tmp_parent_perms" ] && [ "$tmp_parent_perms" != "$tmp_parent_perms_init" ]; then
		if [ "$USER" = "root" ]; then
			resultmsg="FAIL: \$ydb_tmp/.. has permissions [$tmp_parent_perms], but [drwxrwxrwt] expected."
		elif [ "$tmp_parent_perms" != "$tmp_parent_perms_init" ]; then
			resultmsg="FAIL: \$ydb_tmp/.. has permissions [$tmp_parent_perms], but initially had [$tmp_parent_perms_init]. No change expected."
		fi
	fi
	echo $resultmsg
fi

if [ "nogroup" = $install_group ]; then
	# Confirm permissions of $ydb_dist/yottadb
	echo '# Confirm the permissions of $ydb_dist/yottadb are [-r-xr-xr-x]:'
	if [ "$ydbperms" != '-r-xr-xr-x' ]; then
		echo "FAIL: \$ydb_dist/yottadb has permissions [$ydbperms], but [-r-xr-xr-x] expected."
	else
		echo 'PASS: $ydb_dist/yottadb has the correct permissions'
	fi
	# Confirm permissions of $ydb_tmp
	resultmsg='PASS: $ydb_tmp has the correct permissions'
	echo '# Confirm the permissions of $ydb_tmp are [drwxrwxrwx], [drwxrwxrwt], or unchanged:'
	if [ "$tmp_perms" != 'drwxrwxrwx' ]; then
		# $ydb_tmp could have previously had the sticky bit set, in that case, accept [drwxrwxrwt] permissions
		if [ "root" = "$USER" ]; then
			if [ "$tmp_perms" = "drwxrwxrwt" ]; then
				resultmsg='PASS: $ydb_tmp has the correct permissions'
			else
				resultmsg="FAIL: YottaDB installed without --group-restriction, but \$ydb_tmp has permissions [$tmp_perms]: [drwxrwxrwx] expected."
			fi
		elif [ "$tmp_perms" != "$tmp_perms_init" ]; then
			resultmsg="FAIL: ydb_env_set run as non-root user, but \$ydb_tmp permissions were modified from [$tmp_perms_init] to [$tmp_perms]: No change expected."
		fi
	fi
	echo $resultmsg
else
	# Confirm permissions of $ydb_dist/yottadb
	echo '# Confirm the permissions of $ydb_dist/yottadb are [-r-xr-x---]:'
	if [ "$ydbperms" != '-r-xr-x---' ]; then
		echo "FAIL: \$ydb_dist/yottadb has permissions [$ydbperms], but [-r-xr-x---] expected."
	else
		echo 'PASS: $ydb_dist/yottadb has the correct permissions'
	fi
	# Confirm permissions of $ydb_tmp
	# Use nested `if` statement with variable containing result message to implement logic for:
	# if [ "root" = "$USER" ] && [ "$tmp_perms" != 'drwxrwx---' ] && [ "$tmp_perms" != 'drwxrwx--T' ]
	echo '# Confirm the permissions of $ydb_tmp are [drwxrwx---], or unchanged:'
	resultmsg='PASS: $ydb_tmp has the correct permissions'
	if [ "$tmp_perms" != 'drwxrwx---' ] && [ "$tmp_perms" != 'drwxrwx--T' ]; then
		if [ "root" = "$USER" ]; then
			resultmsg="FAIL: YottaDB installed with --group-restriction, but \$ydb_tmp has permissions [$tmp_perms]: [drwxrwx---] expected."
		elif [ "$tmp_perms" != "$tmp_perms_init" ]; then
			resultmsg="FAIL: ydb_env_set run as non-root user, but \$ydb_tmp permissions were modified from [$tmp_perms_init] to [$tmp_perms]: No change expected."
		fi
	fi
	echo $resultmsg
	echo "# Confirm the group of \$ydb_tmp matches --group, i.e. $install_group:"
	if [ "$tmp_group" != "$install_group" ] && [ "root" = "$USER" ]; then
		echo "FAIL: YottaDB installed with --group $install_group, but \$ydb_tmp has group $tmp_group."
	else
		echo 'PASS: $ydb_tmp has the correct group id'
	fi
fi
