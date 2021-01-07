%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  #define noop 0
  #define gotoi 1
  #define printi 2
  #define decinti 3
  #define decdubi 4
  #define decstri 5
  #define assinti 6
  #define assdubi 7
  #define assstri 8
  #define printvari 9
  #define decarri 10
  #define decarrd 11
  #define decarrs 12
  #define getinput 13
  #define arrvar 14
  #define greatercomp 15
  #define lesscomp 16
  #define printarrref 17

  int yylex();
  void yyerror(const char*);
  void gotoinstruction(char*,char*);
  void printinstruction(char*,char*);	
  void decinstruction(char*,char*,int); 
  int checknameexists(char*);
  void assint(char*, char*, int);
  void assdub(char*, char*, double);
  void assstr(char*, char*,char*);
  void printvar(char*, char*);
  int getnameindex(char*);
  void decarray(char*, char*, int, int);
  void inputinstruction(char*, char*);
  void arrbyvar(char* , char*, char*);
  void greatercompare(char*, char*, int val, char*);
  void printarr(char*, char*);  

  struct ins
  {
    int opcode;
    char *s;
    int ival;
    double dval;
    char *sval;
  };
  struct vars
  {
    char *varname;
    int type;
    int ival;
    double dval;
    char *sval;
  };
%}

%union
{
	char *string;
	int value;
	double dvalue;
}

%token INPUT
%token <string>LINENUMBER;
%token GOTO
%token <string>STRING;
%token PRINT
%token <value>INTEGER;
%token <dvalue>DOUBLE;
%token INT
%token DUB
%token DIM
%token AS
%token ASSIGN
%token STR
%token OF
%token <string>VARNAME;
%token ARRAY
%token <string>ARRVAR;
%token PLUS
%token MINUS
%token TIMES
%token DIVIDES
%token GREATER
%token LESS
%token IF
%token <string>ARRVARREF;
%%

exp: exp inst | inst;

inst: goto_exp | printarr_exp | greater_exp | arrbyvar_exp | input_exp | printarrvar_exp |  printvar_exp |  print_exp | decint_exp | decdub_exp | decstr_exp | decarri_exp | decarrd_exp | decarrs_exp | assint_exp | assdub_exp | assstr_exp | assarri_exp | assarrd_exp | assarrs_exp;

input_exp:
	LINENUMBER INPUT AS VARNAME
	{
		//printf("go");
		inputinstruction($1, $4);
	}
greater_exp:
	LINENUMBER IF VARNAME GREATER INTEGER GOTO LINENUMBER
	{
		greatercompare($1, $3, $5, $7);
	}
print_exp:
	LINENUMBER PRINT STRING
	{
		//printf("print call");
		printinstruction($1, $3);
	}
goto_exp:
	LINENUMBER GOTO LINENUMBER
	{
		gotoinstruction($1, $3);
	}
decint_exp:
	LINENUMBER DIM VARNAME AS INT
	{
		//printf("why u running");
		decinstruction($1, $3, decinti);
	}
decdub_exp:
	LINENUMBER DIM VARNAME AS DUB
	{
		//printf("fojeioj");
		decinstruction($1, $3, decdubi);
	}
decstr_exp:
	LINENUMBER DIM VARNAME AS STR
	{
		//printf("do");
		decinstruction($1, $3, decstri);
	}
assint_exp:
	LINENUMBER VARNAME ASSIGN INTEGER
	{
		assint($1, $2, $4);
	}
assdub_exp:
	LINENUMBER VARNAME ASSIGN DOUBLE
	{
		assdub($1, $2, $4);
	}
assstr_exp:
	LINENUMBER VARNAME ASSIGN STRING
	{
		assstr($1, $2, $4);
	}
printarrvar_exp:
	LINENUMBER PRINT ARRVAR
	{
		printvar($1, $3);
	}
printvar_exp:
	LINENUMBER PRINT VARNAME
	{
		printvar($1, $3);
	}
decarri_exp:
	LINENUMBER DIM VARNAME AS ARRAY OF INT INTEGER
	{
		decarray($1, $3, $8, decarri); 
	}
decarrd_exp:
        LINENUMBER DIM VARNAME AS ARRAY OF DUB INTEGER
        {
		decarray($1, $3, $8, decarrd);
        }
decarrs_exp:
        LINENUMBER DIM VARNAME AS ARRAY OF STR INTEGER
        {
		decarray($1, $3, $8, decarrs);
        }
assarri_exp:
	LINENUMBER ARRVAR ASSIGN INTEGER
	{
		assint($1, $2, $4);
	}
assarrd_exp:
	LINENUMBER ARRVAR ASSIGN DOUBLE
	{
		assdub($1, $2, $4);
	}
assarrs_exp:
	LINENUMBER ARRVAR ASSIGN STRING
	{
		assstr($1, $2, $4);
	}
arrbyvar_exp:
	LINENUMBER ARRVAR ASSIGN VARNAME
	{
		arrbyvar($1, $2, $4);
	}
printarr_exp:
	LINENUMBER PRINT ARRVARREF
	{
		printarr($1, $3);
	}

%%


struct ins instruction[100];
struct vars variables[10000];
int numvars = 0;

int main(int argc, char *argv[])
{
	char arrstr[20];
	char sint[10];
	char basestring[20];
        char numstr[10];
	char *cc;
	FILE *fp;
	int i = 0;
	extern FILE *yyin;
	extern int yyparse();
	int index = -1;
	int index2 = -1;
	char *token;
        char *search = "(";
	for(int i=0; i<100; i++)
		instruction[i].opcode = noop;

	if(argc > 1)
	{
		if((fp = fopen(argv[1], "r"))==0)
		{
			printf("could not open %s\n", argv[1]);
		}
		else
		{
			yyin = fp;
			yyparse();
			while(i<100)
			{
				
				//printf("%d\n%s\n",instruction[i].opcode,instruction[i].s);
				switch(instruction[i].opcode)
				{
					case printi:
						//printf("caddd");
						printf("%s\n", instruction[i].s);
						break;
					case gotoi:
						cc = instruction[i].s;
						cc[strlen(cc)-1] = 0;
        					i = atoi(cc);
						i--;
						//printf("lineNumber %d\n", i);
						break;
					case getinput:
						if(checknameexists(instruction[i].s)==0){
							index = getnameindex(instruction[i].s);
							printf("enter input: ");
							if(variables[index].type == 0)
                                                                scanf("%d",&variables[index].ival);
                                                        if(variables[index].type == 1)
                                                                scanf("%lf",&variables[index].dval);
                                                        if(variables[index].type == 2)
                                                                scanf("%s",variables[index].sval);
						}
						else{
							yyerror("Variable takking input not declared");
						}
						break;
					case decinti:
						//printf("odoo");
						if(checknameexists(instruction[i].s)==0){
							//printf("gejiro");
							yyerror("variable already declared");
						}
						else{
							//printf("cowww");
							variables[numvars].varname = instruction[i].s;
							variables[numvars].type = 0;
							numvars++;
						}
						break;
					case decdubi:
						//printf("&&&&");
						if(checknameexists(instruction[i].s)==0)
                                                        yyerror("variable already declared");
                                                else{
							variables[numvars].varname = instruction[i].s;
							variables[numvars].type = 1;
							numvars++;
                                                }
						break;
					case decstri:
						//printf("^^^^");				
						if(checknameexists(instruction[i].s)==0)
                                                        yyerror("variable already declared");
                                                else{
							variables[numvars].varname = instruction[i].s;
							variables[numvars].type = 2;
							numvars++;
                                                }
						break;
					case assinti:
						
						index = getnameindex(instruction[i].s);
						if(index==-1)
							yyerror("var hasn't been declared");
						else{
							if(variables[index].type == 0){
								variables[index].ival = instruction[i].ival;
							}
							else{
								yyerror("value is not same type as variable");
							}
						}
						break;
					case assdubi:
						
                                                index = getnameindex(instruction[i].s);
                                                if(index==-1)
                                                        yyerror("var hasn't been declared");
                                                else{
							if(variables[index].type == 1){
								variables[index].dval = instruction[i].dval;
							}
							else{
								yyerror("value is not same type as variable");
							}
                                                }
						break;
					case decarri:
						for(int j=0; j<instruction[i].ival; j++){
							sprintf(numstr, "%d", j);
							strcpy(basestring, instruction[i].s);
							strcat(basestring, "(");
							strcat(basestring, numstr);
							strcat(basestring, ")");
							variables[numvars].varname = malloc(sizeof(char) * (strlen(basestring) + 1));
							strcpy(variables[numvars].varname, basestring);
							variables[numvars].type = 0;
							numvars++;
						}
						break;
					case decarrd:
                                                for(int j=0; j<instruction[i].ival; j++){
                                                        sprintf(numstr, "%d", j);
                                                        strcpy(basestring, instruction[i].s);
                                                        strcat(basestring, "(");
                                                        strcat(basestring, numstr);
                                                        strcat(basestring, ")");
							variables[numvars].varname = malloc(sizeof(char) * (strlen(basestring) + 1));
                                                        strcpy(variables[numvars].varname, basestring);
                                                        variables[numvars].type = 1;
                                                        numvars++;
                                                }
                                                break;
					case decarrs:
                                                for(int j=0; j<instruction[i].ival; j++){
                                                        sprintf(numstr, "%d", j);
                                                        strcpy(basestring, instruction[i].s);
                                                        strcat(basestring, "(");
                                                        strcat(basestring, numstr);
                                                        strcat(basestring, ")");
							variables[numvars].varname = malloc(sizeof(char) * (strlen(basestring) + 1));
                                                        strcpy(variables[numvars].varname, basestring);
                                                        variables[numvars].type = 2;
                                                        numvars++;
                                                }
                                                break;
					case greatercomp:
						index = getnameindex(instruction[i].s);
                                                if(index==-1)
                                                        yyerror("var hasn't been declared");
                                                else{
							if(variables[index].ival > instruction[i].ival){
								cc = instruction[i].sval;
                                                		cc[strlen(cc)-1] = 0;
                                                		i = atoi(cc);
                                                		i--;
							}
						}
						break;
					case arrvar:
						index = getnameindex(instruction[i].s);
                                                if(index==-1)
                                                        yyerror("var hasn't been declared");
                                                else{
							index2 = getnameindex(instruction[i].sval);
							if(index2==-1)
								yyerror("var not declared");
							else{
								if(variables[index].type == 0)
                                                     			variables[index].ival = variables[index2].ival;
                                                        	if(variables[index].type == 1)
                                                                	variables[index].dval = variables[index2].dval;
                                                        	if(variables[index].type == 2)
                                                                	variables[index].sval = variables[index2].sval;	
							}
						}
						break;
					case printarrref:
						index = getnameindex(instruction[i].s);
						if(index==-1)
                                                        yyerror("var hasn't been declared");
						else{
							index = variables[index].ival;
							token = strtok(instruction[i].sval, "(");
							strcpy(arrstr, token);
							strcat(arrstr, "(");
							sprintf(sint,"%d",index);
							strcat(arrstr, sint);
							strcat(arrstr, ")");
							index = getnameindex(arrstr);
							if(index==-1)
                                                        	yyerror("var hasn't been declared");
                                                	else{
                                                        	if(variables[index].type == 0)
                                                                	printf("%d\n", variables[index].ival);
                                                        	if(variables[index].type == 1)
                                                                	printf("%f\n", variables[index].dval);
                                                        	if(variables[index].type == 2)
                                                                	printf("%s\n", variables[index].sval);
                                                }
						}
						break;
									
					case assstri:
						
                                                index = getnameindex(instruction[i].s);
                                                if(index==-1)
                                                        yyerror("var hasn't been declared");
                                                else{
							if(variables[index].type == 2){
								variables[index].sval = instruction[i].sval;
							}
							else{	
								yyerror("value is not same type as variable");
							}
                                                }
						break;
					case printvari:
						
                                                index = getnameindex(instruction[i].s);
                                                if(index==-1)
                                                        yyerror("var hasn't been declared");
                                                else{
							if(variables[index].type == 0)
								printf("%d\n", variables[index].ival);	
							if(variables[index].type == 1)
								printf("%f\n", variables[index].dval);
							if(variables[index].type == 2)
								printf("%s\n", variables[index].sval);
						}
						break;
				}
				i++;
			}
		}
	}
	else
	{
		printf("Usage: %s <filename>\n", argv[0]);
	}
}
void decarray(char *s1, char *s2, int val, int oc)
{
	s1[strlen(s1)-1] = 0;
        int l = atoi(s1);
	if(instruction[l].opcode == noop){
		instruction[l].opcode = oc;
		instruction[l].s = s2;
		instruction[l].ival = val;
	}		
}

void printinstruction(char *s1, char *s2)
{
	
	s1[strlen(s1)-1] = 0;
	int l = atoi(s1);
	if(instruction[l].opcode == noop){
		//printf("%d\n",l);
		instruction[l].opcode = printi;
		instruction[l].s = s2;
	}
	else
	{
		yyerror("Line Number Duplicate");
	}	
}
void gotoinstruction(char *s1, char *s2)
{
        s1[strlen(s1)-1] = 0;
        int l = atoi(s1);
        if(instruction[l].opcode == noop){
                instruction[l].opcode = gotoi;
                instruction[l].s = s2;
        }
        else
        {
                yyerror("Line Number Duplicate");
        }
}
void printarr(char *s1, char *s2)
{
	s1[strlen(s1)-1] = 0;
        int l = atoi(s1);
	char *token;
	char *search = "(";
	if(instruction[l].opcode == noop){
		token = strtok(s2, search);
		token = strtok(NULL, search);
		token[strlen(token)-1] = 0;
		instruction[l].opcode = printarrref;
		instruction[l].s = token;
		instruction[l].sval = s2;
	}
	else
	{
		yyerror("Line Number Duplicate");
	}
}
void decinstruction(char *s1, char *s2, int oc)
{
	s1[strlen(s1)-1] = 0;
	int l = atoi(s1);
	if(instruction[l].opcode == noop){
		instruction[l].opcode = oc;
		instruction[l].s = s2;
	}
	else
	{
		yyerror("Line Number Duplicate");
	}
}
void inputinstruction(char *s1, char *s2){
	s1[strlen(s1)-1] = 0;
        int l = atoi(s1);
	if(instruction[l].opcode == noop){
		instruction[l].opcode = getinput;
		instruction[l].s = s2;
	}
	else
	{
		yyerror("Line NUmber Duplicate");
	}
}
int checknameexists(char *s)
{
	for(int i=0; i<numvars; i++){
		//printf("\n%s\n",s);
		//printf("%s\n",variables[i].varname);
		if(strcmp(s, variables[i].varname)==0)
			return 0;
	}
	return 1;
}
void assint(char *s1, char *s2, int val){
	s1[strlen(s1)-1] = 0;
        int l = atoi(s1);
        if(instruction[l].opcode == noop){
                instruction[l].opcode = assinti;
                instruction[l].s = s2;
		instruction[l].ival = val;
        }
        else
        {
                yyerror("Line Number Duplicate");
        }
} 
void assdub(char *s1, char *s2, double val){
	s1[strlen(s1)-1] = 0;
        int l = atoi(s1);
        if(instruction[l].opcode == noop){
                instruction[l].opcode = assdubi;
                instruction[l].s = s2;
		instruction[l].dval = val;
        }
        else
        {
                yyerror("Line Number Duplicate");
        }
}
void assstr(char *s1, char *s2, char *val){
	s1[strlen(s1)-1] = 0;
        int l = atoi(s1);
        if(instruction[l].opcode == noop){
                instruction[l].opcode = assstri;
                instruction[l].s = s2;
		instruction[l].sval = val;
        }
        else
        {
                yyerror("Line Number Duplicate");
        }
}
void greatercompare(char *s1, char *s2, int val, char *linenum){
	s1[strlen(s1)-1] = 0;
        int l = atoi(s1);
	if(instruction[l].opcode == noop){
		instruction[l].opcode = greatercomp;
		instruction[l].s = s2;
		instruction[l].sval = linenum;
		instruction[l].ival = val; 
	}
	else
	{
		yyerror("line num dup");
	}
}
void arrbyvar(char *s1, char *s2, char *s3){
	s1[strlen(s1)-1] = 0;
        int l = atoi(s1);
	if(instruction[l].opcode == noop){
		instruction[l].opcode = arrvar;
		instruction[l].s = s2;
		instruction[l].sval = s3;
	}
	else
	{
		yyerror("Line NUm Dupe");
	}
}
void printvar(char *s1, char *s2){
	s1[strlen(s1)-1] = 0;
        int l = atoi(s1);
        if(instruction[l].opcode == noop){
                instruction[l].opcode = printvari;
                instruction[l].s = s2;
        }
        else
        {
                yyerror("Line Number Duplicate");
        }
}
int getnameindex(char *name){
	int index = -1;
	for(int i=0; i<numvars; i++){
		if(strcmp(name, variables[i].varname)==0)
			index = i;
	}

	return index;
}

void yyerror(const char *err)
{
	printf("ERROR: %s\n", err);
	exit(0);
}
