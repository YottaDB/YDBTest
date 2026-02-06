#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Time stamp for this execution uses GT.M version and PID because this can be executed in the same second
set stamp = "${gtm_verno}_$$_`date +%Y%m%d%H%M%S`"

# Move pre-existing dump files out of the way because GDE overwrites any existing GDEDUMP.DMP files when it dumps
if ( -e GDEDUMP.DMP ) then
	mv GDEDUMP.DMP GDEDUMP.DMP_${stamp}
endif
# Need to trap newly created core files in case the prior version MUMPS core dumps in GDE
set nonomatch ; set allcorelist=(core.*) ; unset nonomatch ; if ("core.*" == "$allcorelist") set allcorelist = ()
set precorecount = $#allcorelist

$gtm_dist/mumps -run GDE $* >>& safegde_${stamp}.outx < /dev/null
set gdestat=$status
set nonomatch ; set corelist=(core.*) ; unset nonomatch ; if ("core.*" == "$corelist") set corelist = ()
# Mask this GDEDUMP.DMP file because it may be due to D9K10-002786
if ( -e GDEDUMP.DMP) then
	mv GDEDUMP.DMP GDEDUMP.xDMP_${stamp}
endif
# Mask any newly created core file(s)
if ($precorecount != $#corelist) then
	foreach core ($corelist)
		set precount = $#allcorelist
		set -f allcorelist = ($allcorelist $core)
		# Core count changed, move the core file out of the way
		if ($precount != $#allcorelist) then
			mv $core gde${core}_${stamp}
		endif
	end
endif
set nonomatch ; set corelist=(core.*) ; unset nonomatch ; if ("core.*" == "$corelist") set corelist = ()

$tst_awk '/^$/{nl++;getline}/^(GTM|GDE)>/{getline;nl--}{if(nl){print "";nl--}print}' safegde_${stamp}.outx
if ( -e GDEDUMP.DMP ) then
	# don't leave files in the way in case GDE dumps again
	mv GDEDUMP.DMP GDEDUMP.DMP_${stamp}
	echo "TEST-E-SAFEGDE ERROR Check safegde_${stamp}.outx for details"
	exit 1
endif
exit $gdestat
