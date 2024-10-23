/* CMSC 430 Compiler Theory and Design
   Project 4 
   UMGC CITE, Summer 2023
   Robert Carswell
   5 March 2024

   This file contains type definitions and the function
   prototypes for the type checking functions
   Added enum: REAL_TYPE
   Added function: checkLists, checkListsVariable, checkListsSubscript, checkRelation
   checkEXPOPandNEGOP, checkMODOP, checkIf, checkFold */

typedef char* CharPtr;

enum Types {MISMATCH, INT_TYPE, CHAR_TYPE, NONE, REAL_TYPE};

void checkAssignment(Types function_type, Types statement_type, string message);
Types checkWhen(Types true_expression, Types false_expression);
Types checkSwitch(Types case_statement, Types when, Types other);
Types checkCases(Types cases_type, Types case_statement_type);
Types checkArithmetic(Types left_expression, Types right_expression);
Types checkLists(Types left_element, Types right_element);
Types checkListsVariable(Types list_type, Types element_type);
Types checkListsSubscript(Types list_type, Types subscript_type);
Types checkRelation(Types left_expression, Types right_expression);
Types checkEXPOPandNEGOP(Types right_operand);
Types checkMODOP(Types left_operand, Types right_operand);
Types checkIf(Types if_type, Types elseif_type, Types else_type) ;
Types checkFold(Types list);