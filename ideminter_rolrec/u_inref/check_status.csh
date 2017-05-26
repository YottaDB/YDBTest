#!/usr/local/bin/tcsh -f
set logfile = $1
#GTM-E-MUNOACTION is printed whenever rollback/recovery exits abruptly. Filter that out (since it is a secondary message)
$grep -E ".-[EFW]-" $logfile  | $grep -vE "FORCEDHALT|MUNOACTION|MUKILLIP" > /dev/null
if (! $status) then
	echo "TEST-E-MUPIP ERROR, there was an error in $logfile, cannot continue with the test"
	$grep -E ".-[EFW]-" $logfile  | $grep -vE "FORCEDHALT|MUNOACTION|MUKILLIP"
	exit 4
endif
