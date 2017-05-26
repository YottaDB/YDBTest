;;; wait for ^in4 to become 1, then start the first part of the fill
	f i=201:1:300  D
	.	i ^b(i)'=i  w " ** FAIL ",!,"^b(",i,") = ",^b(i),! q
	
