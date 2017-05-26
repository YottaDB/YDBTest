#!/usr/local/bin/tcsh -f
# $1 -- DISK/SHM
# $2 -- SLT/SRC (for SHM only) (null means SRC)
set timestamp = `date +%H%M%S`
if ("DISK" == "$1") then
	# get the info from disk
	set outfile = editinstance_${timestamp}_$$.out
	$MUPIP replic -editinstance -show -detail mumps.repl >& $outfile
	# 0x00000210 0x0008 SLT # 0 : Resync Sequence Number                     10001 [0x0000000000002711]
	$grep "Resync Sequence Number" $outfile |& $tst_awk '{print $10}'
else #SHM
	# get the info from shared memory
	# 0x0001D448 0x0008 SLT # 0 : Resync Sequence Number                    917259 [0x00000000000DFF0B]
	# 0x0001D870 0x0008 SRC # 0 : Resync Sequence Number                    917259 [0x00000000000DFF0B]
	set outfile = jnlpool_${timestamp}_$$.out
	$MUPIP replic -source -jnlpool -show -detail >& $outfile
	set diskinfo = `$grep "Resync Sequence Number" $outfile | $grep "SLT" | $tst_awk '{print $10}'` # disk copy
	set shminfo  = `$grep "Resync Sequence Number" $outfile | $grep "SRC" | $tst_awk '{print $10}'` # shared mem copy
	if ("SLT" == "$2") then
		echo $diskinfo	# return the shm information from the SLT info
	else
		echo $shminfo	# return the shm information from the SRC info
	endif
endif
