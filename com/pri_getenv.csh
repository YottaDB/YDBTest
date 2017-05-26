#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
##pri_getenv.csh
#
# This script is meant for primary side version switch. If called with argument it will switch to that version
# else will switch to the test version.
# For now being used by MSR tests when the multiple instances gets switched as primary , secondary and vice-versa.
#
###############################
## GTM software environments ##
if ( "" != "$1" ) then
	set switch_ver = "$1"
else
	set switch_ver = $tst_ver
endif
if ( "" != "$2" ) then
	set switch_image = "$2"
else
	set switch_image = $tst_image
endif
setenv gtm_ver_noecho
source $gtm_tst/com/set_active_version.csh $switch_ver $switch_image
setenv GTM "$gtm_exe/mumps -direct"
setenv MUPIP "$gtm_exe/mupip"
setenv LKE "$gtm_exe/lke"
setenv DSE "$gtm_exe/dse"
setenv GDE "$gtm_exe/mumps -run GDE"
# gtm_chset will be randomly chosen to either UTF-8 or M and so we need to set up the proper gtmroutines as a part of env. setup.
source $gtm_tst/com/reset_gtmroutines.csh
