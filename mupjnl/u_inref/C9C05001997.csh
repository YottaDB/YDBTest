# this is the test for C9C05-001997 <mupip journal -recover -back  -extract "*" > command gives GTMASSERT
# since it is just one command, it is run as part of C9B11001825.csh
# UNIX only

$MUPIP journal -recov -back  -extract -since=\"0 00:00:02\" -lookback=\"time=0 00:00:00\"  -show=all -detail  "*" >& C9C05001997.out
echo "The return status from MUPIP is: $status"
$grep -E '.-[E|F]-' C9C05001997.out
if ($status) then 
	echo "PASS C9C05-001997"
else
	echo "FAIL C9C05-001997"
endif
mkdir ./save
mv *.mjl* ./save

