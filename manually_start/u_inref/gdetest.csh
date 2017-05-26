#!/usr/local/bin/tcsh -f
# always switch to M mode to avoid libicu related errors
$switch_chset "M" >&! switch_to_M.outx

alias sv 'source $gtm_tst/com/switch_gtm_version.csh \!:1 \!:2'

if (!($?GDE_SAFE)) setenv GDE_SAFE "$gtm_tst/com/pre_V54002_safe_gde.csh"
# ls *.gld && ls *.gld | xargs rm

setenv gtm_ver_noecho
foreach version ($gtm_root/V[4-8]*[0-9A-Z])
	sv ${version:t} ${tst_image:al}
	setenv gtmgbldir ${version:t}.gld
	$GDE_SAFE exit >&! ${version:t}.gdeout
	if ( ! -e ${version:t}.gld ) then
		echo "TEST-F-FAIL : ${version:t}.gld does not exist"
		$GDE exit
	endif
end
