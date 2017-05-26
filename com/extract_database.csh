#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# The script creates a single datafile GLD to help identify globals residing in the database
# output is a ".glo" file (of datafile name) extracting that particular datafile globals alone
# datafile probed must reside in current dir.

if ( $#argv == 0 ) then
	echo ""
	echo "USAGE of  extract_database.csh"
	echo "extract_database.csh <datafile> [tmpgldprefix]"
	echo ""
	exit 1
endif

if (! $?GDE) setenv GDE "$gtm_exe/mumps -run GDE"
if (! $?MUPIP) setenv MUPIP "$gtm_exe/mupip"
set save_gtmgbldir = $gtmgbldir
setenv gtmgbldir ${2}mumps.gld

set timestamp = `date +%H%M%S`
set fname=`basename $1 .dat`

if (! -d extract_db) mkdir extract_db
if ( -e ${fname}_extract.glo) \mv ${fname}_extract.glo ${fname}_extract.glo_$timestamp
cd extract_db

$GDE << EOF >>&! ../extract_db_${fname}_$timestamp.out
change -segment DEFAULT -file=../$fname.dat
show -map
exit
EOF

# If encryption is enabled, then gtmcrypt_config (pointing to "gtmcrypt.cfg") will not be valid here since the directory is no
# longer the tmp directory in which the keys were created but a different directory. So, point gtmcrypt_config accordingly
if ("ENCRYPT" == "$test_encryption") then
	setenv gtmcrypt_config ../gtmcrypt.cfg
	setenv gtm_dbkeys ../db_mapping_file
endif

$MUPIP extract ../${fname}_extract.glo >>& ../mupip_extract_${fname}_$timestamp.ext
if ($status) then
        echo "TEST-E-DB_EXTRACT, $MUPIP extract for $fname failed"
	cat ../mupip_extract_${fname}_$timestamp.ext
else
	echo "Globals written to ${fname}_extract.glo"
endif
cd ../
setenv gtmgbldir $save_gtmgbldir
