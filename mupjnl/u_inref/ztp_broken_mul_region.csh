#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
$gtm_tst/com/dbcreate.csh mumps 4
setenv gtmgbldir "mumps.gld"
#
if ($?test_replic == 0) then
	$MUPIP set $tst_jnl_str -reg "*" >&! jnl_on.log
	$grep "YDB-I-JNLSTATE" jnl_on.log | sort
endif
#
$GTM << gtm_eof
	s (^a,^b,^c,^d)=1
	ztstart
	   s (^a(1),^b(1),^c(1),^d(1))=1
gtm_eof
#
#
echo "forward extract one......"
echo "mupip journal -forward -extract=tmp.mjf -broken=mumps.broken -lost=mumps.lost mumps.mjl,a.mjl,b.mjl,c.mjl"
$MUPIP journal -forward -extract=tmp.mjf -broken=mumps.broken -lost=mumps.lost mumps.mjl,a.mjl,b.mjl,c.mjl >>& ext_for1.log
set stat1=$status
$grep "successful" ext_for1.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "ztp_broken_mul_region TEST FAILED"
	cat ext_for1.log
	exit 1
endif
$grep "YDB-I-FILECREATE" ext_for1.log
if ($status != 0) then
	echo "ztp_broken_mul_region TEST FAILED"
	cat ext_for1.log
	exit 1
endif
echo "Verifying the extract file ..."
# Sort output since the order of journal records within a multi-region TP/ZTP transaction is non-deterministic
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' tmp.mjf | sort
echo "Verifying the broken file ..."
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' mumps.broken
#
echo "forward extract two......"
echo "mupip journal -forward -extract=a.mjf -broken=a.broken -lost=a.lost *"
$MUPIP journal -forward -extract=a.mjf -broken=a.broken -lost=a.lost "*" >>& ext_for2.log
set stat1=$status
$grep "successful" ext_for2.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "ztp_broken_mul_region TEST FAILED"
	cat ext_for2.log
	exit 1
endif
$grep "YDB-I-FILECREATE" ext_for2.log
if ($status != 0) then
	echo "ztp_broken_mul_region TEST FAILED"
	cat ext_for2.log
	exit 1
endif
echo "Verifying the extract file ..."
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' a.mjf | sort
echo "Verifying the broken file ..."
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' a.broken
#
echo "forward extract three......"
echo "mupip journal -forward -extract=a.mjf -broken=a.broken -lost=a.lost a.mjl,b.mjl,c.mjl,mumps.mjl"
$MUPIP journal -forward -extract=a.mjf -broken=a.broken -lost=a.lost a.mjl,b.mjl,c.mjl,mumps.mjl >>& ext_for3.log
set stat1=$status
$grep "successful" ext_for3.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "ztp_broken_mul_region TEST FAILED"
	cat ext_for3.log
	exit 1
endif
$grep "YDB-I-FILECREATE" ext_for3.log
if ($status != 0) then
	echo "ztp_broken_mul_region TEST FAILED"
	cat ext_for3.log
	exit 1
endif
echo "Verifying the extract file ..."
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' a.mjf | sort
echo "Verifying the broken file ..."
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' a.broken
#
echo "forward extract four......"
echo "mupip journal -forward -extract=c.mjf -broken=c.broken -lost=c.lost c.mjl,b.mjl,a.mjl,mumps.mjl"
$MUPIP journal -forward -extract=c.mjf -broken=c.broken -lost=c.lost c.mjl,b.mjl,a.mjl,mumps.mjl >>& ext_for4.log
set stat1=$status
$grep "successful" ext_for4.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "ztp_broken_mul_region TEST FAILED"
	cat ext_for4.log
	exit 1
endif
$grep "YDB-I-FILECREATE" ext_for4.log
if ($status != 0) then
	echo "ztp_broken_mul_region TEST FAILED"
	cat ext_for4.log
	exit 1
endif
echo "Verifying the extract file ..."
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' c.mjf | sort
echo "Verifying the broken file ..."
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' c.broken
#
$gtm_tst/com/dbcheck.csh -extract
