setarray  s ^PatRec(456)="Doe,Jane",^PatRec(456,970501)="Toothache"
	  s ^PatRec(456,980215)="Cleaning"
	  s ^PatRec(789)="King,Robert",^PatRec(789,960715)="Headache"
	  s ^PatRec(789,980124)="Annual Checkup"
	  quit
	  ;s s1=""
	  ;f i=0:0 s s1=$O(^PatRec(s1)) q:s1=""  w !,"PID=",s1," name=",^PatRec(s1)
	  ;s s1=$O(^PatRec(s1))
	  ;w !,"PID=",$O(^PatRec(s1))," name=",^PatRec($O(^PatRec(s1)))
getfn     if $D(^PatRec($O(^PatRec("")))) w "Got patient: ",$GET(^PatRec($O(^PatRec(""))))
	  quit
orderfn	  w !,"PID=",$O(^PatRec(""))," name=",^PatRec($O(^PatRec("")))
	  quit
queryfn   s ref="^PatRec"  w "query: ",$Q(@ref)
	  quit

