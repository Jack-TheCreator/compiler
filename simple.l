%{
#include <stdio.h>
#include "simple.tab.h"
%}

double  [0-9]+\.[0-9]+
linenumber [0-9]+":"
int	"integer"
dub	"double"
str	"string"
as	"as"
array	"array"
dim	"dim"
goto    "goto"
print	"print"
assign	":="
of	"of"
plus	"+"
minus	"-"
times	"*"
divides "/"
integer [0-9]+
string  \"(.)*\"
arrvar	[a-zA-Z][a-zA-Z0-9]*\([0-9]+\)
arrvarref  [a-zA-Z][a-zA-Z0-9]*\([a-zA-Z][a-zA-Z0-9]*\)
varname [a-zA-Z][a-zA-Z0-9]*
input	"input"
greater ">"
less	"<"
if	"if"

%%
{if}		{
			return IF;
		}
{greater}	{
			return GREATER;
		}
{less}		{
			return LESS;
		}
{plus}		{
			return PLUS;
		}
{minus}		{
			return MINUS;
		}
{times}		{
			return TIMES;
		}
{divides}	{
			return DIVIDES;
		}
{input}		{
			return INPUT;
		
		}
{arrvarref}	{
			yylval.string = strdup(yytext);
			return ARRVARREF;
		}

{arrvar}	{
			//print("arrvar");
			yylval.string = strdup(yytext);
			return ARRVAR;
		}

{linenumber}	{
			//printf("l");
			yylval.string = strdup(yytext);
			return LINENUMBER;
		}

{goto}		{
			//printf("g");
			return GOTO;
		}	
		
{array}		{
			return ARRAY;
		}

{print}		{
			//printf("p");
			return PRINT;
		}

{string}	{
			//printf("s");
			yylval.string = strdup(yytext);
			return STRING;
		}

{integer}	{
			//printf("i");
			yylval.value = atoi(yytext);
			return INTEGER;
		}

{double}	{
			//printf("d");
			yylval.dvalue = atof(yytext);
			return DOUBLE;
		}



{assign}	{
			//printf("a");
			return ASSIGN;
		}


{dim}		{
			//printf("dim");
			return DIM;
		}
{of}		{
			return OF;
		}

{int}		{
			//printf("int");
			return INT;
		}


{dub}		{
			//printf("dub");
			return DUB;
		}


{str}		{
			//printf("str");
			return STR;
		}


{as}		{
			//printf("as");
			return AS;
		}

{varname}       {
                        //printf("v");
                        yylval.string = strdup(yytext);
                        return VARNAME;
                }

[\n\t\r]	{}
.		{}
%%


