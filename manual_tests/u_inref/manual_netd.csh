#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# manual_netd.csh <version>

echo -n "Root Password: "

setty -echo
stty -echo
set password=$<
setty +echo
stty echo
echo ""
echo ""

set SSH=ssh
set EXPECT="expect"
set TARGET_USER="root"
set SPAWN_QUIET="-noecho"
set distver=$1
if ($distver == "") then
    set distver=V990
endif
if ( "${0:h:h:h:t}" =~ T[6-9]* ) then
	setenv testver ${0:h:h:h:t}
else
	echo "${0:h:h:h:t} is not a T[6-9]* version, using T990"
	setenv testver T990
endif

set target_host=$HOST

# This expect script disables, enables and restarts [x]inetd as root. The actual test is run as gtnmuser.
${EXPECT} <<END_EXPECT
	set timeout 300
	spawn ${SPAWN_QUIET} ${SSH} -x ${TARGET_USER}@${target_host}
	expect -re "\[Pp\]assword:" {
		send "${password}\\r"
	}
	expect -re {[#\$]} {
		send "exec /bin/bash\\r"
	}
	expect "#" {send "export PS1=YOUR_COMMANDS_SIR\\r"}
	expect "YOUR_COMMANDS_SIR"
	send -- "uname\r"

	expect {
		# HPUX is teh stupids
		"HP-UX" {
		    send -- "export TERM=vt320\r"
		    expect -- "YOUR_COMMANDS_SIR"
		    send -- "stty erase '^?'\r"
		    expect -- "YOUR_COMMANDS_SIR"
		    send -- "stty intr '^c'\r"
		    expect -- "YOUR_COMMANDS_SIR"
		    send -- "stty -a\r"
		}
		# stty shows AIX mapping ^H to erase, fix it
		"AIX" {
		    send -- "uname -vr\r"
		    sleep 1
		    expect {
			    "1 7" {
				    send -- "stty erase '^?'\r"
			    }
			    "1 6" {
				    send -- "stty erase '^?'\r"
			    }
			    "3 5" {
				    send -- "export TERM=screen\n"
				    expect -- "YOUR_COMMANDS_SIR"
				    send -- "stty erase '^?'\r"
			    }
		    }
		}
		"SunOS" {
		    send -- "export TERMINFO=/usr/local/lib/terminfo\r"
		    expect -- "YOUR_COMMANDS_SIR"
		    send -- "export TERM=vt320\r"
		    expect -- "YOUR_COMMANDS_SIR"
		    send -- "alias stty=/usr/ucb/stty\r"
		}
		"Linux" {send -- "\r"}
	}
	expect "YOUR_COMMANDS_SIR" {send "/gtc/staff/gtm_test/current/${testver}/manual_tests/u_inref/c002916.csh ${distver} disable\\r" }
	expect "YOUR_COMMANDS_SIR" {send "/gtc/staff/gtm_test/current/${testver}/manual_tests/u_inref/c002916.csh ${distver}  enable\\r" }
	expect "YOUR_COMMANDS_SIR" {send "/gtc/staff/gtm_test/current/${testver}/manual_tests/u_inref/c002916.csh ${distver} restart\\r" }
	expect "YOUR_COMMANDS_SIR" {send "su gtmtest\\r"}
	expect -re {[>\$]} {send "set prompt=YOUR_COMMANDS_SIR\\r"}
	expect "YOUR_COMMANDS_SIR"
	expect "YOUR_COMMANDS_SIR" {send "setenv gtm_verno ${distver}\\r"}
	expect "YOUR_COMMANDS_SIR" {send "/gtc/staff/gtm_test/current/${testver}/manual_tests/u_inref/c002916.csh ${distver} client\\r" }
	expect "YOUR_COMMANDS_SIR" {send "exit\\r" }
	expect "YOUR_COMMANDS_SIR" {send "/gtc/staff/gtm_test/current/${testver}/manual_tests/u_inref/c002916.csh ${distver} disable\\r" }
	expect "YOUR_COMMANDS_SIR" {send "/gtc/staff/gtm_test/current/${testver}/manual_tests/u_inref/c002916.csh ${distver} restart\\r" }
	expect "YOUR_COMMANDS_SIR" {send "exit\\r" }
	expect "closed"
	wait
	send_tty "\\n"
END_EXPECT


