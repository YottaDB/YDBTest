d002577	;
	; ------------------------------------------------------------------------------------------------------
	; D9F11-002577 [Narayanan] Patterns mixed with alternations do not work as expected
	; ------------------------------------------------------------------------------------------------------
	set bannerstr="-----------------------------------------------------------------"
	write !,bannerstr,!,"Test case x1",!,bannerstr do x1
	write !,bannerstr,!,"Test case x2",!,bannerstr do x2
	write !,bannerstr,!,"Test case x3",!,bannerstr do x3
	write !
	quit
x1	;
	s text="bone (vl bodies: t4, t9, t11, t13, l3):metastatc "
	set textchk="text?1(.e1p,.p).an"
	write !,"text=",text
	write !,textchk,"=",@textchk
	quit
x2	;
	s dx="bone (vertebral bodies: t4, t9, t11, t13, l3):metastatic osteosarcoma"
	write !,"text=",text
	set textchk="text?1(.e1p,.p).an" do x2helper
	set textchk="text?1(.e1p,.p).an1""sarcoma""" do x2helper
	set textchk="text?1(.e1p,0p).an1""sarc"".e" do x2helper
	set textchk="text?1(.e1p,1p).an1""sarc"".e" do x2helper
	set textchk="text?1(.e1p,.e).an1""sarc"".e" do x2helper
	set textchk="text?1(.p,.e1p).an1""sarc"".e" do x2helper
	set textchk="text?1(0p,.e1p).an1""sarc"".e" do x2helper
	set textchk="text?1(1p,.e1p).an1""sarc"".e" do x2helper
	set textchk="text?1(.e,.e1p).an1""sarc"".e" do x2helper
	set textchk="text?1(.e1p).an1""sarc"".e" do x2helper
	set textchk="text?.1(.e1p).an1""sarc"".e" do x2helper
	set textchk="text?1(1.e,.e1p).an1""sarc"".e" do x2helper
	set textchk="text?1(1.p,.e1p).an1""sarc"".e" do x2helper
	set textchk="text?1(.an,.e1p.an)1""sarc"".e" do x2helper
	quit
x2helper	;
	w !,textchk,!,"        " s text=dx f i=1:1:64 w @textchk w:i#8=0 " " s text=" "_text
	quit
x3	;
        s text="sarcoma"
	write !,"text=",text
	set textchk="text?.1(.e1p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?.2(.e1p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?1(.e1p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?.1(.e1p,0p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?.2(.e1p,0p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?1(.e1p,0p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?.1(.e1p,1p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?.2(.e1p,1p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?1(.e1p,1p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?.1(.e1p,.1p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?.2(.e1p,.1p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?1(.e1p,.1p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?0.1(.e1p,.1p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?0.2(.e1p,.1p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?0.1(.e1p,0p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?0.2(.e1p,0p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?0.1(.e1p)1""sarc"".e" write !,textchk,"=",@textchk
	set textchk="text?0.2(.e1p)1""sarc"".e" write !,textchk,"=",@textchk
	quit
