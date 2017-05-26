#!/usr/local/bin/tcsh -f
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
#
# Test that on completion of a READ from a terminal device, $KEY has the same value as $ZB.
#

setenv TERM xterm
expect -f $gtm_tst/$tst/u_inref/dlrkey.exp $gtm_dist
