#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "###########################################################################################################"
echo '# Test shebang support of yottadb'
echo "###########################################################################################################"

echo '# Add [$gtm_dist] to PATH so .m programs can be found when invoked from the shell'
set path = ($gtm_dist $path)
set savepath = "$path"

echo "# Run [dbcreate.csh]"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

set cmd = "ydbsh"
set basename = "ydb1084"
set filename = $basename.m
cat > $filename << CAT_EOF
#!/usr/bin/env $cmd
 if \$increment(^x)
 zwrite ^x
 zwrite \$zroutines
CAT_EOF

@ expect = 0

echo "# Set [gtmroutines=..] to ensure . is not part of gtmroutines for the rest of the test"
set save_gtmroutines = "$gtmroutines"
setenv gtmroutines ".."

echo "# Set [gtm_tmp=.] to ensure temporary object subdirectory gets created under current directory"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_tmp gtm_tmp `pwd`

chmod +x $filename
foreach type ("NO" "RELATIVE" "ABSOLUTE")
	echo "-------------------------------------------------------------------"
	@ expect = $expect + 1
	echo "# Test $expect : Invoke shebang with $type path. Expect output of [^x=$expect]"
	echo '# Also test that even though $filename cannot be found in $ZROUTINES, no error issued'
	echo '# And a temporary object directory is created and added to $ZROUTINES at process startup'
	echo '# And the source directory (current directory) is also added to $ZROUTINES'
	echo "# Also verify correct PATH of $filename was chosen by looking at "'$zroutines'
	if ($type == "NO") then
		$filename
	else if ($type == "RELATIVE") then
		./$filename
	else
		`pwd`/$filename
	endif
	echo "# Verify that .o file does NOT get created in current directory"
	if (! -e $basename.o) then
		echo "Verification PASS"
	else
		echo "Verification FAIL"
	endif
end

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Verify shebang line is accepted in M program as the first line even if not invoked through shebang"
echo "# This also tests that [$cmd] when invoked outside of shebang also treats it as a shebang invocation."
echo "# Run [$cmd $filename]. Expect no errors."
$cmd $filename

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Test that [yottadb $filename] also works fine even it has a shebang line and is not invoked through $cmd"
echo "# Run [yottadb $filename]. Expect no errors."
$cmd $filename

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Verify [$cmd] issues error if .m has only one shebang line that is not in the first line"
set filename = ${basename}${expect}.m
cat > ${filename} << CAT_EOF

#!/usr/bin/env $cmd
CAT_EOF

chmod +x $filename
echo "# Run [$filename]. Expect LSEXPECTED error."
$cmd $filename

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Verify [$cmd] issues error if .m has more than one shebang line"
set filename = ${basename}${expect}.m
cat > ${filename} << CAT_EOF
#!/usr/bin/env $cmd
 write "Dummy line before the runtime LSEXPECTED error",!
#!/usr/bin/env $cmd
CAT_EOF

chmod +x $filename
echo "# Run [$filename]. Expect LSEXPECTED error."
$cmd $filename

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Verify [$cmd $filename] issues error if $filename does not have xecute permissions"
chmod -x $filename
echo "# Run [$cmd $filename]. Expect RUNPARAMERR error."
$cmd $filename

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Verify [$cmd $filename] issues error even if $filename has xecute permissions because PATH env var"
echo "# does not include the path where $filename can be located"
set path = `echo $path | sed 's/ \.//g;'`	# Temporarily modify PATH to remove current directory
chmod +x $filename
echo "# Run [$cmd $filename]. Expect RUNPARAMERR error."
$cmd $filename
set path = ($savepath)	 # Restore PATH for later tests

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
set filename = ${basename}${expect}.m
echo "# Test $expect : Test a runtime error in shebang M program results in process termination (and not direct mode)"
echo "# Also test that the exit status is non-zero after ydbsh returns to the shell"
echo "# Run [$cmd $filename]. Expect RUNPARAMERR error."
cat > ${filename} << CAT_EOF
#!/usr/bin/env $cmd
 write x
 write "Should not see this line",!
CAT_EOF

chmod +x $filename
echo "# Run [$cmd $filename]. Expect LVUNDEF error."
$cmd $filename
set actualstatus = $status
set expectstatus = 218
if ($expectstatus == $actualstatus) then
	echo "PASS: LVUNDEF error exit code of [$expectstatus] was expected and seen"
else
	echo "FAIL: LVUNDEF error exit code of [$expectstatus] was expected but actual exit code seen was [$actualstatus]"
endif

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Test that error inside shebang invocation is controlled by ydb_etrap or gtm_etrap if either"
echo "# is set before the $cmd invocation. Also test that the process does not terminate like it otherwise would"
echo "# if those env vars are not defined if the ydb_etrap/gtm_etrap error trap does not cause a termination."

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_etrap gtm_etrap 'write "PASS: ydb_etrap/gtm_etrap executed as expected",! zhalt 0'
echo "# Run [$cmd $filename]. Expect NO error."
$cmd $filename
set actualstatus = $status
set expectstatus = 0
if ($expectstatus == $actualstatus) then
	echo "PASS: Exit code of [$expectstatus] was expected and seen"
else
	echo "FAIL: Exit code of [$expectstatus] was expected but actual exit code seen was [$actualstatus]"
endif
source $gtm_tst/com/unset_ydb_env_var.csh ydb_etrap gtm_etrap

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
set filename = ${basename}${expect}.m
echo "# Test $expect : Test that if $filename is shebanged from current directory but "'$gtmroutines'" has a subdirectory"
echo "# ahead of current directory and $filename is found in the subdirectory too, then "'$zroutines'" inside the shebang"
echo '# execution shows a temporary object directory is created and added to $ZROUTINES at process startup'
echo '# And the source directory (current directory) is also added to $ZROUTINES'

cat > ${filename} << CAT_EOF
#!/usr/bin/env $cmd
 zwrite \$zroutines
CAT_EOF

chmod +x $filename
mkdir tmp_$expect
cp $filename tmp_$expect
setenv gtmroutines "tmp_$expect ."
echo "# Run [$filename]"
$filename
setenv gtmroutines ".."

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Test that if object file of $filename can be found in a shared library in "'$gtmroutines'","
echo "# the shebanged copy of $filename is picked up and not the shared library version even if a later directory in"
echo '# $gtmroutines contains the source directory corresponding to '$filename'. Also check that'
echo '# no error is issued but a temporary object directory is created and added to $ZROUTINES at process startup'
echo '# And the source directory (current directory) is also added to $ZROUTINES ahead of the shared library'

cp $filename $filename.orig
echo ' write "Should not see this line as it is only in .so",!' >> $filename
$gtm_dist/mumps $filename
set base = $filename:r
$gt_ld_m_shl_linker ${gt_ld_option_output} ${base}$gt_ld_shl_suffix ${base}.o ${gt_ld_m_shl_options} >& link_ld.outx
setenv gtmroutines "$base.so ."
cp $filename $filename.new
cp $filename.orig $filename
rm $base.o
echo "# Run [$filename]"
$filename
setenv gtmroutines ".."

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
set filename = ${basename}${expect}.m
echo "# Test $expect : Test of "'$ZCMDLINE'" when absolute path is specified in shebang invocation"
echo "# Expect to see absolute path of $filename as first word in "'$ZCMDLINE'

cat > ${filename} << CAT_EOF
#!/usr/bin/env $cmd
 zwrite \$zcmdline
CAT_EOF

chmod +x $filename
echo "# Run [`pwd`/$filename]"
`pwd`/$filename
echo "# Run [`pwd`/$filename param1 param2]"
echo "# Also expect to see [param1 param2] as remaining part of "'$ZCMDLINE'
`pwd`/$filename param1 param2

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Test of "'$ZCMDLINE'" when absolute path is NOT specified in shebang invocation"
echo "# Expect to see $filename without any path as first word in "'$ZCMDLINE'
echo "# Run [$filename]"
$filename
echo "# Run [$filename param1 param2]"
echo "# Also expect to see [param1 param2] as remaining part of "'$ZCMDLINE'
$filename param1 param2

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Test SHEBANGMEXT error is issued if there is no .m extension in the M program name"
set base = $filename:r
foreach extension ("" "." ".nom")
	cp $filename ${base}.nom
	echo "# Run [${base}.nom]. Expect a SHEBANGMEXT error."
	${base}.nom
end

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Test NOTMNAME error is issued if there are underscores in M program name"
cp $filename ${base}_$expect.m
echo "# Run [${base}_$expect.m]. Expect a NOTMNAME error."
${base}_$expect.m

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Test NOTMNAME error is issued if the M program name is longer than 31 characters"
set badname = "abcdefghijklmnopqrstuvwxyz789012.m"
cp $filename $badname
echo "# Run [$badname]. Expect a NOTMNAME error as routine name is 32 characters long."
$badname
set goodname = "abcdefghijklmnopqrstuvwxyz78901.m"
cp $filename $goodname
echo "# Run [$goodname]. Expect no NOTMNAME error (but instead "'$ZCMDLINE'" output) as routine name is 31 characters long."
$goodname

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
set filename = ${basename}${expect}.m
echo "# Test $expect : Test "'$ZROUTINES'" when M program source directory is in "'$gtmroutines'
echo "# Verify that "'$ZROUTINES'" is identical to "'$gtmroutines'" in that no new temporary object"
echo "# directory or the M program source directory got added to it"

cat > ${filename} << CAT_EOF
#!/usr/bin/env $cmd
 zwrite \$zroutines
CAT_EOF

chmod +x $filename
setenv gtmroutines "."
echo "# Run [$filename]"
$filename
setenv gtmroutines ".."

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Test "'$ZROUTINES'" when M program source directory is NOT in "'$gtmroutines'
echo "# Verify that "'$ZROUTINES'" is different from "'$gtmroutines'" in that it contains temporary object"
echo "# directory and the M program source directory added to it"
echo "# Run [$filename]"
$filename

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
echo "# Test $expect : Test that temporary object directory is /tmp if ydb_tmp/gtm_tmp are not set"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_tmp gtm_tmp
echo "# Run [$filename]"
$filename

echo "-------------------------------------------------------------------"
@ expect = $expect + 1
set filename = ${basename}${expect}.m
echo "# Test $expect : Test case where shebang M program does a [do] of another M program [helper.m] and that is linked in fine"
echo "# This is to test that deleting the temporary object directory before starting shebang execution of $filename"
echo '# (happens in YDB, search for "rm -rf" in YDB/sr_unix/jobchild_init.c) does not interfere with zlink of other'
echo "# M programs as needed. Also test that the object directory does not exist at start of $filename execution."

setenv gtm_tmp "."
setenv gtmroutines "tmp"
mkdir tmp
cat > ${filename} << CAT_EOF
#!/usr/bin/env $cmd
 zwrite \$zroutines
 write "Object directory path is [",\$zsearch(\$piece(\$zroutines,"(",1)),"] : Expect to see empty string here.",!
 do ^helper
CAT_EOF

echo ' write "PASS: In helper.m as expected",!' >> tmp/helper.m

chmod +x $filename
echo "# Run [$filename]"
$filename
unsetenv gtm_tmp

setenv gtmroutines "$save_gtmroutines"

echo
echo "# Run [dbcheck.csh]"
$gtm_tst/com/dbcheck.csh >>& dbcheck.out

