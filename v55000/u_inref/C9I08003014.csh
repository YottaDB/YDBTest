#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2011, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# test that CTrap 3 interrupt does not cause mpc/ctxt reset of an indirect frame that breaks the frame
# have to use expect because $P has to be a terminal for CTRAP to work

setenv TERM vt320
expect -f $gtm_tst/$tst/u_inref/C9I08003014.exp $gtm_dist
