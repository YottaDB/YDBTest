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
GTM-F135383 - Test the following release note
*****************************************************************

Release Note (http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-005_Release_Notes.html#GTM-F135383) says:

> When the restriction file specifies AD_ENABLE, DSE establishes
> a connection via a socket, to a logger/listener process, and
> sends all commands, designating src=6, and using the socket
> to the listener for audit logging. If sending succeeds, DSE
> executes the command. If the connection or the send fail, DSE
> issues a RESTRICTEDOP error and does not execute the command.
> AD_ENABLE supports TCP, TLS or UNIX socket types. By default,
> DSE commands execute without logging. Previously, DSE did not
> provide an audit logging option. (GTM-F135383)
CAT_EOF
echo ''

echo "# ---- startup ----"

# set error prefix
setenv ydb_msgprefix "GTM"

echo '# prepare read-write $gtm_dist directory'
set old_dist=$gtm_dist
source $gtm_tst/com/copy_ydb_dist_dir.csh ydb_temp_dist
setenv gtm_dist $ydb_dist
chmod -R +wX ydb_temp_dist

# prepare files, and set constants for filenames
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
set uxsock=auditlistener-${portno}.sock

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

echo "# create database"
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out

echo "# get group ID for restrict.txt"
set gid=`id -gn`

foreach param ( \
	"tcp;AD_ENABLE::127.0.0.1:${portno}" \
	"tls;AD_ENABLE:TLS:127.0.0.1:${portno}:clicert" \
	"unix_socket;AD_ENABLE::${uxsock}" \
	)

	set mode=`echo $param | cut -d';' -f1`
	set restriction=`echo $param | cut -d';' -f2`

	echo
	echo "# ---- test $mode logging ----"

	echo "# setup restrict.txt: audit logging with $mode"
	rm -f $gtm_dist/restrict.txt
	echo "DSE:$gid" > $gtm_dist/restrict.txt
	echo $restriction >> $gtm_dist/restrict.txt
	chmod a-w $gtm_dist/restrict.txt

	echo "# attempt to execute a DSE command (filtered output), but no audit listener is running"
	# filtering out empty lines ("^$" and messages with path ("testarea")
	$gtm_dist/dse exit |& grep -v '^$' | grep -v 'testarea'

	echo "# launch $mode audit_listener"
	rm -f $aulogfile
	if ("$mode" == "tcp") then
		($gtm_dist/audit_listener tcp $pidfile $aulogfile \
			$portno &)
		$gtm_tst/com/wait_for_port_to_be_listening.csh $portno
	endif
	if ("$mode" == "tls") then
		($gtm_dist/audit_listener tls $pidfile $aulogfile \
			$portno $certfile $keyfile ydbrocks &)
		$gtm_tst/com/wait_for_port_to_be_listening.csh $portno
	endif
	if ("$mode" == "unix_socket") then
		($gtm_dist/audit_listener unix $pidfile $aulogfile \
			$uxsock &)
		$gtm_tst/com/wait_for_unix_domain_socket_to_be_listening.csh $uxsock
	endif

	echo "# wait for pidfile"
	while ( ! -f $pidfile)
		sleep 0.1
	end
	set pid=`cat $pidfile`

	echo "# execute a DSE command (filtered output), will be logged as well"
	# filtering out empty lines ("^$" and messages with path ("testarea")
	$gtm_dist/dse exit |& grep -v '^$' | grep -v 'testarea'

	echo "# wait for entries added to log"
	$gtm_tst/com/wait_for_log.csh \
		-log $aulogfile \
		-message exit \
		-duration 1

	echo "# show log captured (should be the DSE command):"
	cat $aulogfile | $gtm_dist/mumps -run "filter^auditlogfilter"

	echo "# reset log by sending SIGHUP to the audit listener"
	kill -HUP $pid

	echo "# setup restrict.txt: no audit logging"
	rm -f $gtm_dist/restrict.txt
	echo "DSE:$gid" > $gtm_dist/restrict.txt
	chmod a-w $gtm_dist/restrict.txt

	echo "# execute a DSE command (filtered output), will be not logged"
	# filtering out empty lines ("^$" and messages with path ("testarea")
	$gtm_dist/dse exit |& grep -v '^$' | grep -v 'testarea'

	echo "# wait for entries added to log (won't happen)"
	sleep 1

	echo "# show log captured (should be empty):"
	cat $aulogfile | $gtm_dist/mumps -run "filter^auditlogfilter"

	echo "# stop audit_listener and wait for finish"
	kill -TERM $pid
	($gtm_tst/com/wait_for_proc_to_die.csh $pid >>& waitforproc.log)
	rm -f $pidfile
	rm -f $aulogfile
end

echo
echo "# ---- cleanup ----"

echo "# shutdown database"
setenv gtm_dist $old_dist
setenv ydb_dist $gtm_dist
$gtm_tst/com/dbcheck.csh >>& dbcheck.out

echo "# release port number"
$gtm_tst/com/portno_release.csh
