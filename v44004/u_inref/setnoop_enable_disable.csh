############################################################################
# Test enabling and disabling duplicate set optimization
# Test the different methods:
# - view "GVDUPSETNOOP" command
# - environment variable gtm_gvdupsetnoop (defined/undefined/0/1/yes/no)
# the tests are ordered so that an "on" is followed by and "off" so that we can see
# the state change (as much as possible).
# Hence: for 1, 3, 5, 7, 8, 9 the optimization is disabled (i.e. "off")
# and for 2, 4, 6, it is enabled (i.e. "on)
# check the output of one and 2, and then make sure the others are matching
# either one.
############################################################################
# Note:	The test was written originally when the env var was supported. In V55000 env var support was removed from the code.
# Instead of removing all portions of the test related to env var testing, the equivalent VIEW GVDUPSETNOOP
# command was replaced in the test to get the same test output. All places that enabled the env var are kept as it is
# to test that the env var has no effect on the code anymore.
setenv count 1
#1
echo "##################################################################"
$gtm_tst/$tst/u_inref/init.csh
unsetenv gtm_gvdupsetnoop
$GTM << EOF
view "GVDUPSETNOOP":0  do ^c002472("off",3)
halt
EOF
source $gtm_tst/$tst/u_inref/check.csh

#2
echo "##################################################################"
$gtm_tst/$tst/u_inref/init.csh
setenv gtm_gvdupsetnoop "1"
$GTM <<EOF
view "GVDUPSETNOOP":1  do ^c002472("on",3)
halt
EOF
source $gtm_tst/$tst/u_inref/check.csh

############################################################################
# print one sample output of optimization enabled and disabled
echo "Output of optimization disabled..."
cat bak1/output_1.out
echo "Output of optimization enabled..."
cat bak2/output_2.out
############################################################################
# now compare the output of each of the above
set error = 0
diff bak1/output_1.out bak2/output_2.out >! /dev/null
if (! $status) then
	echo "TEST-E-NODIFF, the two outputs (1 and 2) should have been different"
	set error = 1
else
	echo "OK."
endif
mv bak1 bak1_1
mv bak2 bak2_2

echo "Now test the other methods faster..."
setenv count 1
#1
echo "##################################################################"
$gtm_tst/$tst/u_inref/init.csh
unsetenv gtm_gvdupsetnoop
$GTM << EOF
view "GVDUPSETNOOP":0  do ^c002472("off",0)
halt
EOF
source $gtm_tst/$tst/u_inref/check.csh

#2
echo "##################################################################"
$gtm_tst/$tst/u_inref/init.csh
setenv gtm_gvdupsetnoop "1"
$GTM <<EOF
view "GVDUPSETNOOP":1  do ^c002472("on",0)
halt
EOF
source $gtm_tst/$tst/u_inref/check.csh

#3
echo "##################################################################"
$gtm_tst/$tst/u_inref/init.csh
setenv gtm_gvdupsetnoop "0"
$GTM <<EOF
view "GVDUPSETNOOP":0  do ^c002472("off",0)
halt
EOF
source $gtm_tst/$tst/u_inref/check.csh

#4
echo "##################################################################"
$gtm_tst/$tst/u_inref/init.csh
setenv gtm_gvdupsetnoop "yes"
$GTM <<EOF
view "GVDUPSETNOOP":1  do ^c002472("on",0)
halt
EOF
source $gtm_tst/$tst/u_inref/check.csh

#5
echo "##################################################################"
$gtm_tst/$tst/u_inref/init.csh
setenv gtm_gvdupsetnoop "no"
$GTM <<EOF
view "GVDUPSETNOOP":0  do ^c002472("off",0)
halt
EOF
source $gtm_tst/$tst/u_inref/check.csh

#6
echo "##################################################################"
$gtm_tst/$tst/u_inref/init.csh
# First ensure it's disabled:
setenv gtm_gvdupsetnoop "0"
# then enable:
$GTM <<EOF
view "GVDUPSETNOOP":1
do ^c002472("on",0)
halt
EOF
source $gtm_tst/$tst/u_inref/check.csh

#7
echo "##################################################################"
$gtm_tst/$tst/u_inref/init.csh
# First ensure it's enabled:
setenv gtm_gvdupsetnoop "1"
# then disable:
$GTM <<EOF
view "GVDUPSETNOOP":0
do ^c002472("off",0)
halt
EOF
source $gtm_tst/$tst/u_inref/check.csh

#8
echo "##################################################################"
$gtm_tst/$tst/u_inref/init.csh
# invalid value:
setenv gtm_gvdupsetnoop ""
$GTM <<EOF
view "GVDUPSETNOOP":0  do ^c002472("off",0)
halt
EOF
source $gtm_tst/$tst/u_inref/check.csh

#9
echo "##################################################################"
$gtm_tst/$tst/u_inref/init.csh
# some bad value:
setenv gtm_gvdupsetnoop "blah"
$GTM <<EOF
view "GVDUPSETNOOP":0  do ^c002472("off",0)
halt
EOF
source $gtm_tst/$tst/u_inref/check.csh

############################################################################
# print one sample output of optimization enabled and disabled
echo "Output of optimization disabled..."
cat bak1/output_1.out
echo "Output of optimization enabled..."
cat bak2/output_2.out
############################################################################
# now compare the output of each of the above
set error = 0
diff bak1/output_1.out bak2/output_2.out >! /dev/null
if (! $status) then
	echo "TEST-E-NODIFF, the two outputs (1 and 2) should have been different"
	set error = 1
else
	echo "OK."
endif
## verify that all opt. disabled outputs are the same (all odd numbered, and 8)
foreach i (1 3 5 7 8 9)
	echo "Check test $i ..."
	diff bak1/output_1.out bak$i/output_$i.out >! /dev/null
	if ($status) then
		echo "TEST-E-DIFF, the two outputs (1 and $i) should not have been different"
		set error = 1
	endif
	if ("off" != `cat bak$i/onoff.out`) then
		echo "TEST-F-TSSERT, this should have been an OFF test, has order changed?"
	endif
end
## verify that all opt. enabled outputs are the same (all even numbered except for 8)
foreach i (2 4 6)
	echo "Check test $i ..."
	diff bak2/output_2.out bak$i/output_$i.out >! /dev/null
	if ($status) then
		echo "TEST-E-DIFF, the two outputs (1 and $i) should not have been different"
		set error = 1
	endif
	if ("on" != `cat bak$i/onoff.out`) then
		echo "TEST-F-TSSERT, this should have been an ON test, has order changed?"
	endif
end
if (1 == $error) then
	echo "TEST-E-FAIL"
else
	echo "Verified that the bak*/output*.out files match."
endif
