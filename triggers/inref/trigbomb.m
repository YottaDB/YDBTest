trigbomb(stop)
	set ref=$reference
	write "@",$ztlevel," BEGIN Trigger ",$ztcode," invoked for ",ref,!
	set subs=$order(^CIF(""),-1)
	if $ztlevel<stop set ^($increment(subs))=subs
	write "@",$ztlevel," End Trigger ",$ztcode," invoked for ",ref,!
	quit
