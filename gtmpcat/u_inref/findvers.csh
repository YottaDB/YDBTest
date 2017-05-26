#!/usr/local/bin/tcsh -f
#
# Find the production versions resident on this system. Add to that list the current version if
# not already in the list and we have the list of versions to process. Type the list when we are
# done.
#
source $gtm_tst/com/set_gtm_machtype.csh
if ("HOST_HP-UX_IA64" == "$gtm_test_os_machtype") then
    set hpuxia64 = 1
else
    set hpuxia64 = 0
endif
#
set allverlist = `\ls $gtm_root/ | $grep -E '^V[5-8][0-9][0-9][0-9][0-9][A-Z]?$'`
set actualverlist = ""
foreach ver ($allverlist)
    if (("$ver" != "$gtm_verno") && (`expr $ver \>= V51000`)) then
	#
	# HPUX IA64 is kinda screwed up until V53002 with JOB command errors and socket issues
	#
	if (!($hpuxia64) || (`expr $ver \>= V53002`)) set actualverlist = "$actualverlist $ver"
    endif
end
echo "$actualverlist $gtm_verno"
exit
