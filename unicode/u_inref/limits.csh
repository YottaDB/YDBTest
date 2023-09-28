#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Disable use of V6 mode DBs using random V6 versions to create DBs as this causes MUNOSTRMBKUP warning that is
# searched for by the test (not just a reference file issue).
setenv gtm_test_use_V6_DBs 0
#
# Test for limits on string length, source line length, db keysize, db record size.
# because of larger block size we will end up with a YDB-W-MUNOSTRMBKUP warning and hence a subsequent dbcreate error
# to avoid it from getting displayed redirect the output and have it checked instead.
#
$gtm_tst/com/dbcreate.csh mumps 1 -key=255 -rec=32767 -blk=65024 -alloc=10 -glo=64 >&! redirected_dbcreate.out
cat dbcreate.out
$gtm_tst/com/check_error_exist.csh redirected_dbcreate.out "YDB-W-MUNOSTRMBKUP" "TEST-E-DBCREATE"
$gtm_tst/com/check_error_exist.csh dbcreate.out "YDB-W-MUNOSTRMBKUP"
#
$echoline
# 1 MB string length limit
$gtm_exe/mumps -run ^error1MB
#
$echoline
# 32766 byte source code line length limit
# All the usage of awk to generate string, redirect to file and use it to generate m routine is because
# setting into a variable is not possible because of tcsh shell limits
#
# 32751 is based on a calculation that if two unicode literals are added to str
# along with the write statement in the routine will exceed 32766 bytes
echo ""|$tst_awk '{ for (i=0;i<32751;i++) printf "a"}' > str.out
#
# 8188 * 4 = 32752 ==> add some more literals to have it in threshold for an error and no error respectively.
echo ""|$tst_awk '{ for (i=0;i<8188;i++) printf "𝐀"}' > strunicode.out
# database key and record size limit - construct a record and key that has the maximum bytes
#
echo ""|$tst_awk '{i=0;while(i<32762) {printf "a";i++}}' > maxreclength.out
echo ""|$tst_awk '{i=0;while(i<247) {printf "a";i++}}' > maxkeylength.out
echo ""|$tst_awk '{print "";i=0;while(i<247) {printf "b";i++}}' >> maxkeylength.out
$convert_to_gtm_chset maxreclength.out
$convert_to_gtm_chset maxkeylength.out
foreach check (noerror error)
	if ( "error" == $check ) then
		# add two byte characters to str
		setenv str2byte "£ęA"
		# add three byte characters to str
		setenv str3byte "ஊAA"
		# add a four byte and two byte character to str
		setenv str4byte "𝐀A"
		# add one more byte to this 4 byte unicode string cross 32766
		set rec="ಚಘ"
		set key="ఉఏ"
		set foruni="¥¥"
	else
		# keep within the limit of 32766 bytes - it should not croak
		setenv str2byte "£ę"
		setenv str3byte "ஊA"
		setenv str4byte "𝐀"
		set rec="ಚ"
		set key="ఉ"
		set foruni="¥"
	endif
#
	foreach bytestr (str2byte str3byte str4byte strunicode1)
		echo "$bytestr""$check	;"			>&! $bytestr$check.m
		if ("strunicode1" == $bytestr) then
			echo '	write "'`cat strunicode.out`$foruni'",!'	>>&! $bytestr$check.m
		else
			set writestr=`echo echo \$${bytestr} | $tst_tcsh`
			echo '	write "'`cat str.out`$writestr'",!'		>>&! $bytestr$check.m
		endif
		echo "	quit"					>>&! $bytestr$check.m
		# error expected on the routine when it gets executed because of source line length > 32766 bytes
$GTM << gtm_eof >&! $bytestr$check.out
do ^$bytestr$check
gtm_eof
		# check and filter out the known expected errors
		if ( "error" == $check ) $gtm_tst/com/check_error_exist.csh $bytestr$check.out "YDB-W-LSINSERTED" "YDB-E-LSEXPECTED" "YDB-E-EXPR"
	end
#
$GTM << gtm_eof >&! rec_$check.out
set file="maxreclength.out"
open file
use file
read x
close file
set ^a=x_"$rec"
gtm_eof
#
$GTM << gtm_eof >&! key_$check.out
set file="maxkeylength.out"
open file
use file
read x
read y
close file
set ^a(x_"$key")="VALUE PLEASE"
if ""'=\$reference write !,"\$REFERENCE should be empty, but is: ",\$reference
if \$data(^a(1))		; set up for a naked reference
set ^(y_"$key")="VALUE PLEASE"
gtm_eof
	# check and filter out the known expected errors
	if ( "error" == $check ) then
		$gtm_tst/com/check_error_exist.csh rec_$check.out "YDB-E-REC2BIG"
		$gtm_tst/com/check_error_exist.csh key_$check.out "YDB-E-GVSUBOFLOW"
	endif
end
$gtm_tst/com/dbcheck.csh
#
