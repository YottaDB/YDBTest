writetxt ;
 w !!,"Checking the result of $TEXT:",!
 f i=1:1 s x=$T(+i^spaces) q:x=""  d
 . w !,"Line ",$j(i,2),": ",x,!?9 
 . f k=1:1:$l(x) d
 . . s a=$a(x,k)
 . . w:$x>65 !?9
 . . w $s(a=32:"<space>",a=9:"<tab>",(a>32)&(a<127):$c(a),1:"<"_a_">")
 . . q
 . q
 w !!,"**End of test**" 
 q
