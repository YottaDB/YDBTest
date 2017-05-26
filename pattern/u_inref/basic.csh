# PATTERN MATCH TEST
# C9A03-001949

cp $gtm_tst/$tst/inref/edmpattable .
$GTM << FIN >&! pattern.out
d ^pattst
h
FIN

$GTM << FIN >>& pattern.out
d ^test
h
FIN

if (! $?gtm_chset) then
	set save_gtm_chset = ""
else
	set save_gtm_chset = "$gtm_chset"
endif

$switch_chset "M" >& switch_chset_1.log
echo "Test in M mode" >>& pattern.out
$GTM << FIN >>& pattern.out
d ^t
h
FIN

if ($gtm_test_unicode_support == "TRUE") then
	$switch_chset "UTF-8" >& switch_chset_2.log
	echo "Test in UTF-8 mode" >>& pattern.out
	$GTM << FIN >>& pattern.out
	d ^t
	h
FIN
endif

if ("$gtm_chset" != "$save_gtm_chset") then
	$switch_chset "$save_gtm_chset" >& switch_chset_3.log
endif

cat pattern.out | sed 's/[ ]*TIME:.*//g'

# We now verify that no pattern/pattern-match exceeded the maxtimeout value (in elapsed seconds).
# Because there may be other activity on the server while this test is running, a particular run of 
# this test may exceed the maxtimeout value due to system load (and not due to pattern-match performance). 
#
# This check very rarely fails, but it did fail recently on our slowest server (maxtimeout value was 10; 
# elapsed time was 12). For now, the maxtimeout value is being increased to 15. If this test fails again, 
# the test needs to be restructured to either re-run the failing pattern/pattern match or re-run the entire
# test (in the hope that the subsequent run will not encounter any increased server load that may have caused 
# the maxtimeout value to be exceeded). See v44003/D9D04002317's mproftp.m and mprtpzt.m for an example 
# of re-running a test.
set timeout = 15
set too_long = `cat pattern.out | $tst_awk '/TIME:/ {if ('$timeout'< $NF) print}'  | wc -l`
if ($too_long) then
	echo "Some patterns took too long to finish:" 
	cat pattern.out | $tst_awk '/TIME:/ {if ('$timeout' < $NF) print}' 
endif

