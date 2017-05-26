#!/usr/local/bin/tcsh
#
# D9H02-002642 PROFILE screen function keys do not work with GT.M V5.2 on AIX/Solaris/HPUX
#

# set host=zztop2
# set remote_dist_path=/gtm/library/V982/dbg
#
if (-X expect) then
	setenv TERM xterm
	expect -f test/v52000/u_inref/D9H02002642_remote.exp $host $remote_dist_path
	echo "Done..."
else
	echo "No expect in PATH, please install"
endif
