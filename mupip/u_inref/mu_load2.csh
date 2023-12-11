#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2015 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Turn off statshare related env var as it causes an assert failure "sr_unix/gds_rundown.c line 880 for expression (0 == rc)"
# and is most definitely due to removing the .dat files (but not removing the corresponding .dat.gst statsdb file)
# while the source server is still running.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

#
#########################################
### mu_load.csh  test for mupip load  ###
#########################################
#
#
echo MUPIP LOAD2
# There is another test for load and extract using UTF-8. To avoid reference file issues have this M always.
$switch_chset M
#
#
setenv gtmgbldir "load.gld"
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh "load" 2 -alloc=6400
else
	$gtm_tst/com/dbcreate.csh "load" 2
endif
#
$GTM << GTM_EOF
d in3^sfnfill("set")
h
GTM_EOF
#
# Extract in all formats
echo "$MUPIP extract -format=go -label=test extr.go"
$MUPIP extract -format=go -label=test extr.go
if ($status) then
	echo "Previous command failed"
	exit
endif
echo "$MUPIP extract -format=bin -label=test extr.bin"
$MUPIP extract -format=bin -label=test extr.bin
if ($status) then
	echo "Previous command failed"
	exit
endif
echo "$MUPIP extract -format=zwr -label=test extr.zwr"
$MUPIP extract -format=zwr -label=test extr.zwr
if ($status) then
	echo "Previous command failed"
	exit
endif
#
#######
# Load
#######
# zwr #
\rm -f *.dat
$MUPIP create |& sort -f
echo "$MUPIP load extr.zwr -format=zwr"
$MUPIP load extr.zwr -format=zwr
if ($status) then
	echo "Previous command failed"
	exit
endif
# go #
\rm -f *.dat
$MUPIP create |& sort -f
echo "$MUPIP load extr.go -format=go"
$MUPIP load extr.go -format=go
if ($status) then
	echo "Previous command failed"
	exit
endif
# bin #
\rm -f *.dat
$MUPIP create |& sort -f
echo "$MUPIP load extr.bin -format=bin"
$MUPIP load extr.bin -format=bin
if ($status) then
	echo "Previous command failed"
	exit
endif
\rm -f *.dat
$MUPIP create |& sort -f
echo "$MUPIP load -stdin < extr.bin"
$MUPIP load -stdin < extr.bin
if ($status) then
	echo "Previous command failed"
	exit
endif
################################
\rm -f *.dat
$MUPIP create |& sort -f
echo "$MUPIP load extr.zwr -format=bin"
$MUPIP load extr.zwr -format=bin
if ($status == 0 ) then
	echo "Previous command was supposed to fail"
	exit
endif
$gtm_tst/com/dbcheck.csh

################################
# Load with fake big key count (Test only for DEBUG)
################################
if ("dbg" == "$tst_image") then
	echo "# Load with fake big key count"
	setenv gtmgbldir "mumps.gld"
	echo "# gtm_tst/com/dbcreate.csh mumps 1"
	$gtm_tst/com/dbcreate.csh mumps 1
	# Do a few updates that so the white box case gets a key count the white box case will inflate
	$gtm_exe/mumps -run %XCMD "for i=1:1:150 set ^x(i)=1"
	echo "# MUPIP extract fextr.zwr -format=zwr"
	$MUPIP extract fextr.zwr -format=zwr
	echo "# MUPIP extract fextr.bin -format=bin"
	$MUPIP extract fextr.bin -format=bin
	# Setup white box test cases to get a fake big key count.
	echo "# Setup white box test cases WBTEST_FAKE_BIG_KEY_COUNT to get a fake big key count."
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_number 118
	setenv gtm_white_box_test_case_count 1
	# Load the file and verify the inflated key count is 2**32-100 + 150
	echo "# MUPIP load fextr.zwr"
	$MUPIP load fextr.zwr
	echo "# MUPIP load fextr.bin"
	$MUPIP load fextr.bin >&! fextrbinload.outx
	$grep -vE "Label =|at File offset" fextrbinload.outx
	$gtm_tst/com/dbcheck.csh
endif
