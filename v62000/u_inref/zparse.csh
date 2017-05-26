#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#########################################################################################
# Test that '..' in $gtmroutines and when provided to $zparse() is processed correctly. #
#########################################################################################

# Make sure that $gtm_dist points to the 'utf8' directory in case UTF-8 is enabled because
# we will be modifying $gtmroutines based on $gtm_dist value.
if ($?gtm_chset) then
	if (("UTF-8" == "$gtm_chset") && ($gtm_dist !~ *utf*)) setenv gtm_dist $gtm_dist/utf8
endif

set pwd = `pwd`
set dir = ${pwd:t}
set file = abc

# Create a shared library, so that $gtmroutines including, and $zparse() on, paths to it
# would succeed.
cat > $file.c <<EOF
int main()
{
 return 0;
}
EOF
$gt_cc_compiler $gt_cc_shl_options $file.c
$gt_ld_shl_linker ${gt_ld_option_output}lib${file}${gt_ld_shl_suffix} $gt_ld_shl_options $file.o $gt_ld_syslibs
set lib = lib${file}${gt_ld_shl_suffix}

# Specify a number of paths to directories and files containing '..' and what they should
# resolve to when supplied to $zparse().
#		Path with '..'		Resolved path
set paths = (	$pwd/..			${pwd:h}/	\
		$pwd/../		${pwd:h}/	\
		${pwd:h}/../.		${pwd:h:h}/	\
		$pwd/./..		${pwd:h}/	\
		$pwd/./../.		${pwd:h}/	\
		$pwd/./.././		${pwd:h}/	\
		$pwd/../../		${pwd:h:h}/	\
		$pwd/../$dir/		${pwd}/		\
		$pwd/../$dir/$lib	${pwd}/$lib	\
		$pwd/../$dir/./$lib	${pwd}/$lib	\
		$pwd/$lib/..		${pwd}/		\
		..			${pwd:h}/	\
		../			${pwd:h}/	\
		../.			${pwd:h}/	\
		./..			${pwd:h}/	\
		./../.			${pwd:h}/	\
		./.././			${pwd:h}/	\
		../../			${pwd:h:h}/	\
		../$dir/		${pwd}/		\
		../$dir/$lib		${pwd}/$lib	\
		../$dir/./$lib		${pwd}/$lib	\
		$lib/..			${pwd}/		\
		/tmp/..			/		)

@ count = $#paths
@ i = 0
@ mult = 0
@ success = 1

# Try every combination.
while ($i < $count)
	@ i = ($mult * 2) + 1
	set origPath = $paths[$i]
	@ i = $i + 1
	set expPath = $paths[$i]
	@ mult = $mult + 1

	# First, try GDE with $gtmroutines containing the chosen path.
	setenv gtmroutines ". $origPath $gtm_dist"
	$GDE >&! gde_$mult.log

	# Then, verify that $zparse() returns what we expect.
	$gtm_exe/mumps -run %XCMD 'write $zparse("'$origPath'")' > mumps_$mult.log
	if ("$expPath" != "`cat mumps_$mult.log`") then
		echo "TEST-E-FAIL, Test case $mult failed: expected '$expPath' but got '`cat mumps_$mult.log`'. See mumps_$mult.log for details."
		@ success = 0
	endif
end

if ($success) then
	echo "TEST-I-PASS, Test succeeded."
endif
