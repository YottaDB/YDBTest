mmaxstr(str);; 
     ; The line below is to test if the M-local variable set by the previous gtm_ci invocation is visible to subsequent calls
     if $data(length) write "string length of the previous call :",length,!
     ;
     set length=$length(str)
     w "length of str: ",length,!
     set mstr="" for i=1:1:$length(str) set mstr=mstr_"A"
     if mstr=str write "M got the correct string",!
     else  write "M got the wrong string",!
     use $P
     q
