;;; wait for ^in4 to become 1, then start the first part of the fill
	f i=1:1:500  D
	.	i ^a(i)'=i  w " ** FAIL ",!,"^a(",i,") = ",^a(i),! q
	.	i ^b(i)'=i  w " ** FAIL ",!,"^b(",i,") = ",^a(i),! q
	.	i ^c(i)'=i  w " ** FAIL ",!,"^b(",i,") = ",^a(i),! q
	.	i ^d(i)'=i  w " ** FAIL ",!,"^b(",i,") = ",^a(i),! q
