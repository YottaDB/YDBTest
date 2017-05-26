manygbls;
	; Creates many globals to have huge Directory tree
	s template="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	; total globals is 2 times totname
	s totname=100
	s totgbls=1000
	f j=1:1:totgbls  D
	.  f i=1:1:totname  DO
	.  .  s ndx=(i-1)#47+1
        .  .  s x="^"_$e(template,ndx,ndx+30)_i  
        .  .  s y=x_"("_j_","_i_")"  s @y=$j(j,15)
	s template="zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA"
	f j=1:1:totgbls  D
	.  f i=1:1:totname  DO
	.  .  s ndx=(i-1)#47+1
        .  .  s x="^"_$e(template,ndx,ndx+5)_i  
        .  .  s y=x_"("_j_","_i_")"  s @y=$j(j,15)
	q
