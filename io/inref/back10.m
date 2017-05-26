; This function writes 10 numbered lines of text to the current pipe device in variable "a"
; reads them back from the pipe, and write them to the principal device 
back10
	for i=1:1:10 do
	. use a
	. write i,":abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz",!
	. for  read x:0 quit:x'=""
	. use $p
	. write x,!
	quit 
