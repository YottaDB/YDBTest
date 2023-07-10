#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Usage : $0 [bak_dir_name] [files] [cp/mv] [nozip]"

if ("" != "$1") then
	set bakdir = "$1"
else
	set bakdir = "backupdir"
endif

if ("" != "$2") then
	set files = "$2"
else
	set files = "*.dat *.mjl* *.gld"
endif

if ("" != "$3") then
	set todo = "$3"
else
	set todo = "cp -pf"
endif

if ("nozip" == "$4") then
	set dontzip=1
endif

# This script can be called from the secondary side of a multi-host replication test. In that case, the below env var
# would not be inherited and so we cannot directly access the env var like we do in various other places. Hence the check
# first for whether the env var is defined.
if ($?ydb_test_4g_db_blks) then
	if (0 != $ydb_test_4g_db_blks) then
		# gzip takes forever with huge/sparse db files. So disable gzip at all costs if huge db files are possible.
		set dontzip = 1
	endif
endif

if (! $?dontzip && ("$todo" =~ "*cp*")) then
	alias ln 'ln \!* |& $grep -v identical'		# AIX and HP-UX gripe if the target is identical to the source
	set todo = "ln -f"
endif

if !(-d $bakdir) mkdir $bakdir

@ batchsize=25
set files=`find $files -type f -print | sort -u`	# remove duplicates
while ($#files > 0)
	if ($#files < $batchsize) @ batchsize=$#files

	eval "$todo $files[1-$batchsize] $bakdir/"

	if ($#files == $batchsize) then
		set files=()
	else
		@ batchnext = $batchsize + 1
		set files=($files[${batchnext}-$#files])
	endif
end

if !($?dontzip) then
	( cd $bakdir/ ; find . -type f ! -name "*.gz" | xargs $tst_gzip_quiet -f )
endif
