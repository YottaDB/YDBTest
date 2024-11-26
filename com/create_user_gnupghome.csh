#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2019-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Ensure that a user-specific directory for gpg files exists and is readable and writable. Set $GNUPGHOME to point to it.

set log_file = /tmp/__${USER}_create_gnupghome.log
set gnupghome_source = /usr/library/com/gnupg

if (! -d $gnupghome_source) then
	echo 'Missing '$gnupghome_source' directory. create_user_gnupghome.csh cannot proceed without that.'
	exit 1
endif

set tmp_dir = /tmp/gnupgdir
if (! -d $tmp_dir) then
	mkdir $tmp_dir >>&! $log_file
	if ($status) then
		# This could fail if a concurrent process created the directory ahead of us. Give it time to finish.
		sleep 1
		if (! -d $tmp_dir) then
			echo "Creating $tmp_dir failed"
			exit 2
		endif
	endif
	echo "`date` : created $tmp_dir" >>&! $log_file
endif

# If we are the owner, ensure that the directory is user- and group-writable and -readable.
@ is_owner = `filetest -o $tmp_dir`
if (1 == $is_owner) then
	chmod 775 $tmp_dir >>&! $log_file
	if ($status) then
		echo "Changing permissions on $tmp_dir failed"
		exit 3
	endif
endif

# Verify permissions.
@ perm = `filetest -P770 $tmp_dir`
if ($perm < 770) then
	echo "Expected permissions on $tmp_dir are 77x while got $perm"
	exit 4
endif

# If $gnupghome_source has been rebuilt, remove the user's copy, so it could be recreated.
set tmp_dir = "$tmp_dir/$USER"
if (((-M $gnupghome_source/gpg.conf) > (-M $tmp_dir/gpg.conf))					\
		|| ((-M $gnupghome_source/gpg-agent.conf) > (-M $tmp_dir/gpg-agent.conf))) then
	chmod -R 775 $tmp_dir >>&! $log_file		# Make things so we CAN remove dir
	rm -rf $tmp_dir >>&! $log_file
	if ($status) then
		echo "Removing stale $tmp_dir failed"
		exit 5
	endif
	echo "`date` : removed stale $tmp_dir" >>&! $log_file
endif
if (! -d $tmp_dir) then
	cp -r $gnupghome_source $tmp_dir >>&! $log_file
	if ($status) then
		echo "Copying $gnupghome_source to $tmp_dir failed"
		exit 6
	endif
	echo "`date` : copied $gnupghome_source to $tmp_dir" >>&! $log_file
endif

# If we are the owner, ensure that the directory is user- and group-writable and -readable; if not, error out.
@ is_owner = `filetest -o $tmp_dir`
if (1 == $is_owner) then
	chmod 1775 $tmp_dir >>&! $log_file	# The leading 1 is to set sticky bit to prevent accidental deletion by non-owners
	if ($status) then
		echo "Changing permissions to 1775 on $tmp_dir failed"
		exit 7
	endif
	# The below files disappear mysteriously on a few boxes. Making them read-only, hoping we'll catch it when a test attempts to remove them.
	set files = "$tmp_dir/gtm@fnis.com_pubkey.txt $tmp_dir/pinentry-test-gtm.sh"
	chmod a-w $files
	if ($status) then
		echo "Changing permissions on $files failed"
		exit 7
	endif
else
	echo "$tmp_dir is not owned by ${USER}"
	exit 8
endif

# Verify permissions.
@ perm = `filetest -P770 $tmp_dir`
if ($perm < 770) then
	echo "Expected permissions on $tmp_dir are 77x while got $perm"
	exit 9
endif
