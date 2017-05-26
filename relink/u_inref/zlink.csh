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

# Tests various combinations zlink and autorelink functionality.
#
# zlinkcases.m contains the different combinations of zlink calls.
# For example, if both the .o and the .m are present, whether
# an extension is used on the zlink call, etc.
#
# zlink.m runs multiple passes across these combinations. These
# passes vary whether autorelinking is used, the zroutines, etc.

cat > pass.m <<DONE
pass
	write "Pass",!
	quit
DONE

cat > fail.m <<DONE
fail
	write "Fail",!
	quit
DONE

$gtm_dist/mumps -run zlink
