#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.  #
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#[smw] 09/10/12 I can see problems sending bin format to stdout on z/OS.  Not an immediate concern but it should be noted

$gtm_tst/com/dbcreate.csh mumps 1 125 10000

set utfmode = 0
if ($?gtm_chset) then
    if ("UTF-8" == "$gtm_chset") then
	set utfmode = 1
    endif
endif


if ($utfmode) then
    set payload = '"D我能吞下玻璃而不伤身体"'
else
    set payload = '""'
endif

$GTM << xyz
for i=1:5:2000  s ^var("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv",i)=i_$payload
for i=851:5:926  K ^var("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv",i)
h
xyz
echo "zwr format"
echo "----------"
$gtm_exe/mupip extract -format=zwr -stdout > stdextract.zwr
$gtm_exe/mupip extract -format=zwr filextract.zwr

# go format is not supported in UTF-8 mode
if (! $utfmode) then
    echo "go format"
    echo "---------"
    $gtm_exe/mupip extract -format=go -stdout > stdextract.go
    $gtm_exe/mupip extract -format=go filextract.go
endif

echo "bin format"
echo "---------"
$gtm_exe/mupip extract -format=bin -stdout > stdextract.bin
$gtm_exe/mupip extract -format=bin filextract.bin

echo "Comparing zwr"
$gtm_tst/com/extractdiff.csh filextract.zwr stdextract.zwr

if (! $utfmode) then
    echo "Comparing go"
    $gtm_tst/com/extractdiff.csh filextract.go stdextract.go
endif

echo "Comparing bin"
$gtm_tst/com/extractdiff.csh filextract.bin stdextract.bin

$gtm_tst/com/dbcheck.csh
