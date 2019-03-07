#!/usr/local/bin/tcsh
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
# Initially the collation library was to support multiple encodings.  This is
# why this script take input variables to build more than one library.

set colnum=$1
if ("" == "$colnum") then
	set colnum=1
endif

if ("$2" == "") then
	set build="-DHINDI "
	set slname="libhindinum"
else
	set build="-D$2 "
	set slname=`echo $2 | tr '[A-Z]' '[a-z]'`
	set slname="lib${slname}num"
endif

if (-e ${slname}${gt_ld_shl_suffix}) \rm ${slname}${gt_ld_shl_suffix}
cp $gtm_tst/com/col_unicode_numeric.c .

echo "Compile" >> ${slname}.log
echo "$gt_cc_compiler $gt_cc_option_I $gtt_cc_shl_options -I$gtm_inc ${build} col_unicode_numeric.c" >>& ${slname}.log
$gt_cc_compiler $gt_cc_option_I $gtt_cc_shl_options -I$gtm_inc ${build} col_unicode_numeric.c >>& ${slname}.log

echo "Link" >> ${slname}.log
echo "$gt_ld_shl_linker ${gt_ld_option_output}${slname}${gt_ld_shl_suffix} $gt_ld_shl_options col_unicode_numeric.o" >>& ${slname}.log
$gt_ld_shl_linker ${gt_ld_option_output}${slname}${gt_ld_shl_suffix} $gt_ld_shl_options col_unicode_numeric.o >>& ${slname}.log

# if the shared library does not exit, cat the log file and exit
ls ${slname}${gt_ld_shl_suffix} >& /dev/null || cat ${slname}.log && exit

set col_n = "gtm_collate_$colnum"
setenv $col_n $PWD/${slname}${gt_ld_shl_suffix}
echo setenv $col_n '$PWD/'${slname}${gt_ld_shl_suffix} >> sourceme.env
# for local variables setenv gtm_local_collate $1
