/* CMSC 430 Compiler Theory and Design
   Project 4 
   UMGC CITE, Summer 2023
   Robert Carswell
   5 March 2024

   Project 4 Parser with semantic actions for static semantic errors. 
   Added new tokens ELSE, ELSIF, ENDFOLD, ENDIF, FOLD, IF, LEFT, REAL, 
   RIGHT, THEN, OROP, NOTOP, MODOP, EXPOP, NEGOP    
   Added error productions to each level
   Added declareAndCheckVariable function to for duplicate scaler and list variables 
   Added grammer for if, then, else statments, and list_choice
   Modified: condition and exspression to pass types to types.cc 
   Added ANDOP | OROP | ADDOP | NOTOP | MULOP | MODOP | EXPOP | NEGOP
   operator precedence and associativity.*/

%{
#include <string>
#include <vector>
#include <map>

using namespace std;

#include "types.h"
#include "listing.h"
#include "symbols.h"

int yylex();
Types find(Symbols<Types>& table, CharPtr identifier, string tableName);
void yyerror(const char* message);
void declareAndCheckVariable(const CharPtr& identifier, const Types& type, const string& tableName, Symbols<Types>& table);

Symbols<Types> scalars;
Symbols<Types> lists;

%}

%define parse.error verbose

%union {
	CharPtr iden;
	Types type;
}

%token <iden> IDENTIFIER

%token <type> INT_LITERAL CHAR_LITERAL REAL_LITERAL

%token ADDOP MULOP RELOP ANDOP ARROW MODOP EXPOP NEGOP OROP NOTOP

%token BEGIN_ CASE CHARACTER ELSE END ENDSWITCH FUNCTION INTEGER IS LIST OF OTHERS
	RETURNS SWITCH WHEN REAL IF THEN ELSIF ENDIF FOLD ENDFOLD RIGHT LEFT

%type <type> list expressions body type statement_ statement cases case expression 
	expression1 expression2 expression3 primary variable elsifs elsif condition 
	condition1 condition2 conditions list_choice function_header variables 

%%

function:	
	function_header variables body {checkAssignment($1, $3, "Function Return");};
	
		
function_header:	
	FUNCTION IDENTIFIER RETURNS type ';' {$$ = $4;}  ;

type:
	INTEGER {$$ = INT_TYPE;} |
	CHARACTER {$$ = CHAR_TYPE;}|
	REAL {$$ = REAL_TYPE;};
	
variables:
	variables variable {$$ = $2;} |
	%empty {$$ = NONE;};

//Added and or modified checkAssignment, declareAndCheckVariable, checkListsVariable
// checkListsVariable, passes components to types.cc
variable:	
	IDENTIFIER ':' type IS statement ';' {
		checkAssignment($3, $5, "Variable Initialization"); 
		declareAndCheckVariable($1, $3, "Scalar", scalars);}|
	IDENTIFIER ':' LIST OF type IS list ';' {
		declareAndCheckVariable($1, $5, "List", lists);
		$$ = checkListsVariable ($5, $7);
		} ;

list:
	'(' expressions')' {$$ = $2;} ;

//added checkLists, passes components to types.cc
expressions:
	expressions ',' expression {$$ = checkLists($1, $3);}| 
	expression ;

body:
	BEGIN_ statement_ END ';' {$$ = $2;} ;
    
statement_:
	statement ';' {$$ = $1;}|
	error ';' {$$ = MISMATCH;} ;

//Added if and fold line, passes components to types.cc
statement:
	expression |
	WHEN condition ',' expression ':' expression 
		{$$ = checkWhen($4, $6);} |
	SWITCH expression IS cases OTHERS ARROW statement ';' ENDSWITCH 
		{$$ = checkSwitch($2, $4, $7);} |
	IF condition THEN statement ';' elsifs ELSE statement ';' ENDIF 
		{$$ = checkIf($4, $6, $8);} |
	FOLD direction operator list_choice ENDFOLD {$$ = checkFold($4);};

direction: LEFT | RIGHT ;

operator: OROP | ANDOP | NOTOP | ADDOP | MULOP | MODOP | EXPOP | NEGOP;

list_choice: 
	list | 
	IDENTIFIER {$$ = find(scalars, $1, "Scalar");};
	
elsifs:
	elsifs elsif {$$ = $2;} | 
	%empty {$$ = NONE;} ;

//Added, passes statement to if
elsif:
	ELSIF condition THEN statement ';' {$$ = $4;};

//Added checkCases, passes components to types.cc
cases:
	cases case {$$ = checkCases($1, $2);}|
	%empty {$$ = NONE;} ;

//Added production.passes statement to cases
case:
	CASE INT_LITERAL ARROW statement ';' {$$ = $4;} ; 

//Added production
condition:
	condition OROP condition1 | 
	condition1 ;

//Added production
condition1:
	condition1 ANDOP condition2 | 
	condition2 ;

//Added production
condition2:
	NOTOP conditions {$$ = $2;} | 
	conditions ;

//Added checkRelation, passes components to types.cc
conditions:
	'(' condition')' {$$ = $2;} |
	expression RELOP expression {$$ = checkRelation($1, $3);};

//Added checkArithmetic, passes components to types.cc
expression:
	expression ADDOP expression1 {$$ = checkArithmetic($1, $3);} |
	expression1 ;

//Added checkArithmetic and checkMODOP, passes components to types.cc
expression1:
	expression1 MULOP expression2 {$$ = checkArithmetic($1, $3);} | 
	expression1 MODOP expression2 {$$ = checkMODOP($1, $3);} | 
	expression2 ;


//Added checkEXPOPandNEGOP, passes components to types.cc
expression2:
	expression3 | 
	primary EXPOP expression2 {$$ = checkEXPOPandNEGOP($3);} ;

//Added checkEXPOPandNEGOP, passes components to types.cc
expression3:
	NEGOP primary {$$ = checkEXPOPandNEGOP($2);} | 
	primary ;

//Added checkListsSubscript, ombine the result of find() with the type checking result and 
//passes components to types.cc
primary:
	'(' expression ')' {$$ = $2;} |
	INT_LITERAL | REAL_LITERAL |
	CHAR_LITERAL |
	IDENTIFIER '(' expression ')' {
		$$ = find(lists, $1, "List");
		$$ = checkListsSubscript($$, $3);
		} |
	IDENTIFIER  {$$ = find(scalars, $1, "Scalar");} ;

%%

Types find(Symbols<Types>& table, CharPtr identifier, string tableName) {
	Types type;
	if (!table.find(identifier, type)) {
		appendError(UNDECLARED, tableName + " " + identifier);
		return MISMATCH;
	}
	return type;
}
//Added declareAndCheckVariable to find duplicate variable types
void declareAndCheckVariable(const CharPtr& identifier, const Types& type, const string& tableName, Symbols<Types>& table) {
    Types existing_type;
    if (table.find(identifier, existing_type)) {
        appendError(GENERAL_SEMANTIC, "Duplicate " + tableName + " " + identifier);
    } else {
        table.insert(identifier, type);
    }
}

void yyerror(const char* message) {
	appendError(SYNTAX, message);
}

int main(int argc, char *argv[]) {
	firstLine();
	yyparse();
	lastLine();
	return 0;
} 
