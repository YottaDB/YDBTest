	; generate a db with random record data
	set recValue="!@#$%^&*()_+{}|"":?><1234567890[]`~\';/.,abcdefghijklmnopqrstuvwxyz"
	for i=1:1:1234 set ^aglobal(i,i*36)=$extract(recValue,$select(i>30:i-30,1:30-i)#66,i#66)
	set ^x(1)=100
	set ^x(2)=200
	set ^x(3)=300
	set ^x(4)=400
	set ^x("abc")="havedata"
	set ^x("abcd")=""		; least possible sized record
	set ^x("abc""def")="xyz"	; key with '"' as a character of subscript 

