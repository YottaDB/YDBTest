#################################################################
#								#
# Copyright (c) 2004-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#! /usr/local/tcsh -f
#
#################################################
# C9D03-002250 Support Long Names
# Test all the M functions to work with long names
#################################################
echo "M function test starts ..."
$gtm_tst/com/dbcreate.csh .
setenv gtmgbldir xxx.gld
$GDE exit
setenv gtmgbldir mumps.gld
$GTM << gtm_eof
zlink "functionwithlongnamedvariables"
do ^functionwithlongnamedvariables
gtm_eof
################################################
#D9G12-002632 check zgetjpi should error out gracefully with incorrect item parameter
################################################
echo "################################################"
echo "Test zgetjpi should error out gracefully with incorrect item parameter"
$GTM << gtm_eof
do ^getjpi
gtm_eof
cat << EOF
################################################
# C9I06-003002 \$ZD does not properly format DAY of the week
################################################
EOF

$gtm_exe/mumps -run dollarzdate

if ($?gtm_chset) then
	if ("UTF-8" == "$gtm_chset") then
		$gtm_exe/mumps -run zdateunicode^dollarzdate
	endif
endif

echo '# Test cases for $VIEW("YGVN2GDS") and $VIEW("YGDS2GVN")'
source $gtm_tst/com/cre_coll_sl_reverse.csh 1
$gtm_exe/mumps -run viewygvn2gds

$gtm_tst/com/dbcheck.csh
echo "M functions test Done."
