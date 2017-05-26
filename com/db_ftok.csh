#!/usr/local/bin/tcsh -f   
set allipc = ""
foreach file (*.dat)
set ipc = `$MUPIP ftok $file | grep dat | $tst_awk '{printf("-s %s -m %s",$3,$6);}'`
set allipc = "$allipc $ipc"
end
echo $allipc
