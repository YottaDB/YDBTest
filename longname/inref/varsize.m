; VARSIZE
;
; The routine sets  globals of string length upto 31 bit
varsize

	set ^X=1000
	for counter=2:1:31 do
	. set str=counter
	. for i=$LENGTH(counter)+1:1:str do
	.. set str="X"_str
	. set @("^"_str_"=1000")
