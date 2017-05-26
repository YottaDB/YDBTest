; This script is called from setexklo.csh.
; This is another case of test that does a bunch of set,kill and merges.
setexklo;
	quit
init    ;
        set str="abcdefg"
        quit
set     ;
        set cmd="set"
        do common
        do merge
        quit
kill    ;
        set cmd="kill"
        do common               ; to validate ^a,^b,^c,...
        set gblname2="m"        ; to validate ^am,^bm,^cm,...
        do common
        quit
        ;
verify(gblname) ;
        set cmd="verify"
        do common               ; to validate ^a,^b,^c,...
        set gblname2="m"        ; to validate ^am,^bm,^cm,...
        do common
        write "Data verification PASS",!
        quit
common  ;
        do init
        for i=1:1:20  do
        .       set i2=2**i
        .       for x=1:1:$l(str)  do
        .       .       set gblname=$extract(str,x)
        .       .       if $get(gblname2)'=""  set gblname=gblname_gblname2
        .       .       set xstr=cmd_" ^"_gblname_"(i2-1)=(i2-1)"  do xecutexstr
        .       .       set xstr=cmd_" ^"_gblname_"(i2-1,"""")=i2" do xecutexstr
        .       .       set xstr=cmd_" ^"_gblname_"(i2-1,1)=(i2+1)" do xecutexstr
        .       .       set xstr=cmd_" ^"_gblname_"(i2)=$justify(i2,i2)" do xecutexstr
        .       .       set xstr=cmd_" ^"_gblname_"(i2,"""")=(i2+2)" do xecutexstr
        .       .       set xstr=cmd_" ^"_gblname_"(i2,1)=(i2+3)" do xecutexstr
        quit
xecutexstr;
        if cmd="set" xecute xstr  quit
        if cmd="kill" set ystr=$piece(xstr,"=",1) xecute ystr  quit
        if cmd="verify" do  quit
        .       set ystr=$piece(xstr," ",2,99)
        .       set ystr1=$piece(ystr,"=",1)
        .       set ystr2=$piece(ystr,"=",2)
        .       set zstr="if "_ystr1_"'="_ystr2_" write ""SPANNODEX-E-VERIFYFAIL"",! zshow ""*""  halt"
        .       xecute zstr
        quit
merge   ;
        merge ^am=^g
        merge ^cm=^am
        merge ^em=^am
        merge ^dm=^c
        merge ^fm=^em
        merge ^bm=^dm
        merge ^gm=^em
        quit