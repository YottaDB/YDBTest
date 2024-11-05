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
GTM-F170998 - Test the following release note
*****************************************************************

Release note (http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-005_Release_Notes.html#GTM-F170998) says:

> The \$ZAUDITLOG() function establishes a connection via a
> socket and sends its argument to a logger/listener process.
> It requires setting the AZA_ENABLE audit logging facility in
> the \$gtm_dist/restrict.txt file. The format for the
> \$ZAUDITLOG() function is:
>
> ZAUDITLOG(expr)
>
> expr specifies the string to send for audit logging
>
> \$ZAUDITLOG() identifies its message with src=4, and like
> other GT.M logging facilities, records the location of GT.M
> distribution, uid, euid, pid, tty, and the
> command / argument(s).
>
> A return of: TRUE (1) indicates successful logging,
> FALSE (0) indicates logging is not enabled; a trappable
> RESTRICTEDOP error indicates logging is enabled but not
> working.
>
> If LGDE is specified as an option for the AZA_ENABLE facility,
> GDE logs all commands. GT.M ignores this option if specified
> with other A\*\_ENABLE audit logging facilities. When it fails
> to log a command, GDE issues a GDELOGFAIL error. The following
> table characterizes \$ZAUDITLOG() and GDE audit logging behavior:
>
> **\$ZAUDITLOG() / GDE logging Characteristics**
>
> | AZA_ENABLE   | LGDE   | Logging success   | GDE audit logging   | \$ZAUDITLOG() result  |
> |--------------|--------|-------------------|---------------------|-----------------------|
> | Yes          | Yes    | Yes               | Yes                 | 1                     |
> | Yes          | No     | Yes               | No                  | 1                     |
> | Yes          | Yes    | No                | GDELOGFAIL error    | RESTRICTEDOP error    |
> | Yes          | No     | No                | No                  | RESTRICTEDOP error    |
> | No           | N/A    | N/A               | No                  | 0                     |
>
> Previously, GT.M did not support the \$ZAUDITLOG() function.
> (GTM-F170998)
CAT_EOF
echo

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
	-o $ydb_dist/audit_listener \
	-lssl -lcrypto

echo "# allocate a port number for TCP and TLS modes"
source $gtm_tst/com/portno_acquire.csh >& portno.out

echo "# set Unix socket filename"
set uxsock=auditlistener-${portno}.sock

echo "# set crypt config file path and name"
if (! $?gtmcrypt_config) then
	setenv gtmcrypt_config `pwd`/gtm_crypt_config.libconfig
endif

echo "# set-up crypt_config file for section clicert"
cat >> $gtmcrypt_config << EOF_CLICERT
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
	\
	"tcp;AZA_ENABLE:LGDE:127.0.0.1:##PORTNO##" \
	"tcp;AZA_ENABLE::127.0.0.1:##PORTNO##" \
	"none;AZA_ENABLE:LGDE:127.0.0.1:##PORTNO##" \
	"none;AZA_ENABLE::127.0.0.1:##PORTNO##" \
	\
	"tls;AZA_ENABLE:LGDE,TLS:127.0.0.1:##PORTNO##:clicert" \
	"tls;AZA_ENABLE:TLS:127.0.0.1:##PORTNO##:clicert" \
	"none;AZA_ENABLE:LGDE,TLS:127.0.0.1:##PORTNO##:clicert" \
	"none;AZA_ENABLE:TLS:127.0.0.1:##PORTNO##:clicert" \
	\
	"unix_socket;AZA_ENABLE:LGDE:##UXSOCK##" \
	"unix_socket;AZA_ENABLE::##UXSOCK##" \
	"none;AZA_ENABLE:LGDE:##UXSOCK##" \
	"none;AZA_ENABLE::##UXSOCK##" \
	\
	"tcp;LIBRARY:##GID##" \
	)

	set mode=`echo $param | cut -d';' -f1`
	set restrp=`echo $param | cut -d';' -f2`

	# preserve a timestamp for debugging purposes, see:
	#   https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2106#note_2129635313
	touch audit_${mode}_${restrp}.txt

	echo
	echo "# ---- connection: $mode, restrict.txt: $restrp ----"
	set librarycomment=`echo $restrp | grep LIBRARY | wc -l`
	if ($librarycomment) then
		echo "# notice:"
		echo "#  case where there's no AZA_ENABLE in restrict.txt,"
		echo "#  only a neutral entry, e.g. LIBRARY"
	endif
	set allocport=`echo $restrp | grep PORTNO | wc -l`
	if ($allocport) then
		echo "# allocate a port number"
		source $gtm_tst/com/portno_acquire.csh >& portno.out
	endif
	if ( "$mode" == "none" ) then
		set gdelog=0
		set zaulog=0
	else
		set gdelog=`echo $restrp | grep LGDE | wc -l`
		set zaulog=`echo $restrp | grep AZA_ENABLE | wc -l`
	endif

	echo "# setup restrict.txt"
	# notice: using '|' as sed separator, because $uxsock contains '/'
	set restr=`echo $restrp \
		| sed -E "s|##PORTNO##|${portno}|g" \
		| sed -E "s|##UXSOCK##|${uxsock}|g" \
		| sed -E "s|##GID##|${gid}|g"`
	rm -f $ydb_dist/restrict.txt
	echo $restr > $ydb_dist/restrict.txt
	chmod a-w $ydb_dist/restrict.txt

	rm -f $aulogfile
	if ("$mode" == "tcp") then
		echo "# launch $mode audit_listener"
		($ydb_dist/audit_listener tcp $pidfile $aulogfile \
			$portno &)
		$gtm_tst/com/wait_for_port_to_be_listening.csh $portno
	endif
	if ("$mode" == "tls") then
		echo "# launch $mode audit_listener"
		($ydb_dist/audit_listener tls $pidfile $aulogfile \
			$portno $certfile $keyfile ydbrocks &)
		$gtm_tst/com/wait_for_port_to_be_listening.csh $portno
	endif
	if ("$mode" == "unix_socket") then
		echo "# launch $mode audit_listener"
		($ydb_dist/audit_listener unix $pidfile $aulogfile \
			$uxsock &)
		$gtm_tst/com/wait_for_unix_domain_socket_to_be_listening.csh $uxsock
	endif
	if ("$mode" == "none") then
		echo "# do not launch audit_listener"
		set pid=""
	else
		echo "# wait for pidfile"
		$gtm_dist/mumps -run waitforfilecreate $pidfile
		set pid=`cat $pidfile`
	endif

	echo "# attempt to execute a GDE command"
	# awk: trim trailing spaces of GDE output
	$gtm_dist/mumps -run GDE exit \
		|& grep "GDE-" \
		| cut -d'/' -f1 \
		| grep -v '^$' \
		| awk '{$1=$1;print}'

	if ($gdelog) then
		echo "# wait for GDE entry added to log"
		$gtm_tst/com/wait_for_log.csh -log $aulogfile -duration 1
		echo "# show GDE log captured:"
		touch $aulogfile
		cat $aulogfile | $ydb_dist/mumps -run "filter^auditlogfilter"
		echo "# reset log"
		kill -HUP $pid
	else
		echo "# wait for GDE entry added to log (won't happen)"
		sleep 1
		echo "# show GDE log captured (should be empty):"
		touch $aulogfile
		cat $aulogfile | $ydb_dist/mumps -run "filter^auditlogfilter"
	endif

	echo '# attempt to execute a M script with $ZAUDITLOG()'
	$ydb_dist/mumps -run logsome^gtmf170998 "rock'n'roll"
	# don't apply restrict.txt on M filter script
	rm -f $ydb_dist/restrict.txt

	if ($zaulog) then
		echo '# wait for $ZAUDITLOG() entry added to log'
		$gtm_tst/com/wait_for_log.csh -log $aulogfile -duration 1
		echo '# show $ZAUDITLOG() log captured:'
		touch $aulogfile
		cat $aulogfile | $ydb_dist/mumps -run "filter^auditlogfilter"
		echo "# reset log"
		kill -HUP $pid
	else
		echo -n '# wait for $ZAUDITLOG() entry added to log'
		echo " (won't happen)"
		sleep 1
		echo '# show $ZAUDITLOG() log captured (should be empty):'
		touch $aulogfile
		cat $aulogfile | $ydb_dist/mumps -run "filter^auditlogfilter"
	endif

	if ( "$pid" != "" ) then
		echo "# stop audit_listener and wait for finish"
		kill -TERM $pid >>& stop_audit_listener.outx
		$gtm_tst/com/wait_for_proc_to_die.csh $pid >>& stop_audit_listener.outx
		rm -f $pidfile
	endif

	if ($allocport) then
		echo "# release port number"
		$gtm_tst/com/portno_release.csh
	endif

	rm -f $aulogfile
end

echo
echo "# ---- cleanup ----"

echo "# shutdown database"
setenv gtm_dist $old_dist
setenv ydb_dist $gtm_dist
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
