largeexp1    ; very large / very small exponent tests 
; Also check D9E08-002478
; part 1 : no errors expected 
	w "k f s f(1E11)=""1E11"" zwr f",! k f s f(1E11)="1E11" zwr f
	w "k ^f s ^f(1E11)=""1E11"" zwr ^f",! k ^f s ^f(1E11)="1E11" zwr ^f 
	w "s x=1E11 w x,!",! s x=1E11 w x,!
	w "s x=1E46 w x,!",! s x=1E46 w x,!
	w "s x=1E-11 w x,!",! s x=1E-11 w x,!
	w "s x=1E-111 w x,!",! s x=1E-111 w x,!
	w "s x=1E-11111111111111111 w x,!",! s x=1E-11111111111111111 w x,! 
	w "s x=1E-40 w x,!",! s x=1E-40 w x,!
	w "s x=1E-41 w x,!",! s x=1E-41 w x,!
	w "s x=1E-42 w x,!",! s x=1E-42 w x,!
	w "s x=1E-43 w x,!",! s x=1E-43 w x,!
	w "s x=1E-44 w x,!",! s x=1E-44 w x,!
	w "s x=1E-45 w x,!",! s x=1E-45 w x,!
	w "s x=1E-46 w x,!",! s x=1E-46 w x,!
	w "s x=1E-47 w x,!",! s x=1E-47 w x,!
	w "s ^x(""1E60"",1)=23 zwr ^x(""1E60"",*)",! s ^x("1E60",1)=23 zwr ^x("1E60",*)
    Q
