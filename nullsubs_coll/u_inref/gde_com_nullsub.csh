#!/usr/local/bin/tcsh -f
######################################################
# We are first running all gde commands like show commands and before creating
# databases we are modifying ENCR flag of gld file as ENCR=ON to have enccrypted
# database . Hence output of GDE show contains ENCR=OFF.
echo ""
echo "default value for null_subscripts should be never"
echo ""
$GDE << \aa
add -name a* -region=areg
add -name A* -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=a.dat
show
exit
\aa
######################################################
echo ""
echo "null_subscript value modified to ALWAYS using GDE add command"
echo ""
$GDE << \aa
add -name b* -region=breg
add -name B* -region=breg
add -region breg -dyn=bseg -null_subs=always
show -region breg
quit
\aa
######################################################
echo ""
echo "null_subscripts values are changed using GDE change command"
echo ""
$GDE << \aa
change -region areg -null_subscripts=EXISTING
show  -region areg
change -region areg -null_subscripts=always
show  -region areg
change -region areg -null_subscripts=never
show  -region areg
quit
\aa
######################################################
echo ""
echo "null_subscripts modified using template command"
echo ""
$GDE << \aa
template -region -null_subscripts=ALWAYS
show -template
template -region -null_subscripts=NEVER
show -template
template -region -null_subscripts=EXISTING
show -template
Add -name C* -region=creg
Add -name c* -region=creg
Add -region  creg -dynamic=cseg
show -reg creg
quit
\aa
######################################################
echo ""
echo "null_subs modified with illegeal values.should error out"
echo ""
$GDE << \aa
change -reg default -null_subscripts=TRUER
change -reg default -null_subscripts=ALWAYSEVER
change -reg default -null_subscripts=ALLOWME
quit
\aa
######################################################
echo ""
echo "null_subs modified with old values & -nonull_subscript qualifier without value.Should pass"
echo ""
echo "-null_subscript qualifier without value should fail"
echo ""
$GDE << \aa
change -reg areg -null_subscripts=FALSE
show -reg areg
change -reg areg -nonull_subscripts
show -reg areg
change -reg areg -null_subscripts=TRUE
show -reg areg
change -reg areg -null_subscripts
quit
\aa
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
######################################################
echo ""
echo "Now create the databases"
echo ""
$MUPIP create
echo ""
echo "modify null_subscripts using DSE CHANGE commands"
echo ""
$DSE << \aa
change  -fileheader -null_subscripts=TRUE
dump -fileheader
change -fileheader -null_subscripts=ALWAYS
dump -fileheader
change -fileheader -null_subscripts=FALSE
dump -fileheader
change -fileheader -null_subscripts=NEVER
dump -fileheader
change -fileheader -null_subscripts=EXISTING
dump -fileheader
exit
\aa
######################################################
echo ""
echo "set global variables when null_subscripts=existing"
$DSE << \aa
change -fileheader -null=always
exit
\aa
$GTM << \aa
set ^a(1,"")="1_null"
set ^a(1,"",1)="one_null_one"
set ^a(2,"")="two_null"
set ^a(2,"",1)="two_null_one"
set ^a(2,"",1,2)="two_null_one_two"
set ^a("",2)=1001
write "use of $incr function , value = ",$incr(^a("",2))
halt
\aa
$DSE << \aa
change -fileheader -null_subs=existing
exit
\aa
echo ""
echo "Existing null subscripts can be  read but a new one cannot be set"
$GTM << \aa
write ^a(1,"")
zwrite ^a(1,"")
set ^a("")="null"
write "use of $incr function , should error out",$incr(^a("",2))
zwr ^a
write $data(^a(1,""))
zwithdraw ^a(1,"")
write $data(^a(1,""))
kill ^a(2,"",1)
zwrite ^a
kill ^a
zwrite ^a
halt
\aa
######################################################
echo ""
echo "check for view  undef/noundef scenario when null_subs=existing"
$GTM << \aa
VIEW "NOUNDEF"
write ^a(1,2,3,"")
VIEW "UNDEF"
write ^a(1,2,3,"")
write $data(^a(""))
write $get(^a(""),"default")
halt
\aa
######################################################
rm -f *.dat mumps.gld
cp $gtm_tst/$tst/inref/multplreg.gde .
echo ""
echo "create a new 6 region gld mapping with null_sub states as follows"
echo ""
echo "AREG -- > NEVER , BREG --> ALWAYS , CREG --> EXISTING , DREG --> TRUE , EREG --> FALSE"
echo ""
$GDE << \gde_eof
@multplreg.gde
exit
\gde_eof
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
echo ""
echo "create the databases"
echo ""
$MUPIP create
source $gtm_tst/com/get_dse_df.csh
### check for Null subscript values from dse dump output as against gde values ###
cat dse_df.log | $tst_awk ' /Region          AREG/ {start=1} start {print}' | $tst_awk ' /Null subscripts/ {print $3}' | sed '2,$ d' | $tst_awk '{if ("NEVER" == $0) print "AREG PASSED";else print "TEST-E-ERROR expected NEVER but got " $0" for AREG"}'
#
cat dse_df.log | $tst_awk ' /Region          BREG/ {start=1} start {print}' | $tst_awk ' /Null subscripts/ {print $3}' | sed '2,$ d' | $tst_awk '{if ("ALWAYS" == $0) print "BREG PASSED";else print "TEST-E-ERROR expected ALWAYS but got " $0" for BREG"}'
#
cat dse_df.log | $tst_awk ' /Region          CREG/ {start=1} start {print}' | $tst_awk ' /Null subscripts/ {print $3}' | sed '2,$ d' | $tst_awk '{if ("EXISTING" == $0) print "CREG PASSED";else print "TEST-E-ERROR expected EXISTING but got " $0" for CREG"}'
#
cat dse_df.log | $tst_awk ' /Region          DREG/ {start=1} start {print}' | $tst_awk ' /Null subscripts/ {print $3}' | sed '2,$ d' | $tst_awk '{if ("ALWAYS" == $0) print "DREG PASSED";else print "TEST-E-ERROR expected ALWAYS but got " $0" for DREG"}'
#
cat dse_df.log | $tst_awk ' /Region          EREG/ {start=1} start {print}' | $tst_awk ' /Null subscripts/ {print $3}' | sed '2,$ d' | $tst_awk '{if ("NEVER" == $0) print "EREG PASSED";else print "TEST-E-ERROR expected NEVER but got " $0" for EREG"}'
#
cat dse_df.log | $tst_awk ' /Region          DEFAULT/ {start=1} start {print}' | $tst_awk ' /Null subscripts/ {print $3}' | sed '2,$ d' | $tst_awk '{if ("NEVER" == $0) print "DEFAULT PASSED";else print "TEST-E-ERROR expected NEVER but got " $0" for DEFAULT"}'
#
### also check for stdnullcoll values of AREG & CREG here ####
cat dse_df.log | $tst_awk ' /Region          AREG/ {start=1} start {print}' | $tst_awk ' /Standard Null Collation/ {print $4}' | sed '2,$ d' | $tst_awk '{if ("TRUE" == $0) print "AREG PASSED for NULCOLLATION";else print "TEST-E-ERROR expected TRUE but got " $0" for AREG NULLCOLATION"}'
#
cat dse_df.log | $tst_awk ' /Region          CREG/ {start=1} start {print}' | $tst_awk ' /Standard Null Collation/ {print $4}' | sed '2,$ d' | $tst_awk '{if ("FALSE" == $0) print "CREG PASSED for NULCOLLATION";else print "TEST-E-ERROR expected FALSE but got " $0" for CREG NULLCOLATION"}'
######################################################
echo ""
echo "check naked reference for BREG (ALWAYS) & CREG (EXISTING)"
echo ""
$GTM << \gtm_eof
write "set  breg  globals with null_subs,naked reference should pass",!
set ^bglobalvar(4,5,6)="to use later"
set ^bglobalvar(1,"",2,3)="1NULL23"
set ^("hi")="Iam naked referenced for bglobalvar"
set ^bglobalvar("",2)=100
write "Increment function used for BREG(ALWAYS),value is ",$incr(^(2))
zwrite ^bglobalvar
write "set creg globals with null_subs,naked reference should error out",!
set ^cregglobalvariable(1,3)=100
set ^(45,"stringme")="I should be set"
set ^cregglobalvariable("",2)=200
write "Increment function used for CREG(EXISTING),should error out",$incr(^(2))
zwrite ^cregglobalvariable
halt
\gtm_eof
$DSE << \dse_eof
find -region=BREG
change -fileheader -null_subs=existing
exit
\dse_eof
$GTM << \gtm_eof
w ^bglobalvar(1,"",2,3)
write "set breg globals which is now EXISTING with null_subs,naked reference should error out",!
s ^(7)="I should not be set"
w ^bglobalvar(4,5,6)
write "set breg globals which is now EXISTING with null_subs,naked reference should error out",!
s ^("")="i should not be set"
halt
\gtm_eof
######################################################
echo ""
echo "check extended references"
echo ""
setenv gtmgbldir "extended.gld"
$GDE << \gde_eof
change -region default -null_subscripts=always
change -segment default -file=extended.dat
show -reg
exit
\gde_eof
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create
setenv gtmgbldir "mumps.gld"
$GTM << \gtm_eof
write "set some null subscripted globals to extended.dat",!
set ^|"extended.gld"|defaultregvariable("")="iam null"
set ^("","extended")=200
write "Increment function used for extended gld(ALWAYS),value = ",$incr(^("extended"))
halt
\gtm_eof
setenv gtmgbldir "extended.gld"
$DSE << \dse_eof
change -fileheader -null_subscripts=existing
exit
\dse_eof
setenv gtmgbldir "mumps.gld"
$GTM << \gtm_eof
write "set  null subscripts to extended.dat which is existing. Should Error out",!
set ^|"extended.gld"|defaultregvariable("")="I shoud not be set"
write "set  without null subscripts to extended.dat.This should pass",!
set ^|"extended.gld"|defaultregvariable(89,123)="I should be set properly"
w ^|"extended.gld"|defaultregvariable("","extended")
write "Increment function used for extended gld(EXISTING),Should error out",$incr(^("extended"))
halt
\gtm_eof
setenv gtmgbldir "extended.gld"
$GTM << \gtm_eof
write "zwrite the globals in extended.dat",!
zwrite ^defaultregvariable
halt
\gtm_eof
setenv gtmgbldir "mumps.gld"
######################################################
