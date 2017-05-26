	Do &void	; no arguments
	Write !

	Set alongp=67890
	Write "passing ",alongp," to outlongp",!
	Do &outlongp(.alongp)
	Write "  value returned from outlongp = ",alongp,!!

	Set aulongp=4294967295
	Write "passing ",aulongp," to outulongp",!
	Do &outulongp(.aulongp)
	Write "  value returned from outulongp = ",aulongp,!!

	Set afltp=123.349
	Write "passing ",afltp," to outfloatp",!
	Do &outfloatp(.afltp)
	Write "  value returned from outfloatp = ",afltp,!!

	Set adblp=654.321
	Write "passing ",adblp," to outdoublep",!
	Do &outdoublep(.adblp)
	Write "  value returned from outdoublep = ",adblp,!!

	Set achrpp="C-style string"
	Write "passing """,achrpp,""" to outcharpp",!
	Do &outcharpp(.achrpp)
	Write "  value returned from outcharpp = """,achrpp,"""",!!

	Write "getting returned value outstringp (address copy)",!
	Do &outstringp(.astrngp)
	Write "    value returned from outstringp = """,astrngp,"""",!!
	
	Write "getting returned value outstringp (memcpy)",!
	Do &outstringp2(.astrngp)
	Write "    value returned from outstringp = """,astrngp,"""",!!	

	Set aintp=67890
	Write "passing ",aintp," to outintp",!
	Do &outintp(.aintp)
	Write "  value returned from outintp = ",aintp,!!

	Set auintp=4294967295
	Write "passing ",auintp," to outuintp",!
	Do &outuintp(.auintp)
	Write "  value returned from outuintp = ",auintp,!!

