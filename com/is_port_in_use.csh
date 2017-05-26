#!/usr/local/bin/tcsh -f
# returns TRUE(0) if portno is found either in the netstat or lsof output
# Usage is_port_in_use.csh portno <out file>
if ($2 != "") then
	set logfile = $2
else
	set logfile = "is_port_in_use.logx"
endif
if ($1 == "") then
	echo "TEST-E-PARAM-ERR Port number required as the first parameter"
	echo "is_port_in_use.csh portno <out file>"
	exit -1
else
	set portno = $1
        # Linux occasionally reports "bogus", let's not trust that output
	# grep -w is not used the grep below and in the ps grep, since grep -wE does not work on Solaris.
	# Since a "wrong grep result" would just mean the port is incorrectly assumed as in-use (which doesn't fail a test), it is okay to live with it
	echo "=========================================================" >>& netstat_$logfile
	date >>& netstat_$logfile
	$netstat |& $grep -v grep |& $grep -E "$portno|bogus" >>& netstat_$logfile
	set nstat = $status
	echo "=========================================================" >>& lsof_$logfile
	date >>& lsof_$logfile
	$lsof -i:$portno |& $grep -v grep |& $grep $portno >>& lsof_$logfile
	set lstat = $status
	$ps |& $grep -v grep |& $grep -E "mupip.*[:=]$portno" >>& ps_$logfile
	set grepstat = $status
	if ((0 == $nstat) || (0 == $lstat) || (0 == $grepstat)) then
		exit 0
	else
		exit 1
	endif
endif
	

