	Do &hello	; no arguments
	Write !

	Set alongp=67890
	Write "passing ",alongp," to iolongp",!
	Do &iolongp(alongp)
	Write "  value returned from iolongp = ",alongp,!!

	Set aulongp=4294967295
	Write "passing ",aulongp," to ioulongp",!
	Do &ioulongp(aulongp)
	Write "  value returned from ioulongp = ",aulongp,!!

	Set afltp=123.456
	Write "passing ",afltp," to iofloatp",!
	Do &iofloatp(afltp)
	Write "  value returned from iofloatp = ",afltp,!!

	Set adblp=654.321
	Write "passing ",adblp," to iodoublep",!
	Do &iodoublep(adblp)
	Write "  value returned from iodoublep = ",adblp,!!

	Set achrpp="C-style string"
	Write "passing """,achrpp,""" to iocharpp",!
	Do &iocharpp(achrpp)
	Write "  value returned from iocharpp = """,achrpp,"""",!!

	Set astrngp="String structure"
	Write "passing """,astrngp,""" to iostringp",!
	Do &iostringp(astrngp)
	Write "  value returned from iostringp = """,astrngp,"""",!!
