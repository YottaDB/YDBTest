#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Portions Copyright (c) 2003-2015 Fidelity National Information#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo ""
echo "------------------------------------------------------------"
echo '# ^%RSEL/^%RD now include routines in shared library files'
echo '# Previously they did not'
echo ""

echo '# Creating a bunch of routines: a,ab,b,ca,cb,t,rtn1,zz,%TU'
echo '# %TU is there to sort in between the files in libyottadbutil.so'
mkdir rtns
foreach i (a ab b ca cb t rtn1 zz _TU)
	set fname = "rtns/${i}.m"
	echo "`echo $i | tr _ %`	;; " >&! $fname
	echo "	;; This is the description for $i" >>&! $fname
	echo "	; Some more description" >>&! $fname
	echo "	; Yet more description" >>&! $fname
	echo "	; Yada yada ya	da" >>&! $fname
	echo "	; Yada yada ya	da" >>&! $fname
	echo '	w "This is '$i'",!' >>&! $fname
	echo '	w "Some text here",!' >>&! $fname
	echo "	q" >>&! $fname
end

echo '# Compiling routines'
$gtm_dist/mumps rtns/*.m

echo '# Linking the a,ab,b routines into a shared library'
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib$gt_ld_shl_suffix a.o ab.o b.o ${gt_ld_m_shl_options} >& incr_link_ld.outx

echo '# Removing the sources and objects for a,ab,b'
rm rtns/{a,ab,b}.m
rm {a,ab,b}.o

echo "# Setting gtmroutines to .(./rtns .) shlib$gt_ld_shl_suffix $gtm_exe/libgtmutil.so or $gtm_exe/libyottadbutil.so"

setenv gtmroutines ".(./rtns .) shlib$gt_ld_shl_suffix $gtm_exe/libgtmutil.so"
# if the chset is UTF-8 over write gtmroutines as appropriate
# shlib.so will be in UTF-8 mode already, so it doesn't need to be overwritten
if ($?gtm_chset) then
	if ("UTF-8" == $gtm_chset) setenv gtmroutines ".(./rtns .) shlib$gt_ld_shl_suffix $gtm_exe/utf8/libyottadbutil.so"
endif

echo "# ^%RD (sources)"
$GTM << EOF
D ^%RD

EOF

echo ""
echo "# OBJ^%RD (objects)"
$GTM << EOF
D OBJ^%RD

EOF

echo ""
echo "# OBJ^%RD (objects range a:d)"
$GTM << EOF
D OBJ^%RD
a:d
EOF

echo ""
echo "# OBJ^%RD (multiple selections: a*, b*, r*)"
$GTM << EOF
D OBJ^%RD
a*
b*
r*
EOF

echo ""
echo '# DO SILENT^%RSEL("*","OBJ") ZWRITE %ZR'
$gtm_exe/mumps -run %XCMD 'DO SILENT^%RSEL("*","OBJ") ZWRITE %ZR'

echo ""
echo '# Test that ? syntax works: GDE???'
$GTM << EOF
D OBJ^%RD
GDE???
EOF


echo ""
echo '# Test that %RSEL with VIEW "NEVERNULLSUBS" does not fail'
setenv gtm_lct_stdnull 1
setenv gtm_lvnullsubs 2
$GTM << EOF
D OBJ^%RD
D:zzz
EOF
