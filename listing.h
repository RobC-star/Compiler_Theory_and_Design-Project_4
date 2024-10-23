/* CMSC 430 Compiler Theory and Design
   Project 4 
   UMGC CITE, Summer 2023
   Robert Carswell
   5 March 2024

   No Change*/

enum ErrorCategories {LEXICAL, SYNTAX, GENERAL_SEMANTIC, DUPLICATE_IDENTIFIER,
	UNDECLARED};

void firstLine();
void nextLine();
int lastLine();
void appendError(ErrorCategories errorCategory, string message);

