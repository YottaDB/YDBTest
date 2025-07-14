#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# NOTE: In canonical mode, the buffer is supplied by the tty driver when using
# fgets/u_fgets (interactively), and is smaller than MAX_LINE
# From the termios man page:
#   In canonical mode:
#     The maximum line length is 4096 chars (including the terminating newline
#     character); lines longer than 4096 chars are truncated. After 4095
#     characters, input processing (e.g., ISIG and ECHO* processing) continues,
#     but any input data after 4095 characters up to (but not including) any
#     terminating newline is discarded. This ensures that the terminal can
#     always receive more input until at least one line can be read.

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

echo "# Test that command utilities with input that is too long, return errors, rather than truncate"
echo "# This tests LKE, DSE, and MUPIP interactively, with readline off (r200/ydb88_08 tests them with readline)"
echo "# It tests LKE, DSE, MUPIP, GTCM_GNP_SERVER, and YOTTADB with readline on and off, from the command line"
echo "# It tests everything using the UTF-8 charset and the M charset, as well as multiple commands, very long and random strings"

# Set environment for tests
setenv TERM xterm
unsetenv gtm_prompt

# Set array for readline info pretty display
set readline = (off on)

# The MAX_LINE limit is 32768 + 256 = 33024
set under_32k = `perl -le "print 'x' x 32000"`
echo $under_32k >> perl.out
set at_32k = `perl -le "print 'x' x 33023"`
echo $at_32k >> perl.out
set over_32k = `perl -le "print 'x' x 34000"`
echo $over_32k >> perl.out

# Note down incoming gtm_chset before playing with it in the below script.
if ($?gtm_chset) then
	set save_chset = $gtm_chset
else
	set save_chset = ""
endif

foreach chset (UTF-8 M)
	# Set the environment variable to avoid $chset from being modified
	setenv gtm_chset $chset

	# Set the YottaDB character set
	$switch_chset $gtm_chset >&! switch_$chset.log

	# Set the locale to UTF-8
	if ("UTF-8" == $chset) then
		setenv LC_CTYPE en_US.utf8
	else
		setenv LC_CTYPE C
	endif

	# Recompile ydb1048 and %XCMD for current charset
	$gtm_dist/yottadb $gtm_tst/r202/inref/ydb1048.m
	$gtm_dist/yottadb $gtm_dist/_XCMD.m

	# The MAX_LINE limit is 32768 + 256 = 33024
	$gtm_dist/yottadb -run ydb1048 33023 $chset > ydb1048_at_32k_rnd_$chset.txt
	$gtm_dist/yottadb -run ydb1048 33100 $chset > ydb1048_over_32k_rnd_$chset.txt
	$gtm_dist/yottadb -run ydb1048 330000 $chset > ydb1048_over_320k_rnd_$chset.txt

	foreach idx (0 1)
		setenv ydb_readline $idx

		# Arrays are 1-based, so we need to add 1 to adjust the index in to the readline array
		set num = `expr $idx + 1`

		echo "#\n##### Test with readline $readline[$num], using gtm_chset equal to $chset #####"
		echo "#\n#### LKE/DSE/MUPIP/GTCM_GNP_SERVER/YOTTADB %YDB-E-CLIERR and %YDB-W-ARGSLONGLINE Test (command line) ####"

		foreach util (lke dse mupip gtcm_gnp_server)
			set name = `echo $util | tr '[:lower:]' '[:upper:]'`

			echo "##### Name: $name  Chset: $chset  Readline: $idx #####" >> cmdline.out
			echo "#\n# Running $name..."
			echo "# send a command shorter than 32k"

			if ("gtcm_gnp_server" == $util) then
				$gtm_dist/$util -bad_command $under_32k |& tee -a cmdline.out | grep '^#\|%YDB-'
			else
				$gtm_dist/$util bad_command $under_32k |& tee -a cmdline.out | grep '^#\|%YDB-'
			endif

			echo "# send a command around 32k"
			$gtm_dist/$util bad_command $at_32k |& tee -a cmdline.out | grep '^#\|%YDB-'

			if ("gtcm_gnp_server" != $util) then
				echo "# send multiple commands, two longer than 32k, one shorter, redirect from file"
				echo $over_32k > string_super_long.txt
				echo $over_32k >> string_super_long.txt
				echo bad_command >> string_super_long.txt
				$gtm_dist/$util < string_super_long.txt |& tee -a cmdline.out | grep '^#\|%YDB-'
				rm string_super_long.txt

				echo "# send a random $chset string around 32k, redirect from file"
				$gtm_dist/$util < ydb1048_at_32k_rnd_$chset.txt |& tee -a cmdline.out | grep '^#\|%YDB-'
				echo "# send a random $chset string longer than 32k, redirect from file"
				$gtm_dist/$util < ydb1048_over_32k_rnd_$chset.txt |& tee -a cmdline.out | grep '^#\|%YDB-'
				echo "# send a random $chset string longer than 320k, redirect from file"
				$gtm_dist/$util < ydb1048_over_320k_rnd_$chset.txt |& tee -a cmdline.out | grep '^#\|%YDB-'
			endif

			echo "# ...$name finished"
			$echoline
			$echoline >> cmdline.out
		end

		echo "##### Name: YOTTADB  Chset: $chset  Readline: $idx #####" >> cmdline.out
		echo "#\n# Running YOTTADB..."

		# Test directly, which goes through a slightly different code path
		echo "# send a command around 32k directly"
		$gtm_dist/yottadb "bad_command $at_32k" |& tee -a cmdline.out | grep '^#\|%YDB-'
		echo "# send a command longer than 32k directly"
		$gtm_dist/yottadb "bad_command $over_32k" |& tee -a cmdline.out | grep '^#\|%YDB-'

		# Test via %XCMD, which goes through a slightly different code path
		echo "# send a command shorter than 32k via %XCMD"
		$gtm_dist/yottadb -run %XCMD "bad_command $under_32k" |& tee -a cmdline.out | grep '^#\|%YDB-'
		echo "# send a command around 32k via %XCMD"
		$gtm_dist/yottadb -run %XCMD "bad_command $at_32k" |& tee -a cmdline.out | grep '^#\|%YDB-'
		echo "# send a command longer than 32k via %XCMD"
		$gtm_dist/yottadb -run %XCMD "bad_command $over_32k" |& tee -a cmdline.out | grep '^#\|%YDB-'

		echo "# ...YOTTADB finished"
		$echoline
		$echoline >> cmdline.out

		# Move *.out to *.outx to avoid -E- from being caught by test framework
		mv cmdline.out cmdline_$chset-$idx.outx

		# Interactive tests with readline on already happen in r200/ydb88_08, so skip
		if (1 == $idx) continue

		# Turn on expect debugging using "-d". The debug output would be in expect.dbg
		# in case needed to analyze stray timing failures.
		(expect -d $gtm_tst/$tst/u_inref/max_truncate_to_error-ydb1048.exp $chset >! expect.out) >& expect.dbg
		if ($status) then
			echo "EXPECT-E-FAIL : expect returned non-zero exit status"
		endif

		# Move *.out to *.outx to avoid -E- from being caught by test framework
		mv expect.out expect_$chset-$idx.outx
		mv expect.dbg expect_$chset-$idx.dbg
		perl $gtm_tst/com/expectsanitize.pl expect_$chset-$idx.outx > expect_sanitized_$chset-$idx.outx
		grep '^#\|%YDB-' expect_sanitized_$chset-$idx.outx
	end
end

# If incoming "gtm_chset" was "UTF-8" switch back to it now that we are done playing with "gtm_chset".
# Not doing so can cause a "gtm_chset" vs "gtmroutines" mismatch which can cause problems (for example when
# "PEEKBYNAME" is invoked inside dbcheck_base.csh). If incoming "gtm_chset" was "M", then no need to switch
# anything as the above "foreach chset (UTF-8 M)" loop has "M" as the last iteration so a "$switch_chset M"
# would have been done anyways at the end of the loop.
if ("UTF-8" == $save_chset) then
	# Restore gtm_chset and gtmroutines back in sync
	$switch_chset $save_chset >&! switch_$chset.dbcheck.log
endif
$gtm_tst/com/dbcheck.csh >& dbcheck.out
