unicodeZtrap;
	kill
	new $ZTRAP
	set $ZTRAP="set $ztrap=""zprint @$zposition break""  set z=""豈羅爛來祿屢讀數""  do error"
	write "$ztrap=",$ztrap,!
	set x=y("அவர்கள் ஏன் தமிழில் பேசக்கூடாது ?")
	quit
error
	write "$zstatus=",$zstatus,!
	quit
