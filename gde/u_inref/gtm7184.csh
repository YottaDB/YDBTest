#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#Encryption cannot support access method MM, so explicitly running the test with NON_ENCRYPT when acc_meth is MM
if ("MM" == $acc_meth) then
       setenv test_encryption NON_ENCRYPT
endif

setenv gtmgbldir nullsub.gld

echo "# Test 1: Test for gde_add operation"
$echoline
echo "## Attemp to add a new region with the null_subscript qualifier as 'exist' "
$GDE << GDE_EXIT >& log1.log
		add -nam a	-reg=areg
		add -reg areg -d=aseg -null=exist
		add -seg aseg -file=a.dat
		exit
GDE_EXIT
$GDE show -r areg>& log1.log
echo "## Output for 'gde show -r', 'EXISTING' expected to be shown in null_subscript field :"
$grep "EXISTING" log1.log
echo " "

echo "## Attemp to add a new region with the null_subscript qualifier as 'al'(always) "
$GDE << GDE_EXIT >& log1.log
		add -nam b	-reg=breg
		add -reg breg -d=bseg -null=al
		add -seg bseg -file=b.dat
		exit
GDE_EXIT
$GDE show -r breg>& log1.log
echo "## Output for 'gde show -r':"
$grep "ALWAYS" log1.log
echo " "

echo "## Attemp to add a new region with the null_subscript qualifier as 't'(true) "
$GDE << GDE_EXIT >& log1.log
		add -nam c	-reg=creg
		add -reg creg -d=cseg -null=t
		add -seg cseg -file=c.dat
		exit
GDE_EXIT
$GDE show -r creg>& log1.log
echo "## Output for 'gde show -r':"
$grep "ALWAYS" log1.log
echo " "

echo "## Attemp to add a new region with the null_subscript qualifier as 'fal'(false) "
$GDE << GDE_EXIT >& log1.log
		add -nam d	-reg=dreg
		add -reg dreg -d=dseg -null=fal
		add -seg dseg -file=d.dat
		exit
GDE_EXIT
$GDE show -r dreg>& log1.log
echo "## Output for 'gde show -r':"
$grep "NEVER" log1.log
echo " "

echo "## Attemp to add a new region with the null_subscript qualifier as 'neve'(never) "
$GDE << GDE_EXIT >& log1.log
		add -nam e	-reg=ereg
		add -reg ereg -d=eseg -null=neve
		add -seg eseg -file=e.dat
		exit
GDE_EXIT
$GDE show -r ereg>& log1.log
echo "## Output for 'gde show -r':"
$grep "NEVER" log1.log
echo " "

echo "## Attemp to add a new region with an invalid null_subscript qualifier"
$GDE add -reg breg -d=bseg -null=xisting >& log1.log
echo "#         --> We expect a VALUEBAD error"
$gtm_tst/com/check_error_exist.csh log1.log VALUEBAD
echo " "

echo "## Attemp to add a new region with an empty null_subscript value"
$GDE add -reg breg -d=bseg -null= >& log1.log
echo "#         --> We expect a VALUEREQD error"
$gtm_tst/com/check_error_exist.csh log1.log VALUEREQD
echo "============Test1 ends=========="

echo " "
echo "# Test 2: Test for gde_change operation"
$echoline
echo "## Change the null_subscript to 'alw' "
$GDE change -r areg -null=alw >& log2.log
echo "## Output: "
$GDE show -r areg>& log2.log
$grep "ALWAYS" log2.log
echo " "

echo "## Change the null_subscript to 'true' "
$GDE change -r areg -null=true >& log2.log
echo "## Output: "
$GDE show -r areg>& log2.log
$grep "ALWAYS" log2.log
echo " "

echo "## Change the null_subscript to 'n' "
$GDE change -r areg -null=never >& log2.log
echo "## Output: "
$GDE show -r areg>& log2.log
$grep "NEVER" log2.log
echo " "

echo "## Change the null_subscript to 'fals' "
$GDE change -r areg -null=fals >& log2.log
echo "## Output: "
$GDE show -r areg>& log2.log
$grep "NEVER" log2.log
echo " "

echo "## Change the null_subscript with 'exist' qualifier"
$GDE change -r areg -null=exist >& log2.log
$GDE show -r areg>& log2.log
echo "## Output:"
$grep "EXISTING" log2.log
echo " "

echo "## Change the null_subscript with 'existi' qualifier"
$GDE change -r areg -null=existi >& log2.log
$GDE show -r areg>& log2.log
$grep "EXISTING" log2.log
echo " "

echo "## Attemp to change a region with an invalid null_subscript qualifier"
$GDE change -r areg -null=c >& log2.log
echo "#         --> We expect a VALUEBAD error"
$gtm_tst/com/check_error_exist.csh log2.log VALUEBAD
echo " "

echo "## Attemp to change a region with an empty null_subscript"
$GDE change -reg areg -d=aseg -null= >& log2.log
echo "#         --> We expect a VALUEREQD error"
$gtm_tst/com/check_error_exist.csh log2.log VALUEREQD
echo "============Test2 ends=========="

echo " "
echo "# Test 3: Test for gde template setting"
$echoline

echo "## Set the template with the null_subscript qualifier as 'a'"
$GDE temp -r -n=always >&log3.log
$GDE show -t >& log3.log
echo "## Output:"
$grep "ALWAYS" log3.log
echo " "

echo "## Set the template with the null_subscript qualifier as 'never'"
$GDE temp -r -n=never >&log3.log
$GDE show -t >& log3.log
echo "## Output:"
$grep "NEVER" log3.log
echo " "

echo "## Set the template with the null_subscript qualifier as 'exist'"
$GDE temp -r -n=exist >&log3.log
$GDE show -t >& log3.log
echo "##Output:"
$grep "EXISTING" log3.log
echo " "

echo "## Set the template with the null_subscript qualifier as 'tru'"
$GDE temp -r -n=true >&log3.log
$GDE show -t >& log3.log
$grep "ALWAYS" log3.log
echo " "



echo "## Set the template with the null_subscript qualifier as 'false'"
$GDE temp -r -n=false >&log3.log
$GDE show -t >& log3.log
echo "##Output:"
$grep "NEVER" log3.log
echo " "

echo "## Set the template with the null_subscript qualifier as 'e'"
$GDE temp -r -n=exist >&log3.log
$GDE show -t >& log3.log
echo "## Output:"
$grep "EXISTING" log3.log
echo " "

echo "## Attemp to set the template with an invalid null_subscript qualifier"
$GDE temp -r -n=ext >& log3.log
echo "#         --> We expect a VALUEBAD error"
$gtm_tst/com/check_error_exist.csh log3.log VALUEBAD
echo " "

echo "## Attemp to set the template with an empty null_subscript"
$GDE temp -r -n= >& log3.log
echo "#         --> We expect a VALUEREQD error"
$gtm_tst/com/check_error_exist.csh log3.log VALUEREQD
echo "============Test3 ends=========="

#==================================================================================================================================
