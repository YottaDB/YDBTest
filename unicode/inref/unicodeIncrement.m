gbl;
	set ^x=$incr(^xglobalnamechangedto31character("①②③④⑤⑥⑦⑧"))
	zwrite ^x
	set ^y("αβγδε")=$incr(^xglobalnamechangedto31character("①②③④⑤⑥⑦⑧"))
	zwrite ^x,^y
	set ^z("我能吞下玻璃而不伤身体")=$incr(^xglobalnamechangedto31character("①②③④⑤⑥⑦⑧"),1)
	zwrite ^x,^y,^z
	set ^z("我能吞下玻璃而不伤身体")=$incr(^xglobalnamechangedto31character("①②③④⑤⑥⑦⑧"),^y("αβγδε"))
	zwrite ^x,^y,^z
	set indir="^a(""αβγδε一丄下丕丢串久"")"
	write "$increment(@indir)",!
	write $increment(@indir),!
	zwr ^a
lcl
	set x=$incr(xglobalnamechangedto31character("①②③④⑤⑥⑦⑧"))
	zwrite x
	set y("αβγδε")=$incr(xglobalnamechangedto31character("①②③④⑤⑥⑦⑧"))
	zwrite x,y
	set z("我能吞下玻璃而不伤身体")=$incr(xglobalnamechangedto31character("①②③④⑤⑥⑦⑧"),1)
	zwrite x,y,z
	set z("我能吞下玻璃而不伤身体")=$incr(xglobalnamechangedto31character("①②③④⑤⑥⑦⑧"),y("αβγδε"))
	zwrite x,y,z
	set indir="a(""αβγδε一丄下丕丢串久"")"
	write "$increment(@indir)",!
	write $increment(@indir),!
	zwr a
	quit
