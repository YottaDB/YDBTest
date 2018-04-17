/****************************************************************
 *								*
 * Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
/* This module is derived from FIS GT.M.
 ****************************************************************/

/*	gtmxc_callin.c - functions
 *
 */
#include <unistd.h>
#include "shrenv.h"
#include "gtm_stdio.h"
#include "gtm_stdlib.h"
#include "gtmxc_types.h"

/* The following code to define [U]INTPTR_T type is copied over from mdef.h */

#include <inttypes.h>

/* For all platforms except Tru64/VMS (alpha platforms), the [U]INTPTR_T types will be equivalenced to [u]intptr_t.
   But since this type is used for alignment and other checking, and since Tru64/VMS (implemented as a
   32 bit platform) unconditionally sets this type to its 8 char variant, on Tru64/VMS we will explicitly make
   [U]INTPTR_T a 4 byte creature.
*/
#ifndef __alpha
typedef intptr_t INTPTR_T;
typedef uintptr_t UINTPTR_T;
#else
typedef int INTPTR_T;
typedef unsigned int UINTPTR_T;
#endif

void **functable;
void (*setup_timer)(INTPTR_T , int , void (*)() , int , char *);
void (*stop_timer)(INTPTR_T );
void (*sleep_interrupted)(int );
void (*sleep_uninterrupted)(int );

void	init_timers ()
{
	char *start_address;

	start_address = (char *)getenv("GTM_CALLIN_START");

	if (start_address == (char *)0)
	{
		FPRINTF(stderr,"Test Failed - GTM_CALLIN_START is not set\n");
		fflush(stdout);
		return;
	}
	functable = (void **)STRTOUL(start_address, NULL, 10);
	if (functable == (void **)0)
	{
		PERROR("strtoul : ");
		FPRINTF(stderr,"Test Failed - addresss set in GTM_CALLIN_START not a number\n");
		fflush(stdout);
		return;
	}
	sleep_interrupted = (void (*)(int )) functable[0];
	sleep_uninterrupted = (void (*)(int )) functable[1];
	setup_timer = (void (*)(INTPTR_T , int, void (*)(), int , char *)) functable[2];
	stop_timer = (void (*)(INTPTR_T )) functable[3];

	return;
}


void	tst_sleep (int count, int time)
{
	(*sleep_uninterrupted)(time);
}

void timer_handler ()
{
	FPRINTF(stderr,"Timer Handler called\n");
}

void	tst_timer (int count, int time_to_int, int time_to_sleep)
{
	int timer_count;

	timer_count = 0;
	for(; timer_count < 200; ++timer_count)
		(*setup_timer)((INTPTR_T)tst_timer + timer_count, time_to_int + timer_count, timer_handler, 0, 0);
	(*sleep_interrupted)(time_to_sleep);
	(*stop_timer)((INTPTR_T)tst_timer);

	return;
}
