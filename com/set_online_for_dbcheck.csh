#!/usr/local/bin/tcsh -f

setenv online_noonline ""
# Environment variable  will be either set in the environment or set randomly by do_random_settings.csh
if ($?gtm_test_online_integ) then
	setenv online_noonline "$gtm_test_online_integ"
endif

#--------------------------------------------------------------------------------------
# Check if -online or -noonline was specified in the arguments. If so override randomly
# chosen value in do_random_settings.csh
# -------------------------------------------------------------------------------------
setenv online_noonline_specified "FALSE"
foreach arg ($argv)
	switch ($arg)
		case "-online":
			setenv online_noonline "-online"
			setenv online_noonline_specified "TRUE"
			breaksw
		case "-noonline":
			setenv online_noonline "-noonline"
			setenv online_noonline_specified "TRUE"
			breaksw
		default:
			setenv online_noonline ""
			breaksw
	endsw
	if ("TRUE" == "$online_noonline_specified") break
end

# If a prior version that does not support ONLINE INTEG gets chosen then we should not be passing -[NO]ONLINE to INTEG options
if (`expr "V54000" \> "$gtm_verno"`) then
	setenv online_noonline ""
endif	

if (-e settings.csh) then
	set now=`date +%H%M%S`
	$grep gtm_test_db_format settings.csh >&! tmp_$now.csh
	source tmp_$now.csh
	\rm tmp_$now.csh
endif
if ($?gtm_test_db_format) then
	if ("V4" == "$gtm_test_db_format") then
		setenv online_noonline ""
	endif
endif

# It is an error if the calling script wanted to do an INTEG -FILE but also has passed -[NO]ONLINE along with it
if (("$1" != "-online") && ("$1" != "-noonline") && ("TRUE" == "$online_noonline_specified")) then
	echo "TEST-E-DBCHECK: [NO]ONLINE qualifiers not supported INTEG -FILE"
	exit 1
endif	
