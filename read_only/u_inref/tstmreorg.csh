#!/usr/local/bin/tcsh -f
#Tests of mupip command "REORG" on a R/O files
echo ""
echo "*** TSTMREORG.CSH ***"
echo ""
# create_multi_jnl_db.csh used instead of dbcreate.csh
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM<<aaa
d in1^sfill("set",3,4)
aaa
echo "------- Before reorg -------"
$gtm_tst/com/dbcheck.csh
chmod 666 *.dat *.mjl
echo "R/W mumps.dat R/W mumps.mjl"
echo "$MUPIP reorg"
$MUPIP reorg
echo "------- Test last reorg -------"
$gtm_tst/com/dbcheck.csh
mipcmanage
#
#
#
\rm -f *.dat *.mjl
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM<<aaa
d in1^sfill("set",3,4)
aaa
echo "------- Before reorg -------"
$gtm_tst/com/dbcheck.csh
chmod 666 *.dat *.mjl
chmod 444 mumps.dat
echo "R/O mumps.dat R/W mumps.mjl"
echo "$MUPIP reorg"
$MUPIP reorg
echo "------- Test last reorg -------"
$gtm_tst/com/dbcheck.csh
mipcmanage
#
#
#
\rm -f *.dat *.mjl
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM<<aaa
d in1^sfill("set",3,4)
aaa
echo "------- Before reorg -------"
$gtm_tst/com/dbcheck.csh
chmod 666 *.dat *.mjl
chmod 444 mumps.mjl
echo "R/W mumps.dat R/O mumps.mjl"
echo "$MUPIP reorg"
$MUPIP reorg
echo "------- Test last reorg -------"
$gtm_tst/com/dbcheck.csh
mipcmanage
#
#
#
\rm -f *.dat *.mjl
$gtm_tst/$tst/u_inref/create_multi_jnl_db.csh $1
$GTM<<aaa
d in1^sfill("set",3,4)
aaa
echo "------- Before reorg -------"
$gtm_tst/com/dbcheck.csh
chmod 666 *.dat *.mjl
chmod 444 mumps.dat
chmod 444 mumps.mjl
echo "R/O mumps.dat R/O mumps.mjl"
echo "$MUPIP reorg"
$MUPIP reorg
echo "------- Test last reorg -------"
$gtm_tst/com/dbcheck.csh
mipcmanage
\rm -f *.dat *.mjl
