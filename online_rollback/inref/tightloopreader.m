tightloopreader
	set jmaxwait=0
	kill ^zstop
	do ^job("job^tightloopreader",1,"""""")
	quit

job
	set $ETRAP="zshow ""*"" halt"
loop	tstart ():serial
	write "$zonlnrlbk=",$zonlnrlbk,?32,"$trestart=",$trestart,!
	if $trestart>2 trollback  goto loop  ; don't hold crit, $trestart 3 or more, trollback
	for l=1:1  quit:$data(^zstop)  write "Waiting for ^zstop to be set",!  hang (($random(10)+1)/10)
	tcommit
	quit

stop
	do ^echoline
	write "Stopping the tight loop reader",!
	set ^zstop=1
	quit
