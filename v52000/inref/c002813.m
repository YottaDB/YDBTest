c002813 ;
	; ------------------------------------------------------------------------------------------------------
	; C9G12-002813 [Narayanan] Pattern match fails with 2 unbounded patterns where 2nd lower bound is >= 9
	; ------------------------------------------------------------------------------------------------------
        set val="1."
        for trailing=1:1:15 set val=val_(trailing#10) write !,trailing,?5,val do
        .       for i=1:1:trailing+10 set patt=".1""-"".n1""."""_i_".n" do
        .       .       set expected='(i>trailing),test=val?@patt write:test'=expected !,val,"?",patt,"=",test,":Expected=",1-test
        quit
