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
Issue description says:
> According to this comment https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2074#note_2080933469,
> Test for Audit Principal Device (APD) facility didn't exist yet even though this was introduced in GT.M V6.3-007.

Release note http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V6.3-007_Release_Notes.html#GTM-7318 says:

> GT.M supports the ability to log actions initiated from a principal device
> including MUMPS commands typed interactively, or piped in by a script or redirect,
> from the principal device (\$PRINCIPAL) and / or any information entered in response
> to a READ from \$PRINCIPAL. An action initiated from \$PRINCIPAL executes as usual when
> Audit Principal Device is disabled, which it is by default. However, when
> Audit Principal Device is enabled, GT.M attempts to send the action out for logging
> before acting on it. Additionally, the \$ZAUDIT Intrinsic Special Variable (ISV)
> provides a Boolean value that indicates whether Audit Principal Device is enabled.
> Please see the Additional information for GTM-7318 - Audit Principal Device
> in this document for details. (GTM-7318)
CAT_EOF
echo ''
setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"

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
echo '# Note:'
echo '# 1) RD means enable logging of all responses READ from $PRINCIPAL which captures input that might be XECUTEd'
echo '# which will resulting in command=TEST in log output'
echo '# 2) $ZAUDIT ISV also tested here. This ISV will be 0 when APD is disabled and 1 when APD is enabled'
echo 
foreach param ( \
	"tcp;APD_ENABLE::127.0.0.1:${portno}" \
	"tls;APD_ENABLE:TLS:127.0.0.1:${portno}:clicert" \
	"unix_socket;APD_ENABLE::${uxsock}" \
	"tcp+RD;APD_ENABLE:RD:127.0.0.1:${portno}" \
	"tls+RD;APD_ENABLE:TLS,RD:127.0.0.1:${portno}:clicert" \
	"unix_socket+RD;APD_ENABLE:RD:${uxsock}" \
	)
	set mode=`echo $param | cut -d';' -f1`
	set restriction=`echo $param | cut -d';' -f2`
	echo "# Testing mode: $mode"
	rm -f $gtm_dist/restrict.txt
	echo '# Run mumps -dir without restriction.txt'
	echo '# Expected to be working fine with $ZAUDIT=0'
	$gtm_dist/mumps -dir << GTM_EOF \
		| awk '{$1=$1;print}' \
		| grep -v 'GTM>' \
		| grep -v '^$'
WRITE "\$ZAUDIT: ",\$ZAUDIT
READ X
TEST
WRITE X
HALT
GTM_EOF
	echo
	echo "# setup restrict.txt: for audit logging"
	echo $restriction >> $gtm_dist/restrict.txt
	chmod a-w $gtm_dist/restrict.txt
	echo '# Run mumps -dir with restriction.txt but not started audit listener process yet'
	echo '# Expected to be error with E-APDLOGFAIL'
	$gtm_dist/mumps -dir << GTM_EOF \
		| awk '{$1=$1;print}' \
		| grep -v 'GTM>' \
		| grep -v '^$'
WRITE "\$ZAUDIT: ",\$ZAUDIT
READ X
TEST
WRITE X
HALT
GTM_EOF
	echo
	set listenermode=`echo $mode | cut -d'+' -f1`
	echo "# launch $listenermode audit_listener"
	rm -f $aulogfile
	if ("$listenermode" == "tcp") then
		($gtm_dist/audit_listener tcp $pidfile $aulogfile \
			$portno &)
	endif
	if ("$listenermode" == "tls") then
		($gtm_dist/audit_listener tls $pidfile $aulogfile \
			$portno $certfile $keyfile ydbrocks &)
	endif
	if ("$listenermode" == "unix_socket") then
		($gtm_dist/audit_listener unix $pidfile $aulogfile \
			$uxsock &)
	endif

	echo "# wait for pidfile"
	while ( ! -f $pidfile)
		sleep 0.1
	end
	set pid=`cat $pidfile`
	echo '# Run mumps -dir with restriction.txt and audit listener process started'
	echo '# Expected to be working fine with $ZAUDIT=1'
	$gtm_dist/mumps -dir << GTM_EOF \
		| awk '{$1=$1;print}' \
		| grep -v 'GTM>' \
		| grep -v '^$'
WRITE "\$ZAUDIT: ",\$ZAUDIT
READ X
TEST
WRITE X
HALT
GTM_EOF
	echo
	echo "# wait for entries added to log"
	$gtm_tst/com/wait_for_log.csh \
		-log $aulogfile \
		-message HALT \
		-duration 1

	echo "# delete restrict.txt before printing audit log otherwise filtering will fail as it also uses mumps -run"
	rm -f $gtm_dist/restrict.txt

	echo "# show log captured (should be the MUMPS -DIR commands):"
	cat $aulogfile | $gtm_dist/mumps -run "filter^auditlogfilter"

	echo "# reset log by sending SIGHUP to the audit listener"
	kill -HUP $pid

	echo "# stop audit_listener and wait for finish"
	kill -KILL $pid
	($gtm_tst/com/wait_for_proc_to_die.csh $pid >>& waitforproc.log)
	rm -f $pidfile
	rm -f $aulogfile
	echo
end

echo "# release port number"
$gtm_tst/com/portno_release.csh
