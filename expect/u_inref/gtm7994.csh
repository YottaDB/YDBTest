#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that the application terminators do not affect direct mode if DMTERM is specified
setenv gtm_dmterm 1
setenv TERM vt220

echo "# Running expect (output: expect.out)"
expect <<EOF > expect.out
    set timeout 10
    spawn $GTM
    # DMTERM is enabled by the gtm_dmterm env. variable
    expect "GTM>" {send "write \\\$view(\\"DMTERM\\")\\r"}
    expect {
	-exact "1" { }
	timeout {puts "Error! DMTERM does not appear to be enabled."; exit 1}
    }
    # Set the terminator to '0' character
    expect "GTM>" {send "use \\\$io:(TERMINATOR=\\"0\\")\\r"}
    # Below read command is terminated by the '0' character
    expect "GTM>" {send "read val\\rEXAMPLE1_STRING0"}
    # Here, we still accept <enter> as a terminator
    expect "GTM>" {send "zwrite val\\r"}
    expect {
	-exact "val=\\"EXAMPLE1_STRING\\"" { }
	timeout {puts "Error! EXAMPLE1_STRING did not appear in the zwrite output."; exit 1}
    }
    expect "GTM>" {send "zwrite \\\$ZB,\\\$key\\r"}
    expect {
	-exact "\\\$ZB=0" { }
	-exact "\\\$key=0" { }
	timeout {puts "Error! .\\\$ZB or \\\$key did not have the correct value when the terminal is CR."; exit 1}
    }
    # Exit DMTERM
    expect "GTM>" {send "view \\"NODMTERM\\"\\r"}
    # Here, the character '0' is used as a command line terminator
    expect "GTM>" {send "write \\\$view(\\"DMTERM\\")0"}
    expect {
	-exact "0" { }
	timeout {puts "Error! DMTERM does not appear to be disabled."; exit 1}
    }
    # '0' terminates the read command as well
    expect "GTM>" {send "read val0EXAMPLE2_STRING0"}
    expect "GTM>" {send "zwrite val0"}
    expect {
	-exact "val=\\"EXAMPLE2_STRING\\"" { }
	timeout {puts "Error! EXAMPLE2_STRING did not appear in the zwrite output."; exit 1}
    }
    expect "GTM>" {send "zwrite \\\$ZB,\\\$key0"}
    expect {
	-exact "\\\$ZB=0" { }
	-exact "\\\$key=0" { }
	timeout {puts "Error! .\\\$ZB or \\\$key did not have the correct value when the direct mode terminator is 0."; exit 1}
    }
    # Go back to DMTERM and quit
    expect "GTM>" {send "view \\"DMTERM\\"0"}
    expect "GTM>" {send "write \\\$view(\\"DMTERM\\")\\r"}
    expect {
	-exact "1" { }
	timeout {puts "Error! DMTERM does not appear to be re-enabled."; exit 1}
    }
    expect "GTM>" {send "halt\\r"}
EOF
if ($status) then
    echo "TEST-E-FAIL Expect error check expect.out"
else
    echo "TEST-I-PASS"
endif
