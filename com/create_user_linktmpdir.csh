#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Ensure that a user-specific temporary directory for relinkctl files exists and is readable and writable.
# Set $gtm_linktmpdir to point to it.

set log_file = /tmp/__${USER}_create_linktmpdir.log

set tmp_dir = /tmp/relinkdir
if (! -d $tmp_dir) then
	mkdir $tmp_dir >>&! $log_file
	if ($status) then
		# This could fail if a concurrent process created the directory ahead of us. Give it time to finish.
		sleep 1
		if (! -d $tmp_dir) then
			echo "Creating $tmp_dir failed"
			exit 1
		endif
	echo "`date` : created $tmp_dir" >>&! $log_file
	endif
endif

# If we are the owner, ensure that the directory is user- and group-writable and -readable.
@ is_owner = `filetest -o $tmp_dir`
if (1 == $is_owner) then
	chmod 775 $tmp_dir >>&! $log_file
	if ($status) then
		echo "Changing permissions on $tmp_dir failed"
		exit 2
	endif
endif

# Verify permissions.
@ perm = `filetest -P770 $tmp_dir`
if ($perm < 770) then
	echo "Expected permissions on $tmp_dir are 77x while got $perm"
	exit 3
endif

set tmp_dir = "$tmp_dir/$USER"
if (! -d $tmp_dir) then
	mkdir $tmp_dir >>&! $log_file
	if ($status) then
		# This could fail if a concurrent process created the directory ahead of us. Give it time to finish.
		sleep 1
		if (! -d $tmp_dir) then
			echo "Creating $tmp_dir failed"
			exit 4
		endif
	endif
	echo "`date` : created $tmp_dir" >>&! $log_file
endif

# If we are the owner, ensure that the directory is user- and group-writable and -readable; if not, error out.
@ is_owner = `filetest -o $tmp_dir`
if (1 == $is_owner) then
	chmod 1775 $tmp_dir >>&! $log_file	# The leading 1 is to set sticky bit to prevent accidental deletion by non-owners
	if ($status) then
		echo "Changing permissions on $tmp_dir failed"
		exit 5
	endif
else
	echo "$tmp_dir is not owned by ${USER}"
	exit 6
endif

# Verify permissions.
@ perm = `filetest -P770 $tmp_dir`
if ($perm < 770) then
	echo "Expected permissions on $tmp_dir are 77x while got $perm"
	exit 7
endif
