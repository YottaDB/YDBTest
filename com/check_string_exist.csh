#!/usr/local/bin/tcsh -f
# Usage : check_string_exist.csh <logfile> <all|any|none> <messages>
#
# This tool checks for the presence of strings based on the second parameter passed

if (3 > $#) then
	echo "TEST-E-ARGS incorrect number of arguments passed. Check usage"
	exit 1
endif

set filetocheck = $1
shift

set condition = `echo $1 | tr '[a-z]' '[A-Z]'`
shift
echo $condition | $grep -E "ALL|ANY|NONE" >&! /dev/null
if ($status) then
	echo "TEST-E-CONDITION Second argument should be one of ALL ANY NONE"
	exit 1
endif

if ("ALL" == "$condition") set msg = "All the messages passed are found in the file $filetocheck"
if ("ANY" == "$condition") set msg = "At least one of the messages passed is found in the file $filetocheck"
if ("NONE" == "$condition") set msg = "None of the messages passed is found in the file $filetocheck"

while ("" != "$1")
	set string = "$1"
	shift
	$grep -E "$string" $filetocheck >&! /dev/null
	if ($status) then
		if ("ALL" == "$condition") then
			echo "CHECK_STRING_EXIST-E-FAILED The below condition was not satisfied"
			echo $msg
			exit 1
		endif
	else
		if ("ANY" == "$condition") then
			echo "CHECK_STRING_EXIST-I-FOUND. $msg"
			exit 0
		else if ("NONE" == "$condition") then
			echo "CHECK_STRING_EXIST-E-FAILED The below condition was not satisfied"
			echo $msg
			exit 1
		endif
	endif
end

if ("ALL" == "$condition") then
	echo "CHECK_STRING_EXIST-I-FOUND. $msg"
	exit 0
else if ("ANY" == "$condition") then
	echo "CHECK_STRING_EXIST-E-FAILED The below condition was not satisfied"
	echo $msg
	exit 1
else if ("NONE" == "$condition") then
	echo "CHECK_STRING_EXIST-I-PASSED. $msg"
	exit 0
endif

