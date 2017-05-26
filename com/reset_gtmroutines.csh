#!/usr/local/bin/tcsh -f
#
# This script is mainly meant for MSR actions and replication in general. It will be called "getenv" scripts before executing respective replication action
# In addition to switch_gtm_versions.csh where gtmroutines is handled for prior version switch this script will also set gtmroutines appropriate
# Because MSR world operates differently. It sets up the environment in its own self sufficient way based on the msr_configurations and such.
# However they all execute "getenv" scripts where before the final replication action on any given site the env. is setup.
# reset_gtmroutines will be called by those "getenv" scripts and correct translatation of gtmroutines as per the version and the chset mode is done
#
if (51 >= "`echo $gtm_exe:h:t|cut -c2-3`") then
	source $gtm_tst/com/set_gtmroutines.csh "M"
else
	if ($?gtm_chset) then
		if ("UTF-8" == "$gtm_chset") then
			source $gtm_tst/com/set_gtmroutines.csh "UTF8"
		endif
	else
		source $gtm_tst/com/set_gtmroutines.csh "M"
	endif
endif
#
