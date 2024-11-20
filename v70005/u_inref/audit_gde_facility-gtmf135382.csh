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

Release Note says:

> When LGDE is specified as an option for the AZA_ENABLE
> facility, GDE logs all commands. For example, an entry like
> the following in \$gtm_dist/restrict.txt enables GDE logging
> via a local socket:
>
> AZA_ENABLE:LGDE:/path/to/sock/file/audit.sock
> The AZA_ENABLE facility enables the use of the \$ZAUDITLOG()
> function which GDE uses for logging commands. Refer to
> GTM-F170998 for information on the \$ZAUDITLOG() function and
> for other possible use in application audit logging.
> Previously, GDE did not provide an audit logging option.
> (GTM-F135382)
CAT_EOF
echo ''

echo "# ---- startup ----"

# set this var to "tls" to check TLS mode with CURL
# extra steps are prefixed by "DEBUG"
# leave it "" (empty string) for production
set testmode=""

# set error prefix
setenv ydb_msgprefix "GTM"

# set strace filter for filtering out unrelated syslog items
set strace_filter = "GTM-I-TEXT|GTM-W-SHMHUGETLB"

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
rm -f $gtm_dist/restrict.txt
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out

echo "# create GDE script"
set gdescript=gdefile.txt
cat << GDE0 >& $gdescript
show -name anonymous
verify -template
verify -map
add -gblname myglob -collation=0
show -gblname
delete -gblname myglob
show -gblname
exit
GDE0

echo "# get group ID for restrict.txt"
set gid=`id -gn`

foreach param ( \
	"tcp;AZA_ENABLE:LGDE:localhost:${portno}" \
	"tls;AZA_ENABLE:TLS,LGDE:localhost:${portno}:clicert" \
	"unix_socket;AZA_ENABLE:LGDE:${uxsock}" \
	)

	set mode=`echo $param | cut -d';' -f1`
	set restriction=`echo $param | cut -d';' -f2`

	echo
	echo "# ---- test $mode logging ----"

	echo "# setup restrict.txt: audit logging with $mode"
	rm -f $gtm_dist/restrict.txt
	echo "LIBRARY:$gid" >> $gtm_dist/restrict.txt
	echo $restriction >> $gtm_dist/restrict.txt
	chmod a-w $gtm_dist/restrict.txt

	echo "# attempt to execute a GDE command - should fail, due to logging fail"
	# awk: trim trailing spaces of GDE output
	strace -s 999 -e trace=sendto -o trace.outx  $gtm_dist/mumps -run GDE < $gdescript \
		|& grep -v $tst_working_dir \
		| grep -v '^GDE>' \
		| grep -v '^$' \
		| awk '{$1=$1;print}'

	echo "# show errors from syslog, from strace output:"
	cat trace.outx \
		| grep "%GTM" \
		| cut -d'%' -f2 \
		| cut -d',' -f1 \
		| grep -vE $strace_filter

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
	$gtm_dist/mumps -run waitforfilecreate $pidfile
	set pid=`cat $pidfile`

	if ("$mode" == "$testmode") then
		echo "# DEBUG: raw restrict.txt file contents:"
		cat $gtm_dist/restrict.txt
		echo "# DEBUG: check $mode listener health with CURL - 'empty reply from server' is OK"
		curl -m0.1 -k "https://localhost:$portno/http_request/"
		$gtm_tst/com/wait_for_log.csh \
			-log $aulogfile \
			-message http_request \
			-duration 1
		echo "# DEBUG: check log sent by CURL (a http request)"
		cat $aulogfile
		echo "# DEBUG: reset log by sending SIGHUP to the audit listener"
		kill -HUP $pid
	endif

	echo "# attempt to execute a GDE command - should succeed and logged"
	# grep-1: filter out lines with path
	# grep-2: don't show GDE prompt
	# grep-3: suppress empty lines
	# awk: trim trailing spaces of GDE output
	strace -s 999 -e trace=sendto -o trace.outx  $gtm_dist/mumps -run GDE < $gdescript \
		|& grep -v $tst_working_dir \
		| grep -v '^GDE>' \
		| grep -v '^$' \
		| awk '{$1=$1;print}'

	echo "# wait for entries added to log"
	$gtm_tst/com/wait_for_log.csh \
		-log $aulogfile \
		-message exit \
		-duration 1

	echo "# show log captured, should show the GDE commands:"
	cat $aulogfile | $gtm_dist/mumps -run filter^auditlogfilter

	echo "# show errors from syslog, from strace output:"
	cat trace.outx \
		| grep "%GTM" \
		| cut -d'%' -f2 \
		| cut -d',' -f1 \
		| grep -vE $strace_filter

	echo "# reset log by sending SIGHUP to the audit listener"
	kill -HUP $pid

	echo "# setup restrict.txt: no audit logging"
	rm -f $gtm_dist/restrict.txt
	echo "LIBRARY:$gid" >> $gtm_dist/restrict.txt
	chmod a-w $gtm_dist/restrict.txt
	if ("$mode" == "$testmode") then
		echo "# DEBUG: raw restrict.txt file contents:"
		cat $gtm_dist/restrict.txt
	endif

	echo "# attempt to execute a GDE command - should succeed, but not logged"
	# awk: trim trailing spaces of GDE output
	strace -s 999 -e trace=sendto -o trace.outx $gtm_dist/mumps -run GDE < $gdescript \
		|& grep -v $tst_working_dir \
		| grep -v '^GDE>' \
		| grep -v '^$' \
		| awk '{$1=$1;print}'

	echo "# wait for entries added to log - won't happen"
	sleep 1

	echo "# show log captured - should be empty:"
	rm -f $gtm_dist/restrict.txt
	cat $aulogfile | $gtm_dist/mumps -run filter^auditlogfilter

	echo "# show errors from syslog, from strace output - should be none:"
	cat trace.outx \
		| grep "%GTM" \
		| cut -d'%' -f2 \
		| cut -d',' -f1 \
		| grep -vE $strace_filter

	echo "# stop audit_listener and wait for finish"
	kill -TERM $pid >>& waitforproc.log
	$gtm_tst/com/wait_for_proc_to_die.csh $pid >>& waitforproc.log
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
