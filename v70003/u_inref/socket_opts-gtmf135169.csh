#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTM-F135169 - Test the following release note
*****************************************************************

Release Note says:

> The OPEN and USE commands for SOCKET devices support
> assigning characteristics maintained with the POSIX
> setsockopt() service using the OPTIONS deviceparameter
> for the newly created socket or the current socket.
>
> OPTIONS=expr  Applies to: SOC
>
> The argument (expr) is a string which contains a comma
> separated list of setsockopt options. If the option takes
> a value, it is given after an equal sign (=) following
> the option. The supported options are:
>
> - KEEPALIVE   - a positive value enables SO_KEEPALIVE.
>                 A zero value disables SO_KEEPALIVE.
> - KEEPIDLE    - sets the TCP_KEEPIDLE socket value.
> - KEEPCNT     - sets the TCP_KEEPCNT socket value.
> - KEEPINTVL   - sets the TCP_KEEPINTVL socket value.
> - SNDBUF      - sets the size of the socket's network send
>                 buffer (SO_SNDBUF) in bytes.
>
> Examples:
>
> USE dev:OPTIONS="KEEPALIVE=1,KEEPIDLE=50"
> This enables SO_KEEPALIVE and set TCP_KEEPIDLE to 50 seconds.
>
> USE dev:OPTIONS="KEEPALIVE=0"
> This disables SO_KEEPALIVE.
>
> _Note_
> _For more information on the use of these options, please review_
> _the man page for setsockopt . On Linux, "man 7 socket" and _
> _"man 7 tcp" provide additional information._
>
> The \$ZSOCKET() function supports an "OPTIONS" keyword which takes
> an index argument and returns a string of the OPTIONS previously
> specified for the selected socket. The string may not exactly
> match the string originally specified but has the same meanings.
>
> The new keywords "KEEPALIVE", "KEEPCNT", "KEEPIDLE", "KEEPINTVL",
> and "SNDBUF" return the individual items. If the system's current
> value for the item doesn't match the value previously specified
> with the OPTIONS device parameter, both values are returned
> separated by a semicolon (";"): "uservalue;systemvalue".
>
> The "ZIBFSIZE" keyword may return the system value for SO_RCVBUF
> in addition to the value from the ZIBFSIZE device parameter. Note
> that the operating system may modify the values specified for
> SO_RCVBUF and SO_SNDBUF so the returned values for those options
> obtained with POSIX getsockopt() service may be different than
> those specified using setsockopt(). (GTM-F135169)

See http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-003_Release_Notes.html#GTM-F135169
CAT_EOF
echo ""

setenv ydb_msgprefix "GTM"
source $gtm_tst/com/portno_acquire.csh >& portno.out
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log

echo "# ---- Executing KEEPALIVE=0 tests ----"
echo "# For details, see MRs:"
echo "# - Fix socket OPEN error: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1524"
echo "# - Fix socket USE error: https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1525"
echo "#"

foreach case ( 1 2 3 4 )
	$gtm_dist/mumps -run k$case^gtmf135169 $portno keepalive-$case - single
end
echo ""

echo "# ---- Test of normal path and various DEVICEOPTION error code paths ----"

# CLI args for "devopt" tests (argtest^gtmf135169):
#
# 1: Random TCP port number
# 2: Case title: "devopt-<n>"
# 3: Process ID: not used (specified "-")", these are not server/client tests
# 4: Run mode: not used (set to "single"), there are no fg or bg processes
# 5: Option: the option to be tested, e.g. "KEEPALIVE"
#    - Ignored if arg7 is "MULTI" (used "-" for placeholder)
# 6: Command: command to test, "OPEN" or "USE"
# 7: Mistake: error type which should trigger the tested behaviour:
#    - "NONE": valid OPTION string, no error
#    - "UNKNOWN": unknown option
#    - "INVALID": invalid value
#    - "MISSING": missing value
#    - "MULTI": malformed multiple keywords (arg5 gets repeated)
#
# With the exception of Mistake Type (arg7), all test parameters are defined
# here.

@ case = 1
$gtm_dist/mumps -run argtest^gtmf135169 $portno devopt-$case - single KEEPTHECHANGE_UNKNOWN_OPTION=82 OPEN UNKNOWN
@ case += 1
$gtm_dist/mumps -run argtest^gtmf135169 $portno devopt-$case - single KEEPTHECHANGE_UNKNOWN_OPTION=84 USE UNKNOWN
@ case += 1

foreach option ( \
	"KEEPALIVE=1" \
	"KEEPCNT=2" \
	"KEEPIDLE=3" \
	"KEEPINTVL=4" \
	"SNDBUF=22" \
	)
	foreach command ( "OPEN" "USE" )
		foreach mistake ( "NONE" "INVALID" "MISSING" "MULTI" "OVERFLOW" )
			$gtm_dist/mumps -run argtest^gtmf135169 $portno devopt-$case - single $option $command $mistake
			@ case += 1
		end
	end
end
echo ''

echo '# executing write-readback tests (displaying results later)'

# CLI args for write-readback tests (wrtest^gtmf135169 and client^gtmf135169):
#
# 1: Random TCP port number
# 2: Case ID: "devopt-<n>"
# 3: Process ID: identifies server and client part of tests, used in logging
# 4: Run mode: informs M program if the program runs in foreground or
#    background. There should be only one foreground process, which shouldn't
#    exit until all background processes finish. See LOCK instructions in the M
#    program, `startup` and `clenaup` subroutines.
# 5: Options: options to test, in "index:o1=v1,o2=v2;index:o3=v3" format, where
#    index is the 3rd arg of $ZSOCKET(), o<n>=v<n> is option name and value.
#    Note that item separator is semicolon (";")
# 5 (parse) filename: strace output to parse
# 6: Commnand: the command to set options: `OPEN` or `USE`
# 7: Readback: read mode for checking the options: `INDIVIDUAL`` or `OPTIONS`
#    - `INDIVIDUAL` use $ZSOCKET(s,<option_to_check>,index) - for each option
#    - `OPTIONS` use $ZSOCKET(s,"OPTIONS",index) - once, it will report
#       almost all options
#
# When iterating through the parameters, some permutations has the same meaning:
# if there's no option defined for index 0, the case with OPEN and USE command
# are the same, these cases will be only mentioned and skipped (see
# isnotdupe^gtmf135169).
#
# Note that getting individual option value may differ from value set. When
# this happens, a masked value will appear instead of the value read.
# Similarly, system value appears ("usrval;sysval" format), if it differs from
# user-set values. System value is _always_ masked, except for KEEPALIVE, which
# is booleanish, it may has value only 0 or 1. Using "OPTIONS" as second
# parameter of $ZSOCKET() always provides user-set values.
#
# Each test case runs twice, with different readback modes:
# - "indv": reads back all the options set one by one,
# - "opts": reads back options at once.
#
# On SUSE systems, there are extra lines in the trace log, which should be
# filtered out (see "SUSE filter" comment below):
#   access("/dev/hugepages", R_OK|W_OK|X_OK) = -1 EACCES (Permission denied)
# See also: https://gitlab.com/YottaDB/DB/YDBTest/-/commit/e05423cc053732223465569adc5bc4e657db6cbe
echo ''

$gtm_dist/mumps -run chkrst^gtmf135169 $portno
@ case = 1
foreach options ( \
	"KEEPALIVE=101;2:KEEPALIVE=102" \
	"1:KEEPALIVE=0,KEEPIDLE=99;2:KEEPALIVE=2,KEEPIDLE=2" \
	"1:KEEPCNT=101;2:KEEPCNT=102" \
	"0:KEEPINTVL=202;1:KEEPINTVL=208" \
	"KEEPCNT=3,SNDBUF=304" \
	"1:KEEPALIVE=1;2:ZIBFSIZE=401,KEEPCNT=402;2:KEEPINTVL=403" \
	"2:KEEPCNT=509" \
	)
	foreach command ( "OPEN" "USE" )
		set valid=`$gtm_dist/mumps -run isnotdupe^gtmf135169 $options $command`
		if ("$valid" == "1") then
			foreach readback ( "indv" "opts" )
				(strace -o raw-$case-$readback.outx $gtm_dist/mumps -run wrtest^gtmf135169 $portno wrtest-$case server bg $options $command $readback >>& server.out & ; echo $! >&! ${readback}-server.pid) >&! ${readback}-server-bg.out
				($gtm_dist/mumps -run client^gtmf135169 $portno wrtest-$case client-1 bg $options $command >>& client1-$case-$readback.out & ; echo $! >&! ${readback}-client.pid) >&! ${readback}-client-bg.out
				$gtm_dist/mumps -run client^gtmf135169 $portno wrtest-$case client-2 fg $options $command >>& client2-$case-$readback.out
				cat raw-$case-$readback.outx | grep -v "access.*hugepages.*EACCES" > trace-$case-$readback.out  # SUSE filter
				$gtm_dist/mumps -run parse^gtmf135169 $portno wrtest-$case parse - $options trace-$case-$readback.out $readback >>& filtered-$case-$readback.out
				$gtm_dist/mumps -run chkrst^gtmf135169 $portno
				cat filtered-$case-$readback.out >>& server.out
				# Wait for server and client processes backgrounded above to terminate before moving on to the next stage of the test
				$gtm_tst/com/wait_for_proc_to_die.csh `cat ${readback}-server.pid`
				$gtm_tst/com/wait_for_proc_to_die.csh `cat ${readback}-client.pid`

			end
			echo '#' >>& server.out
			@ case += 1
		else
			set q='"'
			echo "# wrtest-skip: options=$q$options$q, command=$q$command$q - same as next one" >>& server.out
			echo '#' >>& server.out
		endif
	end
end

echo "# ---- Write-readback test with strace logs ----"

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
The server sets options with OPEN or USE, then reading
back the value with \$ZSOCKET(). If the option is simple,
\$ZSOCKET() simply reports its value. If the option has
constraints, e.g. buffer size has a high or low limit,
\$ZSOCKET() may report both user value (which has been
set) and system value (the effective value). If user
value and system value are different, \$ZSOCKET()
reports both value in "uservalue;sysvalue" format. If
they are same, it reports only one value.
CAT_EOF

cat server.out

$gtm_tst/com/dbcheck.csh >& dbcheck.log
$gtm_tst/com/portno_release.csh
