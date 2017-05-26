#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#	instream.csh for dbload
#
#	This script is based on the original script dbload.csh which
#	was sent to us by DHT.  We made a few local modifications to
#	enable it to run on all of our Unix platforms, including:
#
#		created GDE input file describing the global directory
#			and GO-format cd MUPIP EXTRACT file
#
#			This enables us to run the test on any platform;
#			their original test included a .gld file and a
#			binary format MUPIP EXTRACT file which caused
#			problems on platforms with different
#			byte-ordering.
#
#
#	This test addresses the following Support Requests:
#
#		S9610-000314
#
#
# First, create the global empty database.
$switch_chset M >&! /dev/null
cp $gtm_tst/$tst/inref/{gde.in,*.m} .
cp $gtm_tst/$tst/u_inref/dbload1 .
#
setenv gtmgbldir $cwd/dbload_gbl.gld	# $cwd/ is required because dbload1 cds to tmp* and invokes dbload routine
setenv dbdir $cwd			# dbload.gde below uses $dbdir for database path, for the same reason above
setenv test_specific_gde $gtm_tst/$tst/inref/dbload.gde

$gtm_tst/com/dbcreate.csh dbload_gbl -global_buffer_count=64

# The original code used a binary format MUPIP EXTRACT file, cd.b
# mupip load -format=binary cd.b
$MUPIP load -format=go $gtm_test/big_files/$tst/cd.go
# Make sure that path of gtmcrypt_config is consistent through out the test run.  Extract operation inside dbload1 scripts requires encryption keys for the databases.
if ("ENCRYPT" == $test_encryption) setenv gtmcrypt_config $PWD/gtmcrypt.cfg
#
$tst_tcsh dbload1 >& dbload1.log
$gtm_tst/com/dbcheck.csh
