V1WR	;WRITE ALL CHARACTER;YS-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	W !!,"V1WR: WRITE ALL CHARACTERS",!
802	W !,"I-802  Output of alphabetics"
	W !!,"I-802.1  Output of upper-case alphabetics  (visual)"
	W !,"         following two lines should be identical"
	WRITE !,"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	W !,"A","B","C","D","E","F","G","H","I","J","K","L","M"
	W "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
	;
	W !!,"I-802.2  Output of lower-case alphabetics  (visual)"
	W !,"         following two lines should be identical"
	WRITE !,"abcdefghijklmnopqrstuvwxyz"
	W !,"a","b","c","d","e","f","g","h","i","j","k","l","m"
	W "n","o","p","q","r","s","t","u","v","w","x","y","z"
	;
803	W !!,"I-803  Output of digits  (visual)"
	W !,"       following two lines should be identical"
	WRITE !,"1234567890"
	W !,"1","2","3","4","5","6","7","8","9","0"
	;
804	W !!,"I-804  Output of punctuation characters  (visual)"
	W !,"       following two lines should be identical"
	WRITE !," !""#$%&'()+,-./:;<=>?@[\]^_`{|}~"
	W !," ","!","""","#","$","%","&","'","(",")","+",",","-",".","/",":",";"
	W "<","=",">","?","@","[","\","]","^","_","`","{","|","}","~"
	;
END	W !!,"END OF V1WR",!
	S ROUTINE="V1WR",TESTS=4,AUTO=0,VISUAL=4 D ^VREPORT
