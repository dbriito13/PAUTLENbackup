%{
#include <stdio.h>
#include "alfa.h"
#include "tabla_hash.h"
#include "generacion.h"
#define LOCAL 0
#define GLOBAL 1

extern int yy_morph_error;
extern long yylin;
extern long yycol;

hash_table *tabla_global = NULL;
hash_table *tabla_local = NULL;
int ambito = GLOBAL;

int num_variables_locales_actual;
int pos_variable_local_actual;
int num_parametros_actual;
int pos_parametro_actual;

int tipo_actual;
int clase_actual;
int tamanio_vector_actual;
int num_parametros_llamada_actual;

tuple **contents;
int i;

char nombre_funcion_actual[MAX_LONG_ID];

int etiqueta = 1;
int size = 0;

value *val_local = NULL;
value *val_global = NULL;
value *val = NULL;
int res;
char str_aux[MAX_LONG_ID];


int en_explist = FALSE;
/*VARIABLES PARA COMPROBAR RETORNOS*/
int existe_retorno = FALSE; /*FALSE: no existe retorno, TRUE: SI existe*/

int yylex();
void error_semantico(error_sem err, char* id);
void yyerror(const char * s);
%}

%union {
   info_atributos atributos;
}

%token TOK_MAIN
%token TOK_INT
%token TOK_BOOLEAN
%token TOK_ARRAY
%token TOK_FUNCTION
%token TOK_IF
%token TOK_ELSE
%token TOK_WHILE
%token TOK_SCANF
%token TOK_PRINTF
%token TOK_RETURN

%token TOK_PUNTOYCOMA
%token TOK_COMA
%token TOK_PARENTESISIZQUIERDO
%token TOK_PARENTESISDERECHO
%token TOK_CORCHETEIZQUIERDO
%token TOK_CORCHETEDERECHO
%token TOK_LLAVEIZQUIERDA
%token TOK_LLAVEDERECHA

%token TOK_ASIGNACION
%token TOK_MAS
%token TOK_MENOS
%token TOK_DIVISION

%token TOK_ASTERISCO
%token TOK_AND
%token TOK_OR
%token TOK_NOT
%token TOK_IGUAL
%token TOK_DISTINTO
%token TOK_MENORIGUAL
%token TOK_MAYORIGUAL
%token TOK_MENOR
%token TOK_MAYOR

%token <atributos> TOK_CONSTANTE_ENTERA
%token TOK_TRUE
%token TOK_FALSE

%token <atributos> TOK_IDENTIFICADOR

%type <atributos> fn_name
%type <atributos> fn_declaration
%type <atributos> elemento_vector
%type <atributos> if_exp_sentencias
%type <atributos> if_exp
%type <atributos> while_exp
%type <atributos> while
%type <atributos> exp
%type <atributos> idf_llamada_funcion
%type <atributos> comparacion
%type <atributos> constante
%type <atributos> constante_logica
%type <atributos> constante_entera
%type <atributos> identificador

%left TOK_IGUAL TOK_MENORIGUAL TOK_MENOR TOK_MAYORIGUAL TOK_MAYOR TOK_DISTINTO
%left TOK_AND TOK_OR
%left TOK_MAS TOK_MENOS
%left TOK_ASTERISCO TOK_DIVISION
%right NEG TOK_NOT

%%

programa:                 inicioTabla TOK_MAIN TOK_LLAVEIZQUIERDA declaraciones escritura_TS funciones escritura_main sentencias TOK_LLAVEDERECHA
                              {
                                fprintf(yyout, ";R1:\t<programa> ::= <inicioTabla> main { <declaraciones> <escritura_TS> <funciones> <escritura_main> <sentencias> }\n");

                                escribir_fin(yyout);
                                if(ambito == LOCAL){
                                  wipe(tabla_local);
                                }
                                wipe(tabla_global);
                                return 0;
                              }
                          ;
inicioTabla:                /* empty */ {
                                fprintf(yyout, ";R:\t<inicioTabla>:\n");
                                /*Creamos la tabla global*/
                                tabla_global = create_table();
                                if (tabla_global == NULL)
                                {
                                  printf("Error creando la tabla global!\n");
                                  return -1;
                                }
                              }
                          ;

escritura_TS:                 {
                                fprintf(yyout, ";R:\t<escritura_TS>:\n");
                                //Aqui tenemos que crear la cabecera del segmento BSS y el de datos
                                escribir_cabecera_bss(yyout);

                                contents = extract_table_contents(tabla_global);
                                for(i = 0; i < tabla_global->n_elems; i++){
                                  declarar_variable(yyout, contents[i]->name, contents[i]->val->basic_type, contents[i]->val->size);
                                }
                                free(contents);

                                escribir_subseccion_data(yyout);
                                escribir_segmento_codigo(yyout);
                              }
                          ;
escritura_main:               {
                                fprintf(yyout, ";R:\t<escritura_main>:\n");
                                escribir_inicio_main(yyout);
                              }
                          ;

declaraciones:            declaracion
                              {fprintf(yyout,";R2:\t<declaraciones> ::= <declaracion>\n");}
                          |   declaracion declaraciones
                              {fprintf(yyout,";R3:\t<declaraciones> ::= <declaracion> <declaraciones>\n");}
                          ;
declaracion:              clase identificadores TOK_PUNTOYCOMA
                              {fprintf(yyout,";R4:\t<declaracion> ::= <clase> <identificadores> ;\n");}
                          ;
clase:                    clase_escalar
                              {
                                fprintf(yyout,";R5:\t<clase> ::= <clase_escalar>\n");
                                clase_actual = ESCALAR;
                              }
                          |   clase_vector
                              {
                                fprintf(yyout,";R7:\t<clase> ::= <clase_vector>\n");
                                clase_actual = VECTOR;
                              }
                          ;
clase_escalar:            tipo
                              {fprintf(yyout,";R9:\t<clase_escalar> ::= <tipo>\n");}
                          ;
tipo:                     TOK_INT
                              {
                                fprintf(yyout,";R10:\t<tipo> ::= int\n");
                                tipo_actual = INT;
                              }
                          |   TOK_BOOLEAN
                              {
                                fprintf(yyout,";R11:\t<tipo> ::= boolean\n");
                                tipo_actual = BOOLEAN;
                              }
                          ;
clase_vector:             TOK_ARRAY tipo TOK_CORCHETEIZQUIERDO constante_entera TOK_CORCHETEDERECHO
                              {
                                fprintf(yyout,";R15:\t<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");
                                tamanio_vector_actual = $4.valor_entero;
                              }
                          ;
identificadores:          identificador
                              {fprintf(yyout,";R18:\t<identificadores> ::= <identificador>\n");}
                          |   identificador TOK_COMA identificadores
                              {fprintf(yyout,";R19:\t<identificadores> ::= <identificador> , <identificadores>\n");}
                          ;
funciones:                funcion funciones
                              {fprintf(yyout,";R20:\t<funciones> ::= <funcion> <funciones>\n");}
                          |   /* vacío */
                              {fprintf(yyout,";R21:\t<funciones> ::= \n");}
                          ;
funcion:                  fn_declaration sentencias TOK_LLAVEDERECHA
                              {
                                fprintf(yyout,";R22:\t<funcion> ::=  <fn_declaration> <sentencias> }\n");
                                /*Hay que comprobar que haya un return y que el tipo del retorno sea = tipo de la variable retornada por la funcion*/
                                if(existe_retorno == FALSE){
                                  error_semantico(FUNC_NO_RETURN, NULL);
                                  return -1;
                                }
                                val = get($1.nombre, tabla_global);
                                if(val == NULL){
                                  error_semantico(VARIABLE_NO_DECLARADA, $1.nombre);
                                  return -1;
                                }
                                wipe(tabla_local);
                                ambito = GLOBAL;
                                set($1.nombre, NO_CHANGE, NO_CHANGE, NO_CHANGE, NO_CHANGE, num_parametros_actual, NO_CHANGE, num_variables_locales_actual, NO_CHANGE, tabla_global);
                                existe_retorno = FALSE;
                              }
                          ;
fn_declaration:           fn_name TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion
                              {
                                fprintf(yyout,";R:\t<fn_declaration> ::= <fn_name> ( <parametros> ) { <declaraciones_funcion>\n");

                                strcpy($$.nombre, $1.nombre);
                                res = set($1.nombre, NO_CHANGE, NO_CHANGE, NO_CHANGE, NO_CHANGE, num_parametros_actual, NO_CHANGE, num_variables_locales_actual, NO_CHANGE, tabla_global);
                                res = set($1.nombre, NO_CHANGE, NO_CHANGE, NO_CHANGE, NO_CHANGE, num_parametros_actual, NO_CHANGE, num_variables_locales_actual, NO_CHANGE, tabla_local);
                                if(res == ERROR){
                                  error_semantico(VARIABLE_NO_DECLARADA, $1.nombre);
                                  return -1;
                                }
                                fprintf(yyout, "; declararFuncion:\n");
                                declararFuncion(yyout, $1.nombre, num_variables_locales_actual);
                              }
                          ;

fn_name:                  TOK_FUNCTION tipo TOK_IDENTIFICADOR
                              {
                                fprintf(yyout,";R:\t<fn_name> ::= function <tipo> TOK_IDENTIFICADOR\n");

                                if(ambito == LOCAL){
                                  error_semantico(VAR_LOCAL_NO_ESCALAR, NULL);
                                  return -1;
                                }
                                res = insert($3.nombre, FUNCION, tipo_actual, clase_actual, 0, 0, 0, 0, 0, tabla_global);
                                if(res == FOUND)
                                {
                                  /*Se encuentra el elemento solicitado, error semantico.*/
                                  error_semantico(DECLARACION_DUPLICADA, NULL);
                                  return -1;
                                }
                                else if(res == INSERTED)
                                {
                                  /*No se encuentra el elemento solicitado, se abre el ambito local.*/
                                  tabla_local = create_table();
                                  if (tabla_local == NULL)
                                  {
                                    printf("Error creando la tabla local!\n");
                                    wipe(tabla_global);
                                    return -1;
                                  }
                                  res = insert($3.nombre, FUNCION, tipo_actual, 0, 0, 0, 0, 0, 0, tabla_local);
                                  ambito = LOCAL;
                                  num_variables_locales_actual = 0;
                                  pos_variable_local_actual = 1;
                                  num_parametros_actual = 0;
                                  pos_parametro_actual = 0;
                                  strcpy($$.nombre, $3.nombre);
                                  strcpy(nombre_funcion_actual, $$.nombre);
                                }
                              }
                          ;
parametros_funcion:       parametro_funcion resto_parametros_funcion
                              {fprintf(yyout,";R23:\t<parametros_funcion> ::= <parametro_funcion> <resto_parametros_funcion>\n");}
                          |   /* vacío */
                              {fprintf(yyout,";R24:\t<parametros_funcion> ::= \n");}
                          ;
resto_parametros_funcion: TOK_PUNTOYCOMA parametro_funcion resto_parametros_funcion
                              {fprintf(yyout,";R25:\t<resto_parametros_funcion> ::= ; <parametro_funcion> <resto_parametros_funcion>\n");}
                          |   /* vacío */
                              {fprintf(yyout,";R26:\t<resto_parametros_funcion> ::= \n");}
                          ;
parametro_funcion:        clase idpf
                              {fprintf(yyout,";R27:\t<parametro_funcion> ::= <clase> <idpf>\n");}
                          ;
idpf:                     TOK_IDENTIFICADOR
                            {
                              fprintf(yyout,";R:\t<idpf> ::= TOK_IDENTIFICADOR\n");

                              if(clase_actual == VECTOR){
                                error_semantico(PARAM_ES_FUNC, NULL);
                                return -1;
                              }
                              res = insert($1.nombre, PARAMETRO, tipo_actual, clase_actual, 1, 0, pos_parametro_actual, 0, 0, tabla_local);
                              if(res == FOUND){
                                  error_semantico(DECLARACION_DUPLICADA, NULL);
                                  return -1;
                              }
                              pos_parametro_actual++;
                              num_parametros_actual++;
                            }
                          ;
declaraciones_funcion:    declaraciones
                              {fprintf(yyout,";R28:\t<declaraciones_funcion> ::= <declaraciones>\n");}
                          |   /* vacío */
                              {fprintf(yyout,";R29:\t<declaraciones_funcion> ::= \n");}
                          ;
sentencias:               sentencia
                              {fprintf(yyout,";R30:\t<sentencias> ::= <sentencia>\n");}
                          |   sentencia sentencias
                              {fprintf(yyout,";R31:\t<sentencias> ::= <sentencia> <sentencias>\n");}
                          ;
sentencia:                sentencia_simple TOK_PUNTOYCOMA
                              {fprintf(yyout,";R32:\t<sentencia> ::= <sentencia_simple> ;\n");}
                          |   bloque
                              {fprintf(yyout,";R33:\t<sentencia> ::= <bloque>\n");}
                          ;
sentencia_simple:         asignacion
                              {fprintf(yyout,";R34:\t<sentencia_simple> ::= <asignacion>\n");}
                          |   lectura
                              {fprintf(yyout,";R35:\t<sentencia_simple> ::= <lectura>\n");}
                          |   escritura
                              {fprintf(yyout,";R36:\t<sentencia_simple> ::= <escritura>\n");}
                          |   retorno_funcion
                              {fprintf(yyout,";R38:\t<sentencia_simple> ::= <retorno_funcion>\n");}
                          ;
bloque:                   condicional
                              {fprintf(yyout,";R40:\t<bloque> ::= <condicional>\n");}
                          |   bucle
                              {fprintf(yyout,";R41:\t<bloque> ::= <bucle>\n");}
                          ;
asignacion:               TOK_IDENTIFICADOR TOK_ASIGNACION exp
                              {
                                fprintf(yyout,";R43:\t<asignacion> ::= TOK_IDENTIFICADOR = <exp>\n");
                                val_local = NULL;
                                if(ambito == LOCAL){
                                  val_local = get($1.nombre, tabla_local);
                                }
                                if(val_local == NULL){
                                  val_global = get($1.nombre, tabla_global);
                                  val = val_global;
                                }else{
                                  val = val_local;
                                }                                

                                if(val){ /*Si encontramos el simbolo en el ambito local / global */
                                  if(val->element_category != FUNCION && val->category == ESCALAR
                                    && val->basic_type == $3.tipo){
                                      if(ambito == LOCAL && val_local != NULL){
                                        if(val_local->element_category == VARIABLE){
                                          fprintf(yyout, "; escribirVariableLocal:\n");
                                          escribirVariableLocal(yyout, val->pos_local_variable);
                                          fprintf(yyout, "; asignarDestinoEnPila:\n");
                                          asignarDestinoEnPila(yyout, $3.es_direccion);
                                        }else{
                                          fprintf(yyout, "; escribirParametro:\n");
                                          escribirParametro(yyout, val_local->pos_param, get(nombre_funcion_actual, tabla_global)->num_params);
                                          fprintf(yyout, "; asignarDestinoEnPila:\n");
                                          asignarDestinoEnPila(yyout, $3.es_direccion);
                                        }

                                      } else {
                                        fprintf(yyout, "; asignar:\n");
                                        asignar(yyout, $1.nombre, $3.es_direccion);
                                      }
                                  } else {
                                    error_semantico(ASIGN_INCOMPATIBLE, NULL);
                                    return -1;
                                  }
                                }
                              }
                          |   elemento_vector TOK_ASIGNACION exp
                              {
                                fprintf(yyout,";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");
                                if($1.tipo == $3.tipo){
                                  fprintf(yyout, "; asignarDestinoEnPilaVector:\n");
                                  asignarDestinoEnPilaVector(yyout, $3.es_direccion);
                                } else {
                                  error_semantico(ASIGN_INCOMPATIBLE, NULL);
                                  return -1;
                                }
                              }
                          ;
elemento_vector:          TOK_IDENTIFICADOR TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO
                              {
                                fprintf(yyout,";R48:\t<elemento_vector> ::= TOK_IDENTIFICADOR [ <exp> ]\n");
                                if(ambito == LOCAL){
                                  val = get($1.nombre, tabla_local);
                                  if(val == NULL){
                                    val = get($1.nombre, tabla_global);
                                  }
                                } else {
                                  val = get($1.nombre, tabla_global);
                                }
                                if(val){
                                  if(val->category == VECTOR){
                                    if($3.tipo == INT){
                                      $$.tipo = val->basic_type;
                                      $$.es_direccion = VALOR_REFERENCIA;
                                      fprintf(yyout, "; escribir_elemento_vector:\n");
                                      escribir_elemento_vector(yyout, $1.nombre, val->size, $3.es_direccion);
                                    }else{
                                      error_semantico(INDEX_INT, NULL);
                                      return -1;
                                    }
                                  }else{
                                    error_semantico(INDEX_NO_VECTOR, NULL);
                                    return -1;
                                  }
                                }else {
                                  printf("BAD"); 
                                  error_semantico(VARIABLE_NO_DECLARADA, $1.nombre);
                                  return -1;
                                }

                              }
                          ;
condicional:              if_exp sentencias TOK_LLAVEDERECHA
                              {
                                fprintf(yyout,";R50:\t<condicional> ::= if ( <exp> ) { <sentencias> }\n");
                                ifthen_fin(yyout, $1.etiqueta);
                              }
                          | if_exp_sentencias TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA
                              {
                                fprintf(yyout,";R51:\t<condicional> ::= if ( <exp> ) { <sentencias> } else { <sentencias> }\n");
                                ifthenelse_fin(yyout, $1.etiqueta);
                              }
                          ;
if_exp_sentencias:        if_exp sentencias TOK_LLAVEDERECHA
                              {
                                fprintf(yyout,";R:\t<if_exp_sentencias> ::= <if_exp> <sentencias> }\n");

                                $$.etiqueta = $1.etiqueta;
                                ifthenelse_fin_then(yyout, $1.etiqueta);
                              }
                          ;
if_exp:                   TOK_IF TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA
                              {
                                fprintf(yyout,";R:\t<if_exp> ::= if ( <exp> ) {\n");

                                if($3.tipo != BOOLEAN){
                                  error_semantico(CONDICIONAL_INT, NULL);
                                }
                                $$.etiqueta = etiqueta;
                                ifthenelse_inicio(yyout, $3.es_direccion, $$.etiqueta);
                                etiqueta++;
                              }
                          ;
bucle:                    while_exp sentencias TOK_LLAVEDERECHA
                              {
                                fprintf(yyout,";R52:\t<bucle> ::= <while_exp> <sentencias> }\n");
                                while_fin(yyout, $1.etiqueta);
                              }
                          ;
while_exp:                while exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA
                              {
                                fprintf(yyout,";R:\t<while_exp> ::= <while> <exp> ) } \n");

                                if($2.tipo != BOOLEAN){
                                  error_semantico(CONDICIONAL_INT, NULL);
                                  return -1;
                                }
                                $$.etiqueta = $1.etiqueta;
                                while_exp_pila(yyout, $2.es_direccion, $1.etiqueta);
                              }
                          ;
while:                    TOK_WHILE TOK_PARENTESISIZQUIERDO
                              {
                                fprintf(yyout,";R:\t<while> ::= while (\n");
                                $$.etiqueta = etiqueta;
                                while_inicio(yyout, $$.etiqueta);
                                etiqueta++;
                              }
                          ;
lectura:                  TOK_SCANF TOK_IDENTIFICADOR
                              {
                                fprintf(yyout,";R54:\t<lectura> ::= scanf TOK_IDENTIFICADOR\n");
                                val_global = get($2.nombre, tabla_global);
                                val_local = NULL;
                                if(ambito == LOCAL){
                                 val_local = get($2.nombre, tabla_local);
                                }
                                if(val_global == NULL && val_local == NULL){
                                  error_semantico(VARIABLE_NO_DECLARADA, $2.nombre);
                                  return -1;
                                } else if(val_local) { //Si la encontramos en la tabla local
                                  if(val_local->element_category == FUNCION || val_local->category == VECTOR){
                                    error_semantico(LECTURA_ERROR, NULL);
                                    return -1;
                                  } else {
                                    if(val_local->basic_type == INT){
                                      leer(yyout, $2.nombre, INT);
                                    } else if(val_local->basic_type == BOOLEAN){
                                      leer(yyout, $2.nombre, BOOLEAN);
                                    }
                                  }
                                } else { //si la encontramos en la tabla global
                                  if(val_global->element_category == FUNCION || val_global->element_category == VECTOR){
                                    error_semantico(LECTURA_ERROR, NULL);
                                    return -1;
                                  } else {
                                    if(val_global->basic_type == INT){
                                      leer(yyout, $2.nombre, INT);
                                    } else if(val_global->basic_type == BOOLEAN){
                                      leer(yyout, $2.nombre, BOOLEAN);
                                    }
                                  }
                                }
                              }
                          ;
escritura:                TOK_PRINTF exp
                              {
                                fprintf(yyout,";R56:\t<escritura> ::= printf <exp>\n");
                                escribir(yyout, $2.es_direccion, $2.tipo);
                              }
                          ;
retorno_funcion:          TOK_RETURN exp
                              {
                                fprintf(yyout,";R61:\t<retorno_funcion> ::= return <exp>\n");
                                if (ambito != LOCAL){
                                  error_semantico(RETURN_OUT_FUNC, NULL);
                                  return -1;
                                }
                                val = get(nombre_funcion_actual, tabla_local);
                                if(!val){
                                  error_semantico(VARIABLE_NO_DECLARADA, nombre_funcion_actual);
                                  return -1;
                                }
                                if(val->basic_type != $2.tipo){
                                  error_semantico(RETORNO_DIFERENTE_TIPO, NULL);
                                  return -1;
                                }
                                /*Actualizamos variable de retorno*/
                                existe_retorno = TRUE;
                                retornarFuncion(yyout, $2.es_direccion);
                              }
                          ;
exp:                      exp TOK_MAS exp
                              {
                                fprintf(yyout,";R72:\t<exp> ::= <exp> + <exp>\n");
                                if($1.tipo == INT && $3.tipo == INT){
                                  $$.valor_entero = $1.valor_entero + $3.valor_entero;
                                  $$.tipo = INT;
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  sumar(yyout, $1.es_direccion, $3.es_direccion);
                                } else {
                                  error_semantico(OPERACION_ARITMETICA_BOOLEAN, NULL);
                                  return -1;
                                }
                              }
                          |   exp TOK_MENOS exp
                              {
                                fprintf(yyout,";R73:\t<exp> ::= <exp> - <exp>\n");
                                if($1.tipo == INT && $3.tipo == INT){
                                  $$.valor_entero = $1.valor_entero - $3.valor_entero;
                                  $$.tipo = INT;
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  restar(yyout, $1.es_direccion, $3.es_direccion);
                                } else {
                                  error_semantico(OPERACION_ARITMETICA_BOOLEAN, NULL);
                                  return -1;
                                }
                              }
                          |   exp TOK_DIVISION exp
                              {
                                fprintf(yyout,";R74:\t<exp> ::= <exp> / <exp>\n");
                                if($1.tipo == INT && $3.tipo == INT){
                                  $$.valor_entero = $1.valor_entero / $3.valor_entero;
                                  $$.tipo = INT;
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  dividir(yyout, $1.es_direccion, $3.es_direccion);
                                } else {
                                  error_semantico(OPERACION_ARITMETICA_BOOLEAN, NULL);
                                  return -1;
                                }
                              }
                          |   exp TOK_ASTERISCO exp
                              {
                                fprintf(yyout,";R75:\t<exp> ::= <exp> * <exp>\n");
                                if($1.tipo == INT && $3.tipo == INT){
                                  $$.valor_entero = $1.valor_entero * $3.valor_entero;
                                  $$.tipo = INT;
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  multiplicar(yyout, $1.es_direccion, $3.es_direccion);
                                } else {
                                  error_semantico(OPERACION_ARITMETICA_BOOLEAN, NULL);
                                  return -1;
                                }
                              }
                          |   TOK_MENOS exp %prec NEG
                              {
                                fprintf(yyout,";R76:\t<exp> ::= - <exp>\n");
                                if($2.tipo == INT){
                                  $$.valor_entero = - $2.valor_entero;
                                  $$.tipo = INT;
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  cambiar_signo(yyout, $2.es_direccion);
                                } else {
                                  error_semantico(OPERACION_ARITMETICA_BOOLEAN, NULL);
                                  return -1;
                                }
                              }
                          |   exp TOK_AND exp
                              {
                                fprintf(yyout,";R77:\t<exp> ::= <exp> && <exp>\n");
                                if($1.tipo == BOOLEAN && $3.tipo == BOOLEAN){
                                  $$.tipo = BOOLEAN;
                                  $$.valor_entero = $1.valor_entero && $3.valor_entero;
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  fprintf(yyout, ";mm %d %d\n", $1.es_direccion, $3.es_direccion);
                                  y(yyout, $1.es_direccion, $3.es_direccion);
                                } else {
                                  error_semantico(OPERACION_LOGICA_INT, NULL);
                                  return -1;
                                }
                              }
                          |   exp TOK_OR exp
                              {
                                fprintf(yyout,";R78:\t<exp> ::= <exp> || <exp>\n");
                                if($1.tipo == BOOLEAN && $3.tipo == BOOLEAN){
                                  $$.tipo = BOOLEAN;
                                  $$.valor_entero = $1.valor_entero || $3.valor_entero;
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  o(yyout, $1.es_direccion, $3.es_direccion);
                                } else {
                                  error_semantico(OPERACION_LOGICA_INT, NULL);
                                  return -1;
                                }
                              }
                          |   TOK_NOT exp
                              {
                                fprintf(yyout,";R79:\t<exp> ::= ! <exp>\n");
                                if($2.tipo == BOOLEAN){
                                  $$.tipo = BOOLEAN;
                                  $$.valor_entero = ! $2.valor_entero;
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  no(yyout, $2.es_direccion, 1);
                                } else {
                                  error_semantico(OPERACION_LOGICA_INT, NULL);
                                  return -1;
                                }
                              }
                          |   TOK_IDENTIFICADOR
                              {
                                fprintf(yyout,";R80:\t<exp> ::= TOK_IDENTIFICADOR\n");
                                val_local = NULL;
                                if(ambito == LOCAL){
                                  val_local = get($1.nombre, tabla_local);
                                }

                                val_global = get($1.nombre, tabla_global);
                                if(val_local == NULL && val_global == NULL){
                                  error_semantico(VARIABLE_NO_DECLARADA, $1.nombre);
                                  return -1;
                                } else if(val_local) {
                                  if(val_local->element_category == FUNCION || val_local->category == VECTOR){
                                    error_semantico(ASIGN_INCOMPATIBLE, NULL);
                                    return -1;
                                  } else {
                                    $$.tipo = val_local->basic_type;
                                    $$.es_direccion = VALOR_REFERENCIA;
                                    if(val_local->element_category == PARAMETRO){
                                      fprintf(yyout, "; escribirParametro:\n");
                                      escribirParametro(yyout, val_local->pos_param, get(nombre_funcion_actual, tabla_global)->num_params);
                                    }else{
                                      fprintf(yyout, "; escribirVariableLocal:\n");
                                      escribirVariableLocal(yyout, val_local->pos_local_variable);
                                    }
                                  }
                                } else {
                                  if(val_global->element_category == FUNCION || val_global->category == VECTOR){
                                    error_semantico(ASIGN_INCOMPATIBLE, NULL);
                                    return -1;
                                  } else {
                                    $$.tipo = val_global->basic_type;
                                    $$.es_direccion = VALOR_REFERENCIA;
                                    fprintf(yyout, "; escribir_operando:\n");
                                    escribir_operando(yyout, $1.nombre, VALOR_REFERENCIA);
                                    if(en_explist == TRUE){
                                      fprintf(yyout, "; operandoEnPilaAArgumento:\n");
                                      operandoEnPilaAArgumento(yyout, VALOR_REFERENCIA);
                                    }
                                  }
                                }
                                strcpy($$.nombre, $1.nombre);
                              }
                          |   constante
                              {
                                fprintf(yyout,";R81:\t<exp> ::= <constante>\n");
                                $$.tipo = $1.tipo;
                                $$.es_direccion = $1.es_direccion;
                                $$.valor_entero = $1.valor_entero;
                                sprintf(str_aux, "%d", $1.valor_entero);
                                fprintf(yyout, "; escribir_operando:\n");
                                escribir_operando(yyout, str_aux, VALOR_EXPLICITO);
                              }
                          |   TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO
                              {
                                fprintf(yyout,";R82:\t<exp> ::= ( <exp> )\n");
                                $$.tipo = $2.tipo;
                                $$.es_direccion = $2.es_direccion;
                                /*
                                sprintf(str_aux, "%d", $2.valor_entero);
                                fprintf(yyout, "; escribir_operando:\n");
                                escribir_operando(yyout, str_aux, VALOR_EXPLICITO);
                                */
                              }
                          |   TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO
                              {
                                fprintf(yyout,";R83:\t<exp> ::= ( <comparacion> )\n");
                                $$.tipo = $2.tipo;
                                $$.es_direccion = $2.es_direccion;
                              }
                          |   elemento_vector
                              {
                                fprintf(yyout,";R85:\t<exp> ::= <elemento_vector>\n");
                                $$.tipo = $1.tipo;
                                $$.es_direccion = $1.es_direccion;

                                if(en_explist == TRUE){
                                  fprintf(yyout, "; operandoEnPilaAArgumento:\n");
                                  operandoEnPilaAArgumento(yyout, $1.es_direccion);
                                  //escribirParametro(yyout, pos_parametro_actual, num_parametros_actual);
                                }
                                /* else {
                                  fprintf(yyout, "; escribir_operando:\n");
                                  escribir_operando(yyout, $1.nombre, $1.es_direccion);
                                } */
                              }
                          |   idf_llamada_funcion TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO
                              {
                                fprintf(yyout,";R88:\t<exp> ::= <idf_llamada_funcion> ( <lista_expresiones> )\n");
                                val = get($1.nombre, tabla_global);
                                if(val->num_params == num_parametros_llamada_actual){
                                  llamarFuncion(yyout, $1.nombre, num_parametros_llamada_actual);
                                  en_explist = FALSE;
                                  $$.tipo = val->basic_type;
                                  $$.es_direccion = VALOR_EXPLICITO;
                                } else {
                                  error_semantico(NUMERO_PARAMS_FUNC, NULL);
                                  return -1;
                                }
                              }
                          ;
idf_llamada_funcion:      TOK_IDENTIFICADOR
                              {
                                fprintf(yyout,";R:\t<idf_llamada_funcion> ::= TOK_IDENTIFICADOR\n");

                                val = get($1.nombre, tabla_global);
                                if(val == NULL){
                                  error_semantico(VARIABLE_NO_DECLARADA, $1.nombre);
                                } else { //Si encuentra la función
                                  if(val->element_category != FUNCION){
                                    error_semantico(PARAM_FUN, NULL);
                                    return -1;
                                  }
                                  if(en_explist == TRUE){
                                    error_semantico(PARAM_FUN, NULL);
                                    return -1; 
                                  }else {
                                    num_parametros_llamada_actual = 0;
                                    en_explist = TRUE;
                                    strcpy($$.nombre, $1.nombre);
                                  }
                                }
                              }
lista_expresiones:        exp resto_lista_expresiones
                              {
                                fprintf(yyout,";R89:\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");
                                num_parametros_llamada_actual++;
                              }
                          |   /* vacío */
                              {fprintf(yyout,";R90:\t<lista_expresiones> ::= \n");}

                          ;
resto_lista_expresiones:  TOK_COMA exp resto_lista_expresiones
                              {
                                fprintf(yyout,";R91:\t<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");
                                num_parametros_llamada_actual++;
                              }
                          |   /* vacío */
                              {fprintf(yyout,";R92:\t<resto_lista_expresiones> ::= \n");}

                          ;
comparacion:              exp TOK_IGUAL exp
                              {
                                fprintf(yyout,";R93:\t<comparacion> ::= <exp> == <exp>\n");
                                if($1.tipo == INT && $3.tipo == INT){
                                  $$.tipo = BOOLEAN;
                                  $$.valor_entero = ($1.valor_entero == $3.valor_entero);
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  igual(yyout, $1.es_direccion, $3.es_direccion, etiqueta);
                                  etiqueta++;
                                } else {
                                  error_semantico(COMPARACION_BOOLEAN, NULL);
                                  return -1;
                                }
                              }
                          |   exp TOK_DISTINTO exp
                              {
                                fprintf(yyout,";R94:\t<comparacion> ::= <exp> != <exp>\n");
                                if($1.tipo == INT && $3.tipo == INT){
                                  $$.tipo = BOOLEAN;
                                  $$.valor_entero = ($1.valor_entero != $3.valor_entero);
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  distinto(yyout, $1.es_direccion, $3.es_direccion, etiqueta);
                                  etiqueta++;
                                } else {
                                  error_semantico(COMPARACION_BOOLEAN, NULL);
                                  return -1;
                                }
                              }
                          |   exp TOK_MENORIGUAL exp
                              {
                                fprintf(yyout,";R95:\t<comparacion> ::= <exp> <= <exp>\n");
                                if($1.tipo == INT && $3.tipo == INT){
                                  $$.tipo = BOOLEAN;
                                  $$.valor_entero = ($1.valor_entero <= $3.valor_entero);
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  menor_igual(yyout, $1.es_direccion, $3.es_direccion, etiqueta);
                                  etiqueta++;
                                } else {
                                  error_semantico(COMPARACION_BOOLEAN, NULL);
                                  return -1;
                                }
                              }
                          |   exp TOK_MAYORIGUAL exp
                              {
                                fprintf(yyout,";R96:\t<comparacion> ::= <exp> >= <exp>\n");
                                if($1.tipo == INT && $3.tipo == INT){
                                  $$.tipo = BOOLEAN;
                                  $$.valor_entero = ($1.valor_entero >= $3.valor_entero);
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  mayor_igual(yyout, $1.es_direccion, $3.es_direccion, etiqueta);
                                  etiqueta++;
                                } else {
                                  error_semantico(COMPARACION_BOOLEAN, NULL);
                                  return -1;
                                }
                              }
                          |   exp TOK_MENOR exp
                              {
                                fprintf(yyout,";R97:\t<comparacion> ::= <exp> < <exp>\n");
                                if($1.tipo == INT && $3.tipo == INT){
                                  $$.tipo = BOOLEAN;
                                  $$.valor_entero = ($1.valor_entero < $3.valor_entero);
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  menor(yyout, $1.es_direccion, $3.es_direccion, etiqueta);
                                  etiqueta++;
                                } else {
                                  error_semantico(COMPARACION_BOOLEAN, NULL);
                                  return -1;
                                }
                              }
                          |   exp TOK_MAYOR exp
                              {
                                fprintf(yyout,";R98:\t<comparacion> ::= <exp> > <exp>\n");
                                if($1.tipo == INT && $3.tipo == INT){
                                  $$.tipo = BOOLEAN;
                                  $$.valor_entero = ($1.valor_entero > $3.valor_entero);
                                  $$.es_direccion = VALOR_EXPLICITO;
                                  mayor(yyout, $1.es_direccion, $3.es_direccion, etiqueta);
                                  etiqueta++;
                                } else {
                                  error_semantico(COMPARACION_BOOLEAN, NULL);
                                  return -1;
                                }
                              }
                          ;
constante:                constante_logica
                              {
                                fprintf(yyout,";R99:\t<constante> ::= <constante_logica>\n");
                                $$.tipo = $1.tipo;
                                $$.es_direccion = $1.es_direccion;
                                $$.valor_entero = $1.valor_entero;
                              }
                          |   constante_entera
                              {
                                fprintf(yyout,";R100:\t<constante> ::= <constante_entera>\n");
                                $$.tipo = $1.tipo;
                                $$.es_direccion = $1.es_direccion;
                                $$.valor_entero = $1.valor_entero;
                              }
                          ;
constante_logica:         TOK_TRUE
                              {
                                fprintf(yyout,";R102:\t<constante_logica> ::= true\n");
                                $$.tipo = BOOLEAN;
                                $$.es_direccion = VALOR_EXPLICITO;
                                $$.valor_entero = 1;
                              }
                          |   TOK_FALSE
                              {
                                fprintf(yyout,";R103:\t<constante_logica> ::= false\n");
                                $$.tipo = BOOLEAN;
                                $$.es_direccion = VALOR_EXPLICITO;
                                $$.valor_entero = 0;
                              }
                          ;
constante_entera:         TOK_CONSTANTE_ENTERA
                              {
                                fprintf(yyout,";R104:\t<constante_entera> ::= TOK_CONSTANTE_ENTERA\n");
                                $$.valor_entero = $1.valor_entero;
                                $$.tipo = INT;
                                $$.es_direccion = VALOR_EXPLICITO;
                              }
                          ;
identificador:            TOK_IDENTIFICADOR
                              {
                                fprintf(yyout,";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
                                strcpy($$.nombre, $1.nombre);
                                if(clase_actual == ESCALAR){
                                    size = 1;
                                } else{ //clase_actual == VECTOR
                                    size = tamanio_vector_actual;
                                    if ((size < 1) || (size > MAX_TAMANIO_VECTOR)){
                                      error_semantico(MAX_TAM_VECTOR, $1.nombre);
                                      return -1;
                                    }
                                }
                                if(ambito == LOCAL){
                                    if(clase_actual == ESCALAR){
                                        num_variables_locales_actual++;
                                        res = insert($1.nombre, VARIABLE, tipo_actual, clase_actual, 1, 0, 0, num_variables_locales_actual, pos_variable_local_actual, tabla_local);
                                        pos_variable_local_actual++;
                                    } else{ //if clase_actual == VECTOR
                                        error_semantico(VAR_LOCAL_NO_ESCALAR, NULL);
                                        return -1;
                                    }
                                } else {
                                    res = insert($1.nombre, VARIABLE, tipo_actual, clase_actual, size, 0, 0, 0, 0, tabla_global);
                                }
                                if(res == FOUND){
                                    error_semantico(DECLARACION_DUPLICADA, NULL);
                                    return -1;
                                }
                              }

%%

void error_semantico(error_sem err, char* id) {
  if(err == DECLARACION_DUPLICADA){
    printf("****Error semantico en lin %ld: Declaracion duplicada.\n", yylin);
  } else if(err == VARIABLE_NO_DECLARADA){
    printf("****Error semantico en lin %ld: Acceso a variable no declarada (%s).\n", yylin, id);
  } else if(err == OPERACION_ARITMETICA_BOOLEAN){
    printf("****Error semantico en lin %ld: Operacion aritmetica con operandos boolean.\n", yylin);
  }else if(err == OPERACION_LOGICA_INT){
    printf("****Error semantico en lin %ld: Operacion logica con operandos int.\n", yylin);
  }else if(err == COMPARACION_BOOLEAN){
    printf("****Error semantico en lin %ld: Comparacion con operandos boolean.\n", yylin);
  }else if(err == CONDICIONAL_INT){
    printf("****Error semantico en lin %ld: Condicional con condicion de tipo int.\n", yylin);
  }else if(err == BUCLE_INT){
    printf("****Error semantico en lin %ld: Bucle con condicion de tipo int.\n", yylin);
  }else if(err == NUMERO_PARAMS_FUNC){
    printf("****Error semantico en lin %ld: Numero incorrecto de parametros en llamada a funcion.\n", yylin);
  }else if(err == ASIGN_INCOMPATIBLE){
    printf("****Error semantico en lin %ld: Asignacion incompatible.\n", yylin);
  }else if(err == MAX_TAM_VECTOR){
    printf("****Error semantico en lin %ld: El tamanyo del vector %s excede los limites permitidos (1,64).\n", yylin, id);
  }else if(err == INDEX_NO_VECTOR){
    printf("****Error semantico en lin %ld: Intento de indexacion de una variable que no es de tipo vector.\n", yylin);
  }else if(err == INDEX_INT){
    printf("****Error semantico en lin %ld: El indice en una operacion de indexacion tiene que ser de tipo entero.\n", yylin);
  }else if(err == FUNC_NO_RETURN){
    printf("****Error semantico en lin %ld: Funcion %s sin sentencia de retorno.\n", yylin, id);
  }else if(err == RETURN_OUT_FUNC){
    printf("****Error semantico en lin %ld: Sentencia de retorno fuera del cuerpo de una funcion.\n", yylin);
  }else if(err == PARAM_ES_FUNC){
    printf("****Error semantico en lin %ld: No esta permitido el uso de llamadas a funciones como parametros de otras funciones.\n", yylin);
  }else if(err == VAR_LOCAL_NO_ESCALAR){
    printf("****Error semantico en lin %ld: Variable local de tipo no escalar..\n", yylin);
  }else if(err == LECTURA_ERROR){
    printf("****Error semantico en lin %ld: Lectura no posible para Funcion o Vector\n", yylin);
  }else if(err == RETORNO_DIFERENTE_TIPO){
    printf("****Error semantico en lin %ld: El tipo del retorno la funcion no coincide con el tipo retornado\n", yylin);
  }else if(err == LLAMADA_NO_FUNCION){
    printf("****Error semantico en lin %ld: Llamada de tipo funcion a un elemento que no lo es\n", yylin);
  }else if(err == DIF_TIPOS){
    printf("****Error semantico en lin %ld: Intento de operacion entre 2 variables de distinto tipo\n", yylin);
  }else if(err == PARAM_ES_VECTOR){
    printf("****Error semantico en lin %ld: No esta permitido el uso de vectores en los parametros de una funcion.\n", yylin);
  }else if(err == PARAM_FUN){
    printf("****Error semantico en lin %ld: No esta permitido que los parametros sean llamadas a otras funciones.\n", yylin);
  }

  wipe(tabla_global);
  if (ambito == LOCAL){
    wipe(tabla_local);
  }
}

void yyerror(const char * s) {
    if(!yy_morph_error) {
        printf("****Error sintactico en [lin %ld, col %ld]\n", yylin, yycol);
    }
    wipe(tabla_global);
    if (ambito == LOCAL){
      wipe(tabla_local);
    }
    return;
}
