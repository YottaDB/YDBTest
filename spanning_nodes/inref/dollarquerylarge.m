; Test $query() and set/get facilities
; This code assumes block size is set to 1024, maximum record size is 10000
; This script is called from basic.csh
; Character set is NOT UTF-8

dqpg1;
	write "reg",!
	do prepreg
	do display
	write !,!,"reg with nulls",!
	do prepwnulls
	do display
        write !,!,"sn",!
        do prepsn
        do display
        write !,!,"halfandhalf",!
        do prephalf
        do display
        write !,!,"sn with nulls",!
        do prepsnwnulls
        do display
        write !,!,"half and half with nulls",!
        do prephalfwnulls
        do display
        write !,!
	quit

display;
	set y="^c"
	for  set y=$query(@y) quit:y=""  write !,y
	quit
prepreg;
	kill ^c
	set ^c(1,2,3)="123"
	set ^c(1,2,3,7)="1237"
	set ^c(1,2,4)="124"
	set ^c(1,2,5,9)="1259"
	set ^c(1,6)="126"
	set ^c("B",1)="B1"
	quit

prepwnulls;
	kill ^c
	set sn=""
	set ^c(1,2,3,"")="123null"_sn_"123null"
	set ^c(1,2,3)="123"_sn_"123"
	set ^c(1,2,3,7,"")="1237null"_sn_"1237null"
	set ^c(1,2,3,7)="1237"_sn_"1237"
	set ^c(1,2,4)="124"_sn_"124"
	set ^c(1,2,4,"")="124null"_sn_"124null"
	set ^c(1,2,5,9,"")="1259null"_sn_"1259null"
	set ^c(1,6,"")="126null"_sn_"126null"
	set ^c("B",1,"")="B1null"_sn_"B1null"
	quit
	

prepsn;
	kill ^c
	set sn="begin"_$justify(" ",8000)_"end"
	set ^c(1,2,3)="123"_sn_"123"
	set ^c(1,2,3,7)="1237"_sn_"1237"
	set ^c(1,2,4)="124"_sn_"124"
	set ^c(1,2,5,9)="1259"_sn_"1259"
	set ^c(1,6)="16"_sn_"16"
	set ^c("B",1)="B1"_sn_"B1"
	quit

prephalf;
	kill ^c
	set sn="begin"_$justify(" ",8000)_"end"
	set ^c(1,2,3)="123"
	set ^c(1,2,3,7)="1237"_sn_"1237"
	set ^c(1,2,4)="124"
	set ^c(1,2,5,9)="1259"_sn_"1259"
	set ^c(1,6)="16"
	set ^c("B",1)="B1"_sn_"B1"
	quit

prepsnwnulls;
	kill ^c
	set sn="begin"_$justify(" ",8000)_"end"
	set ^c(1,2,3,"")="123null"_sn_"123null"
	set ^c(1,2,3)="123"_sn_"123"
	set ^c(1,2,3,7,"")="1237null"_sn_"1237null"
	set ^c(1,2,3,7)="1237"_sn_"1237"
	set ^c(1,2,4)="124"_sn_"124"
	set ^c(1,2,4,"")="124null"_sn_"124null"
	set ^c(1,2,5,9,"")="1259null"_sn_"1259null"
	set ^c(1,6,"")="16null"_sn_"16null"
	set ^c("B",1,"")="B1null"_sn_"B1null"
	quit

prephalfwnulls;
	kill ^c
	set sn="begin"_$justify(" ",8000)_"end"
	set ^c(1,2,3)="123"
	set ^c(1,2,3,"")="123null"
	set ^c(1,2,3,7)="1237"_sn_"1237"
	set ^c(1,2,3,7,"")="1237null"_sn_"1237null"
	set ^c(1,2,4)="124"
	set ^c(1,2,4,"")="124null"
	set ^c(1,2,5,9)="1259"_sn_"1259"
	set ^c(1,2,5,9,"")="1259null"_sn_"1259null"
	set ^c(1,6)="16"
	set ^c(1,6,"")="16null"
	set ^c("B",1)="B1"_sn_"B1"
	set ^c("B",1,"")="B1null"_sn_"B1null"
	quit
