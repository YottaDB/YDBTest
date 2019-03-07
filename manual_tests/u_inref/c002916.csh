#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Use this script to automate [x]inetd configuration and status checking.
# Please refer to the help section for usage information.
# Intentionally drop the -f to pull in all the host TCSH configuration

#ONLY WORKS WITH PRO VERSION

# test setup
if ! (-X gawk) source /gtc/staff/common/etc_csh.cshrc

if ( "$1" =~ [vV][6-9]* ) then
	setenv gtm_verno $1
else
	setenv gtm_verno  V990
endif

echo "Runing with ${gtm_verno} pro"
setenv gtm_tools /usr/library/$gtm_verno/tools
setenv gtm_dist /usr/library/$gtm_verno/pro
setenv gtm_exe $gtm_dist
setenv gtmroutines ". $gtm_exe"

if ( "${0:h:h:h:t}" =~ T[6-9]* ) then
	setenv tver ${0:h:h:h:t}
else
	echo "${0:h:h:h:t} is not a T[6-9]* version, using T990"
	setenv tver T990
endif
echo "Using $gtm_verno / $tver"
setenv gtm_tst $gtm_test/${tver}
setenv tst manual_tests
source $gtm_test/${tver}/com/set_specific.csh


set cmd = "$2"
if ( "${cmd}" == "" ) then
	set cmd = "show"
endif

# Port number is fixed to 9777 because inetd requires the port number to set in /etc/services.
set port = "$3"
if ( "${port}" == "" ) then
	set port = 9777
endif

# check user credentials
set id = `id -un`
if ("${cmd}" == "client") then
	if ( "${id}" == "root") then
		echo "You need to be user to execute ${cmd}"
		exit 1
	endif
else if ( "${cmd}" == "enable" || "${cmd}" == "disable" || "${cmd}" == "restart") then
	if ( "${id}" != "root") then
		echo "You need to be root to execute ${cmd}"
		exit 1
	endif
endif

set tmpfile=/tmp/__${USER}_c002916_inetd_$$

# Assumption: The presence of /etc/xinetd.conf means that xinetd is the active INET daemon. It's possible for inetd or some other
# INET service to be running, but /etc/xinetd.conf is hanging around from a prior configuration. The alternative is to use ps to
# find out which INET is running.
# Amul: we could check /var/run for a PID file as well, but that would require some more platform specific smarts.
if ( -e /etc/xinetd.conf ) then
    set xinet_avail = 1
    echo "Permissions for ls /etc/xinetd.d/C9H10002916:"
    ls -l /etc/xinetd.d/C9H10002916
else if ( -e /etc/inetd.conf ) then
    set xinet_avail = 0
    echo "Permissions for /etc/inetd.conf:"
    ls -l /etc/inetd.conf
else
    echo "/etc/(x)inet.conf does not exist. Test can not continue. Check your (x)inet settings."
    exit 1
endif

set issolaris=`uname -a | $tst_awk '/SunOS/{sub(/5./,"",$3);print $3;i++}END{if(i==""){print 0}}'`

echo $version | $grep pa_risc
if ((0 == $status) || (0 != $issolaris)) then
	set ipv6test=0
else
	set ipv6test=1
endif

# aliases
set backslash_quote
alias showinetdserver  '$tst_awk \'BEGIN{printf "The target server is "}/C9H10002916/{print $6;i++}END{print (i)?"":"MISSING"}\' /etc/inetd.conf'
alias checkinetdcfg    '$tst_awk \'BEGIN{printf "The configuration is "}/C9H10002916/{if($0 ~ /^#/){print "DISABLED"}else{print "ENABLED"}i++;exit}END{print (i)?"":"MISSING"}\' /etc/inetd.conf'

alias checkxinetdcfg   '$tst_awk \'BEGIN{printf "The configuration is "}/disable/{if($NF ~ /[Nn][Oo]/){print "ENABLED"}else{print "DISABLED"}}\' /etc/xinetd.d/C9H10002916'
alias showxinetdserver '$tst_awk \'BEGIN{printf "The target server is "}/server = /{print $NF;i++}END{print (i)?"":"MISSING"}\' /etc/xinetd.d/C9H10002916'

# run the commands
switch ($cmd)
	case help:
		echo "Usage of $0"
		echo "help | usage : display this help"
		echo "show | info  : validate the current configuration (default)"
		echo "enable       : (must run as root) enable the C9H10002916 [x]inetd configuration. establish the [x]inetd configuration if necessary. you must \'$0 restart\'"
		echo "disable      : (must run as root) disable the C9H10002916 [x]inetd configuration. you must \'$0 restart\'"
		echo "restart      : (must run as root) restart the [x]inetd server after a configuration change"
		echo "client       : (should be run as a regular user) run the C9H10002916 client and validate/dump some of the output"
		breaksw
	case show:
	case info:
		echo "Check port ${port} in /etc/services"
		$tst_awk '/'${port}'/{printf "\t"$0;i++}END{print (i)?"":"\t--->> not present, please add <<---\n\t\\"gtmserver\t9777/tcp\t# C9H10002916\\""}' /etc/services
		echo "Checking if port ${port} is in use"
		netstat -an | $tst_awk '/:'${port}'/{print "\t"$0;i++}END{if(i<1){print "\t--->> port '${port}' not in use <<---"}}'
		echo "Check for the [x]inetd process"
		$ps | $tst_awk '/inetd/ && \!/awk/ {print "\t"$0;i++}END{if(i<1){print "\t--->> please start inetd <<---"}}'
		echo -n "Check for the [x]inetd configurations: "
		if ( $xinet_avail ) then
			echo "XINETD"
			if ( -e /etc/xinetd.d/C9H10002916 ) then
				checkxinetdcfg
				showxinetdserver
			else
				echo "But there is no /etc/xinetd.d/C9H10002916. \'enable\' will copy it"
			endif
		else if ($issolaris) then
			inetadm -l svc:/network/gtmserver/tcp:default
		else
			echo "INETD"
			checkinetdcfg
			showinetdserver
		endif
		breaksw
	case enable:
		\rm C9H10002916.*inetd >& /dev/null
		cat > /tmp/C9H10002916.xinetd <<EOF
service gtmserver
{
# NOTE : All xinetd configurations intentionally call the service gtmserver
#	 Do not try to run more than one at once
#       YES means do not run this service
        disable = no
#       UNLISTED because xinetd can be told the service is not in /etc/services
	type = UNLISTED
	port = $port
	socket_type = stream
	protocol = tcp
	user = gtmtest
	wait = no
	FLAGS = IPv4
	server = /gtc/staff/gtm_test/current/$tver/manual_tests/u_inref/C9H10002916.sh
	server_args = $gtm_verno $tver
}
EOF

		cat > /tmp/C9H10002916.xinetd6 <<EOF
service gtmserver
{
# NOTE : All xinetd configurations intentionally call the service gtmserver
#	 Do not try to run more than one at once
#       YES means do not run this service
        disable = no
#       UNLISTED because xinetd can be told the service is not in /etc/services
	type = UNLISTED
	port = $port
	socket_type = stream
	protocol = tcp
	user = gtmtest
	wait = no
	FLAGS = IPv6
	server = /gtc/staff/gtm_test/current/$tver/manual_tests/u_inref/C9H10002916.sh
	server_args = $gtm_verno $tver
}
EOF

		cat > /tmp/C9H10002916.inetd <<EOF
gtmserver stream tcp nowait gtmtest /gtc/staff/gtm_test/current/$tver/manual_tests/u_inref/C9H10002916.sh C9H10002916.sh $gtm_verno $tver
EOF
		cat > /tmp/C9H10002916.inetd6 <<EOF
gtmserver stream tcp6 nowait gtmtest /gtc/staff/gtm_test/current/$tver/manual_tests/u_inref/C9H10002916.sh C9H10002916.sh $gtm_verno $tver
EOF

		if (0 == $ipv6test) then
			set rand = 0
		else
			set rand = `echo | $tst_awk '{srand(); print int(rand()+0.5)}'`
		endif

		if ( $xinet_avail ) then
			echo "Enabling gtmserver xinetd configuration"
			if (0 == $rand) then
				cp /tmp/C9H10002916.xinetd /etc/xinetd.d/C9H10002916
			else
				cp /tmp/C9H10002916.xinetd6 /etc/xinetd.d/C9H10002916
			endif
			checkxinetdcfg
		else if ($issolaris) then
			inetconv -i /tmp/C9H10002916.inetd
			inetadm -e svc:/network/gtmserver/tcp:default
			if ($issolaris > 10) then
			    svcadm enable svc:/network/gtmserver/tcp:default
			endif
		else
			echo "Enabling gtmserver inetd configuration"
			$grep -v C9H10002916 /etc/inetd.conf > ${tmpfile}
			if (0 == $rand) then
				cat /tmp/C9H10002916.inetd >> ${tmpfile}
			else
				cat /tmp/C9H10002916.inetd6 >> ${tmpfile}
			endif
			diff /etc/inetd.conf ${tmpfile}
			\mv ${tmpfile}  /etc/inetd.conf
			checkinetdcfg
		endif
		breaksw
	case disable:
		if ( $xinet_avail ) then
			echo "Disabling gtmserver xinetd configuration"
			if ( -e /etc/xinetd.d/C9H10002916 ) then
				$tst_awk '/disable/{$0="\tdisable = yes"}{print}' /etc/xinetd.d/C9H10002916 > ${tmpfile}
				diff -u /etc/xinetd.d/C9H10002916 ${tmpfile}
				cat ${tmpfile} > /etc/xinetd.d/C9H10002916
				checkxinetdcfg
			else
				echo "There is no /etc/xinetd.d/C9H10002916. Nothing to disable"
			endif
		else if ($issolaris) then
			inetadm -d svc:/network/gtmserver/tcp:default
			svccfg delete -f svc:/network/gtmserver/tcp:default
			if ($issolaris > 10) then
			    svccfg -s svc:/network/gtmserver/tcp:default delcust
			    rm /lib/svc/manifest/network/gtmserver* >& /dev/null
			else
			    rm /var/svc/manifest/network/gtmserver* >& /dev/null
			endif
			svcadm restart manifest-import
		else
			echo "Disabling gtmserver inetd configuration"
			$tst_awk '/^[^#]/ && /C9H10002916/{sub(/^/,"#")}{print}' /etc/inetd.conf > ${tmpfile}
			diff /etc/inetd.conf ${tmpfile}
			\mv ${tmpfile} /etc/inetd.conf
			checkinetdcfg
		endif
		breaksw
	case restart:
		if (0 == $issolaris) then
		    echo "Restarting the [x]inetd Internet super server"
		    if ("" == `$ps  | $grep inetd | $grep -v grep`) /etc/init.d/xinetd start
		    $ps | $tst_awk '/inetd/ && \!/awk/ {print $0;system("kill -HUP "$2)}' # BYPASSOK awk kill
		    if ($xinet_avail) service xinetd restart
		    # if we create a list of PID files we can do something like
		    # cat /var/run/xinetd.pid | xargs kill -HUP  # BYPASSOK kill
		endif
		breaksw
	case client:
		if ( "$gtm_dist" !~ *pro* ) then
		    echo "Please select a pro version and run again. "
		    exit 1
		endif
		cd /testarea1/gtmtest
	        setenv gtmroutines ".(. $gtm_test/${tver}/manual_tests/inref $gtm_test/${tver}/com) $gtm_dist"
		foreach operation (read write)
		    setenv ts1 `date +"%b %e %H:%M:%S"`
		    echo "$gtm_exe/mumps -run c002916client($operation,$port) > client_c002916_${HOST:r:r:r}.log"
		    $gtm_exe/mumps -run %XCMD "do ^c002916client(\"$operation\",$port)" > client_c002916_${HOST:r:r:r}.log
		    echo "######VALIDATION#####VALIDATION######VALIDATION#####VALIDATION######VALIDATION#####"
		    sleep 1 # ensure that time advances
		    $gtm_tst/com/getoper.csh "$ts1" "" srv_c002916_${HOST:r:r:r}.syslog "" NOPRINCIO
		    set srvpid=`$tst_awk -F"=" '/^.JOB=/{print $2;exit}' /testarea1/gtmtest/$gtm_verno/gtminetd/c2916out.txt`
		    echo "A NOPRINCIO message should come from the PID : $srvpid"
		    ($grep NOPRINCIO srv_c002916_${HOST:r:r:r}.syslog | $grep $srvpid ) || echo "TEST-F-FAIL : $srvpid not seen in syslog"
		    $tst_awk '/^after|dollarkey/{print FILENAME":"NR":"$0}/^.(JOB|ZSTATUS|ECODE|IO)=".+"/{print FILENAME":"NR":"$0}/(SOCKET|DELAY|DELIM)/{print FILENAME":"NR":"$0}' /testarea1/gtmtest/$gtm_verno/gtminetd/c2916out*.txt
		    set ts="_`date +%Y%m%d_H%M%S`"
		    # save files
		    \mv -f client_c002916_${HOST:r:r:r}.log{,${ts}}
		    \mv -f srv_c002916_${HOST:r:r:r}.syslog{,${ts}}
		    cp /testarea1/gtmtest/$gtm_verno/gtminetd/c2916out.txt c2916out.txt_${ts}
		end
		breaksw
	default:
		echo "How did you get here?"
		exit -1
		breaksw
endsw

exit 0
