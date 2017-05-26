#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# GT.M versions prior to V54002 suffer from D9K10-002786 on newer platforms
# which causes GDE to randomly dump due to local variable corruption. Take
# evasive action when GDE fails with a prior version.
#
# (option 1) This script executes GDE as normal on the first try. If GDE dumps
# and the version is prior to V54002, try option 2.
#
# (option 2) attempt a retry calling GDE from direct mode rather than from mumps -run
#
# (option 3) Use the old GDE code with the current run time to recreate the
# GLD. This option does not work and should be revisited if option 2 fails.

# Time stamp for this execution uses GT.M version and PID because this can be executed in the same second
set stamp = "${gtm_verno}_$$_`date +%Y%m%d%H%M%S`"

# Move pre-existing dump files out of the way because GDE overwrites any existing GDEDUMP.DMP files when it dumps
if ( -e GDEDUMP.DMP ) then
	mv GDEDUMP.DMP GDEDUMP.DMP_${stamp}
endif
# Need to trap newly created core files in case the prior version MUMPS core dumps in GDE
set nonomatch ; set allcorelist=(core.*) ; unset nonomatch ; if ("core.*" == "$allcorelist") set allcorelist = ()
set precorecount = $#allcorelist

# Max tries depends on which version used
set create_tries = 0
if (`expr $gtm_verno "<" "V54002"`) then
	set create_tries = 2
endif

# 1. First Try
$gtm_dist/mumps -run GDE $* >>& safegde_${stamp}_${create_tries}.outx < /dev/null
set gdestat=$status
set nonomatch ; set corelist=(core.*) ; unset nonomatch ; if ("core.*" == "$corelist") set corelist = ()
while (( -e GDEDUMP.DMP || ($precorecount != $#corelist)) && ($create_tries > 0))
	# Mask this GDEDUMP.DMP file because it may be due to D9K10-002786
	if ( -e GDEDUMP.DMP) then
		mv GDEDUMP.DMP GDEDUMP.xDMP_${stamp}_${create_tries}
	endif
	# Mask any newly created core file(s)
	if ($precorecount != $#corelist) then
		foreach core ($corelist)
			set precount = $#allcorelist
			set -f allcorelist = ($allcorelist $core)
			# Core count changed, move the core file out of the way
			if ($precount != $#allcorelist) then
				mv $core gde${core}_${stamp}_${create_tries}
			endif
		end
	endif
	@ create_tries--
	if ($create_tries >= 1) then
		# 2. Second try - do it from direct mode
		$GTM >>& safegde_${stamp}_${create_tries}.outx << EOF
do ^GDE
$*
exit
EOF
		set gdestat=$status
	else
		# 3. Third try - use the older GDE with the CURPRO runtime
		$gtm_tst/com/mumps_curpro.csh -cur_dist_rtns gtmgbldir=$gtmgbldir -run GDE $* >>& safegde_${stamp}_${create_tries}.outx
		set gdestat=$status
	endif
	set nonomatch ; set corelist=(core.*) ; unset nonomatch ; if ("core.*" == "$corelist") set corelist = ()
end

$tst_awk '/^$/{nl++;getline}/^(GTM|GDE)>/{getline;nl--}{if(nl){print "";nl--}print}' safegde_${stamp}_${create_tries}.outx
if ( -e GDEDUMP.DMP ) then
	# don't leave files in the way in case GDE dumps again
	mv GDEDUMP.DMP GDEDUMP.DMP_${stamp}_${create_tries}
	echo "TEST-E-SAFEGDE ERROR Check safegde_${stamp}_${create_tries}.outx for details"
	exit 1
endif
exit $gdestat
