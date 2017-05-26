ulongstr(length) ; create a unicode long string (of length 'length' bytes)
	if $zv["VMS" quit $$^longstr(length)
	if length<20 quit $$^longstr(length)
	;  U+0000  to U+007F  - One Byte
	;  U+0080  to U+07FF  - Two Byte
	;  U+0800  to U+FFFF  - Three Byte
	;  U+10000 to U+1FFFF - Four Byte
	set oldstate=$view("BADCHAR")
	view "NOBADCHAR"
	new start,codepoint,tstr,tlen,i,padding
	set (start(1),codepoint(1))=14			; This is to generate 1-byte chars
	set (start(2),codepoint(2))=$$FUNC^%HD(80)	; This is to generate 2-byte chars
	set (start(3),codepoint(3))=$$FUNC^%HD(800)	; This is to generate 3-byte chars
	set (start(4),codepoint(4))=$$FUNC^%HD("E800")	; This is to generate 3-byte chars
	set (start(5),codepoint(5))=$$FUNC^%HD(10000)	; This is to generate 4-byte chars
	set end(1)=$$FUNC^%HD(80)	
	set end(2)=$$FUNC^%HD(800)	
	set end(3)=$$FUNC^%HD("D800")	
	set end(4)=$$FUNC^%HD(10000)	
	set end(5)=$$FUNC^%HD(100000)	
	set tstr=""
	set tlen=0
	set unitstrlen=$zlength($char(codepoint(1),codepoint(2),codepoint(3),codepoint(4),codepoint(5)))
	; Instead of building a long string by a simple for loop concatenating one character with the accumulated string
	; we do it in two sets of loops. This is because concatenation of a huge string with one character is a very
	; costly operation that we want to avoid. Hence the logic below which ensures the concatenation always happens with
	; a string that is not more than 2K bytes long
	for  do  q:(tlen>(length-unitstrlen))
	.	do createsubstr
	.	set tstr=tstr_substr
	set tlen=$zlength(tstr)
	set padding=""
	set padtemplate=$C(0,1,2,3,4,5,6,7,8,9)_"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	set padlen=$zlength(padtemplate)
	set remain=length-tlen
	if remain>padlen set $piece(padding,padtemplate,remain\padlen)=""
	set tstr=tstr_padding
	set tlen=$zlength(tstr)
	set remain=length-tlen
	set padding=""
	set $piece(padding,$C(1),remain+1)=""
	set tstr=tstr_padding
	if oldstate=1 view "BADCHAR"
	quit tstr
createsubstr;
	set substr=""
	set subtlen=0
	for  do  q:((tlen>(length-unitstrlen))!(subtlen>1024))
	. set substr=substr_$char(codepoint(1),codepoint(2),codepoint(3),codepoint(4),codepoint(5))
	. set tlen=tlen+unitstrlen
	. set subtlen=subtlen+unitstrlen
	. for cp=1:1:5 do 
	. . set codepoint(cp)=codepoint(cp)+1
	. . if (codepoint(cp)=133)!(codepoint(cp)=8233) set codepoint(cp)=codepoint(cp)+1
	. . if (codepoint(cp)=8232) set codepoint(cp)=codepoint(cp)+2
	. . if codepoint(cp)'<end(cp) set codepoint(cp)=start(cp)
