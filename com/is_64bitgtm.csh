
file $gtm_exe/mumps | grep "64" > /dev/null

if ( "$?" == 0 ) then
	setenv cur_platform_size 1
else
	setenv cur_platform_size 0
endif
