#!/usr/local/bin/tcsh -f
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
############################################################
# Create file.txt (outref.txt) from file.log     #
# Run in individual test result directory (e.g. jnl, tp)   #
# after doing "ver version variant" and defining gtm_test  #
#     (though the script tries to figure stuff out)        #
# Gets information from where it is run and ../config.log  #
# For subtests copy output file to the same place as       #
# outstream.log.					   #
# USAGE: inref.csh outstream         #
# USAGE: inref.csh jnl1         #
# USAGE: inref.csh jnl2         #
############################################################
#
if (`basename $0` == $0) then
   setenv source_dir "$PWD"
else
   setenv source_dir `dirname $0`
endif

if ($1 == "")  then
	echo "Usage: inref.csh <output_file without extension>"
	exit
endif
set here = `pwd`
set tmpcsh = env.csh_$$
if (-e $subtest/env.txt.gz) then
	gunzip $subtest/env.txt.gz
endif
if (! -e $subtest/env.txt) then
	echo "$subtest/env.txt* not found"
	exit 1
endif
sed 's/^/setenv /;s/=/ "/;s/$/"/' $subtest/env.txt > $tmpcsh
source $tmpcsh
$tst_awk -f $source_dir/inref.awk $here/$1.log >! $1.txt
