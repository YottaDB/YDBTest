#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test MUPIP Size by creating a database with several globals and passing
# different sets of parameters (valid or invalid) to MUPIP SIZE
# The randomness is taken care of by passing a specific seed to the generator

# This test has an already complicated reference file (separate sections for SPANNING_REGIONS and NONSPANNING_REGIONS).
# And each section has different output from MUPIP INTEG and MUPIP SIZE in case the > 4g db block scheme is enabled
# (due to the big HOLE). It is not considered worth maintaining an even more complicated reference file just for this scheme
# so disable it in this test.
setenv ydb_test_4g_db_blks 0

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
# If spanning regions is chosen, pick a static spanning regions gde configuration since
# the test reference file relies on the actual layout of the global nodes
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set colno = 0
	if ($?test_collation_no) then
		set colno = $test_collation_no
	endif
	setenv test_specific_gde $gtm_tst/$tst/inref/gtm7292_col${colno}.gde
endif
setenv gtm_test_spanreg 0 # Since we have pointed test_specific_gde to a spanning regions gde already

$gtm_tst/com/dbcreate.csh mumps 4 -block_size=1024 >& dbcreate.log

echo "Fill a database of height 3 in a random-ish manner to try to get a mix of record counts among index blocks"
echo "Fill 5 other databases with various sizes in the same manner"
$gtm_exe/mumps -run gtm7292

echo "###############################################"
echo "Running MUPIP INTEG to get actual globals sizes"
set verbose
$MUPIP integ -full mumps.dat
$MUPIP integ -full a.dat
$MUPIP integ -full b.dat
$MUPIP integ -full c.dat
unset verbose

@ SEED = 1
echo "###############################################"
echo "Testing -heuristic qualifier on A/R sampling method"
set verbose
$MUPIP size -heuristic="arsample,samples"
# The below should work. The output is non-deterministic and so can't be in reference file.
# Just checking the status, as any errors thrown would be caught at the end by error catching framework scripts
$MUPIP size -heuristic="ar,sample=110" 		>>& heur_ar.log
echo $status
$MUPIP size -heuristic="arsample,samples=0"
$MUPIP size -heuristic="arsample,samples=-3"
$MUPIP size -heuristic="arsample,samples=34s"
$MUPIP size -heuristic="arsample,dummy=110"
$MUPIP size -heuristic="arsample,dummy"
$MUPIP size -heuristic="arsample,samples=110,seed=$SEED"
$MUPIP size -heuristic="arsample,samples=10000,seed=$SEED"
$MUPIP size -heuristic="arsample,seed=$SEED"
unset verbose

echo "###############################################"
echo "Testing -heuristic qualifier on importance sampling method"
set verbose
$MUPIP size -heuristic="impsample,samples"
$MUPIP size -heuristic="impsample,samples=0"
$MUPIP size -heuristic="impsample,samples=-3"
$MUPIP size -heuristic="impsample,samples=34s"
$MUPIP size -heuristic="impsample,dummy=110"
$MUPIP size -heuristic="impsample,dummy"
$MUPIP size -heuristic="impsample,samples=110,seed=$SEED"
$MUPIP size -heuristic="impsample,samples=10000,seed=$SEED"
$MUPIP size -heuristic="impsample,seed=$SEED"
unset verbose

echo "###############################################"
echo "Testing -heuristic qualifier on Scan method"
set verbose
$MUPIP size -heuristic="scan,level"
$MUPIP size -heuristic="scan,level=4"
$MUPIP size -heuristic="scan,level=12"	# == MAX_BT_DEPTH + 1
$MUPIP size -heuristic="scan,level=-19"
$MUPIP size -heuristic="scan,level=-1s9"
$MUPIP size -heuristic="scan,level=-13"	# == -MAX_BT_DEPTH - 2
$MUPIP size -heuristic="scan"
$MUPIP size -heuristic="scan,level=1"
$MUPIP size -heuristic="scan,level=2"
$MUPIP size -heuristic="scan,level=0"
$MUPIP size -heuristic="scan,level=-1"
$MUPIP size -heuristic="scan,level=-2"
$MUPIP size -heuristic="scan,level=-3"
unset verbose

echo "###############################################"
echo "Testing -heuristic qualifier disallowed combinations"
set verbose
$MUPIP size -heuristic="scan,arsample"
$MUPIP size -heuristic="scan,impsample"
$MUPIP size -heuristic="impsample,level=1"
$MUPIP size -heuristic="arsample,level=1"
$MUPIP size -heuristic="scan,samples=101"
$MUPIP size -heuristic="scan,seed=5"
unset verbose

echo "###############################################"
echo "Testing -heuristic default behavior"
set verbose
$MUPIP size					>& default_behavior.log
unset verbose
# Since the seed is not passed, there's no reference. So we'll just check whether all
# globals are there
foreach gbl_i ( a b c c2 c3 d )
	$grep "Global: ${gbl_i}" default_behavior.log
end

echo "###############################################"
echo "Testing -select qualifier"
set verbose
$MUPIP size -heuristic="impsample,samples=1000" -select="nonexistent"
$MUPIP size -heuristic="impsample,samples=1000,seed=$SEED" -select="a"
$MUPIP size -heuristic="impsample,samples=1000,seed=$SEED" -select="b"
$MUPIP size -heuristic="impsample,samples=1000,seed=$SEED" -select="a,b"
$MUPIP size -heuristic="impsample,samples=1000,seed=$SEED" -select="c1:c3"
$MUPIP size -heuristic="impsample,samples=1000,seed=$SEED" -select="c*"
unset verbose

echo "###############################################"
echo "Testing -region qualifier"
set verbose
$MUPIP size -heuristic="impsample,samples=1000" -select="b" -region="nonexistent"
$MUPIP size -heuristic="impsample,samples=1000" -select="b" -region
$MUPIP size -heuristic="impsample,samples=1000" -select="a" -region="BREG"
$MUPIP size -heuristic="impsample,samples=1000,seed=$SEED" -region="AREG"
#Region Name in Mixed cases should be accpeted
$MUPIP size -heuristic="impsample,samples=1000,seed=$SEED" -region="Breg,CREG"
$MUPIP size -heuristic="impsample,samples=1000,seed=$SEED" -region="*REG"
$MUPIP size -heuristic="impsample,samples=1000,seed=$SEED" -region="*"
$MUPIP size -heuristic="impsample,samples=1000,seed=$SEED" -region="DEFAULT"
$MUPIP size -heuristic="impsample,samples=1000,seed=$SEED" -select="d" -region="DEF*"
$MUPIP size -heuristic="impsample,samples=1000,seed=$SEED" -select="a" -region="AREG"
unset verbose

echo "###############################################"
echo "Testing -adjacency qualifier"
set verbose
$MUPIP size -heuristic="arsample,samples=110,seed=$SEED" -adjacency=200
$MUPIP size -heuristic="impsample,samples=110,seed=$SEED" -adjacency=200
$MUPIP size -heuristic="scan" -adjacency=200
$MUPIP size -heuristic="scan" -adjacency=-200
$MUPIP size -heuristic="scan" -adjacency=foo
unset verbose

echo "Done!"
$gtm_tst/com/dbcheck.csh >& dbcheck.log
