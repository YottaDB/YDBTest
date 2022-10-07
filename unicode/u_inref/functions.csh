#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
######################################################################################################################################
# The subtest will test the below listed functions for unicode applicability and general behavior with and without unicode strings.
# The subtest will make use of unicodesampledata.m to load some M arrays with unicode strings and its corresponding decimal represenation.
# This will be used to compare the results of the functions
# Following functions will be tested in this subtest
# > $ZASCII,$ASCII
# > $ZCHAR,$CHAR
# > $ZEXTRACT,$EXTRACT
# > $ZFIND,$FIND
# > $ZJUSTIFY,$JUSTIFY
# > $ZLENGTH,$LENGTH
# > $ZPIECE,$PIECE
# > $ZTRANSLATE,$TRANSLATE
# > $ZCONVERT
# > $ZSUBSTR
# > $ZWIDTH
# > $ZPATNUMERIC
######################################################################################################################################
# Common section:
# unicodesampledata will hold all the values in a local variable.We should populate them to globals and use it throughout this test
# to avoid repeated calls to the routine
$echoline
echo "A SPECIAL NOTE FOR THIS SUBTEST REFERENCE FILE:"
echo 'use "more" or "less" command to view the test output which will be more revealing and interesting!'
$echoline
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 1024
# disable badchar behavior when we fill the database because it will cause compilation error otherwise
$GTM << EOF >&! unicodesampledata_with_warns.outx
view "NOBADCHAR"
do global^unicodesampledata
EOF
#
$tst_awk -f $gtm_tst/com/filter_litnongraph.awk unicodesampledata_with_warns.outx
# end of common section
#
# For zconvert testing we need to trigger convert.awk that creates convert.m routine dynamically. This routine will be used #BYPASSOK
# to check for conversion results of the strings present in there.
$tst_awk -f $gtm_tst/com/convert.awk $gtm_tst/com/special_casing.txt
# NOTE: All systems may not have the list of locales listed in special_casing.txt, so check for its availability and comment out the piece if not present
set localeinfo=`$tst_awk -F'"' '/localearray/ {print $2}' convert.m`
# NOTE: For now there is only one additional locale that is getting tested which is Turkish. In future if we choose to add
#	more in special_casing.txt then do a foreach here and comment out accordingly.
# scylla's locale -a gives binary output and grep needs -a option to get the actual value instead of "Binary file (standard input) matches"
# but -a is not supported on non-linux servers.
if ("Linux" == "$HOSTOS") then
	set binaryopt = "-a"
else
	set binaryopt = ""
endif
if !(`locale -a | $grep -c $binaryopt $localeinfo`) then
	# comment the missing locale from convert.m
	$tst_awk '{ if ($0~/localearray/) print ";"$0;else print $0}' convert.m >&! /tmp/convert.m
	\mv /tmp/convert.m convert.m
endif

######################################################################################################################################
#
# Ready the reference files needed by the "zconvert" iteration of the below "foreach" loop.
cp $gtm_tst/$tst/outref/longstrM.out longstrM.cmp
cp $gtm_tst/$tst/outref/longstrUTF-8.out longstrUTF-8.cmp
# The "zconvert" iteration of the foreach loop below produces different output in UTF-8 mode for ICU versions >= 64.2 and < 64.2.
# The 64.2 output is the correct one where for title-case output only the first letter in a word has upper-case and all the rest
# are in lower-case. So use the incorrect version only if the current box has ICU version < 64.2. Or else use the default version.
if (1 == `echo "if ($gtm_tst_icu_numeric_version < 64) 1" | bc`) then
	cp $gtm_tst/$tst/outref/longstrUTF-8_pre_ICU_64.out longstrUTF-8.cmp
endif
#
foreach function("zascii" "zchar" "zextract" "zfind" "zjustify" "zlength" "zpiece" "ztranslate" "zconvert" "zsubstr" "zwidth")
	$echoline
	echo "Testing $function for unicode support when ZCHSET is UTF-8"
	$switch_chset "UTF-8"
$GTM << eof >&! ${function}_with_warns.outx
write "On default BADCHAR behavior"
do ^$function
eof
	$tst_awk -f $gtm_tst/com/filter_litnongraph.awk ${function}_with_warns.outx
$GTM << eof
write "On NOBADCHAR behavior"
view "NOBADCHAR"
do ^$function
eof
#
	$echoline
	echo "Testing $function when gtm_chset is not defined, should behave the same way as M"
	$switch_chset
$GTM << eof
write "On default BADCHAR behavior"
do ^$function
eof
$GTM << eof
view "NOBADCHAR"
write "On NOBADCHAR behavior"
do ^$function
eof
#
end
#
echo "Testing zpatnumeric for unicode support"
# zpatnumeric testing depends on one other env. variable gtm_numeric. So the test code is separated
# from the rest of the above functions
foreach mode("UTF-8" "M")
	echo "Test Switching to $mode"
	$switch_chset $mode
	foreach num_mode("UTF-8" "M")
		if ("" == $num_mode) then
			echo "unsetenv gtm_patnumeric"
			source $gtm_tst/com/unset_ydb_env_var.csh ydb_patnumeric gtm_patnumeric
		else
			echo "setenv gtm_patnumeric $num_mode"
			source $gtm_tst/com/set_ydb_env_var_random.csh ydb_patnumeric gtm_patnumeric $num_mode
		endif
$GTM << eof
write "On default BADCHAR behavior"
do ^zpatnumeric
eof
$GTM << eof
write "On NOBADCHAR behavior"
view "NOBADCHAR"
do ^zpatnumeric
eof
#
	end
end

if ( "dbg" == "$tst_image" ) then
	$switch_chset "UTF-8"
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_number 124
	$gtm_exe/mumps -run %XCMD 'w $zconvert("a","T")'
endif

#
echo "END OF TEST"
######################################################################################################################################
$gtm_tst/com/dbcheck.csh
