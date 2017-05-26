quittest;
	; Literal
	set ret1=$$quitfn1(1)
	set ret2=$$quitfn1(2)
	set ret3=$$quitfn1(2)
	set ret4=$$quitfn1(2)
	if ret1'="লায়েক" write "Failed quit literal",!
	if ret2'="ＡＤＩＲ" write "Failed quit literal",!
	if ret3'="αβγδε" write "Failed quit literal",!
	if ret4'="我能吞下玻璃而不伤身体" write "Failed quit literal",!
	;
	; Variable with unicode result
	for I=1:1:50 do
	. set ret(I)=$$quitfn2(I)
	. if ret(I)'=$$^genstr(I,0) write "quit test failed",!
	quit
	;
quitfn1(case)
	if case=1 quit "লায়েক"
	if case=2 quit "ＡＤＩＲ"
	if case=3 quit "αβγδε"
	if case=4 quit "我能吞下玻璃而不伤身体"
	quit ""

quitfn2(case)
	quit $$^genstr(case,0)
