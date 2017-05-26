	f i=1:1:10 d A8
	q
A8 S D=""
 F J=81:1:90 S D=D_"A" F I=71:1:90 S S=$C(J)_$C(I)_"=D",@S
 K I,J,D Q
