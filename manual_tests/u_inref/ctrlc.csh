#! /usr/local/bin/tcsh -f
set ctst="${0:t:r}"
set prompt="$ctst `hostname`:$PWD >"
source $cms_tools/server_list
setenv echoline 'echo ###################################################################'

foreach host ($server_args)
	$echoline
	echo $host
	expect $gtm_test/T999/manual_tests/u_inref/remote_${ctst}.exp $host $gtm_tst $gtm_verno
end

exit 0
