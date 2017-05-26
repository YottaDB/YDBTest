	Do &void	; no arguments
	Write !

	Set alongp=67890
	Write "passing ",alongp," to iolongp",!
	Do &iolongp(.alongp)
	Write "  value returned from iolongp = ",alongp,!!
;
; pass in a 1 should return a ULONG_MAX 4294967295 for 32 bit machine and
; 18446744073709551615 for 64 bit machine
;
	Set aulongp=1
	Write "passing ",aulongp," to ioulongp",!
	Do &ioulongp(.aulongp)
	Write "  value returned from ioulongp = ",aulongp,!!


	Set afltp=123.349
	Write "passing ",afltp," to iofloatp",!
	Do &iofloatp(.afltp)
	Write "  value returned from iofloatp = ",afltp,!!

	Set adblp=654.321
	Write "passing ",adblp," to iodoublep",!
	Do &iodoublep(.adblp)
	Write "  value returned from iodoublep = ",adblp,!!

	Set achrpp="C-style string"
	Write "passing """,achrpp,""" to iocharpp",!
	Do &iocharpp(.achrpp)
	Write "  value returned from iocharpp = """,achrpp,"""",!!

	Set astrngp="String structure"
	Write "passing """,astrngp,""" to iostringp return with address copy",!
	Do &iostringp(.astrngp)
	Write "  value returned from iostringp = """,astrngp,"""",!!
	
	Set astrngp="String structure"
	Write "passing """,astrngp,""" to iostringp return with memcpy",!
	Do &iostringp2(.astrngp)
	Write "  value returned from iostringp = """,astrngp,"""",!!

	Set aintp=2147483647
	Write "passing ",aintp," to iointp",!
	Do &iointp(.aintp)
	Write "  value returned from iointp = ",aintp,!!
;
; pass in a 1 should return a UINT_MAX 4294967295
;
	Set auintp=1
	Write "passing ",auintp," to iouintp",!
	Do &iouintp(.auintp)
	Write "  value returned from iouintp = ",auintp,!!
