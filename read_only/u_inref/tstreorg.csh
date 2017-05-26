#!/usr/local/bin/tcsh -f
#Tests of mupip command "REORG" on a R/O files
echo ""
echo "*** TSTREORG.CSH ***"
echo ""
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM<<aaa
d in1^sfill("set",3,4)
aaa
echo "------- Before reorg -------"
$MUPIP integ -REG "*"
chmod 666 *.dat *.mjl
echo "R/W mumps.dat R/W mumps.mjl"
echo "$MUPIP reorg -select=b*"
$MUPIP reorg -select="b*"
echo "------- Test last reorg -------"
$MUPIP integ -REG "*"
mipcmanage
#
#
#
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM<<aaa
d in1^sfill("set",3,4)
aaa
echo "------- Before reorg -------"
$MUPIP integ -REG "*"
chmod 666 *.dat *.mjl
chmod 444 mumps.dat
echo "R/O mumps.dat R/W mumps.mjl"
lsmumps
echo "$MUPIP reorg -select=b*"
$MUPIP reorg -select="b*"
echo "------- Test last reorg -------"
$MUPIP integ -REG "*"
mipcmanage
#
#
#
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM<<aaa
d in1^sfill("set",3,4)
aaa
echo "------- Before reorg -------"
$MUPIP integ -REG "*"
chmod 666 *.dat *.mjl
chmod 444 mumps.mjl
echo "R/W mumps.dat R/O mumps.mjl"
lsmumps
echo "$MUPIP reorg -select=b*"
$MUPIP reorg -select="b*"
echo "------- Test last reorg -------"
$MUPIP integ -REG "*"
mipcmanage
#
#
#
\cp -f tmumps.dat mumps.dat
\cp -f tmumps.mjl mumps.mjl
chmod 666 mumps.dat
chmod 666 mumps.mjl
lsmumps
$GTM<<aaa
d in1^sfill("set",3,4)
aaa
echo "------- Before reorg -------"
$MUPIP integ -REG "*"
chmod 666 *.dat *.mjl
chmod 444 mumps.dat
chmod 444 mumps.mjl
echo "R/O mumps.dat R/O mumps.mjl"
lsmumps
echo "$MUPIP reorg -select=b*"
$MUPIP reorg -select="b*"
echo "------- Test last reorg -------"
$MUPIP integ -REG "*"
mipcmanage
