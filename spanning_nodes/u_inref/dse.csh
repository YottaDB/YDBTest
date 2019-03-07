#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Verify that special indices used by spanning nodes are properly displayed (#SPAN1)
# Verify that sn can be found with "find -key"

$GDE change -region DEFAULT -null_subscripts=always -stdnull -rec=6000
$gtm_exe/mupip create

$GTM <<EOF
set ^nsgbl="BEGIN"_\$JUSTIFY(" ",5000)_"END"
set ^nsgbl(1)="BEGIN"_\$JUSTIFY(" ",5500)_"END"
set ^nsgbl("erdeniz")="BEGIN"_\$JUSTIFY(" ",5500)_"END"
EOF

echo "#SPAN1 tag exists for global ^ngbl?"
set blockno=`$gtm_exe/dse find -key="^nsgbl" | & $tst_awk '{if ($1=="Key") {print $5}}' | tr -d "\."`
$gtm_exe/dse dump -block=$blockno | & $grep -c "\#SPAN1"
echo "#SPAN1 tag exists for global ^ngbl(1)?"
set blockno=`$gtm_exe/dse find -key="^nsgbl(1)" | & $tst_awk '{if ($1=="Key") {print $5}}' | tr -d "\."`
$gtm_exe/dse dump -block=$blockno | & $grep -c "\#SPAN1"
echo '#SPAN1 tag exists for global ^ngbl("erdeniz")?'
set blockno=`$gtm_exe/dse find -key='^nsgbl("""erdeniz""")' | & $tst_awk '{if ($1=="Key") {print $5}}' | tr -d "\."`
$gtm_exe/dse dump -block=$blockno | & $grep -c "\#SPAN1"
