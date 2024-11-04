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
GTM-F188829 - Test the following release note
*****************************************************************

Release note http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-005_Release_Notes.html#GTM-F188829 says:

> When the restriction file contains a line specifying
> AM_ENABLE, commands typed at the MUPIP prompt (MUPIP>) are
> audit logged and executed the same as MUPIP shell commands.
> Note that MUPIP returns to the shell after each command.
> Previously, when this facility was enabled, all commands
> typed at the MUPIP prompt (MUPIP>) produced the RESTRICTEDOP
> error. (GTM-F188829)
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
if (! $?gtmcrypt_config) then
	setenv gtmcrypt_config `pwd`/gtm_crypt_config.libconfig
endif

echo "# set-up crypt config file for section clicert"
cat >> $gtmcrypt_config << EOF_CLICERT
tls: {
	clicert: {
		CAfile: "$certfile";
	};
}
EOF_CLICERT

echo "# get group ID for restrict.txt"
set gid=`id -gn`

foreach param ( \
	"tcp;AM_ENABLE::127.0.0.1:${portno}" \
	"tls;AM_ENABLE:TLS:127.0.0.1:${portno}:clicert" \
	"unix_socket;AM_ENABLE::${uxsock}" \
	)

	set mode=`echo $param | cut -d';' -f1`
	set restriction=`echo $param | cut -d';' -f2`

	echo
	echo "# ---- test $mode logging ----"

	echo "# setup restrict.txt: audit logging with $mode"
	rm -f $gtm_dist/restrict.txt
	echo $restriction >> $gtm_dist/restrict.txt
	chmod a-w $gtm_dist/restrict.txt

	echo "# attempt to execute MUPIP shell commands"
	# sed: ignore "asynchronous" prompt
	$gtm_dist/mupip << MUPIP1 |& sed 's/MUPIP> //g'
intrpt 1
exit
MUPIP1

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

	echo "# attempt to execute MUPIP shell commands"
	# awk: trim trailing spaces of MUPIP output
	$gtm_dist/mupip << MUPIP2 \
		| awk '{$1=$1;print}' \
		| grep -v 'MUPIP>' \
		| grep -v '^$'
intrpt 1
exit
MUPIP2

	echo "# wait for entries added to log"
	$gtm_tst/com/wait_for_log.csh \
		-log $aulogfile \
		-message exit \
		-duration 1

	echo "# show log captured (should be the MUPIP commands):"
	cat $aulogfile | $gtm_dist/mumps -run "filter^auditlogfilter"

	echo "# stop audit_listener and wait for finish"
	kill -TERM $pid >>& waitforproc.log
	$gtm_tst/com/wait_for_proc_to_die.csh $pid >>& waitforproc.log
	rm -f $pidfile
	rm -f $aulogfile
end

echo
echo "# ---- cleanup ----"

echo "# release port number"
$gtm_tst/com/portno_release.csh
