inline	; A part of mprof/D9L03002804 test. Ensures that disabling tracing on the same line with other code works
	; as expected. 
	;
	kill ^trace
	view "trace":1:"^trace"
	do setbeforeoff
	view "trace":1:"^trace"
	do setafteroff
	view "trace":1:"^trace"
	do quitbeforeoff
	do quitafteroff
	view "trace":1:"^trace"
	do foroff
	view "trace":1:"^trace"
	do dobeforeoff
	view "trace":1:"^trace"
	do doafteroff
	zwrite ^trace
	quit
	;
setbeforeoff ; disable tracing after SET
	new i
	set i=1  view "trace":0:"^trace"
	quit
	;
setafteroff ; disable tracing before SET
	new i
	view "trace":0:"^trace"  set i=1
	quit
	;
quitbeforeoff ; disable tracing after QUIT
	new i
	set i=1
	quit  view "trace":0:"^trace"
	;
quitafteroff ; disable tracing before QUIT
	new i
	set i=1
	view "trace":0:"^trace"  quit
	;
foroff ; disable tracing within a FOR
	for i=1:1:1  view "trace":0:"^trace"
	quit
	;
dobeforeoff ; disable tracing after a DO
	new i
	set i=1
	do dummy  view "trace":0:"^trace"
	quit
	;
doafteroff ; disable tracing before a DO
	new i
	set i=1
	view "trace":0:"^trace"  do dummy
	quit
	;
dummy ; dummy function
	new j
	set j=1
