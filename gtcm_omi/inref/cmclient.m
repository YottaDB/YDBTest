;	Initialize a GT.CM client
;
;	Parameters
;	  user		user id of client
;	  group		group id of client
;	  env		server environment (path to the global directory to use)
;
;	Return value
;	  n/a
;
cmclient(user,group,env)
;	w "user = ",user,!
;	w "group = ",group,!
;	w "env = ",env,!
	do init^cminit(env)
	do hdrinit^header(user,group)
	q

	
