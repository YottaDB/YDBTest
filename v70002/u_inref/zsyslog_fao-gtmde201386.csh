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

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTMDE-201386 - Test the following release note
*****************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637465)

> \$ZSYSLOG() ignores Format Ascii Output (FAO) directives.
> Previously, \$ZSYSLOG() did not ignore such directives
> resulting in a segmentation violation (SIG-11).

See also:
  https://gitlab.com/YottaDB/DB/YDBTest/-/issues/580
CAT_EOF
echo ""

set unique = `pwd`
set syslog_start = `date +"%b %e %H:%M:%S"`
$gtm_dist/mumps -run zsyslogfao^gtmde201386 $unique
echo ""
$gtm_tst/com/getoper.csh "$syslog_start" "" test_syslog.txt
echo '# Output of $ZSYSLOG() messages, extract, FAO and index:'
cat test_syslog.txt | grep $unique | cut -d';' -f3-4
