; Create in excess of 64 indirect frames in a row and do a ZSHOW "S". Prior to C9L04-003403, used to overflow array
; on stack causing potential damage to return addresses and such. Now generates an indication that the internal array
; overflowed and some (indirect) entries were bypassed.
;

	Set A1="@A"
	Set A="sub"
	For i=2:1:75 Do
	. Set @("A"_i)="@A"_(i-1)
	Do @A75		; Triggers 75 indirect frames to be created
	Quit

sub
	ZShow "S"
	;ZMessage 150377788 ; Generates core if want to look at it with gtmpcat
	Quit
