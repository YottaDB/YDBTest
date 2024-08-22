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

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F135381 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-004_Release_Notes.html#GTM-F135381)

When the Audit MUPIP facility (AM_ENABLE) is enabled, MUPIP establishes a connection (via a UNIX/TCP/TLS socket)
to a logger/listener process, and sends any MUPIP shell command through the socket to the listener for logging.
If sending is successful, MUPIP executes the command. If the connection is not successful or sending of the command fails,
then MUPIP produces an error and does not execute the command. When this facility is enabled, all commands typed at
the MUPIP prompt (MUPIP>) produce the RESTRICTEDOP error. When this facility is disabled, which it is by default,
MUPIP commands execute as usual.In addition, the APD_ENABLE facility displays the appropriate network error messages
and exits the process gracefully. Previously, certain network errors could result in a segmentation fault without
reporting the reason. (GTM-F135381)

This test only contains test below :
- Test New error message : AUDINITFAIL, AUDCONNFAIL and AUDLOGFAIL

Notes:
1) Audit MUPIP facility already tested in v70005/audit_mupip_facility-gtmf188829
(https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2052) so this will not be tested here
2) APD_ENABLE Facility mentioned in later part of release note will not tested in this test
because there is not enough description of the use case to come up with a test case.

CAT_EOF

echo

setenv ydb_msgprefix 'GTM'
setenv ydb_prompt 'GTM>'

echo '# Prepare read-write $gtm_dist directory'
set old_dist=$gtm_dist
source $gtm_tst/com/copy_ydb_dist_dir.csh ydb_temp_dist
setenv gtm_dist $ydb_dist
chmod -R +wX ydb_temp_dist
set aulogfile=log.txt
set pidfile=pid.txt
set certfile=$gtm_tst/com/tls/certs/CA/ydbCA.crt
set keyfile=$gtm_tst/com/tls/certs/CA/ydbCA.key

echo "# compile audit_listener utility"
$gt_cc_compiler \
	$gtm_tst/com/audit_listener.c \
	-o $gtm_dist/audit_listener \
	-lssl -lcrypto

echo "# allocate a port number for TCP and TLS modes"
source $gtm_tst/com/portno_acquire.csh >& portno.out

echo "# set Unix socket filename"
set uxsock=audit.sock

echo "# set crypt config file path and name"
setenv gtmcrypt_config `pwd`/gtm_crypt_config.libconfig

echo "# set-up crypt config file for section clicert"
cat > $gtmcrypt_config << EOF_CLICERT
tls: {
	clicert: {
		CAfile: "$certfile";
	};
}
EOF_CLICERT

echo "# get group ID for restrict.txt"
set gid=`id -gn`

echo
echo '# Test 1) :  Test new error message : AUDINITFAIL, AUDCONNFAIL and AUDLOGFAIL'
echo '# 1.1) AUDINITFAIL : This message will show up in syslog when restriction file format is invalid'
echo '# AUDLOGFAIL will also show up in syslog as YottaDB/GT.M unable to send the to-be-logged activitiy to logger'
echo '# We will test for all mode including TCP, TLS, UNIX Socket by just setting up restrict.txt with invalid format'
foreach param ( \
	"tcp;AM_ENABLE:::" \
	"tls;AM_ENABLE:TLS:::clicert" \
	"unix_socket;AM_ENABLE::" \
	)
	set mode=`echo $param | cut -d';' -f1`
	set restriction=`echo $param | cut -d';' -f2`
	echo "# Testing mode : $mode"
	echo "# setup restrict.txt: for audit logging"
	echo 
	rm -f $gtm_dist/restrict.txt
	echo "LIBRARY:$gid" >> $gtm_dist/restrict.txt
	echo $restriction >> $gtm_dist/restrict.txt
	chmod a-w $gtm_dist/restrict.txt
	echo '# This will show RESTRICTEDOP error in stdout/stderr'
	strace -s 999 -e trace=sendto -o test_syslog_${mode}_1_1.txt $gtm_dist/mupip << MUPIP1 |& sed 's/MUPIP> //g'
intrpt 1
exit
MUPIP1
	echo
	echo '# Check if AUDINITFAIL and AUDLOGFAIL message exist in syslog from strace output'
	$grep -E "AUDINITFAIL|AUDLOGFAIL" test_syslog_${mode}_1_1.txt | $grep "%GTM" \
			| cut -d'%' -f2 \
			| cut -d',' -f1 \
			| grep -Ev 'GTM-I-TEXT|GTM-E-RESTRICTSYNTAX'
	echo
end


echo
echo '# 1.2) AUDCONNFAIL : Facility for logging activity is enabled'
echo '# but is unable to form a connection with its configured logging program'
echo '# AUDLOGFAIL will also show up here'
echo '# We will test for all mode including TCP, TLS, UNIX Socket by setting up appropriate restrict.txt'
echo '# But we will not start audit listener so that AUDCONNFAIL error will show up (also AUDLOGFAIL)'
echo
foreach param ( \
	"tcp;AM_ENABLE::127.0.0.1:${portno}" \
	"tls;AM_ENABLE:TLS:127.0.0.1:${portno}:clicert" \
	"unix_socket;AM_ENABLE::${uxsock}" \
	)
	set mode=`echo $param | cut -d';' -f1`
	set restriction=`echo $param | cut -d';' -f2`
	echo "# Testing mode : $mode"
	echo "# setup restrict.txt: for audit logging"
	echo 
	rm -f $gtm_dist/restrict.txt
	#echo "LIBRARY:$gid" >> $gtm_dist/restrict.txt
	echo $restriction >> $gtm_dist/restrict.txt
	chmod a-w $gtm_dist/restrict.txt
	echo '# This will show RESTRICTEDOP error in stdout/stderr'
	strace -s 999 -e trace=sendto -o test_syslog_${mode}_1_2.txt $gtm_dist/mupip << MUPIP |& sed 's/MUPIP> //g'
intrpt 1
exit
MUPIP
	echo
	$grep -E "AUDCONNFAIL|AUDLOGFAIL" test_syslog_${mode}_1_2.txt | $grep "%GTM" \
			| cut -d'%' -f2 \
			| cut -d',' -f1 \
			| grep -v 'GTM-I-TEXT'
	echo
end
echo
echo "# release port number"
$gtm_tst/com/portno_release.csh
