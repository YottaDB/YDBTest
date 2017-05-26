#! /usr/local/bin/tcsh -f
set echo
set verbose
@ i = 0;
if ("" == $1) then
	@ num_bg_process=1
else
	@ num_bg_process=$1
endif
while ( $i < $num_bg_process )
	($gtm_exe/mumps -run breg^largeupdates < /dev/null >>& bkgrndset_$i.out&) >&! bg_$i.log
	@ i = $i + 1;
end
unset echo
unset verbose
