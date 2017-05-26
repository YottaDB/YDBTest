zbtst   
        ; Set a break point on line fetching more than 8 locals
        ; We need a line fetch before such a line to avoid the bootstrap
        ; fetch all optimization
        ; For this example, ZB zbtst+6^zbtst
        N A     ; need a LINE FETCH before 
        N B,C,D,E,F,G,H,I,J     ; 9 parameters
        N K,L,M,N,O,P,Q,R     	; 8 parameters
        N S,T,U,V,W,X,Y     	; 7 parameters
        Q

main
	zb zbtst+6:"w ""zbreak succeeded at ""_$zpos,! zc"
	zb zbtst+7:"w ""zbreak succeeded at ""_$zpos,! zc"
	zb zbtst+8:"w ""zbreak succeeded at ""_$zpos,! zc"
	d zbtst
	q
