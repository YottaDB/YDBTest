#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that the application terminators do not affect direct mode if DMTERM is specified
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_dmterm gtm_dmterm 1
setenv TERM vt220

echo "# Running expect (output: expect.out)"
expect <<EOF > expect.out
    set timeout 10
    spawn $GTM
    # DMTERM is enabled by the ydb_env/gtm_dmterm env. variable
    expect "YDB>" {send "write \\\$view(\\"DMTERM\\")\\r"}
    expect {
	-exact "1" { }
	timeout {puts "Error! DMTERM does not appear to be enabled."; exit 1}
    }
    # Set the terminator to '0' character
    expect "YDB>" {send "use \\\$io:(TERMINATOR=\\"0\\")\\r"}
    # Below read command is terminated by the '0' character
    expect "YDB>" {send "read val\\rEXAMPLE1_STRING0"}
    # Here, we still accept <enter> as a terminator
    expect "YDB>" {send "zwrite val\\r"}
    expect {
	-exact "val=\\"EXAMPLE1_STRING\\"" { }
	timeout {puts "Error! EXAMPLE1_STRING did not appear in the zwrite output."; exit 1}
    }
    expect "YDB>" {send "zwrite \\\$ZB,\\\$key\\r"}
    expect {
	-exact "\\\$ZB=0" { }
	-exact "\\\$key=0" { }
	timeout {puts "Error! .\\\$ZB or \\\$key did not have the correct value when the terminal is CR."; exit 1}
    }
    # Exit DMTERM
    expect "YDB>" {send "view \\"NODMTERM\\"\\r"}
    # Here, the character '0' is used as a command line terminator
    expect "YDB>" {send "write \\\$view(\\"DMTERM\\")0"}
    expect {
	-exact "0" { }
	timeout {puts "Error! DMTERM does not appear to be disabled."; exit 1}
    }
    # '0' terminates the read command as well
    expect "YDB>" {send "read val0EXAMPLE2_STRING0"}
    expect "YDB>" {send "zwrite val0"}
    expect {
	-exact "val=\\"EXAMPLE2_STRING\\"" { }
	timeout {puts "Error! EXAMPLE2_STRING did not appear in the zwrite output."; exit 1}
    }
    expect "YDB>" {send "zwrite \\\$ZB,\\\$key0"}
    expect {
	-exact "\\\$ZB=0" { }
	-exact "\\\$key=0" { }
	timeout {puts "Error! .\\\$ZB or \\\$key did not have the correct value when the direct mode terminator is 0."; exit 1}
    }
    # Go back to DMTERM and quit
    expect "YDB>" {send "view \\"DMTERM\\"0"}
    expect "YDB>" {send "write \\\$view(\\"DMTERM\\")\\r"}
    expect {
	-exact "1" { }
	timeout {puts "Error! DMTERM does not appear to be re-enabled."; exit 1}
    }
    expect "YDB>" {send "halt\\r"}
EOF
if ($status) then
    echo "TEST-E-FAIL Expect error check expect.out"
else
    echo "TEST-I-PASS"
endif
