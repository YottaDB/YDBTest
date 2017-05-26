	Write "Passing:",!!

	Set along=12345
	Write "    ",along,!

	Set alongp=67890
	Write "    ",alongp,!

	Set aulong=4294967295
	Write "    ",aulong,!

	Set aulongp=4294967295
	Write "    ",aulongp,!

	Set aint=12345
	Write "    ",aint,!

	Set aintp=2147483647
	Write "    ",aintp,!

	Set auint=4294967295
	Write "    ",auint,!

	Set auintp=4294967295
	Write "    ",auintp,!

	Set afltp=123.349
	Write "    ",afltp,!

	Set adblp=654.321
	Write "    ",adblp,!

	Set achrp="c"
	Write "    """,achrp,"""",!

	Set achrpp="C-style string"
	Write "    """,achrpp,"""",!

	Set astrngp="String structure"
	Write "    """,astrngp,"""",!

	Write "to inmult",!!
	Do &inmult(along,alongp,$$aulong,aulongp,aint,aintp,auint,auintp,afltp,adblp,achrp,achrpp,astrngp)

	Write "Values returned from inmult:",!!	;the label seems misleading as these variables are not changed by the call
	Write "    ",along,!
	Write "    ",alongpo,!
	Write "    ",aulong,!
	Write "    ",aulongp,!
	Write "    ",aint,!
	Write "    ",aintp,!
	Write "    ",auint,!
	Write "    ",auintp,!
	Write "    ",afltp,!
	Write "    ",adblp,!
	Write "    """,achrp,"""",!
	Write "    """,achrpp,"""",!
	Write "    """,astrngp,"""",!

	Quit
aulong()				; test that the side effect doesn't affect an argument to the left
	Set alongpo=alongp,alongp=aulong
	quit alongp