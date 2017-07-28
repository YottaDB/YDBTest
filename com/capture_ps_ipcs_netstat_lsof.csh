#!/usr/local/bin/tcsh -f

echo "########################################################################"
echo "Time = `date`"
# Include -l option to have the "Process State" information. But not including it in the default $ps as it has some column issues
set ps = "${ps:s/ps /ps -l /}"	#BYPASSOK ps
echo "$ps"
echo "########################################################################"
$ps
echo ""

echo "########################################################################"
echo "Time = `date`"
echo "$gtm_tst/com/ipcs -a"
echo "########################################################################"
$gtm_tst/com/ipcs -a
echo ""

echo "########################################################################"
echo "Time = `date`"
echo "$netstat"
echo "########################################################################"
$netstat
echo ""

echo "########################################################################"
echo "Time = `date`"
echo "$lsof -i"
echo "########################################################################"
$lsof -i
echo ""

