largeexp2    ; very large / very small exponent tests 
; part 2 : errors expected on all 
	w "k f s f(1E111)=""1E111"" zwr f",! 
	k f s f(1E111)="1E111" zwr f
	w "k f s f(1E11111111111111111)=""1Ealot"" zwr f",! 
	k f s f(1E11111111111111111)="1Ealot" zwr f
	w "k f s f(1E1111111111111111111111)=""1Ealotalot"" zwr f",! 
	k f s f(1E1111111111111111111111)="1Ealotalot" zwr f
	w "k ^f s ^f(1E111)=""1E111"" zwr ^f",! 
	k ^f s ^f(1E111)="1E111" zwr ^f
	w "k ^f s ^f(1E11111111111111111)=""1Ealot"" zwr ^f",! 
	k ^f s ^f(1E11111111111111111)="1Ealot" zwr ^f
	w "k ^f s ^f(1E1111111111111111111111)=""1Ealotalot"" zwr ^f",! 
	k ^f s ^f(1E1111111111111111111111)="1Ealotalot" zwr ^f
	w "s x=1E111 w x,!",! s x=1E111 w x,!
	w "s x=1E11111111111111111 w x,!",! s x=1E11111111111111111 w x,!
	w "s x=1E47 w x,!",! s x=1E47 w x,!
    Q
