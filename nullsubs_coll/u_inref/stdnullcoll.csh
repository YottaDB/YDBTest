#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2004, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#############################################################################
## check for GDE & DSE commands ##
#############################################################################
# We are first running all gde commands like show commands and before creating databases
# we are modifying ENCR flag of gld file as ENCR=ON to have enccrypted database.
# Hence output of GDE show contains ENCR=OFF.
echo "GDE Commands for standard null collation"
echo "Default value of standard null collation is false"
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
# Run this test in M mode unconditionally as the reference file for UTF8 mode is very different (due to $ZCH output)
$switch_chset "M" >& switch_chset_m.log
$GDE << EOF
exit
EOF
$GDE << EOF
show
change -reg DEFAULT -nostdnull
show -reg default
change -reg DEFAULT -stdnull
show -reg default
add -name a* -reg=areg
add -name A* -reg=areg
add -reg areg -dyn=aseg -stdnullcoll -null_subscripts=always
add -seg aseg -file=a.dat
show -reg areg
add -name b* -reg=breg
add -name B* -reg=breg
add -reg breg -dyn=bseg -nostdnullcoll -null_subscripts=always
add -seg bseg -file=b.dat
show -reg breg
exit
EOF
$GDE << EOF
show -reg
template -region -stdnullcoll
add -name c* -reg=creg
add -name C* -reg=creg
add -reg creg -dyn=cseg
add -seg cseg -file=c.dat
show -reg creg
template -region -nostdnullcoll
show -template
exit
EOF
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif

echo "Now create databases"
$MUPIP create
## verify dse change commands for stdnullcoll qualifier ##
$DSE << EOF
change -fileheader -stdnullcoll=false
dump -fileheader
change -fileheader -stdnullcoll=true
dump -fileheader
exit
EOF
#
#############################################################################
## check DSE dump output
#############################################################################
echo "DSE  dump output "
$GTM << EOF
do one^varfill
halt
EOF
$DSE dump -fileheader |& $grep "Null"
$DSE << EOF
dump -block=3
EOF
#
#############################################################################
## check for $ORDER $NEXT $QUERY M-functions with stdnullcoll behavior #
#############################################################################
rm -f *.dat mumps.gld
source $gtm_tst/com/cre_coll_sl_reverse.csh 10
echo 'TESTING $ORDER/$NEXT/$ZPREVIOUS/$QUERY functions'
# $NEXT & $QUERY is removed from the for loop for GLOBALS due to infinite looping conditions under GT.M null collation.
# $NEXT alone is removed from the for loop for locals due to infinite looping conditions under GT.M null collation.
# pls. remove those work-around "if" conditions once TR [C9E11-002667] is resolved.
foreach coltype(stdnullcoll nostdnullcoll)
$GDE << EOF
change -region default -$coltype -null_subscripts=ALWAYS
exit
EOF
foreach acttype(0 10)
$GDE << EOF
change -region default -collation_default=$acttype
show -reg
exit
EOF
$MUPIP create
foreach ncttype(0 1)
setenv col $coltype
setenv act $acttype
setenv nct $ncttype
$GTM << EOF
write !,\$\$set^%GBLDEF("^aregionvar",\$ZTRNLNM("nct"),\$ZTRNLNM("act")),!
do chkMfunc^varfill
do ^gblop("\$ORDER")
do ^gblop("\$ZPREVIOUS")
if (\$ZTRNLNM("col")="stdnullcoll") do ^gblop("\$QUERY")
if (\$ZTRNLNM("col")="stdnullcoll") do ^gblop("\$NEXT")
kill ^aregionvar
write \$\$set^%LCLCOL(\$ZTRNLNM("act"),\$ZTRNLNM("nct"))
do ^lclop("\$ORDER")
do ^lclop("\$ZPREVIOUS")
do ^lclop("\$QUERY")
if ((\$ZTRNLNM("nct")=1)&((\$ZTRNLNM("act")=0))) do ^lclop("\$NEXT")
kill localvariable
halt
EOF
end
rm -f mumps.dat
end
end
#
#############################################################################
# check %gbldef behavior. It should not change with the inroduction of stdnullcoll
#############################################################################
#
# *** NOTE: FOR MERGE ACROSS GLOBALS WITH DIFFERENT ACT RESULT IS ABNORMAL *** #
# *** TR = C9E11-002663. FOR NOW REFERENCE FILE HAS INCORRECT SUBS. CORRECT IT & RUN ONCE TR IS FIXED *** #
#
# single region/databse check
echo "#######################################################################"
echo "%GBLDEF CHECK BEGINS HERE"
echo "#######################################################################"
echo ""
echo '%gbldef check for single region database'
rm -f mumps.gld
foreach type(stdnullcoll nostdnullcoll)
$GDE << EOF
change -region default -$type -null_subscripts=ALWAYS -collation_default=10
show -reg
exit
EOF
$MUPIP create
setenv coltype $type
$GTM << EOF
do ^chkgbldef
do cont^chkgbldef
do reversemerge^chkgbldef
halt
EOF
rm -f mumps.dat
end
#
# multiple region/databse check
echo ""
echo '%gbldef check for multiple region database'
rm -f mumps.gld
# because this test enables stdnullcoll in one region and not in the other and there are only two regions, we cannot
# enable random spanning regions in this easily. Besides, the database (across 2 regions) has only 40 nodes in total and so
# there is not a lot of test coverage we gain from enabling spanning regions in this test. So disable it.
setenv gtm_test_spanreg 0
source $gtm_tst/com/dbcreate.csh mumps 2
rm -f *.dat
$GDE << EOF
change -region areg -nostdnullcoll -null_subscripts=ALWAYS
change -region default -stdnullcoll -null_subscripts=ALWAYS -collation_default=10
exit
EOF
$MUPIP create
setenv coltype 'stdnullcoll'
$GTM << EOF
write "AREG GLOBALS COLLATES IN NOSTDNULLCOLL",!
write "DEFAULT GLOBALS COLLATES IN STDNULLCOLL",!
do ^chkgbldef
do cont^chkgbldef
do reversemerge^chkgbldef
halt
EOF
#
#############################################################################
# check %lclcol behavior. It should not change with the introduction of stdnullcoll
#############################################################################
echo "#######################################################################"
echo "%LCLCOL CHECK BEGINS HERE"
echo "#######################################################################"
setenv gtm_lct_stdnull 1
$GTM << EOF
set (lcl(1),lcl("x"),lcl(""),lcl("y"))=1
write "env. variable set to M std. null collation",!
zwrite lcl
write "getncol should return 1 here",!
write \$\$getncol^%LCLCOL
kill lcl
write "change local collation order to GT.M null collation",!
write \$\$set^%LCLCOL(0,0)
write "getncol should return 0 here",!
write \$\$getncol^%LCLCOL
set (lcl(1),lcl("x"),lcl(""),lcl("y"))=1
write "collating order should be GT.M null collation here",!
zwrite lcl
kill lcl
write "change local collation order to M std. again",!
write \$\$set^%LCLCOL(0,1)
write "getncol should return 1 here",!
write \$\$getncol^%LCLCOL
write \$\$set^%LCLCOL(,1)
write "getncol should return 1 here",!
write \$\$getncol^%LCLCOL
set (lcl(1),lcl("x"),lcl(""),lcl("y"))=1
write "collating order should be M std. here",!
zwrite lcl
halt
EOF
unsetenv gtm_lct_stdnull
#
$gtm_tst/com/dbcheck.csh
