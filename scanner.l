/* CMSC 430 Compiler Theory and Design
   Project 4 
   UMGC CITE, Summer 2023
   Robert Carswell
   5 March 2024
   
   This file contains the Project 4 flex input file. This file contains flex 
   input file with the following changes were made during Project 1 and 2. 
   Both which are    identified below modified lexeme and operator. Some are 
   not listed because of comment errors but I addedd integer and updated comment 
   literals to include the regex. */

%{
#include <cstdio>
#include <string>
#include <vector>

using namespace std;

#include "types.h"
#include "listing.h"
#include "tokens.h"

%}

%option noyywrap

ws		[ \t\r]+
comment		(?:\/\/|--).*\n
line		[\n]
id		[A-Za-z](_{0,2}[A-Za-z0-9])*
digit		[0-9]
dec		{digit}+
char		('.'|'\\b'|'\\t'|'\\n'|'\\r'|'\\f')
punc		[\(\),:;]
reals	[0-9]*\.[0-9]+([Ee]([+-]?[0-9]+)?)?
integers		[?<=#][A-Fa-f0-9]([A-Fa-f0-9])*
%%

{ws}		{ ECHO; }
{comment}	{ ECHO; nextLine(); }
{line}		{ ECHO; nextLine(); }
"+"		{ ECHO; return(ADDOP); }
"*"		{ ECHO; return(MULOP); }
"&"		{ ECHO; return(ANDOP); }
"<"		{ ECHO; return(RELOP); }
"=>"		{ ECHO; return(ARROW); }
begin		{ ECHO; return(BEGIN_); }
case		{ ECHO; return(CASE); }
character	{ ECHO; return(CHARACTER); }
end		{ ECHO; return(END); }
endswitch	{ ECHO; return(ENDSWITCH); }
function	{ ECHO; return(FUNCTION); }
integer		{ ECHO; return(INTEGER); }
is		{ ECHO; return(IS); }
list		{ ECHO; return(LIST); }
of		{ ECHO; return(OF); }
others		{ ECHO; return(OTHERS); }
returns		{ ECHO; return(RETURNS); }
switch		{ ECHO; return(SWITCH); }
when		{ ECHO; return(WHEN); }

real		{ ECHO; return(REAL); } //added project 1

if		   { ECHO; return(IF); } //added project 1
then		{ ECHO; return(THEN); } //added project 1
else		{ ECHO; return(ELSE); } //added project 1
elsif		{ ECHO; return(ELSIF);}  //added project 1
endif		{ ECHO; return(ENDIF); } //added project 1

"|"		{ ECHO; return(OROP); } //added project 1
"!"		{ ECHO; return(NOTOP); } //added project 1

"="		{ ECHO; return(RELOP); } //added project 1
"<>"		{ ECHO; return(RELOP); } //added project 1
">"		{ ECHO; return(RELOP); } //added project 1
">="		{ ECHO; return(RELOP); } //added project 1
"<="		{ ECHO; return(RELOP); } //added project 1

"-"		{ ECHO; return(ADDOP); } //added project 1

"/"		{ ECHO; return(MULOP); } //added project 1

"%"		{ ECHO; return(MODOP); } //updated project 2

"^"		{ ECHO; return(EXPOP); } //added project 1

"~"		{ ECHO; return(NEGOP); } //added project 1

fold		{ ECHO; return(FOLD); } //added project 1
endfold	{ ECHO; return(ENDFOLD); } //added project 1
left		{ ECHO; return(LEFT); } //added project 1
right		{ ECHO; return(RIGHT); } //added project 1

{reals} { ECHO; yylval.type = REAL_TYPE; return(REAL_LITERAL);}
{integers} { ECHO; yylval.type = INT_TYPE; return(INT_LITERAL); }

{id}		{ ECHO; yylval.iden = (CharPtr)malloc(yyleng + 1); 
			strcpy(yylval.iden, yytext); return(IDENTIFIER);}
{dec}		{ ECHO; yylval.type = INT_TYPE; return(INT_LITERAL); }
{char}		{ ECHO; yylval.type = CHAR_TYPE; return(CHAR_LITERAL); }
{punc}		{ ECHO; return(yytext[0]); }
.		{ ECHO; appendError(LEXICAL, yytext); }
%%
