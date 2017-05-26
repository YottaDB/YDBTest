#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# GTM-8183  JNLBADRECFMT error when filesystem-block-size is greater than os-page-size

# We have found NFS filesystems satisfying the property : filesystem-block-size > os-page-size
# So this test will use an NFS filesystem for the journal files.

set hostn = $HOST:ar
# to prevent unison issues while the test is running, create the directory in _unison_ignore directory, which would be ignored by unison
set tmpdir = $HOME/_unison_ignore
if (! -d $tmpdir) then
	mkdir -p $tmpdir
endif
set jnldir = $tmpdir/gtm8183_${hostn}_$$
rm -f $jnldir
mkdir $jnldir
mkdir $jnldir/pri
mkdir $jnldir/sec

echo ">>> MULTISITE_REPLIC_PREPARE"
$MULTISITE_REPLIC_PREPARE 2

echo ">>> Create Database"
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 4096 2000 4096 2000

echo ">>> MSR START INST1 INST2"
$MSR START INST1 INST2

echo ">>> Switch journal files to NFS filesystems on both primary and secondary"
$MSR RUN INST1 'set msr_dont_trace ; $MUPIP set -file mumps.dat '${tst_jnl_str}',file='${jnldir}'/pri/mumps.mjl >&! jnlswitch.out'
$MSR RUN INST2 'set msr_dont_trace ; $MUPIP set -file mumps.dat '${tst_jnl_str}',file='${jnldir}'/sec/mumps.mjl >&! jnlswitch.out'

echo ">>> Start imptp"
$MSR RUN INST1 "$gtm_tst/com/imptp.csh" >&! imptp1.out

echo ">>> Sleep 5 seconds"
sleep 5

echo ">>> Stop imptp"
$gtm_tst/com/endtp.csh

echo ">>> Check journal files for JNLBADRECFMT error"
$gtm_tst/com/jnlextall.csh mumps

echo ">>> Do dbcheck"
$gtm_tst/com/dbcheck.csh -extract

# Move NFS directory to test output in case it is needed for failure analysis.
mv $jnldir .

echo ">>> Test done"
