#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#;;;write_anywhere.csh
#;;;Test the unix ability to write anywhere in a sequential device with both M and unicode tests
#;;;No longer requires a read from the beginning of the file for unicode as it now reads the BOM
#;;;under the covers if needed.  Now only writes a BOM at the beginning of a file
#;;;In unicode mode the parameters(0,3,2) passed to wrany represent the BOM length
#;;;This work was done under the GTM-8018
#;;;
$switch_chset M

# Create one-region gld and associated .dat file
$gtm_tst/com/dbcreate.csh mumps 1

$echoline
echo "**************************** wrany in M mode ****************************"
$echoline
$gtm_dist/mumps -run wrany
$echoline
echo "**************************** wranyfix in M mode ****************************"
$echoline
$gtm_dist/mumps -run wranyfix

if ("TRUE" == $gtm_test_unicode_support) then
	$echoline
	echo "**************************** UTF-8 wrany no BOM ****************************"
	$echoline
	$switch_chset UTF-8
	$gtm_dist/mumps -run wrany 0
	$echoline
	echo "**************************** UTF-8 wrany with BOM ****************************"
	$echoline
	$gtm_dist/mumps -run wrany 3
	$echoline
	echo "**************************** UTF-16 wrany with BOM ****************************"
	$echoline
	$gtm_dist/mumps -run wrany 2
	$echoline
	echo "**************************** UTF-16LE wrany no BOM ****************************"
	$echoline
	$gtm_dist/mumps -run wrany 4
	$echoline
	echo "**************************** UTF-16LE wrany with BOM ****************************"
	$echoline
	$gtm_dist/mumps -run wrany 5
	$echoline
	echo "**************************** UTF-8 wranyfix no BOM ****************************"
	$echoline
	$switch_chset UTF-8
	$gtm_dist/mumps -run wranyfix 0
	$echoline
	echo "**************************** UTF-8 wranyfix with BOM ****************************"
	$echoline
	$gtm_dist/mumps -run wranyfix 3
	$echoline
	echo "**************************** UTF-16 wranyfix with BOM ****************************"
	$echoline
	$gtm_dist/mumps -run wranyfix 2
	$echoline
	echo "**************************** UTF-16LE wranyfix no BOM ****************************"
	$echoline
	$gtm_dist/mumps -run wranyfix 4
	$echoline
	echo "**************************** UTF-16LE wranyfix with BOM ****************************"
	$echoline
	$gtm_dist/mumps -run wranyfix 5
endif

$gtm_tst/com/dbcheck.csh
