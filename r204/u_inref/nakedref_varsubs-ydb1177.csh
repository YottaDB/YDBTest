#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

echo '# -------------------------------------------------------------------------------------------------------------'
echo '# Test naked reference optimization if GVN subscripts are unsubscripted local variables'
echo '# -------------------------------------------------------------------------------------------------------------'
echo

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps -null_subscripts=ALWAYS >& dbcreate.out
echo
# Descriptions and pointers derived from the list at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/873
set nakedb = "naked8b in:\n#  https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2928117803"
set nakedb = "${nakedb}\n#  https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2928178104"
set nakedb = "${nakedb}\n#  https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2931493706"
set nakedb = "${nakedb}\n#  https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2933909981"
set descriptions = ( \
	"in MR description at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782 where one subscript in the global reference is a local variable y" \
	"at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2900580851" \
	"naked8.m at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2900585936" \
	"naked8a in https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2906212967" \
	"$nakedb" \
	"naked10.m at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2900750298" \
	"naked11 in https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2903391035" \
	"naked12 in https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2903524681" \
	"at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2925315026" \
	"at https://gitlab.com/YottaDB/DB/YDB/-/issues/1177#todo-list" \
	"at https://gitlab.com/YottaDB/DB/YDB/-/issues/1177#note_2964158415" \
)
set expect_nogvdbgnakedmismatch = '# Expect no GVDBGNAKEDMISMATCH error. Previously, "%YDB-E-GVDBGNAKEDMISMATCH, Invalid GVNAKED in gv_optimize: $REFERENCE did not match OP_GVNAKED:'
set expect_gvnamenaked = "# Confirm OC_GVNAMENAKED present in machine instruction output.\n# Previously, this was omitted and OC_GVNAME instruction was output instead."
set outputs = ( \
	"$expect_gvnamenaked" \
	"$expect_gvnamenaked" \
	"$expect_nogvdbgnakedmismatch ^x(3,1) != ^x(1,1)."'" was issued' \
	"$expect_nogvdbgnakedmismatch ^x(2,1) != ^x(1,1)."'" was issued' \
	"# Confirm OC_GVNAMENAKED not present in machine instruction output, since the optimization is only performed when the local variable value is unchanged." \
	"$expect_nogvdbgnakedmismatch "'^x(1,2) != ^x(1,1,"R",2)"  was issued' \
	"$expect_nogvdbgnakedmismatch "'^x(1,2) != ^x(1,1,"R",2)"  was issued' \
	"$expect_nogvdbgnakedmismatch "'^x(1,2) != ^x(1,1,"R",2)"  was issued' \
	"$expect_gvnamenaked" \
	"$expect_gvnamenaked" \
	"# Expect no GVDBGNAKEDUNSET or GVNAKED errors. Previously, GVDBGNAKEDUNSET was seen in Debug builds and GVNAKED was seen in Pro builds." \
)

cp $gtm_tst/$tst/inref/ydb1177T5.m ./T5.m
echo "b() quit *b" >&! b.m
set T5_ops = ( \
	'set a=a+1 ; OC_ADD' \
	'set a=a-1 ; OC_SUB' \
	'set a=a*2 ; OC_MUL' \
	'set a=a\/0.5 ; OC_DIV' \
	'set a=a\0.5 ; OC_IDIV' \
	'set a=a#1 ; OC_MOD' \
	'set a=-a ; OC_NEG' \
	'set a=+(a-2) ; OC_FORCENUM' \
	'set a=a_2 ; OC_CAT' \
	'if $incr(a) ; OC_FNINCR' \
	'set b="a" if $incr(@b) ; OC_INDINCR' \
	'kill a ; OC_KILL' \
	'new @"a" ; OC_COMMARG' \
	'new a ; OC_NEWVAR' \
	'read a ; OC_READ' \
	'read *a ; OC_RDONE' \
	'read a#2 ; OC_READFL' \
	'set a=2 ; OC_STO' \
	'set $piece(a,"abcd",1)=2 ; OC_SETPIECE' \
	'kill (a) ; OC_XKILL' \
	'zkill a; OC_LVZWITHDRAW' \
	'set a=2 ; OC_STOLIT' \
	'set $piece(a,"2")=2 ; OC_SETZP1 and OC_SETP1: SETZP1 if M mode, SETP1 if UTF-8 mode' \
	'set $extract(a,"2")=2 ; OC_SETEXTRACT' \
	'merge a=b ; OC_MERGE_LVARG' \
	'set $zextract(a,"2")=2 ; OC_SETZEXTRACT' \
	'set $zpiece(a,"23")=2 ; OC_SETZPIECE' \
	'set *a=b ; OC_SETALS2ALS' \
	'set *a(1)=b ; OC_SETALSIN2ALSCT' \
	'set *a(1)=b(2) ; OC_SETALSCT2ALSCT' \
	'set *a=b(1) ; OC_SETALSCTIN2ALS' \
	'kill *a ; OC_KILLALIAS' \
	'set *a=\$\$^b ; OC_SETFNRETIN2ALS' \
	'set *a(1)=\$\$^b ; OC_SETFNRETIN2ALSCT' \
	'kill *  ; OC_KILLALIASALL' \
	'kill  ; OC_KILLALL' \
	'new (a) ; OC_XNEW' \
)

echo "# Compile [ydb1177.m] routine with -machine"
$gtm_dist/mumps -machine -list=ydb1177.lis $gtm_tst/$tst/inref/ydb1177.m
foreach tnum ( `seq 1 11` )
	echo
	if ($tnum == 5) then
		echo "### Test ${tnum}: See test case $descriptions[$tnum]"
		foreach opnum ( `seq 1 $#T5_ops` )
			set op = "$T5_ops[$opnum]"
			set opname = `echo -n "$op" | cut -f 2 -d ";" | sed 's/.*\(OC.*\)$/\1/g'`
			echo "## T${tnum}n${opnum}: $opname"
			sed "s/; REPLACE/$op/g" T${tnum}.m >&! T${tnum}n${opnum}.m
			if (("$op" =~ *kill*) || ("$op" =~ *new*)) then
				# If the operation is a KILL or a NEW, perform `set $etrap`
				# enable `incrtrap` to catch expected LVUNDEF errors.
				sed -i "s/REPLACE/1/g" T${tnum}n${opnum}.m
			else
				# Otherwise, disable `incrtrap`
				sed -i "s/REPLACE/0/g" T${tnum}n${opnum}.m
			endif
			echo "# Compile [^T${tnum}n${opnum}.m] routine with -machine"
			$gtm_dist/mumps -machine -list=T${tnum}n${opnum}.lis T${tnum}n${opnum}.m
			echo "# Run [T${tnum}n${opnum}] routine"
			$gtm_dist/mumps -r T${tnum}n${opnum} >& T${tnum}n${opnum}-mumps.out
			if ("$op" =~ *KILLALL*) then
				echo "# Expect LVUNDEF error in the OC_KILLALL case, since it is not possible to restore the local variable"
				echo "# without interfering with the OC_GVNAMENAKED optimization."
				$gtm_tst/com/check_error_exist.csh T${tnum}n${opnum}-mumps.out LVUNDEF
			endif
			if (($opnum == 29) || ($opnum == 30)) then
				echo "# Confirm OC_GVNAMENAKED present, per discussion at: https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2514#note_2972221662"
			else
				echo $outputs[$tnum]
			endif
			sed -n "/T$tnum ;/,/quit/p" T${tnum}n${opnum}.lis  | grep OC_GVNAME | sed 's/^.*;\(OC_.*\)/\1/g'
		end
	else
		echo "## Test ${tnum}: See test case $descriptions[$tnum]"
		echo "# Run [T${tnum}^ydb1177] label"
		$gtm_dist/mumps -r T${tnum}^ydb1177 >& T${tnum}-mumps.out
		if ($tnum == 11) then
			echo "# Expect MERGEDESC error (followed by GVUNDEF) in T${tnum}, since this is required to trigger "
			echo "# a previously issued GVDBGNAKEDUNSET that is no longer expected."
			$gtm_tst/com/check_error_exist.csh T${tnum}-mumps.out MERGEDESC GVUNDEF
		endif
		echo $outputs[$tnum]
		sed -n "/T$tnum ;/,/quit/p" ydb1177.lis | grep OC_GVNAME | sed 's/^.*;\(OC_.*\)/\1/g'
	endif
end

$gtm_tst/com/dbcheck.csh >& dbcheck.out
