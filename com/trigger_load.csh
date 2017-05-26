#!/usr/local/bin/tcsh -f

if ( "1" != "$gtm_test_trigger" ) then
	exit 0
endif

if ("" == $1 ) then
	echo "No target file ($1) given"
	exit -15
endif
set file=$1
set output=./${1:t}.trigout
# append timestamps if the file exists. some tests expected output file name w/o time stamp
if ( -e $output ) set output=./${1:t}.trigout_`date +%Y%m%d%H%M%S`

# Want errors only when MUPIP does not match the desired state
#
# By default expect to PASS, print error messages only when
# 	MUPIP trigger fails
# If we expect the test to FAIL then print error messages only when
# 	MUPIP trigger succeeds
set switch=0
if ("" != $2) then
	if ("FAIL" == "$2") then
		set switch=1
	endif
endif

# pass the -noprompt keyword when using -* in a trigger file
set prompt=$3

# convert for z/OS
$convert_to_gtm_chset $1
$MUPIP trigger -triggerfile=${file} ${prompt} >&! ${output}
set rstatus=$?
if ((0 != $rstatus && 0 == $switch) || (1 == $switch && 0 == $rstatus)) then
	echo "Trigger load for ${file} FAILED see  ${output}"
	$tail -n 50 ${output}
else if ("" != $2) then
	echo "Trigger load for ${file} PASSED"
endif

