#!/usr/local/bin/tcsh -f

# delete all triggers with this script
cat > tmprem.trg << EOF
-*
EOF
# convert for z/OS
$convert_to_gtm_chset tmprem.trg

$MUPIP trigger -triggerfile=tmprem.trg -noprompt >&! tmprm.trigout

# capture status and report errors
set zstat=$status
if ( $zstat ) then 
	cat tmprm.trigout
endif
rm tmprem.trg tmprm.trigout

# rethrow the mupip error
exit $zstat
