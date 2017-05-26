nullfill(act,node);
	NEW $ZTRAP
	SET $ZTRAP="GOTO errcont^errcont" 
	SET ERR=1
	K ^tmpvar
	if act="ver" W !,"Verify ",node,!  M ^tmpvar=@node
	else  W !,act," Started",!
	set ind(1)=-100
	set ind(2)=-22/7
	set ind(3)=0
	set ind(4)=22/7
	set ind(5)=100
	set ind(6)=""
	set ind(7)=$C(0)
	set ind(8)=$C(1,2,3,4)
	set ind(9)=" abcdefg " 
	set cnt=0
	for i=1:1:9 DO 
	. for j=5:1:7 DO 
	. . for k=1:1:9 DO 
	. . . set cnt=cnt+1
	. . . if act="set" DO
	. . . . set varlongvariablenamesworkfornull(ind(i),ind(j),ind(k))=cnt
	. . . . set ^varlongvariablenamesworkfornull(ind(i),ind(j),ind(k))=cnt
	. . . if act="kill"  DO
	. . . . kill varlongvariablenamesworkfornull(ind(i),ind(j),ind(k))
	. . . . kill ^varlongvariablenamesworkfornull(ind(i),ind(j),ind(k))
	. . . if act="ver" DO
	. . . . do EXAM(act,"INDEX ("_i_","_j_","_k_")",cnt,$GET(^tmpvar(ind(i),ind(j),ind(k))))
	. . . . zwithdraw ^tmpvar(ind(i),ind(j),ind(k))
	. . . if ERR>8  w " Not reporting any further, too many errors ",!  q
	;
	; Some literals
	if act="set" DO
	. set ^varlongvariablenamesworkfornull("")="null"
	. set ^varlongvariablenamesworkfornull(0,"",0,"")="null,0,null,0"
	. set varlongvariablenamesworkfornull("")="null"
	. set varlongvariablenamesworkfornull(0,"",0,"")="null,0,null,0"
	if act="kill" DO
	. kill ^varlongvariablenamesworkfornull("")
	. kill ^varlongvariablenamesworkfornull(0,"",0,"")
	. kill varlongvariablenamesworkfornull("")
	. kill varlongvariablenamesworkfornull(0,"",0,"")
	if act="ver" DO
	. do EXAM(act,"^tmpvar("_""""""_")","null",$GET(^tmpvar("")))
	. do EXAM(act,"^tmpvar(0,"_""""""_",0,"_""""""_")","null,0,null,0",$GET(^tmpvar(0,"",0,"")))
	. zwithdraw ^tmpvar("")
	. zwithdraw ^tmpvar(0,"",0,"")
	. ;do EXAM(act,"^varlongvariablenamesworkfornull("_""""_")","null",$GET(^varlongvariablenamesworkfornull("")))
	. ;do EXAM(act,"^varlongvariablenamesworkfornull(0,"_""""_",0,"_""""_")","null,0,null,0",$GET(^varlongvariablenamesworkfornull(0,"",0,"")))
	. ;do EXAM(act,"varlongvariablenamesworkfornull("_""""_")","null",$GET(varlongvariablenamesworkfornull("")))
	. ;do EXAM(act,"varlongvariablenamesworkfornull(0,"_""""_",0,"_""""_")","null,0,null,0",$GET(varlongvariablenamesworkfornull(0,"",0,"")))
	if act="ver" if ($data(^tmpvar))'=0 W !,"Verify Failed",!  q
	if act="ver" if ($data(^tmpvar))=0 W !,"Verify of "_node_" Passed",!
	else  W !,act," Finished",!
	K ERR,ind,cnt,i,j,k
	Q
EXAM(act,pos,vcorr,vcomp)
	i vcorr=vcomp  q
	s ERR=ERR+1
	w " ** FAIL ",act," verifying global ",pos,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	q
