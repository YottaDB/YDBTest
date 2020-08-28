#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Check for break in formating for ZSYSLOG() - Checks cases when FAO directive is used along with ZSYSLOG()"
set syslog_start1 = `date +"%b %e %H:%M:%S"`
set date_signature = `date +"%m-%d-%Y %H:%M"`
set message = "ZSYSLOGR"
echo '# Testing $zsyslog(<date> <$PWD> Wine_$char(10,13). Expecting a return value of 1'
$gtm_dist/mumps -r ^%XCMD 'write $zsyslog("'${date_signature} $PWD' Wine"_$char(10,13))'
echo '# Testing $zsyslog("<date> <$PWD> Beer\!_$char(10,13)". Expecting a return value of 1'
$gtm_dist/mumps -r ^%XCMD 'write $zsyslog("'${date_signature} $PWD' Beer!"_$char(10,13))'
echo '# Testing $zsyslog("<date> <$PWD> Pizza\!_$char(10,13)". Expecting a return value of 1'
$gtm_dist/mumps -r ^%XCMD 'write $zsyslog("'${date_signature} $PWD' Pizza!"_$char(10,13))'
echo '# Testing $zsyslog("\!AD <$PWD> <date>"). Expecting a return value of 1'
$gtm_dist/mumps -r ^%XCMD 'write $zsyslog("\!AD '${date_signature} $PWD'")' #\!AD used instead of !AD as they are equivalent and !AD is interpreted as event by tcsh
echo '# Testing $zsyslog("<date> <$PWD> ZSYSLOGR). Expecting a return value of 1'
$gtm_dist/mumps -r ^%XCMD 'write $zsyslog("'$date_signature $PWD $message'")'

echo '# Verifying that strings sent using $zsyslog do show up in syslog'
$gtm_tst/com/getoper.csh "$syslog_start1" "" syslog1.txt "" $message
$grep -o "${date_signature} $PWD Wine" syslog1.txt | awk '{print $4}'
$grep -o "${date_signature} $PWD Beer!" syslog1.txt | awk '{print $4}'
$grep -o "${date_signature} $PWD Pizza!" syslog1.txt | awk '{print $4}'
$grep -o "\!AD ${date_signature} $PWD" syslog1.txt | awk '{print $1}'
echo "# End of ZSYSLOG Test"
