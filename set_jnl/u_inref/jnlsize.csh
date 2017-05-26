#!/usr/local/bin/tcsh -f
set pat = "$1"
@ alloc = "$2" * 512
@ exten = "$3" * 512
@ auto = "$4" * 512
if ($pat == "") set pat = "*.mjl*"
if ($alloc == "") @ alloc = 512
if ($exten == "") @ exten = 512
if ($auto == "") @ auto = 512
@ count = 0
set firstfile = 0
foreach jnl (`\ls $pat | sort`)
	@ count = $count + 1
	@ filesize = `ls -l $jnl | awk '{print $5}'`
	@ vfilesizeblocks = `$MUPIP journal -show=header -forw $jnl |& grep "Virtual file size" | awk '{print $4}'`
	@ vfilesize = $vfilesizeblocks * 512
	echo "FILE number $count : os size $filesize"
	echo "FILE number $count : virtual size $vfilesize"
	if ($vfilesize == 51200 && $firstfile == 0) then
		set firstfile = 1
		continue
	endif	
	if ($filesize > $auto) then
		echo "TEST-E-FSZGTAUT $jnl size $filesize is more than autoswitch limit $auto"
		exit
	endif
	if ($filesize > $vfilesize) then
		echo "TEST-E-FSZGTVSZ $jnl size $filesize is more than virtual file size $vfilesize"
		exit
	endif
	@ vfilesize = $vfilesize - $alloc
	@ vfilesize = $vfilesize - (($vfilesize / $exten) * $exten)
	if ($vfilesize != 0) echo "TEST-E-NOTMULAUTO $jnl size is not multiple of alloc = $alloc and exten = $exten"    
end
echo "Total Files of type $pat = $count"
