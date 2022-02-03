#ifndef _ALFA_H

/*Definimos como función global el fichero de salida*/
extern FILE *yyout;

/*ES DIRECCION*/
#define VALOR_EXPLICITO 0
#define VALOR_REFERENCIA 1

/*TAMAÑOS*/
#define MAX_LONG_ID 100
#define MAX_TAMANIO_VECTOR 64

#define TRUE 1
#define FALSE 0

typedef struct _info_atributos info_atributos;

struct _info_atributos {
	char nombre[MAX_LONG_ID + 1];
	int valor_entero;
	int tipo; 			/*INT o BOOLEAN*/
	int es_direccion; 		/*atributo que indica si un símbolo representa una
						dirección de memoria o es un valor constante.*/
	int etiqueta; 			/*atributo necesario para gestión de sentencias
						condicionales e iterativas. Es un atributo
						definido exclusivamente para la generación de código.*/
};

/*ERRORES SEMANTICOS*/
enum _error_semantico
{
    DECLARACION_DUPLICADA,
    VARIABLE_NO_DECLARADA,
    OPERACION_ARITMETICA_BOOLEAN,
		OPERACION_LOGICA_INT,
		COMPARACION_BOOLEAN,
		CONDICIONAL_INT,
		BUCLE_INT,
		NUMERO_PARAMS_FUNC,
		ASIGN_INCOMPATIBLE,
		MAX_TAM_VECTOR,
		INDEX_NO_VECTOR,
		INDEX_INT,
		FUNC_NO_RETURN,
		RETURN_OUT_FUNC,
		PARAM_ES_FUNC,
		VAR_LOCAL_NO_ESCALAR,

		LECTURA_ERROR,
		RETORNO_DIFERENTE_TIPO,
		LLAMADA_NO_FUNCION,
		DIF_TIPOS,
		PARAM_ES_VECTOR,
		PARAM_FUN
};
typedef enum _error_semantico error_sem;


#endif
