#include <stdio.h>
#include <string.h>
#include "alfa.h"

int yylex();
int yyparse();

int main(int argc, char ** argv) {
    extern FILE * yyin;

    if(argc != 3){
      return 1;
    }

    yyin = fopen(argv[1], "r");
    if(yyin == NULL) {
        return 1;
    }
    yyout = fopen(argv[2], "w");
    if(yyout == NULL) {
        fclose(yyin);
        return 1;
    }

    yyparse();

    fclose(yyin);
    fclose(yyout);
    return 0;
}
