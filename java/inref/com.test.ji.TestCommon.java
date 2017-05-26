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
package com.test.ji;

import java.text.DecimalFormat;
import java.util.Random;

/**
 * Common final definitions used in both TestCI and TestXC classes.
 */
public class TestCommon {
	public static final Random rand = new Random();
	public static final DecimalFormat F5 = new DecimalFormat(".#####");
	public static final DecimalFormat F6 = new DecimalFormat(".######");
	public static final DecimalFormat D14 = new DecimalFormat(".##############");
	public static final DecimalFormat D15 = new DecimalFormat(".###############");

	public static final double M_MIN = 1E-18;
	public static final double M_LIMIT = 1E43;

	public static final String[] STRING_ARGS = new String[] {
		"", "abcd", "~!@#$%^&*()_+-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", "\u0438\u0432\u0430\u043d"};
	public static final int STRING_ARGS_LENGTH = STRING_ARGS.length;
}
