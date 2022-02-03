#include <stdio.h>
#include <stdlib.h>
#include "generacion.h"

/*
Alejandro Bravo, Daniel Brito, Carmen Díez
*/

void escribir_cabecera_bss(FILE *fpasm)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al escribir la cabecera bss");
    exit(1);
  }

  fprintf(fpasm, "segment .bss\n");
  fprintf(fpasm, "\t__esp resd 1\n");
}

void escribir_subseccion_data(FILE *fpasm)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al escribir la subseccion data");
    exit(1);
  }

  fprintf(fpasm, "segment .data\n");
  fprintf(fpasm, "\t_err_div_0 db \"****Error de ejecucion: División por 0\",0\n");
  fprintf(fpasm, "\t_err_indice_fuera_rango db \"****Error de ejecucion: Indice fuera de rango\",0\n");
}

void declarar_variable(FILE *fpasm, char *nombre, int tipo, int tamano)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al declarar variable\n");
    exit(1);
  }
  else if (nombre == NULL)
  {
    printf("Error NULL nombre al declarar variable");
    exit(1);
  }
  else if (tipo != ENTERO && tipo != BOOLEANO)
  {
    printf("Error tipo no definido al declarar variable");
    exit(1);
  }
  else if (tamano <= 0)
  {
    printf("El tamano tiene que ser mayor que cero al declarar una variable");
    exit(1);
  }

  fprintf(fpasm, "\t_%s resd %d\n", nombre, tamano);
}

void escribir_segmento_codigo(FILE *fpasm)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al escribir la segmento codigo");
    exit(1);
  }

  fprintf(fpasm, "segment .text\n");
  fprintf(fpasm, "\tglobal main\n");
  fprintf(fpasm, "\textern print_int, print_boolean, print_string, print_blank, print_endofline\n");
  fprintf(fpasm, "\textern scan_int, scan_boolean\n");
}

void escribir_inicio_main(FILE *fpasm)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al escribir main");
    exit(1);
  }

  fprintf(fpasm, "main:\n");
  //Guardamos el puntero de pila en la variable __esp
  fprintf(fpasm, "\tMOV DWORD [__esp], ESP\n");
}

void escribir_fin(FILE *fpasm)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al escribir fin");
    exit(1);
  }

  fprintf(fpasm, "fin:\n");
  fprintf(fpasm, "\tMOV DWORD ESP, [__esp]\n");
  fprintf(fpasm, "\tret\n");

  //Error que se produce al intentar dividir entre cero
  fprintf(fpasm, "div_0:\n");
  fprintf(fpasm, "\tPUSH DWORD _err_div_0\n");
  fprintf(fpasm, "\tCALL print_string\n");
  fprintf(fpasm, "\tADD ESP, 4\n");
  fprintf(fpasm, "\tCALL print_endofline\n");
  fprintf(fpasm, "\tJMP fin\n");

  //Error que se produce al intentar extraer de un array un elemento fuera de rango
  fprintf(fpasm, "fin_indice_fuera_rango:\n");
  fprintf(fpasm, "\tPUSH DWORD _err_indice_fuera_rango\n");
  fprintf(fpasm, "\tCALL print_string\n");
  fprintf(fpasm, "\tADD ESP, 4\n");
  fprintf(fpasm, "\tCALL print_endofline\n");
  fprintf(fpasm, "\tJMP fin\n");
}

void escribir_operando(FILE *fpasm, char *nombre, int es_variable)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al escribir operando");
    exit(1);
  }
  else if (nombre == NULL)
  {
    printf("Error NULL nombre al escribir operando");
    exit(1);
  }
  else if (es_variable != VALOR_EXPLICITO && es_variable != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al escribir operando");
    exit(1);
  }
  if (es_variable == VALOR_REFERENCIA)
  {
    fprintf(fpasm, "\tPUSH DWORD _%s\n", nombre);
  }
  else
  {
    fprintf(fpasm, "\tPUSH DWORD %s\n", nombre);
  }
}

void asignar(FILE *fpasm, char *nombre, int es_variable)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al asignar");
    exit(VALOR_REFERENCIA);
  }
  else if (nombre == NULL)
  {
    printf("Error NULL nombre al asignar");
    exit(1);
  }
  else if (es_variable != VALOR_EXPLICITO && es_variable != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al asignar");
    exit(1);
  }

  if (es_variable == VALOR_REFERENCIA)
  {
    fprintf(fpasm, "\tPOP DWORD ECX\n");
    fprintf(fpasm, "\tMOV DWORD ECX, [ECX]\n");
    fprintf(fpasm, "\tMOV DWORD [_%s], ECX\n", nombre);
  }
  else
  {
    fprintf(fpasm, "\tPOP DWORD ECX\n");
    fprintf(fpasm, "\tMOV DWORD [_%s], ECX\n", nombre);
  }
}

void asignar_reg(FILE *fpasm, char *nombre, int es_variable)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al asignar");
    exit(VALOR_REFERENCIA);
  }
  else if (nombre == NULL)
  {
    printf("Error NULL nombre al asignar");
    exit(1);
  }
  else if (es_variable != VALOR_EXPLICITO && es_variable != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al asignar");
    exit(1);
  }

  if (es_variable == VALOR_REFERENCIA)
  {
    fprintf(fpasm, "\tPOP DWORD ECX\n");
    fprintf(fpasm, "\tMOV DWORD ECX, [ECX]\n");
    fprintf(fpasm, "\tMOV DWORD %s, ECX\n", nombre);
  }
  else
  {
    fprintf(fpasm, "\tPOP DWORD %s\n", nombre);
  }
}

void sumar(FILE *fpasm, int es_variable_1, int es_variable_2)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al sumar");
    exit(1);
  }
  else if (es_variable_1 != VALOR_EXPLICITO && es_variable_1 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al sumar");
    exit(1);
  }
  else if (es_variable_2 != VALOR_EXPLICITO && es_variable_2 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al sumar");
    exit(1);
  }

  asignar_reg(fpasm, "EBX", es_variable_2);
  asignar_reg(fpasm, "EAX", es_variable_1);

  fprintf(fpasm, "\tADD EAX, EBX\n");

  escribir_operando(fpasm, "EAX", VALOR_EXPLICITO);
}

/*Comprobar de aqui pa' bajo*/

void restar(FILE *fpasm, int es_variable_1, int es_variable_2)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al restar");
    exit(1);
  }
  else if (es_variable_1 != VALOR_EXPLICITO && es_variable_1 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al restar");
    exit(1);
  }
  else if (es_variable_2 != VALOR_EXPLICITO && es_variable_2 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al restar");
    exit(1);
  }

  asignar_reg(fpasm, "EBX", es_variable_2);
  asignar_reg(fpasm, "EAX", es_variable_1);

  fprintf(fpasm, "\tSUB EAX, EBX\n");

  escribir_operando(fpasm, "EAX", VALOR_EXPLICITO);
}

void multiplicar(FILE *fpasm, int es_variable_1, int es_variable_2)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al multiplicar");
    exit(1);
  }
  else if (es_variable_1 != VALOR_EXPLICITO && es_variable_1 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al multiplicar");
    exit(1);
  }
  else if (es_variable_2 != VALOR_EXPLICITO && es_variable_2 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al multiplicar");
    exit(1);
  }

  asignar_reg(fpasm, "EBX", es_variable_2);
  asignar_reg(fpasm, "EAX", es_variable_1);

  /*[EAX] = [EAX]*[EBX]*/
  fprintf(fpasm, "\tIMUL DWORD EBX\n");

  escribir_operando(fpasm, "EAX", VALOR_EXPLICITO);
}

void dividir(FILE *fpasm, int es_variable_1, int es_variable_2)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al dividir");
    exit(1);
  }
  else if (es_variable_1 != VALOR_EXPLICITO && es_variable_1 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al dividir");
    exit(1);
  }
  else if (es_variable_2 != VALOR_EXPLICITO && es_variable_2 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al dividir");
    exit(1);
  }

  asignar_reg(fpasm, "EBX", es_variable_2);
  asignar_reg(fpasm, "EAX", es_variable_1);

  //Comprobamos que no se divide entre cero
  fprintf(fpasm, "\tCMP EBX, 0\n");
  fprintf(fpasm, "\tJE div_0\n");

  //Ponemos a cero el registro que se usa para dividir
  fprintf(fpasm, "\tCDQ\n");

  fprintf(fpasm, "\tIDIV EBX\n");
  escribir_operando(fpasm, "EAX", VALOR_EXPLICITO);
}

void o(FILE *fpasm, int es_variable_1, int es_variable_2)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al sumar");
    exit(1);
  }
  else if (es_variable_1 != VALOR_EXPLICITO && es_variable_1 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al sumar");
    exit(1);
  }
  else if (es_variable_2 != VALOR_EXPLICITO && es_variable_2 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al sumar");
    exit(1);
  }

  asignar_reg(fpasm, "EBX", es_variable_2);
  asignar_reg(fpasm, "EAX", es_variable_1);

  fprintf(fpasm, "\tOR EAX, EBX\n");

  escribir_operando(fpasm, "EAX", VALOR_EXPLICITO);
}

void y(FILE *fpasm, int es_variable_1, int es_variable_2)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al sumar");
    exit(1);
  }
  else if (es_variable_1 != VALOR_EXPLICITO && es_variable_1 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al sumar");
    exit(1);
  }
  else if (es_variable_2 != VALOR_EXPLICITO && es_variable_2 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al sumar");
    exit(1);
  }

  asignar_reg(fpasm, "EBX", es_variable_2);
  asignar_reg(fpasm, "EAX", es_variable_1);

  fprintf(fpasm, "\tAND EAX, EBX\n");

  escribir_operando(fpasm, "EAX", VALOR_EXPLICITO);
}

void cambiar_signo(FILE *fpasm, int es_variable)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al sumar");
    exit(1);
  }
  else if (es_variable != VALOR_EXPLICITO && es_variable != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al sumar");
    exit(1);
  }

  asignar_reg(fpasm, "EAX", es_variable);

  fprintf(fpasm, "\tNEG EAX\n");

  escribir_operando(fpasm, "EAX", VALOR_EXPLICITO);
}

void no(FILE *fpasm, int es_variable, int cuantos_no)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al no");
    exit(1);
  }
  else if (es_variable != VALOR_EXPLICITO && es_variable != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al no");
    exit(1);
  }

  asignar_reg(fpasm, "EAX", es_variable);

  fprintf(fpasm, "\tCMP EAX, 0\n");
  fprintf(fpasm, "\tJE no_%d\n", cuantos_no);

  fprintf(fpasm, "\tPUSH DWORD 0\n");
  fprintf(fpasm, "\tJMP no_fin_%d\n", cuantos_no);

  fprintf(fpasm, "no_%d:\n", cuantos_no);
  fprintf(fpasm, "\tPUSH DWORD 1\n");

  fprintf(fpasm, "no_fin_%d:\n", cuantos_no);
}

void igual(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al igual");
    exit(1);
  }
  else if (es_variable1 != VALOR_EXPLICITO && es_variable1 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al igual");
    exit(1);
  }
  else if (es_variable2 != VALOR_EXPLICITO && es_variable2 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al igual");
    exit(1);
  }
  asignar_reg(fpasm, "EBX", es_variable2);
  asignar_reg(fpasm, "EAX", es_variable1);

  fprintf(fpasm, "\tCMP EAX, EBX\n");
  fprintf(fpasm, "\tJE es_igual_%d\n", etiqueta);

  // False: no es distinto
  fprintf(fpasm, "\tPUSH DWORD 0\n");
  fprintf(fpasm, "\tJMP igual_fin_%d\n", etiqueta);

  fprintf(fpasm, "es_igual_%d:\n", etiqueta);
  fprintf(fpasm, "\tPUSH DWORD 1\n");

  fprintf(fpasm, "igual_fin_%d:\n", etiqueta);
}



void menor(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al menor");
    exit(1);
  }
  else if (es_variable1 != VALOR_EXPLICITO && es_variable1 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al menor");
    exit(1);
  }
  else if (es_variable2 != VALOR_EXPLICITO && es_variable2 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al menor");
    exit(1);
  }
  asignar_reg(fpasm, "EBX", es_variable2);
  asignar_reg(fpasm, "EAX", es_variable1);

  fprintf(fpasm, "\tCMP EAX, EBX\n");
  fprintf(fpasm, "\tJL es_menor_%d\n", etiqueta);

  // False: no es menor
  fprintf(fpasm, "\tPUSH DWORD 0\n");
  fprintf(fpasm, "\tJMP menor_fin_%d\n", etiqueta);

  fprintf(fpasm, "es_menor_%d:\n", etiqueta);
  fprintf(fpasm, "\tPUSH DWORD 1\n");

  fprintf(fpasm, "menor_fin_%d:\n", etiqueta);
}

void mayor(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al mayor");
    exit(1);
  }
  else if (es_variable1 != VALOR_EXPLICITO && es_variable1 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al mayor");
    exit(1);
  }
  else if (es_variable2 != VALOR_EXPLICITO && es_variable2 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al mayor");
    exit(1);
  }
  asignar_reg(fpasm, "EBX", es_variable2);
  asignar_reg(fpasm, "EAX", es_variable1);

  fprintf(fpasm, "\tCMP EAX, EBX\n");
  fprintf(fpasm, "\tJG es_mayor_%d\n", etiqueta);

  // False: no es mayor
  fprintf(fpasm, "\tPUSH DWORD 0\n");
  fprintf(fpasm, "\tJMP mayor_fin_%d\n", etiqueta);

  fprintf(fpasm, "es_mayor_%d:\n", etiqueta);
  fprintf(fpasm, "\tPUSH DWORD 1\n");

  fprintf(fpasm, "mayor_fin_%d:\n", etiqueta);
}

void distinto(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al distinto");
    exit(1);
  }
  else if (es_variable1 != VALOR_EXPLICITO && es_variable1 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al distinto");
    exit(1);
  }
  else if (es_variable2 != VALOR_EXPLICITO && es_variable2 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al distinto");
    exit(1);
  }
  asignar_reg(fpasm, "EBX", es_variable2);
  asignar_reg(fpasm, "EAX", es_variable1);

  fprintf(fpasm, "\tCMP EAX, EBX\n");
  fprintf(fpasm, "\tJNE es_distinto_%d\n", etiqueta);

  // False: no es distinto
  fprintf(fpasm, "\tPUSH DWORD 0\n");
  fprintf(fpasm, "\tJMP distinto_fin_%d\n", etiqueta);

  fprintf(fpasm, "es_distinto_%d:\n", etiqueta);
  fprintf(fpasm, "\tPUSH DWORD 1\n");

  fprintf(fpasm, "distinto_fin_%d:\n", etiqueta);
}

void menor_igual(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al menor_igual");
    exit(1);
  }
  else if (es_variable1 != VALOR_EXPLICITO && es_variable1 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al menor_igual");
    exit(1);
  }
  else if (es_variable2 != VALOR_EXPLICITO && es_variable2 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al menor_igual");
    exit(1);
  }
  asignar_reg(fpasm, "EBX", es_variable2);
  asignar_reg(fpasm, "EAX", es_variable1);

  fprintf(fpasm, "\tCMP EAX, EBX\n");
  fprintf(fpasm, "\tJLE es_menor_igual_%d\n", etiqueta);

  // False: no es menor o igual
  fprintf(fpasm, "\tPUSH DWORD 0\n");
  fprintf(fpasm, "\tJMP menor_igual_fin_%d\n", etiqueta);

  fprintf(fpasm, "es_menor_igual_%d:\n", etiqueta);
  fprintf(fpasm, "\tPUSH DWORD 1\n");

  fprintf(fpasm, "menor_igual_fin_%d:\n", etiqueta);
}

void mayor_igual(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al mayor_igual");
    exit(1);
  }
  else if (es_variable1 != VALOR_EXPLICITO && es_variable1 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al mayor_igual");
    exit(1);
  }
  else if (es_variable2 != VALOR_EXPLICITO && es_variable2 != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al mayor_igual");
    exit(1);
  }
  asignar_reg(fpasm, "EBX", es_variable2);
  asignar_reg(fpasm, "EAX", es_variable1);

  fprintf(fpasm, "\tCMP EAX, EBX\n");
  fprintf(fpasm, "\tJGE es_mayor_igual_%d\n", etiqueta);

  // False: no es mayor o igual
  fprintf(fpasm, "\tPUSH DWORD 0\n");
  fprintf(fpasm, "\tJMP mayor_igual_fin_%d\n", etiqueta);

  fprintf(fpasm, "es_mayor_igual_%d:\n", etiqueta);
  fprintf(fpasm, "\tPUSH DWORD 1\n");

  fprintf(fpasm, "mayor_igual_fin_%d:\n", etiqueta);
}

void leer(FILE *fpasm, char *nombre, int tipo)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al leer");
    exit(1);
  }
  else if (nombre == NULL)
  {
    printf("Error NULL nombre al leer");
    exit(1);
  }
  else if (tipo != ENTERO && tipo != BOOLEANO)
  {
    printf("Error tipo mal definido al leer");
    exit(1);
  }

  fprintf(fpasm, "\tPUSH DWORD _%s\n", nombre);
  if (tipo == ENTERO)
  {
    fprintf(fpasm, "\tCALL scan_int\n");
  }
  else if (tipo == BOOLEANO)
  {
    fprintf(fpasm, "\tCALL scan_boolean\n");
  }
  fprintf(fpasm, "\tADD ESP, 4\n");
}


void escribir(FILE *fpasm, int es_variable, int tipo)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al escribir");
    exit(1);
  }
  else if (es_variable != VALOR_EXPLICITO && es_variable != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al escribir");
    exit(1);
  }
  else if (tipo != ENTERO && tipo != BOOLEANO)
  {
    printf("Error tipo mal definido al escribir");
    exit(1);
  }

  asignar_reg(fpasm, "EAX", es_variable);
  fprintf(fpasm, "\tPUSH DWORD EAX\n");
  if (tipo == ENTERO)
  {
    fprintf(fpasm, "\tCALL print_int\n");
    fprintf(fpasm, "\tCALL print_endofline\n");
  }
  else if (tipo == BOOLEANO)
  {
    fprintf(fpasm, "\tCALL print_boolean\n");
    fprintf(fpasm, "\tCALL print_endofline\n");
  }
  fprintf(fpasm, "\tADD ESP, 4\n");
}


void ifthenelse_inicio(FILE *fpasm, int exp_es_variable, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al ifthenesle_inicio");
    exit(1);
  }
  else if (exp_es_variable != VALOR_EXPLICITO && exp_es_variable != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al ifthenesle_inicio");
    exit(1);
  }
  asignar_reg(fpasm, "EAX", exp_es_variable);
  fprintf(fpasm, "\tCMP EAX, 0\n");
  fprintf(fpasm, "\tJE NEAR fin_then_%d\n", etiqueta);
}


void ifthen_inicio(FILE *fpasm, int exp_es_variable, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al ifthenesle_inicio");
    exit(1);
  }
  else if (exp_es_variable != VALOR_EXPLICITO && exp_es_variable != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al ifthenesle_inicio");
    exit(1);
  }
  asignar_reg(fpasm, "EAX", exp_es_variable);
  fprintf(fpasm, "\tCMP EAX, 0\n");
  fprintf(fpasm, "\tJE NEAR fin_then_%d\n", etiqueta);
}


void ifthen_fin(FILE *fpasm, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file ifthen_fin");
    exit(1);
  }
  fprintf(fpasm, "fin_then_%d:\n", etiqueta);
}


void ifthenelse_fin_then(FILE *fpasm, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file ifthenelse_fin_then");
    exit(1);
  }
  fprintf(fpasm, "\tJMP NEAR ifthenelse_fin_%d\n", etiqueta);
  fprintf(fpasm, "fin_then_%d:\n", etiqueta);
}


void ifthenelse_fin(FILE *fpasm, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file ifthenelse_fin");
    exit(1);
  }
  fprintf(fpasm, "ifthenelse_fin_%d:\n", etiqueta);
}


void while_inicio(FILE *fpasm, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file while_inicio");
    exit(1);
  }
  fprintf(fpasm, "while_ini_%d:\n", etiqueta);
}


void while_exp_pila(FILE *fpasm, int exp_es_variable, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file while_exp_pila");
    exit(1);
  }

  asignar_reg(fpasm, "EAX", exp_es_variable);

  // Si el cmp anterior era False while_fin
  fprintf(fpasm, "\tCMP EAX, 0\n");
  fprintf(fpasm, "\tJE while_fin_%d\n", etiqueta);
}


void while_fin(FILE *fpasm, int etiqueta)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file while_fin");
    exit(1);
  }
  fprintf(fpasm, "\tJMP while_ini_%d\n", etiqueta);
  fprintf(fpasm, "while_fin_%d:\n", etiqueta);
}


void escribir_elemento_vector(FILE *fpasm, char *nombre_vector,
                              int tam_max, int exp_es_direccion)
{
  if (fpasm == NULL || nombre_vector == NULL || tam_max < 0)
  {
    printf("Error NULL file al escribir_elemento_vector");
    exit(1);
  }
  else if (exp_es_direccion != VALOR_EXPLICITO && exp_es_direccion != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al escribir_elemento_vector");
    exit(1);
  }
  asignar_reg(fpasm, "EAX", exp_es_direccion);

  //Error si el indice es menor que cero
  fprintf(fpasm, "\tCMP EAX, 0\n");
  fprintf(fpasm, "\tJL NEAR fin_indice_fuera_rango\n");

  //Error si el indice supera el tamaño máximo
  fprintf(fpasm, "\tCMP EAX, %d\n", (tam_max - 1));
  fprintf(fpasm, "\tJG NEAR fin_indice_fuera_rango\n");

  //Guardamos en EDX la direccion del vector
  fprintf(fpasm, "\tMOV DWORD EDX, _%s\n", nombre_vector);

  //Guardamos en EAX el elemento del vector indicado por
  //el elmento superior de la pila
  fprintf(fpasm, "\tLEA EAX, [EDX + EAX*4]\n");
  fprintf(fpasm, "\tPUSH DWORD EAX\n");
}


void declararFuncion(FILE *fd_asm, char *nombre_funcion, int num_var_loc)
{
  if (fd_asm == NULL || nombre_funcion == NULL || num_var_loc < 0)
  {
    printf("Error al declararFuncion");
    exit(1);
  }
  fprintf(fd_asm, "%s:\n", nombre_funcion);
  fprintf(fd_asm, "\tPUSH DWORD EBP\n");
  fprintf(fd_asm, "\tMOV DWORD EBP, ESP\n");
  fprintf(fd_asm, "\tSUB ESP, %d\n", 4 * num_var_loc);
}

void retornarFuncion(FILE *fd_asm, int es_variable)
{
  if (fd_asm == NULL)
  {
    printf("Error NULL file al retornarFuncion");
    exit(1);
  }
  else if (es_variable != VALOR_EXPLICITO && es_variable != VALOR_REFERENCIA)
  {
    printf("Error tipo mal definido al retornarFuncion");
    exit(1);
  }
  asignar_reg(fd_asm, "EAX", es_variable);
  fprintf(fd_asm, "\tMOV DWORD ESP, EBP\n"); /* restaurar el puntero de pila */
  fprintf(fd_asm, "\tPOP DWORD EBP\n");      /* sacar de la pila ebp */
  fprintf(fd_asm, "\tret\n");
}

void escribirParametro(FILE *fpasm, int pos_parametro, int num_total_parametros)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al escribirParametro");
    exit(1);
  }
  else if (num_total_parametros < 0 || pos_parametro < 0)
  {
    printf("Error numero mal definido al escribirParametro");
    exit(1);
  }
  int d_ebp;
  d_ebp = 4 * (1 + num_total_parametros - pos_parametro);

  fprintf(fpasm, "\tLEA EAX, [EBP + %d]\n", d_ebp);
  fprintf(fpasm, "\tPUSH DWORD EAX\n");
}


void escribirVariableLocal(FILE *fpasm, int posicion_variable_local)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al escribirVariableLocal");
    exit(1);
  }
  else if (posicion_variable_local < 0)
  {
    printf("Error posicion_variable_local menor que 0 al escribirVariableLocal");
    exit(1);
  }

  int d_ebp;
  d_ebp = 4 * posicion_variable_local;

  fprintf(fpasm, "\tLEA EAX, [EBP - %d]\n", d_ebp);
  fprintf(fpasm, "\tPUSH DWORD EAX\n");
}


void asignarDestinoEnPila(FILE *fpasm, int es_variable)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al asignarDestinoEnPila\n");
    exit(1);
  }
  else if (es_variable != VALOR_EXPLICITO && es_variable != VALOR_REFERENCIA)
  {
    printf("Error es_variable mal definido al asignarDestinoEnPila\n");
    exit(1);
  }
  asignar_reg(fpasm, "EAX", VALOR_EXPLICITO); //direccion donde guardamos la variable o valor
  asignar_reg(fpasm, "EBX", es_variable);     //variable o valor a guardar
  fprintf(fpasm, "\tMOV DWORD [EAX], EBX\n");
}

void asignarDestinoEnPilaVector(FILE *fpasm, int es_variable)
{
  if (fpasm == NULL)
  {
    printf("Error NULL file al asignarDestinoEnPilaVector\n");
    exit(1);
  }
  else if (es_variable != VALOR_EXPLICITO && es_variable != VALOR_REFERENCIA)
  {
    printf("Error es_variable mal definido al asignarDestinoEnPilaVector\n");
    exit(1);
  }
  asignar_reg(fpasm, "EBX", es_variable);     //variable o valor a guardar
  asignar_reg(fpasm, "EAX", VALOR_EXPLICITO); //direccion donde guardamos la variable o valor
  fprintf(fpasm, "\tMOV DWORD [EAX], EBX\n");
}


void operandoEnPilaAArgumento(FILE *fd_asm, int es_variable)
{
  if (fd_asm == NULL)
  {
    printf("Error NULL file al operandoEnPilaAArgumento\n");
    exit(1);
  }
  else if (es_variable != VALOR_EXPLICITO && es_variable != VALOR_REFERENCIA)
  {
    printf("Error es_variable mal definido al operandoEnPilaAArgumento\n");
    exit(1);
  }

  if (es_variable == VALOR_REFERENCIA)
  {
    fprintf(fd_asm, "\tPOP DWORD EAX\n");
    fprintf(fd_asm, "\tMOV DWORD EAX, [EAX]\n");
    fprintf(fd_asm, "\tPUSH DWORD EAX\n");
  } // si es VALOR_EXPLICITO, el valor de la variable ya está en la pila
}


void llamarFuncion(FILE *fd_asm, char *nombre_funcion, int num_argumentos)
{
  if (fd_asm == NULL || nombre_funcion == NULL)
  {
    printf("Error NULL file al llamarFuncion\n");
    exit(1);
  }
  else if (num_argumentos < 0)
  {
    printf("Error numero de argumentos menor que 0 al llamarFuncion\n");
    exit(1);
  }

  fprintf(fd_asm, "\tCALL %s\n", nombre_funcion);
  limpiarPila(fd_asm, num_argumentos);
  fprintf(fd_asm, "\tPUSH DWORD EAX\n");
}

void limpiarPila(FILE *fd_asm, int num_argumentos)
{
  if (fd_asm == NULL)
  {
    printf("Error NULL file al limpiarPila\n");
    exit(1);
  }
  else if (num_argumentos < 0)
  {
    printf("Error numero de argumentos menor que 0 al limpiarPila\n");
    exit(1);
  }

  fprintf(fd_asm, "\tADD ESP, %d\n", num_argumentos * 4);
}
