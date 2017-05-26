	Do &pk.void	; no arguments
	Write !

	Set along=12345
	Write "passing ",along," to pk.inlong",!
	Do &pk.inlong(along)
	Write !

	Set alongp=67890
	Write "passing ",alongp," to pk.inlongp",!
	Do &pk.inlongp(.alongp)
	Write "  value returned from pk.inlongp = ",alongp,!!

	Set aulong=4294967295
	Write "passing ",aulong," to pk.inulong",!
	Do &pk.inulong(aulong)
	Write !

	Set aulongp=4294967295
	Write "passing ",aulongp," to pk.inulongp",!
	Do &pk.inulongp(.aulongp)
	Write "  value returned from pk.inulongp = ",aulongp,!!

	Set aint=12345
	Write "passing ",aint," to pk.inint",!
	Do &pk.inint(aint)
	Write !

	Set aintp=2147483647
	Write "passing ",aintp," to pk.inintp",!
	Do &pk.inintp(.aintp)
	Write "  value returned from pk.inintp = ",aintp,!!

	Set auint=4294967295
	Write "passing ",auint," to pk.inuint",!
	Do &pk.inuint(auint)
	Write !

	Set auintp=4294967295
	Write "passing ",auintp," to pk.inuintp",!
	Do &pk.inuintp(.auintp)
	Write "  value returned from pk.inuintp = ",auintp,!!

	Set afltp=123.349
	Write "passing ",afltp," to pk.infloatp",!
	Do &pk.infloatp(.afltp)
	Write "  value returned from pk.infloatp = ",afltp,!!

	Set adblp=654.321
	Write "passing ",adblp," to pk.indoublep",!
	Do &pk.indoublep(.adblp)
	Write "  value returned from pk.indoublep = ",adblp,!!

	Set achrp="c"
	Write "passing """,achrp,""" to pk.incharp",!
	Do &pk.incharp(.achrp)
	Write "  value returned from pk.incharp = """,achrp,"""",!!

	Set achrpp="C-style string"
	Write "passing """,achrpp,""" to pk.incharpp",!
	Do &pk.incharpp(.achrpp)
	Write "  value returned from pk.incharpp = """,achrpp,"""",!!

	Set astrngp="String structure"
	Write "passing """,astrngp,""" to pk.instringp",!
	Do &pk.instringp(.astrngp)
	Write "  value returned from pk.instringp = """,astrngp,"""",!!
