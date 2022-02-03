%{
#include <stdio.h>
#include "alfa.h"
#include "y.tab.h"

void _print_token(FILE * out) {
    fprintf(out, ";D:\t%s\n", yytext);
}

extern FILE * yyout;
long yylin = 1;
long yycol = 0;
int yy_morph_error = 0;
%}

%option noyywrap
ESPACIO 		[ \t]+
SALTOLINEA	\n|\n\r|\r
COMENTARIOS "//".*\n
ID		[a-zA-Z]([a-zA-Z0-9]){0,99}
CTE_ENTERA  [0-9]+
ERROR_LONG  [a-zA-Z]([a-zA-Z0-9]){100,}
ERROR		.

%%
{ESPACIO} {yycol += yyleng;}
{SALTOLINEA}	{yycol = 0; yylin += 1;}
{COMENTARIOS}	{yycol = 0; yylin += 1;}

main {yycol += yyleng; _print_token(yyout); return TOK_MAIN;}
int {yycol += yyleng; _print_token(yyout); return TOK_INT;}
boolean {yycol += yyleng; _print_token(yyout); return TOK_BOOLEAN;}
array {yycol += yyleng; _print_token(yyout); return TOK_ARRAY;}
function {yycol += yyleng; _print_token(yyout); return TOK_FUNCTION;}
if {yycol += yyleng; _print_token(yyout); return TOK_IF;}
else {yycol += yyleng; _print_token(yyout); return TOK_ELSE;}
while {yycol += yyleng; _print_token(yyout); return TOK_WHILE;}
scanf {yycol += yyleng; _print_token(yyout); return TOK_SCANF;}
printf {yycol += yyleng; _print_token(yyout); return TOK_PRINTF;}
return {yycol += yyleng; _print_token(yyout); return TOK_RETURN;}

";" {yycol += yyleng; _print_token(yyout); return TOK_PUNTOYCOMA;}
"," {yycol += yyleng; _print_token(yyout); return TOK_COMA;}
"(" {yycol += yyleng; _print_token(yyout); return TOK_PARENTESISIZQUIERDO;}
")" {yycol += yyleng; _print_token(yyout); return TOK_PARENTESISDERECHO;}
"[" {yycol += yyleng; _print_token(yyout); return TOK_CORCHETEIZQUIERDO;}
"]" {yycol += yyleng; _print_token(yyout); return TOK_CORCHETEDERECHO;}
"{" {yycol += yyleng; _print_token(yyout); return TOK_LLAVEIZQUIERDA;}
"}" {yycol += yyleng; _print_token(yyout); return TOK_LLAVEDERECHA;}

"=" {yycol += yyleng; _print_token(yyout); return TOK_ASIGNACION;}
"+" {yycol += yyleng; _print_token(yyout); return TOK_MAS;}
"-" {yycol += yyleng; _print_token(yyout); return TOK_MENOS;}
"/" {yycol += yyleng; _print_token(yyout); return TOK_DIVISION;}

"*" {yycol += yyleng; _print_token(yyout); return TOK_ASTERISCO;}
"&&" {yycol += yyleng; _print_token(yyout); return TOK_AND;}
"||" {yycol += yyleng; _print_token(yyout); return TOK_OR;}
"!" {yycol += yyleng; _print_token(yyout); return TOK_NOT;}
"==" {yycol += yyleng; _print_token(yyout); return TOK_IGUAL;}
"!=" {yycol += yyleng; _print_token(yyout); return TOK_DISTINTO;}
"<=" {yycol += yyleng; _print_token(yyout); return TOK_MENORIGUAL;}
">=" {yycol += yyleng; _print_token(yyout); return TOK_MAYORIGUAL;}
"<" {yycol += yyleng; _print_token(yyout); return TOK_MENOR;}
">" {yycol += yyleng; _print_token(yyout); return TOK_MAYOR;}

true {yycol += yyleng; _print_token(yyout); return TOK_TRUE;}
false {yycol += yyleng; _print_token(yyout); return TOK_FALSE;}
{CTE_ENTERA}  {yycol += yyleng; yylval.atributos.valor_entero = atoi(yytext); _print_token(yyout); return TOK_CONSTANTE_ENTERA;}

{ID}		{yycol += yyleng; strcpy(yylval.atributos.nombre, yytext); _print_token(yyout); return TOK_IDENTIFICADOR;} /*TODO: strcpy?*/

{ERROR_LONG}		{yycol += yyleng; fprintf(stderr,"****Error en [lin %ld, col %ld]: longitud maxima alcanzada\n", yylin, yycol); yy_morph_error = 1;}
{ERROR}		{yycol += yyleng; fprintf(stderr,"****Error en [lin %ld, col %ld]: simbolo no permitido (%s)\n", yylin, yycol, yytext); yy_morph_error = 1;}
%%

/*
int main() {
         return yylex();
}*/
