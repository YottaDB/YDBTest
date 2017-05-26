+^A(sub=:) -commands=SET -name=trigtrc -xecute=<<
 If sub=0 Do
 . Write "sub=0 - Setting ZBreak in trigger",!
 . ZBreak ^trigtrc#:"Write ""sub=1 - ZBreak works"",!"
 Else  If sub=1 Do  ; no output as zbreak took care of that already
 . Zbreak -*
 Else  If sub=2 Do
 . Write "sub=2 ",$Text(+11^trigtrc#),!
 Else  If sub=3 Do
 . Write "sub=3 " ZPrint +12^trigtrc#
 Else  Write "Error - unknown sub: ",sub,!
; $Text call reference
; ZPrint reference
>>
