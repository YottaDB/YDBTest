#!/usr/local/bin/tcsh -f
#################################################
# do not create journal files at /*.mjl if $1 is null, use . then
set jnldir = "$1"
if ("$jnldir" == "") set jnldir = "."
 
if (("$2" != "-replic=on")&&("$2" != "")) then
 echo "Arguments not understood $2"
 exit
endif

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
foreach x (`$grep -v "GDE" gde.out | $tst_awk -f $gtm_tst/com/v4gde_jnl_on.awk | grep -v ":" | $tst_awk -F. '{print $1}' | sort -u`)
	sleep 1
	@ num = `date | $tst_awk '{srand(); print (1 + int(rand() * 3))}'` 
	if ($num == 2) then
		echo $MUPIP set -file ${x}.dat ${tst_jnl_str},file=$jnldir/${x}_curr.mjl $2 >>&! jnl.log
		$MUPIP set -file ${x}.dat ${tst_jnl_str},file=$jnldir/${x}_curr.mjl $2 >>&! jnl.log
	endif
end
