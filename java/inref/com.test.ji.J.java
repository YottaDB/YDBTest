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

/**
 * A set of functions that have to do with generation of Java-related constructs.
 */
public class J {
	public static String genArgInit(String argName, String argType, String argValue) {
		return argType + " " + argName + " = new " + argType + "(" + argValue + ");";
	}

	public static String genArgInitNull(String argName, String argType) {
		return argType + " " + argName + " = null;";
	}

	public static String genArgCast(String argName, String argType, int argIndex) {
		return argType + " " + argName + " = (" + argType + ")args[" + argIndex + "];";
	}
}
