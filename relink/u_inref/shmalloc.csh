#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
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

# This is a test of rtnobj shared memory allocations and expansions. We specify an initial allocation of 1 MB
# and double it until we get an error about being unable to allocate so much memory. At every step we verify
# that the actual allocation size is correct (taking the huge page overrides into account).

cat > x.m <<eof
x
 quit
eof

setenv gtmroutines '.* '"$gtmroutines"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_linktmpdir gtm_linktmpdir `pwd`

@ i = 1
while (1)
	setenv gtm_autorelink_shm $i
	echo | $tst_awk '{print "Time: "systime()}' >>&!	log.logx
	echo "gtm_autorelink_shm=$gtm_autorelink_shm" >>&!	log.logx

	$gtm_dist/mumps -run %XCMD 'do ^x zsystem "$gtm_tst/com/ipcs -a > ipcs.logx; $MUPIP rctldump >& rctl.logx"' |& tee -a log.logx
	$grep -q RELINKCTLERR log.logx
	if (! $status) break

	set shmids = `$grep "Rtnobj shared memory # 1" rctl.logx | $tst_awk '{print $8}'`
	@ j = 1
	while ($j <= $#shmids)
		@ shmid = $shmids[$j]
		# Treat size as a string to avoid overflows in tcsh.
		if ("Linux" == $HOSTOS) then
			set shmsize = `$tst_awk '{print $1" "$2" "$6}' ipcs.logx | $grep "m $shmid " | $tst_awk '{print $3}'`
		else
			set shmsize = `$tst_awk '{print $1" "$2" "$10}' ipcs.logx | $grep "m $shmid " | $tst_awk '{print $3}'`
		endif

		@ exp_min_shm_size_mb = `$gtm_dist/mumps -run %XCMD "set i=1,q=0 for  set:(i-$min_shm_alloc_mb>=0) q=1 write:q i quit:q  set i=i*2"`
		if ($exp_min_shm_size_mb > $i) then
			@ exp_shm_size_mb = $exp_min_shm_size_mb
		else
			@ exp_shm_size_mb = $i
		endif

		set size = `$gtm_dist/mumps -run %XCMD "write (2**20)*$exp_shm_size_mb,!"`

		if ($shmsize != $size) then
			echo "TEST-E-FAIL, Expected the shared memory segment $shmid to be of size $size rather than $shmsize. See log.logx, ipcs.logx, and rctl.logx for details."
			exit 1
		endif

		@ j++
	end

	if ($size == "4611686018427387904") break

	@ i = $i * 2
end
