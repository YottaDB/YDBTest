#!/usr/local/bin/tcsh -f
#################################################
# do not create journal files at /*.mjl if $1 is null, use . then
set jnldir = "$1"
if ("$jnldir" == "") set jnldir = "."
 
if (("$2" != "-replic=on")&&("$2" != "")) then
 echo "Arguments not understood $2"
 exit
endif

sleep 1
setenv gtm_test_since_time `date +'%d-%b-%Y %H:%M:%S'`
echo $gtm_test_since_time > gtm_test_since_time.txt
sleep 1

setenv GDE "$gtm_exe/mumps -run GDE"
$GDE << GDE_EOF>&! gde.out
show -map
quit
GDE_EOF

echo "####################################################################" >>&! jnl.log
date >>&! jnl.log
echo "--------------------" >>&! jnl.log
echo "JOURNAL OPTIONS: $tst_jnl_str" >>&! jnl.log
# ':' is a sign of GT.CM region (oscar:/testarea4/...)
foreach x (`$grep "FILE" gde.out | $tst_awk '{print $NF}' | grep -v ":" | $tst_awk -F. '{print $1}' | sort -u`)
echo $MUPIP set -file ${x}.dat ${tst_jnl_str},file=$jnldir/${x}_curr.mjl $2 >>&! jnl.log
$MUPIP set -file ${x}.dat ${tst_jnl_str},file=$jnldir/${x}_curr.mjl $2 >>&! jnl.log
end
