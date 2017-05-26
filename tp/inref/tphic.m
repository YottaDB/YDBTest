tphic
	set jmaxwait=14400	; wait for max of 4 hours for children to be done
	do ^job("start^tphic",4,"""""")
	quit

start	;
	; the do ^job done above will set the local variable "jobindex" to 1, 2, ... depending on the job number
	;
	new fullstr,length,i,index
	set fullstr="abcd"
	set length=$length(fullstr)
	for i=0:1:length-1 set index(i)=$extract(fullstr,(i+jobindex-1)#length+1);
	set xstr="Set ^"_index(0)_"(j)=$Get(^"_index(1)_"(j))+$Get(^"_index(2)_"(j))+$Get(^"_index(3)_"(j))+1"
	set ystr="If j#10=0 Kill ^"_index(0)_"(j-1),^"_index(1)_"(j-1)"
	for i=1:1:10 Do
	. for j=1:1:1000 Do 
	. . TStart ()
        . . xecute xstr
        . . xecute ystr
        . . TCommit
	quit
