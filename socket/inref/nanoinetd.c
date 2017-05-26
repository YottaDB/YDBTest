/****************************************************************
*								*
*	Copyright 2013 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <assert.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define USAGE	fprintf(stderr, "usage: %s portno command [arg0 .. argn]\n", argv[0])

/* Keep in sync with gtm_ipv6.h */
#if (defined(__hppa) || defined(__vms) || defined(__osf__))
#define LISTEN_AF	AF_INET
#define HINT_FLAGS	(AI_PASSIVE)
#elif (defined(AI_V4MAPPED) && defined(AI_NUMERICSERV))
#define LISTEN_AF	AF_INET6
#define HINT_FLAGS	(AI_PASSIVE | AI_NUMERICSERV | AI_V4MAPPED)
#else
#define LISTEN_AF	AF_UNSPEC
#define HINT_FLAGS	(AI_PASSIVE)
#endif

/* Keep in sync with gtm_socket.h */
#if defined(__osf__) && defined(__alpha)
#define GTM_SOCKLEN_TYPE size_t
#else
#define GTM_SOCKLEN_TYPE socklen_t
#endif

int main(int argc, char* argv[])
{
	int				status;
	char				*port;
	int				sl, sc;
	int				arg;
	char				*cmd;
	char				**args;
	struct addrinfo			hints, *ai;
	struct sockaddr_storage		sa;
	GTM_SOCKLEN_TYPE		salen;

	if (argc < 3)
	{
		USAGE;
		exit(1);
	}

	port = argv[1];
	cmd = argv[2];

	args = (char **) malloc(sizeof(char *) * (argc-1));

	args[0] = strdup(cmd);
	for(arg = 1; arg < argc-1; arg++)
	{
		args[arg] = argv[arg+2] ? strdup(argv[arg+2]) : NULL;
	}

	sl = socket(LISTEN_AF, SOCK_STREAM, 0);
	assert(sl > 0);

	memset(&hints, 0, sizeof(hints));
	hints.ai_family = LISTEN_AF;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_protocol = 0;
	hints.ai_flags = HINT_FLAGS;

	status = getaddrinfo(NULL, port, &hints, &ai);
	assert(status == 0);

	status = bind(sl, ai->ai_addr, ai->ai_addrlen);
	assert(status == 0);

	status = listen(sl, 1);
	assert(status == 0);

	salen = sizeof(sa);
	memset(&sa, 0, salen);
	sc = accept(sl, (struct sockaddr *) &sa, &salen);
	assert(sc > 0);

	dup2(sc, 0);
	dup2(sc, 1);
	dup2(sc, 2);
	close(sc);

	execvp(cmd, args);
	assert(0);
}
