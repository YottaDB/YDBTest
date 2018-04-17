#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# This is a test for memory leakage with autorelink operations.

# Embed source in the object files for easier estimation of the final size.
setenv gtmcompile "-embed_source"

# We need autorelink enabled to test routine object shared memory.
source $gtm_tst/$tst/u_inref/enable_autorelink_dirs.csh
set save_gtmroutines = "$gtmroutines"

# Define a few relevant constants.
@ mb =				1048576
@ obj_overhead =		32
@ obj_size_increment =		16
@ max_autorelink_shm_mb =	8

$gtm_tst/com/dbcreate.csh mumps

##################################################################################################################################
# CASE 1. Specify a random initial shared memory segment size for object code and ensure that it is rounded up to the next power #
#         of 2. If the first object to get linked is bigger than the allocation, the expansion should happen right at start.     #
#                                                                                                                                #
# CASE 2. Shared memory expansion should double the previous size.                                                               #
##################################################################################################################################

# Pick the initial allocation from 0 to 8 MB.
set shmmax = `$gtm_dist/mumps -run %XCMD 'write $random('$max_autorelink_shm_mb'+1)'`
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_autorelink_shm gtm_autorelink_shm $shmmax
@ shm_size_mb = `echo $shmmax`

# Pick the size for the object to generate, from 1 to 8 MB.
@ obj_size_mb = `$gtm_dist/mumps -run %XCMD 'write $random('$max_autorelink_shm_mb')+1'`
@ safe_obj_size = ((($obj_size_mb * $mb) - $obj_overhead) - $obj_size_increment) - 1

# Figure out the required shared memory allocation to fit the object and honor the shmmax setting.
if ($obj_size_mb > $shm_size_mb) then
	@ req_shm_size_mb = $obj_size_mb
else
	@ req_shm_size_mb = $shm_size_mb
endif

# Adjust for huge pages, if needed.
if ($min_shm_alloc_mb > $req_shm_size_mb) then
	@ req_shm_size_mb = $min_shm_alloc_mb
endif

# Calculate the appropriate power-of-two allocation based on the required size.
@ exp_shm_size_mb = `$gtm_dist/mumps -run %XCMD "set i=1,q=0 for  set:(i-$req_shm_size_mb>=0) q=1 write:q i quit:q  set i=i*2"`

# Calculate the size of the second routine that would be enough to cause an expansion.
@ obj_size_to_expand = (((($exp_shm_size_mb - $obj_size_mb) + 1) * $mb) - $obj_overhead) - $obj_size_increment

# Create two routines, one approximating the chosen object size, the other big enough to cause an expansion.
$gtm_dist/mumps -run genobj a $safe_obj_size
$gtm_dist/mumps -run genobj b $obj_size_to_expand

# Generate an RCTLDUMP to verify our expectations.
$gtm_dist/mumps -run %XCMD 'zlink "a" zsystem "$MUPIP rctldump . >&! mupip_rctl1.log" zlink "b" zsystem "$MUPIP rctldump . >&! mupip_rctl2.log"'

# Obtain the size of the actual initial allocation and ensure there is only one segment.
set act_shm_size_hex = `$grep "Rtnobj shared memory" mupip_rctl1.log | $tst_awk '{print $10}'`
if (1 != $#act_shm_size_hex) then
	echo "TEST-E-FAIL, Case 1 failed. Expected 1 routine object shared memory segment but got $#act_shm_size_hex."
	echo '             $ydb_autorelink_shm/$gtm_autorelink_shm = '$shmmax'; estimated routine object size is '$safe_obj_size
else
	# Convert the size to MBs.
	@ act_shm_size = `$gtm_dist/mumps -run %XCMD 'write $$FUNC^%HD($piece("'$act_shm_size_hex'","x",2))'`
	@ act_shm_size_mb = `$gtm_dist/mumps -run %XCMD "write $act_shm_size/$mb"`

	# Validate the numbers.
	if ($act_shm_size_mb != $exp_shm_size_mb) then
		echo "TEST-E-FAIL, Case 1 failed. Expected the routine object shared memory to be $exp_shm_size_mb MB in size whereas it is $act_shm_size_mb MB."
		echo '             $ydb_autorelink_shm/$gtm_autorelink_shm = '$shmmax'; estimated routine object size is '$safe_obj_size
	endif
endif

# Obtain the size of the actual initial allocation and ensure there is only one segment.
set act_shm_size_hex = `$grep "Rtnobj shared memory" mupip_rctl2.log | $tst_awk '{print $10}'`
if (2 != $#act_shm_size_hex) then
	echo "TEST-E-FAIL, Case 2 failed. Expected 2 routine object shared memory segments but got $#act_shm_size_hex."
	echo '             $ydb_autorelink_shm/$gtm_autorelink_shm = '$shmmax'; estimated routine object size is '$safe_obj_size
else
	# Convert the size to MBs.
	@ act_shm_size = `$gtm_dist/mumps -run %XCMD 'write $$FUNC^%HD($piece("'$act_shm_size_hex[2]'","x",2))'`
	@ act_shm_size_mb = `$gtm_dist/mumps -run %XCMD "write $act_shm_size/$mb"`
	@ exp_shm_size_mb = $exp_shm_size_mb * 2

	# Validate the numbers.
	if ($act_shm_size_mb != $exp_shm_size_mb) then
		echo "TEST-E-FAIL, Case 2 failed. Expected the routine object shared memory expansion to reach $exp_shm_size_mb MB in size whereas it is $act_shm_size_mb MB."
		echo '             $ydb_autorelink_shm/$gtm_autorelink_shm = '$shmmax'; estimated routine object size is '$safe_obj_size
	endif
endif

##################################################################################################################################
# CASE 3. When reference count for a particular routine goes to 0, but the shared memory is not being removed (at least one      #
#         process is using it), the routine's space should get freed.                                                            #
##################################################################################################################################

setenv gtmroutines "obj($gtm_tst/$tst/inref) $gtmroutines"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_autorelink_shm gtm_autorelink_shm 1

# We rely on the fact that unused routine object memory is released, so unset this variable.
if ($?gtm_autorelink_keeprtn) then
	set save_gtm_autorelink_keeprtn = $gtm_autorelink_keeprtn
	unsetenv gtm_autorelink_keeprtn
endif

# Figure out the expected shared memory size.
if ($min_shm_alloc_mb > 1) then
	@ exp_shm_size_mb = $min_shm_alloc_mb
else
	@ exp_shm_size_mb = 1
endif

mkdir obj

# Run 7 + 1 jobs on as many objects, the size of each (except the last one) being 1 / 8 of 1 MB.
@ num_of_test_jobs = 7
@ num_of_total_jobs = $num_of_test_jobs + 1
@ min_obj_size = $mb / ($num_of_total_jobs + 1)

# Assign actual routine object sizes based on the previous calculations.
set rtn_obj_sizes = `$gtm_dist/mumps -run %XCMD 'for i=1:1:'$num_of_total_jobs' write (($random(('$mb'-'$obj_overhead')/'$num_of_total_jobs'+1-'$min_obj_size')+'$min_obj_size'))," "'`
@ rtn_obj_sizes[$num_of_total_jobs] = $mb - (2 * $obj_overhead) - $obj_size_increment - 1

# Generate routine objects of chosen sizes.
@ i = 1
while ($i <= $num_of_total_jobs)
	$gtm_dist/mumps -run genobj rtn${i} $rtn_obj_sizes[$i]
	@ i++
end

$gtm_dist/mumps -run memleak^memleak $num_of_test_jobs

# Obtain the shared memory size after all but one processes detached from it and ensure there is only one segment.
set act_shm_size_hex = `$grep "Rtnobj shared memory" mupip_rctl3.log | $tst_awk '{print $10}'`
if (1 != $#act_shm_size_hex) then
	echo "TEST-E-FAIL, Case 3 failed. Expected 1 routine object shared memory segment but got $#act_shm_size_hex."
	echo '             $ydb_autorelink_shm/$gtm_autorelink_shm = '$shmmax'; routine sizes are as follows: '"$rtn_obj_sizes"
else
	# Convert the size to MBs.
	@ act_shm_size = `$gtm_dist/mumps -run %XCMD 'write $$FUNC^%HD($piece("'$act_shm_size_hex'","x",2))'`
	@ act_shm_size_mb = `$gtm_dist/mumps -run %XCMD "write $act_shm_size/$mb"`

	# Validate the numbers.
	if ($exp_shm_size_mb != $act_shm_size_mb) then
		echo "TEST-E-FAIL, Case 3 failed. Expected the routine object shared memory to be $exp_shm_size_mb MB in size whereas it is $act_shm_size_mb MB."
		echo '             $ydb_autorelink_shm/$gtm_autorelink_shm = '$shmmax'; routine sizes are as follows: '"$rtn_obj_sizes"
	endif
endif

if ($?save_gtm_autorelink_keeprtn) then
	setenv gtm_autorelink_keeprtn $save_gtm_autorelink_keeprtn
endif

##################################################################################################################################
# CASE 4. Incrementally linking (implicitly or explicitly) several versions of the same routine in a loop should not need more   #
#         process-private memory than allocated for one iteration of the loop.                                                   #
##################################################################################################################################

setenv gtmroutines ".*(. $gtm_tst/$tst/inref)"

$gtm_dist/mumps -run relinks^memleak

setenv gtmroutines "$save_gtmroutines"

# Obtain the shared memory size used for this directory.
set act_shm_size_hex = `$grep "Rtnobj shared memory" zshow_a.logx | $tst_awk '{print $10}'`
if (1 != $#act_shm_size_hex) then
	echo "TEST-E-FAIL, Case 4 failed. Expected 1 routine object shared memory segment but got $#act_shm_size_hex."
	echo '             $ydb_autorelink_shm/$gtm_autorelink_shm = '$shmmax
else
	# Convert the size to MBs.
	@ act_shm_size = `$gtm_dist/mumps -run %XCMD 'write $$FUNC^%HD($piece("'$act_shm_size_hex'","x",2))'`
	@ act_shm_size_mb = `$gtm_dist/mumps -run %XCMD "write $act_shm_size/$mb"`

	# Validate the numbers.
	if ($exp_shm_size_mb != $act_shm_size_mb) then
		echo "TEST-E-FAIL, Case 4 failed. Expected the routine object shared memory to be $exp_shm_size_mb MB in size whereas it is $act_shm_size_mb MB."
		echo '             $ydb_autorelink_shm/$gtm_autorelink_shm = '$shmmax
	endif
endif

# The cycle number should correspond to the number of times the routine has actually been relinked.
@ cycle = `$grep "rtnname: rtn" zshow_a.logx | $tst_awk '{print $5}'`
if (100 != $cycle) then
	echo "TEST-E-FAIL, Case 4 failed. Expected rtn to go through 100 iterations instead of $cycle."
	echo '             $ydb_autorelink_shm/$gtm_autorelink_shm = '$shmmax
endif

##################################################################################################################################
# CASE 5. ZRUPDATEs should not affect the process-private memory.                                                                #
##################################################################################################################################

setenv gtmroutines ".*(. $gtm_tst/$tst/inref)"

$gtm_dist/mumps -run zrupdates^memleak

##################################################################################################################################
# CASE 6. With recursive relink process-private memory could grow so long as the old version is on the stack; once it is off the #
#         stack, the memory should be freed.                                                                                     #
##################################################################################################################################

# Note that currently links always allocate additional memory, so testing this may have to wait for the fix.
# However, we should be avoiding relinks of an unchanged object file (currently done with autorelink and may
# be implemented for certain flavors of explicit ZLINK).

setenv gtmroutines ".*"

cp $gtm_tst/$tst/inref/memleak.m .

$gtm_dist/mumps -run recursive^memleak

##################################################################################################################################
# CASE 7. Ensure that we do not leak memory when we fail to open the existing relinkctl file or work with the shared memory      #
#         that has already been created for it.                                                                                  #
##################################################################################################################################

setenv gtmroutines "."

$gtm_dist/mumps -run ctlopen^memleak >&! ctlopen.out

setenv gtmroutines "$save_gtmroutines"

$gtm_tst/com/dbcheck.csh
