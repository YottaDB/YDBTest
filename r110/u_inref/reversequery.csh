#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test for $query(lvn,-1) and $query(gvn,-1)
#
# There are various tests each embedded in scripts numbered rqtest00.csh, rqtest01.csh etc.
# Each in turn invoke helper M programs rqtest00.m, rqtest01.m etc.
# And each test has its own reference file rqtest00.txt, rqtest01.txt etc. to decide PASS or FAIL for each test.
#
foreach file ($gtm_tst/$tst/u_inref/rqtest*.csh)
        set subtst = $file:t:r
	mkdir $subtst
	cd $subtst
        $file >& $subtst.outx
	set reference = "$gtm_tst/$tst/outref/$subtst.txt"
	$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk $subtst.outx $reference >&! $subtst.cmp
        diff $subtst.cmp $subtst.outx >& $subtst.diff
	@ status1 = $status
	cd ..
        if ($status1) then
                echo "  --> Test $subtst : FAIL. See $subtst.diff for details"
        else
                echo "  --> Test $subtst : PASS"
        endif
end

