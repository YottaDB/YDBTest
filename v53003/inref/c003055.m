c003055	;
	set $zgbldir="mumps.gld"
	view "NOISOLATION":"^x"
	set $zgbldir="mumpsec0.gld"
	view "NOISOLATION":"^x"
	write $zgbldir," : $get(^x)=",$get(^x),!
	set $zgbldir="mumps.gld"
	write $zgbldir," : $get(^x)=",$get(^x),!
	quit
