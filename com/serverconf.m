;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2007, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
serverconf	;
	; This script holds the server specific configuration/settings/values used by the following tests
	; When there is a server change make sure all of the sections are updated
	; At the end of each configuration data make sure you have the line ";endofdata".
	; This line serves as "end of data". Otherwise the for loops will loop indefinitely

memstress(hostn)	;mem_stress configuration
	; ^arrlen to determine array length of big strings (1MB)
	; ^repcnt to determine how many times to continue the loop to see if there is any memory leak.
	;	We had to limit ^repcnt for running time. Ideally even for a very high value test should pass.
	Set template=$text(memstressdata)
	for i=1:1 set data=$text(memstressdata+i) quit:($piece(data,";",2)="endofdata")!'$Length(data)  if ($piece(data,";",2)=hostn) do  quit
	. for i=3:1:$length(data,";") set @$piece(template,";",i)=$piece(data,";",i)
	quit
	;The entrys should be of the form
	;server;^arrlen;^repcnt
memstressdata;server;^arrlen;^repcnt
	;scylla;10;50
	;charybdis;10;50
	;atlst2000;10;10
	;lespaul;10;25
	;pfloyd;10;25
	;jackal;10;50
	;other;3;50
	;endofdata

profile(hostn,ver,numaccts,img)	; profile test configuration
	set ver=$$FUNC^%LCASE(ver)
	set numaccts=$$FUNC^%UCASE(numaccts)
	set img=$$FUNC^%UCASE(img)
	Set template=$text(profiledata)
	for i=1:1 set data=$text(profiledata+i) q:($piece(data,";",2)="endofdata")!'$Length(data)  if ((i=1)!(($piece(data,";",2)=hostn)&($piece(data,";",3)=ver)&($piece(data,";",4)=numaccts)&($piece(data,";",5)=img))) do  quit:i>1
	. for i=6:1:$length(data,";") set @$piece(template,";",i)=$piece(data,";",i)
	quit

	; The following data is profile test related data. It should be of the form
	; hostname;<profile_tstver>;image;^zzzavg("QUE039");^zzzstddev("QUE039");^zzzavg("QUE055");^zzzstddev("QUE055");^zzzavg("QUE096");^zzzstddev("QUE096")
profiledata	;hostname;<profile_tstver>;numaccts;image;^zzzavg("QUE039");^zzzstddev("QUE039");^zzzavg("QUE055");^zzzstddev("QUE055");^zzzavg("QUE096");^zzzstddev("QUE096")
	;default;must;be;first entry;8000;100;8000;100;8000;100
	;jackal;v64;100K;DBG;8000;100;8000;100;8000;100
	;jackal;v64;100K;PRO;45.5;0.51;128.45;1.54;34.35;0.49
	;jackal;v70;100K;DBG;8000;100;8000;100;8000;100
	;jackal;v70;100K;PRO;56.74;0.78;171.78;1.11;91;0.78
	;jackal;v734;100K;DBG;8000;100;8000;100;8000;100
	;jackal;v734;100K;PRO;8000;100;8000;100;8000;100
	;jackal;v734;1M;DBG;8000;100;8000;100;8000;100
	;jackal;v734;1M;PRO;8000;100;8000;100;8000;100
	;charybdis;v64;100K;DBG;8000;100;8000;100;8000;100
	;charybdis;v64;100K;PRO;8000;100;8000;100;8000;100
	;charybdis;v70;100K;DBG;8000;100;8000;100;8000;100
	;charybdis;v70;100K;PRO;8000;100;8000;100;8000;100
	;charybdis;v734;100K;DBG;8000;100;8000;100;8000;100
	;charybdis;v734;100K;PRO;8000;100;8000;100;8000;100
	;charybdis;v734;1M;DBG;8000;100;8000;100;8000;100
	;charybdis;v734;1M;PRO;8000;100;8000;100;8000;100
	;scylla;v64;100K;DBG;8000;100;8000;100;8000;100
	;scylla;v64;100K;PRO;82.8;10.26;201.6;20.61;32.95;1.9
	;scylla;v70;100K;DBG;8000;100;8000;100;8000;100
	;scylla;v70;100K;PRO;103.94;11.99;341.82;39.99;113.18;5.39
	;scylla;v734;100K;DBG;8000;100;8000;100;8000;100
	;scylla;v734;100K;PRO;8000;100;8000;100;8000;100
	;scylla;v734;1M;DBG;8000;100;8000;100;8000;100
	;scylla;v734;1M;PRO;8000;100;8000;100;8000;100
	;atlst2000;v64;100K;DBG;8000;100;8000;100;8000;100
	;atlst2000;v64;100K;PRO;8000;100;8000;100;8000;100
	;atlst2000;v70;100K;DBG;8000;100;8000;100;8000;100
	;atlst2000;v70;100K;PRO;8000;100;8000;100;8000;100
	;atlst2000;v734;100K;DBG;8000;100;8000;100;8000;100
	;atlst2000;v734;100K;PRO;8000;100;8000;100;8000;100
	;atlst2000;v734;1M;DBG;8000;100;8000;100;8000;100
	;atlst2000;v734;1M;PRO;8000;100;8000;100;8000;100
	;lespaul;v64;100K;DBG;8000;100;8000;100;8000;100
	;lespaul;v64;100K;PRO;118.25;14.44;300.95;2.82;81.2;13.6
	;lespaul;v70;100K;DBG;8000;100;8000;100;8000;100
	;lespaul;v70;100K;PRO;161;16.74;431;13.23;221.47;15.67
	;lespaul;v734;100K;DBG;8000;100;8000;100;8000;100
	;lespaul;v734;100K;PRO;8000;100;8000;100;8000;100
	;lespaul;v734;1M;DBG;8000;100;8000;100;8000;100
	;lespaul;v734;1M;PRO;8000;100;8000;100;8000;100
	;pfloyd;v64;100K;DBG;8000;100;8000;100;8000;100
	;pfloyd;v64;100K;PRO;8000;100;8000;100;8000;100
	;pfloyd;v70;100K;DBG;8000;100;8000;100;8000;100
	;pfloyd;v70;100K;PRO;8000;100;8000;100;8000;100
	;pfloyd;v734;100K;DBG;8000;100;8000;100;8000;100
	;pfloyd;v734;100K;PRO;8000;100;8000;100;8000;100
	;pfloyd;v734;1M;DBG;8000;100;8000;100;8000;100
	;pfloyd;v734;1M;PRO;8000;100;8000;100;8000;100
	;tuatara;v70;100K;DBG;8000;100;8000;100;8000;100
	;tuatara;v70;100K;PRO;53;7.4;85.3;1.6;55.4;4.3
	;tuatara;v734;100K;DBG;8000;100;8000;100;8000;100
	;tuatara;v734;100K;PRO;8000;100;8000;100;8000;100
	;tuatara;v734;1M;DBG;8000;100;8000;100;8000;100
	;tuatara;v734;1M;PRO;8000;100;8000;100;8000;100
	;strato;v70;100K;DBG;8000;100;8000;100;8000;100
	;strato;v70;100K;PRO;8000;100;8000;100;8000;100
	;strato;v734;100K;DBG;8000;100;8000;100;8000;100
	;strato;v734;100K;PRO;8000;100;8000;100;8000;100
	;strato;v734;1M;DBG;8000;100;8000;100;8000;100
	;strato;v734;1M;PRO;8000;100;8000;100;8000;100
	;titan;v70;100K;DBG;8000;100;8000;100;8000;100
	;titan;v70;100K;PRO;53;7.4;85.3;1.6;55.4;4.3
	;titan;v734;100K;DBG;8000;100;8000;100;8000;100
	;titan;v734;100K;PRO;8000;100;8000;100;8000;100
	;titan;v734;1M;DBG;8000;100;8000;100;8000;100
	;titan;v734;1M;PRO;8000;100;8000;100;8000;100
	;carmen;v70;100K;DBG;8000;100;8000;100;8000;100
	;carmen;v70;100K;PRO;53;7.4;85.3;1.6;55.4;4.3
	;carmen;v734;100K;DBG;8000;100;8000;100;8000;100
	;carmen;v734;100K;PRO;8000;100;8000;100;8000;100
	;carmen;v734;1M;DBG;8000;100;8000;100;8000;100
	;carmen;v734;1M;PRO;8000;100;8000;100;8000;100
	;endofdata
