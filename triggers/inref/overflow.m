overflow
	; Test overflow in trigger error message
	new x,longname,invalidname

	if $zchset="M"  do
	. set longname="aa"
	. set invalidname="+a"

	if $zchset="UTF-8"  do
	. set longname="અઅ"
	. set invalidname="+અ"

	; It's exponential.  This get strings length to 32K
	for i=1:1:14 do
	. set longname=longname_longname
	. set invalidname=invalidname_invalidname

	do trigselect
	do trigload

	quit

trigselect
	; trigger select overflow

	; overflow ^GVN usage
	set x=$ztrigger("select","^"_longname)
	; overflow trigger-name usage
	set x=$ztrigger("select",longname)

	quit

trigload
	; trigger loading overflow

	; error in pieces
	set x=$ztrigger("item","+^a -command=SET -xecute=""set x=1"" -pieces="_longname_" -delim="":"" -name=fail")
	; error in delim
	set x=$ztrigger("item","+^a -command=SET -xecute=""set x=1"" -pieces=1 -delim="""_longname_""" -name=fail")
	; error in xecute
	set x=$ztrigger("item","+^a -command=SET -xecute="""_longname_""" -pieces=1 -delim="":"" -name=fail")
	set x=$ztrigger("item","+^a -command=SET -xecute="" set x = "_longname_""" -pieces=1 -delim="":"" -name=fail")
	; invalid GVN
	set x=$ztrigger("item","^a"_longname_" -command=SET -xecute=""set x=1"" -pieces=1 -delim="":"" -name=fail")
	set x=$ztrigger("item","+^a"_invalidname_" -command=SET -xecute=""set x=1"" -pieces=1 -delim="":"" -name=fail")
	; error in command
	set x=$ztrigger("item","+^a -command=killZ -xecute="""_longname_""" -pieces=1 -delim="":"" -name=fail")
	set x=$ztrigger("item","+^a -command=S,,K -xecute="""_longname_""" -pieces=1 -delim="":"" -name=fail")
	; error in options
	set x=$ztrigger("item","+^a -command=SET -options="_longname_" -xecute=""set x=1"" -pieces=1 -delim="":"" -name=fail")
	set x=$ztrigger("item","+^a -command=SET -options= noi -xecute=""set x=1"" -pieces=1 -delim="""_longname_""" -name=fail")
	; error in subscript
	set x=$ztrigger("item","+^a("""_longname_""") -command=SET -xecute=""set x=1"" -pieces=1 -delim="":"" -name=fail")

	quit
