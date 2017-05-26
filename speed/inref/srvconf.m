;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2009, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
srvconf	;
	; This script holds the server specific configuration/settings/values used by the speed test
	; When there is a server change make sure all of the sections are updated
	; At the end of each configuration data make sure you have the line ";endofdata". 
	; This line serves as "end of data". Otherwise the for loops will loop indefinitely

speed(hostn);Speed test configuration
	new i,data
	; For now speed test compares two GT.M versions only.
	; You can compare two machines as long as same size is used for the operation(s).
	; Note online TP runs too slow compared to batch TP since the same size is not used in the test for both.
	; As a result speed results between them are not comparable.
	; If same size is used between these two different operations, you can find out which is faster and how much.
	; Similarly local variable is too slow compared to global variable for big array size.
	; So smaller size is used for local variables.
	; To compare a local variable operation with global variable, in below same size must be used.
	; Hostname mapping is also done here
	for i=1:1 set data=$text(spddata+i) quit:($piece(data,";",2)="endofdata")!'$Length(data)  if ($piece(data,";",2)=hostn) do  quit
	. set ^hostname(hostn)=$piece(data,";",3),sizes(hostn)=$piece(data,";",4)
	quit
	; The entries should be of the form
	; server;server alias;data of the form LOCKI=...|ZDSRTST1=...|ZDSRTST2=...|LCL=...|GBLS=...|GBLREORG=...|GBLM=...|TPBA=...|TPON=...;Name of server ref file to be used in speed test
spddata	;
	;scylla;srv1;LOCKI=1000000|ZDSRTST1=2000000|ZDSRTST2=2000000|LCL=25000|GBLS=600000|GBLREORG=600000|GBLM=180000|TPBA=200000|TPON=40000
	;lespaul;srv3;LOCKI=1000000|ZDSRTST1=2000000|ZDSRTST2=2000000|LCL=25000|GBLS=400000|GBLREORG=400000|GBLM=180000|TPBA=200000|TPON=4000
	;charybdis;srv6;LOCKI=1000000|ZDSRTST1=2000000|ZDSRTST2=2000000|LCL=25000|GBLS=250000|GBLREORG=250000|GBLM=60000|TPBA=100000|TPON=40000	; This machine has speed issues.
	;jackal;srv7;LOCKI=1000000|ZDSRTST1=2000000|ZDSRTST2=2000000|LCL=25000|GBLS=250000|GBLREORG=250000|GBLM=60000|TPBA=100000|TPON=40000
	;pfloyd;srv10;LOCKI=600000|ZDSRTST1=2000000|ZDSRTST2=2000000|LCL=25000|GBLS=200000|GBLREORG=200000|GBLM=60000|TPBA=100000|TPON=4000
        ;atlst2000;srv15;LOCKI=600000|ZDSRTST1=2000000|ZDSRTST2=2000000|LCL=25000|GBLS=200000|GBLREORG=200000|GBLM=60000|TPBA=100000|TPON=4000
	;other;srv44;LOCKI=1000000|ZDSRTST1=2000000|ZDSRTST2=2000000|LCL=25000|GBLS=600000|GBLREORG=600000|GBLM=180000|TPBA=200000|TPON=40000
	;other;srv45;LOCKI=10000|ZDSRTST1=20000|ZDSRTST2=20000|LCL=25|GBLS=50|GBLREORG=50|GBLM=20|TPBA=20|TPON=20 ; move this above while debugging
	;endofdata

