#! /usr/local/bin/tcsh -f
#Tests of mupip command "REORG" on a read_only database file in the absence or journal file
echo ""
echo "*** TSTREORGNJ.CSH ***"
echo ""
#
#
#
\cp -f tmumps.dat mumps.dat
$GTM<<aaa
d in1^sfill("set",3,3)
aaa
echo " ------- Before reorg --------"
$MUPIP integ -REG "*"
echo "$MUPIP reorg -select=b*"
$MUPIP reorg -select="b*"
echo " ------- After reorg --------"
$MUPIP integ -REG "*"
mipcmanage
#
#
#
\cp -f tmumps.dat mumps.dat
$GTM<<eee
d in1^sfill("set",3,3)
eee
echo "----- Before reorg -----"
$MUPIP integ -REG "*"
echo "****** Changing database to read_only ******"
chmod 444 mumps.dat
lsmumps
echo "$MUPIP reorg -select=b*"
$MUPIP reorg -select="b*"
echo " ----- After reorg on read_only database -----"
$MUPIP integ -REG "*"
mipcmanage
