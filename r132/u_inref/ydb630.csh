#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test that various executables are properly identified when sending messages to the system log"
set syslog_start1 = `date +"%b %e %H:%M:%S"`
set date_signature = `date +"%m-%d-%Y %H:%M"`
set message = "ZSYSLOGR"
echo '# Testing $zsyslog(<date> <$PWD> Wine_$char(10,13). Expecting a return value of 1'
$ydb_dist/mumps -r ^%XCMD 'write $zsyslog("'${date_signature} $PWD' Wine"_$char(10,13))'
echo '# Testing $zsyslog("<date> <$PWD> Beer\!_$char(10,13)". Expecting a return value of 1'
$ydb_dist/yottadb -r ^%XCMD 'write $zsyslog("'${date_signature} $PWD' Beer!"_$char(10,13))'
echo "# Running Simple API Test"
setenv ydb_ci `pwd`/tab.ci

cat >> tab.ci << xx
tst: void tst^tst(I:ydb_char_t*, O:ydb_char_t*)
xx

cat >> tst.m << \xxxx
tst(var,error)
        write "Successfully Performed SimpleAPI Call",!
	if $zsyslog(var)
	quit:$quit 0 quit
	;
\xxxx

# Compile and link ydb630.c.
$gt_cc_compiler $gt_cc_shl_options $gtm_tst/$tst/inref/ydb630.c -I $ydb_dist -g -DDEBUG
$gt_ld_linker $gt_ld_option_output ydb630 $gt_ld_options_common ydb630.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
	exit 1
endif
rm -f link.map

# Invoke the executable.
set log_info = "$date_signature $PWD Vodka"
ydb630 $log_info
echo '# Testing $zsyslog("<date> <$PWD> ZSYSLOGR). Expecting a return value of 1'
$ydb_dist/mumps -r ^%XCMD 'write $zsyslog("'$date_signature $PWD $message'")'
$gtm_tst/com/getoper.csh "$syslog_start1" "" syslog1.txt "" $message
# Get the process-name[pid] section from the log and extract the process name from it.
# 1. Delete ]: and everything after
# 2. Get the last argument
# 3. Delete [: and everything after
echo ""
echo "# Verifying executable names in syslog messages"

$grep "${date_signature} $PWD Wine" syslog1.txt   | sed 's/\]:.*//' | awk '{print $NF}' | sed 's/\[.*//'
$grep "${date_signature} $PWD Beer!" syslog1.txt  | sed 's/\]:.*//' | awk '{print $NF}' | sed 's/\[.*//'
$grep "${date_signature} $PWD Vodka" syslog1.txt  | sed 's/\]:.*//' | awk '{print $NF}' | sed 's/\[.*//'
echo "# End of ZSYSLOG Test"
