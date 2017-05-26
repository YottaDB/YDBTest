#!/usr/local/bin/tcsh -f

#
# Mimics tail (-t) and head (-h) system command usage, using do_m_filtering.csh.
#

if (("-t" == "$1") || ("-tail" == "$1")) then
	set mfunc="tail"
	set defsign="-"
else
	if (("-h" == "$1") || ("-head" == "$1")) then
		set mfunc="head"
		set defsign="+"
	else
		echo "usage : $0 [-t(ail)|-h(ead)] ..."
		exit -1
	endif
endif

# this is needed so "echo -n" print "-n"...
set echo_style="none"

set car="`echo $2 | cut -b 1`"

# this handles default uses (ie. no options).
if ("-" != "$car") then
        if ("" == "$2") then
                set files="-"
        else
                set files="$argv[2-]"
        endif
	set num="$defsign""10"
else
	# this handles "... -6" forms
	if ("n" != "`echo $2 | cut -b 2`") then
		if ("" == "$3") then
			set files="-"
		else
			set files="$argv[3-]"
		endif
		set num="$defsign`echo $2 | cut -b 2-`"
	# the rest handles "... -n" form
	else
		set num="`echo $2 | cut -b 3-`"
		set car="`echo $2 | cut -b 3`"

		# this is for "... -n XX".
		if ("" == "$car") then
			set num="$3"
			set car="`echo $3 | cut -b 1`"
			if ("" == "$4") then
		                set files="-"
		        else
		                set files="$argv[4-]"
		        endif
		# this is for "... -nXX".
		else
		        if ("" == "$3") then
                		set files="-"
		        else
		                set files="$argv[3-]"
		        endif
		endif

		# this set the correct sign if not specified
		if (("+" != "$car") && ("-" != "$car")) then
			set num="$defsign$num"
		endif
	endif
endif

# On systems with tail & head implementations supporting multiple files, those commands, when called
# with multiple files, will print the file name before each output and add an empty line between each
# file.  We want to emulate this behavior here.
foreach file ($files)
	if ($?notfirstfile) echo ""
	if ("$file" != "$files") then
		set notfirstfile
		echo "==> $file <=="
	endif
	# If %XCMD isn't supported, revert to system's tail & head
	# $tst_dir and $gtm_tst_out are required for do_m_filtering.csh
	if ((! -e $gtm_exe/_XCMD.m) || (!($?tst_dir)) || (!($?gtm_tst_out)) || (! -e $tst_dir/$gtm_tst_out)) then
		# HP-UX's head doesn't support signed line numbers.
		if (("HP-UX" == "$HOSTOS") && ("head" == "$mfunc")) then
			set num="`echo $num | cut -b 2-`"
		endif
		cat $file | $mfunc -n $num
		set ret=$status
	else
		$gtm_test_com_individual/do_m_filtering.csh "do ^$mfunc($num)" $file
		set ret=$status
	endif
end

exit $ret

