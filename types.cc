/* CMSC 430 Compiler Theory and Design
   Project 4 
   UMGC CITE, Summer 2023
   Robert Carswell
   5 March 2024

   This file contains type definitions and the function
   prototypes for the type checking functions
   Added enum: REAL_TYPE
   Added functions: checkLists, checkListsVariable, checkListsSubscript, checkRelation
   checkEXPOPandNEGOP, checkMODOP, checkIf, checkFold 
   Modified function: checkArithmetic, checkAssignment*/


#include <string>
#include <vector>

using namespace std;

#include "types.h"
#include "listing.h"

//Modified skeleton function to compare function type with variable and body statments
void checkAssignment(Types function_type, Types statement_type, string message) {
	if ((function_type != MISMATCH) && 
		(statement_type != MISMATCH) && 
		(function_type != statement_type)) {
		if ((function_type == INT_TYPE) && (statement_type == REAL_TYPE)) {
			appendError(GENERAL_SEMANTIC, "Illegal Narrowing "+ message);
		} 
		else {
			appendError(GENERAL_SEMANTIC, "Type Mismatch on " + message);
		}
	} 
}

//Skeleton function, compares a when statments true and fals expression
Types checkWhen(Types true_expression, Types false_expression) {
	if ((true_expression == MISMATCH) || (false_expression == MISMATCH))
		return MISMATCH;
	else if (true_expression == false_expression) {
		return true_expression;
	}
	else {
		appendError(GENERAL_SEMANTIC, "When Types Mismatch ");
		return MISMATCH;
	}
}

//Skeleton function, compares case statement with intergers
Types checkSwitch(Types case_statement, Types when, Types other) {
	if (case_statement == MISMATCH){
		return MISMATCH;}
	else if (case_statement == INT_TYPE) {
		return checkCases(when, other);
	}
	else {
		appendError(GENERAL_SEMANTIC, "Switch Expression Not Integer");
		return MISMATCH;
	}
}

//Skeleton function, compares the cases type with case statement type
Types checkCases(Types cases_type, Types case_statement_type) {
	if ((cases_type == MISMATCH) || (case_statement_type == MISMATCH)) {
		return MISMATCH;
	}
	else if ((cases_type == NONE) || (cases_type == case_statement_type)) {
		return case_statement_type;
	}
	else {
		appendError(GENERAL_SEMANTIC, "Case Types Mismatch");
		return MISMATCH;
	}
}

//Modified skeleton function to allow the upcast from int to real
Types checkArithmetic(Types left_expression, Types right_expression) {
	if ((left_expression == MISMATCH) || (right_expression == MISMATCH)) {
		return MISMATCH;
	}
	else if ((left_expression == INT_TYPE) && (right_expression == INT_TYPE)) {
		return INT_TYPE;
	}
	else if ((left_expression == REAL_TYPE) && (right_expression == REAL_TYPE)) {
		return REAL_TYPE;
	}
	else if (((left_expression == INT_TYPE) && (right_expression == REAL_TYPE)) || 
			((left_expression == REAL_TYPE) && (right_expression == INT_TYPE))) {
		return REAL_TYPE;
	}
	else {
		appendError(GENERAL_SEMANTIC, "Integer Type Required");
		return MISMATCH;
	}
}

//Added to check list elements types
Types checkLists(Types left_element, Types right_element) {
	if ((left_element == MISMATCH) || (right_element == MISMATCH)) {
		return MISMATCH;
	}
	else if ((left_element == NONE) || (left_element == right_element)) {
		return right_element;
	}
	else {
		appendError(GENERAL_SEMANTIC, "List Element Types Do Not Match");
		return MISMATCH;
	}
}

//Added to check variable types of list elements
Types checkListsVariable(Types list_type, Types element_type) {
	if ((list_type == MISMATCH) || (element_type == MISMATCH)) {
		return MISMATCH;
	}
	else if ((list_type == element_type)) {
		return element_type;
	}
	else {
		appendError(GENERAL_SEMANTIC, "List Type Does Not Match Element Types");
		return MISMATCH;
	}
}

//Added to check list subscript type of the list
Types checkListsSubscript(Types list_type, Types subscript_type) {
    if (list_type == MISMATCH || subscript_type == MISMATCH) {
        return MISMATCH;
    } else if (subscript_type == INT_TYPE) {
        return list_type;
    } else {
        appendError(GENERAL_SEMANTIC, "List Subscript Must Be Integer");
        return MISMATCH;
    }
}

//Added to check the type of the left and right expresion of a relation
Types checkRelation(Types left_expression, Types right_expression) {
	if ((left_expression == MISMATCH) || (right_expression == MISMATCH)) {
		return MISMATCH;
	}
	else if ((left_expression == NONE) || (left_expression == right_expression)) {
		return right_expression;
	}
	else {
		appendError(GENERAL_SEMANTIC, "Character Literals Cannot be Compared to Numeric Expressions");
		return MISMATCH;
	}
}

//Added to check the type of the operators right operand
Types checkEXPOPandNEGOP(Types right_operand) {
	if (right_operand == MISMATCH) {
		return MISMATCH;
	}
	else if ((right_operand == INT_TYPE) || (right_operand == REAL_TYPE)) {
		return right_operand;
	}
	else {
		appendError(GENERAL_SEMANTIC, "Arithmetic Operator Requires Numeric Types");
		return MISMATCH;
	}
}

//Added to check the type of the operators left and right operand
Types checkMODOP(Types left_operand, Types right_operand) {
	if ((left_operand == MISMATCH) || (right_operand == MISMATCH)) {
		return MISMATCH;
	}
	else if ((left_operand == INT_TYPE) && (right_operand == INT_TYPE)) {
		return left_operand;
	}
	else {
		appendError(GENERAL_SEMANTIC, "Remainder Operator Requires Integer Operands");
		return MISMATCH;
	}
}

//Added to check the if, elseif, else statements return type
Types checkIf(Types if_type, Types elseif_type, Types else_type) {
    if ((if_type == MISMATCH) || (elseif_type == MISMATCH) || (else_type == MISMATCH)) {
		return MISMATCH;
	}
    else if (elseif_type == NONE) {
        if (if_type == else_type) {
			return if_type;
		}
		else {
			appendError(GENERAL_SEMANTIC, "If-Elsif-Else Type Mismatch");
			return MISMATCH;
		}
    } 
	else if ((if_type == elseif_type) && (if_type == else_type) && (elseif_type == else_type)) {
		return if_type;
    }
	else {
		appendError(GENERAL_SEMANTIC, "If-Elsif-Else Type Mismatch");
		return MISMATCH;
	}
}

//Added to check the fold return type
Types checkFold(Types list) {
	if (list == MISMATCH){
		return MISMATCH;
	}
	else if ((list == INT_TYPE) || (list == REAL_TYPE) ) {
		return list;
	}
	else {
		appendError(GENERAL_SEMANTIC, "Fold Requires A Numeric List");
		return MISMATCH;
	}
}





