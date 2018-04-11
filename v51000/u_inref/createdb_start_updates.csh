#! /usr/local/bin/tcsh -f
#################################################################
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
# This module is derived from FIS GT.M.
#################################################################

#
###################
# Initializations #
###################
#
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
# This script creates databases with larger blocksizes. If the randomly chosen align size is too small,
# mupip will error out with YDB-W-JNLALIGNTOOSM. So disable the randomly chosen align size
setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`
#
#On linux the limit to shared memory is 32MB
# To compensate the increase in the size in database block size limit global buffers to 512
$gtm_tst/com/dbcreate.csh mumps 4 255 32240 32256 -global_buffer_count=512
#Increase the default journal buffer size from 64K(128 blocks) to about 16 Mb. Since this test runs
#with large GDS block size(32k) and since every update fills almost one GDS block, two updates will cause
#the journal buffer to be full. This in turn will decrease the throughput to a great extent.
#This not acceptable as the test normally runs in a tight loop
if ("$tst_jnl_str" != "") then
	echo "# `date`" >>&! jnl_buffset.log
	$MUPIP set $tst_jnl_str,buffer_size=32004 -region "*" >>&! jnl_buffset.log
endif
$GTM << gtm_eof
s ^stop=0
do ^largeupdates
set ^permissionchanged=0,^afterchangeupdate=0
h
gtm_eof
# start GT.M processes at the background
($gtm_tst/$tst/u_inref/mu_set_bg.csh $argv >>& bkgrndset.out&) >&! bgset.log
# $gtm_tst/com/dbcheck.csh executed by main script, retry_driver.csh
