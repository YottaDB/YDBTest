;;; wait for ^in4 to become 1, then start the first part of the fill
	f i=10001:1:11000  D
	.	i ^b(i)'=i  w " ** FAIL ",!,"^b(",i,") = ",^b(i),! q
	
