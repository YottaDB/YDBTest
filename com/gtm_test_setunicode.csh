#!/usr/local/bin/tcsh -f
# unless otherwise requested, set gtm_chset to UTF-8 or M, randomly:
# $gtm_chset:
#  50% "UTF-8",
#  25% "M",
#  25% undefined
# $gtm_test_dbdata:
#  50% "UTF-8",
#  50% "M"
#
# the argument "norecurse" is only an internal argument (between gtm_test_setunicode.csh and set_locale.csh),
# no other script should use the "norecurse" option.

# The settings messages are echo'ed on screen. The caller of the script should redirect the output.
# For now, logsettings is hardcoded to true. Make it an optional second parameter if required later
set logsettings = 1

#
if ($?gtm_test_unicode) then
	set rand = 2	# not random, since -unicode was specified
else if ($?gtm_test_nounicode) then
	set rand = 1	# not random, since -nounicode was specified
else
	# pick randomly [0,3]
	set rand = `date | $tst_awk '{srand() ; print (int(rand() * 4))}'`
	#50-50 UTF-8 or M
	#if M: 50-50 defined or undefined
	# at this point the script has decided how to handle gtm_chset
	setenv gtm_chset_setdone
endif
if (1 == "$rand") setenv gtm_chset "M"
if (1 < "$rand") setenv gtm_chset "UTF-8"

if ($?gtm_chset) then
	if (("UTF-8" == "$gtm_chset") && ("norecurse" != "$1")) source $gtm_tst/com/set_locale.csh norecurse
	# (sub)tests still have to source this for dspmbyte
endif

# Irrespective of the randomness of gtm_chset, randomize gtm_test_dbdata
if ($?gtm_test_unicode) then
	set rand = 1	#not random, since -unicode was specified
else if ($?gtm_test_nounicode) then
	set rand = 0	#not random, since -nounicode was specified
else
	# pick randomly [0,1]
	set rand = `date | $tst_awk '{srand() ; print (int(rand() * 2))}'`
endif
if (0 == "$rand") setenv gtm_test_dbdata "M"
if (1 == "$rand") setenv gtm_test_dbdata "UTF-8"

# Now log the settings.
if !($logsettings) then
	# logsettings is set to FALSE. So exit here. The rest of the script is just echo of settings.
	exit
endif

if ($?gtm_chset) then
	if ($?gtm_chset_setdone) then
		echo "# gtm_chset defined in gtm_test_set_unicode.csh"
	else
		echo "# gtm_chset defined by either -unicode option OR current environment"
	endif
	echo "setenv gtm_chset $gtm_chset"
	echo ""
	echo 'if ("UTF-8" == "$gtm_chset") source $gtm_tst/com/set_locale.csh'
else
	echo "# gtm_chset left undefined in gtm_test_set_unicode.csh"
	echo "unsetenv gtm_chset"
endif

if ($?gtm_test_dbdata)  then
	echo "# gtm_test_dbdata defined in gtm_test_set_unicode.csh"
	echo "setenv gtm_test_dbdata $gtm_test_dbdata"
	echo ""
endif

