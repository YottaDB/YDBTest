#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2009, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9J06003134 GDE should print error if not able to source the .gde file (e.g. permissions)
#

cp -f $gtm_tst/$tst/inref/c003134.gde .

# Test that sourcing normal .gde works fine
$GDE << GDE_EOF
@c003134.gde
quit
GDE_EOF

# Test that sourcing .gde that does not have read permissions issues an error
chmod -r c003134.gde
$GDE << GDE_EOF
@c003134.gde
quit
GDE_EOF
chmod +r c003134.gde

# Test that sourcing .gde that does not exist issues an error and that the error can be followed by success
$GDE << GDE_EOF
@c003134a.gde
@c003134.gde
quit
GDE_EOF

