getunitemplate()
	new multibytestr
	if $ztrnlnm("gtm_chset")'="UTF-8" quit "NOTUTF8"
	SET multibytestr=$CHAR(65,167,1604,2437,8544,8803,22784,120120)
	;SET multibytestr=$CHAR(167,1604,2437,8544,8803,22784,120120)
	quit multibytestr
