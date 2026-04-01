#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Prepare the gld with decently sized global buffer and allocation settings for the benchmark
# We need to set a higher key and record size to avoid GVSUBOFLOW/REC2BIG errors respectively.
cat > gld.cmd << CAT_EOF
change -segment DEFAULT -file=mumps.dat
change -segment DEFAULT -allocation=50000
change -segment DEFAULT -global_buffer_count=10000
change -segment DEFAULT -lock_space=262144
change -segment DEFAULT -exten=100000
change -segment DEFAULT -mutex_slots=32768
change -region DEFAULT -record_size=1024
change -region DEFAULT -key_size=1000
CAT_EOF

# Unset any overriding YDB env vars as we want to use GT.M env vars for testing
# as this is going to test with GT.M and YottaDB builds.
unsetenv ydb_dist ydb_routines ydb_gbldir
setenv gtmgbldir mumps.gld

setenv ydb_mutex_benchmark "interestposting"

set nonomatch
rm -f bak.gld.* bak.dat.*
unset nonomatch

# Test with GT.M V7.1-002, YottaDB r2.02, YottaDB r2.04 and GT.M V7.1-010
set verpathlist = "/usr/local/lib/fis-gtm/V7.1-002_x86_64 /usr/library/R20{2,4}/pro /usr/local/lib/fis-gtm/V7.1-010_x86_64 "

foreach nprocs (1 2 4 8 16 32 64 128 256 512 1024 2048)
	foreach verpath ($verpathlist)
		set gtmver = $verpath:t
		if ($gtmver == "pro") then
			set gtmver = $verpath:h:t
		endif
		setenv verno $gtmver
		setenv gtm_dist $verpath
		setenv gtmroutines ".(. $gtm_dist)"
		if (-e $gtm_dist/libgtmutil.so) then
			setenv gtmroutines "$gtmroutines $gtm_dist/libgtmutil.so"
		endif
		setenv gtmroutines "$gtmroutines $gtm_dist"
		$gtm_dist/mumps interestposting.m
		if (! -e bak.gld.$verno) then
			rm -f mumps.gld mumps.dat
			$gtm_dist/mumps -run GDE @gld.cmd >& gde_$verno.out
			$gtm_dist/mupip create >& mupip_create_$verno.out
			$gtm_dist/mumps -run dbinit^interestposting
			cp mumps.gld bak.gld.$verno
			cp mumps.dat bak.dat.$verno
		else
			cp bak.gld.$verno mumps.gld
			cp bak.dat.$verno mumps.dat
		endif
		repeat 1 $gtm_dist/mumps -run interestposting $nprocs
		$gtm_dist/dse dump -file -all >& dse_d_f_a_${verno}_${nprocs}_interestposting
	end
end
