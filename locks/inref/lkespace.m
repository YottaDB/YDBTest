lock	;
	lock ^A1
	lock +^B2
	lock +^global(1)
	lock +^global("string")
	lock +^global("two words")
	lock +^global("three words here","two here")
	lock +^global("embedded"" quote")
	lock +^global("embedded = equals")
	lock +^global("embedded = and""")
	lock +^global("embed=and""nospace")
	write "Show only one lock with embedded = and quote",!
	s showlock="$LKE show -lock=""^global(\""embedded = and\""\""\"")"""
	zsystem showlock
	write "Remove only one lock with embedded = and quote witout space",!
	s clearlock="$LKE clear -nointeractive -lock=""^global(\""embed=and\""\""nospace\"")"""
	zsystem clearlock
	write !,"Remove only one lock ^global(two words)",!
	s clearlock="$LKE clear -nointeractive -lock=""^global(\""two words\"")"""
	zsystem clearlock
	write !,"Remove only one lock ^global(embedded = equals)",!
	s clearlock="$LKE clear -nointeractive -lock=""^global(\""embedded = equals\"")"""
	zsystem clearlock
	write !,"Clear all locks",!
	s clearall="$LKE clear -nointeractive"
	zsystem clearall
