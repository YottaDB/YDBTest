largeexp3    ; very large / very small exponent tests 
; part 3 : These descriminate if very large exponents are handled properly 
	w "k f s f(1E1111111111111111111111)=""1Ealotalot"" zwr f",! 
	k f s f(1E1111111111111111111111)="1Ealotalot" zwr f
	w "k ^f s ^f(1E1111111111111111111111)=""1Ealotalot"" zwr ^f",! 
	k ^f s ^f(1E1111111111111111111111)="1Ealotalot" zwr ^f
    Q
