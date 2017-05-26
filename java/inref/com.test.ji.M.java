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

import java.util.HashSet;

/**
 * A set of (though currently only one) functions that have to do with generation of M-related constructs.
 */
public class M {
	private static HashSet<String> mVarNames = new HashSet<String>();

	public static String genVarName(boolean global) {
		StringBuilder builder = new StringBuilder();

		do {
			int length = 3 + (int)(Math.random() * 7);
			builder = new StringBuilder(length);

			if (global)
				builder.append("^");

			for (int i = 0; i < length; i++)
				builder.append((char)(97 + (int)(Math.random() * 26)));
		} while (mVarNames.contains(builder.toString()));

		return builder.toString();
	}
}
