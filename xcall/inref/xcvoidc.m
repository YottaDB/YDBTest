	Do &voidc^caret	; no arguments
	Write !

	Set along=12345
	Write "passing ",along," to inlong",!
	Do &inlong^caret(along)
	Write !

	Set alongp=67890
	Write "passing ",alongp," to inlongp",!
	Do &inlongp^caret(.alongp)
	Write "  value returned from inlongp = ",alongp,!!

	Set aulong=4294967295
	Write "passing ",aulong," to inulong",!
	Do &inulong^caret(aulong)
	Write !

	Set aulongp=4294967295
	Write "passing ",aulongp," to inulongp",!
	Do &inulongp^caret(.aulongp)
	Write "  value returned from inulongp = ",aulongp,!!

	Set afltp=123.349
	Write "passing ",afltp," to infloatp",!
	Do &infloatp^caret(.afltp)
	Write "  value returned from infloatp = ",afltp,!!

	Set adblp=654.321
	Write "passing ",adblp," to indoublep",!
	Do &indoublep^caret(.adblp)
	Write "  value returned from indoublep = ",adblp,!!

	Set achrp="c"
	Write "passing """,achrp,""" to incharp",!
	Do &incharp^caret(.achrp)
	Write "  value returned from incharp = """,achrp,"""",!!

	Set achrpp="C-style string"
	Write "passing """,achrpp,""" to incharpp",!
	Do &incharpp^caret(.achrpp)
	Write "  value returned from incharpp = """,achrpp,"""",!!

	Set astrngp="String structure"
	Write "passing """,astrngp,""" to instringp",!
	Do &instringp^caret(.astrngp)
	Write "  value returned from instringp = """,astrngp,"""",!!

	Set aint=12345
	Write "passing ",aint," to inint",!
	Do &inint^caret(aint)
	Write !

	Set aintp=2147483647
	Write "passing ",aintp," to inintp",!
	Do &inintp^caret(.aintp)
	Write "  value returned from inintp = ",aintp,!!

	Set auint=4294967295
	Write "passing ",auint," to inuint",!
	Do &inuint^caret(auint)
	Write !

	Set auintp=4294967295
	Write "passing ",auintp," to inuintp",!
	Do &inuintp^caret(.auintp)
	Write "  value returned from inuintp = ",auintp,!!

