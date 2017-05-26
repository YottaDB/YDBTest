#!/usr/local/bin/tcsh -f

# set host=zztop2
# set tst=v52000
# expect -f test/v52000/u_inref/D9G12002636_remote.exp $host /gtm/library/V982 $gtm_test/T982 $tst `ssh $host "pwd"`

if (-X expect) then
	setenv TERM xterm
	expect -f $gtm_tst/$tst/u_inref/D9G12002636_remote.exp \
		$host $target_ver_path $gtm_tst $tst `ssh $host pwd`
	echo "Done..."
else
	echo "No expect in PATH, please install"
endif
