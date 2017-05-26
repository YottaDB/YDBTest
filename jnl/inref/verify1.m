;;; wait for ^in4 to become 1, then start the first part of the fill
	f i=1:1:1000  D
	.	i ^a(i)'=i  w " ** FAIL ",!,"^a(",i,") = ",^a(i),! q
	
