# dbcreate.csh not used because of complicated GLD setup.
set verbose
$GDE << \FIN
change -segment DEFAULT -file_name=mumps.dat
add -name a* -region=areg
add -name A* -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=a.dat
add -name b* -region=breg
add -name B* -region=breg
add -region breg -dyn=bseg
add -segment bseg -file=b.dat
add -name c* -region=creg
add -name C* -region=creg
add -region creg -dyn=cseg
add -segment cseg -file=c.dat
change -reg AREG  -journal=(BEFORE,file="$logi")
show -all
exit
\FIN
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
setenv logi xxx.mjl
$MUPIP create
$MUPIP set -journal=enable,before -region "*" |& sort -f 
ls *.mjl*
$GDE << FIN
show -all
FIN
$GTM << XXX
f i=2:5:1000 s ^a(i)=i,^b(i)=i
h
XXX
setenv logi yyy.mjl
$MUPIP set -jour="enable,before" -reg "*" |& sort -f 
ls *.mjl*
$GTM << XXX
f i=3:5:1000 s ^a(i)=i,^c(i)=i
h
XXX
$MUPIP set -jour="enable,before" -reg BREG |& sort -f 
ls *.mjl*
$GTM << XXX
f i=4:5:1000 s ^a(i)=i,^c(i)=i,^z(i)=i 
f i=3:5:1000 s ^c(i)=3*i 
h
XXX
$MUPIP set -jour="enable,before" -reg "*" |& sort -f 
rm *.dat
$MUPIP create 
ls *.mjl*
# The following command turns journaling on currently (for AREG), which it should not do. This has a TR entry, and will be fixed in the future, but to avoid constant failures now, the reference file has been created to accept that journaling is turned on. --Nergis
$MUPIP journal -recover -forward xxx.mjl,b.mjl,c.mjl,mumps.mjl
ls *.mjl*
$GTM << XXX
w "2 = ",^a(2)
w "3 = ",^a(3)
w "4 = ",^a(4)
w "2 = ",^b(2)
w "9 = ",^c(3)
w "4 = ",^c(4)
w "4 = ",^z(4)
h
XXX
$MUPIP set -jour="enable,before" -reg "*" |& sort -f 

$gtm_tst/com/dbcheck.csh
