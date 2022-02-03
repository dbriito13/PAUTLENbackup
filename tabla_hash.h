#ifndef HEADER_HASH
#define HEADER_HASH

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define MAX_SIZE 1048576
/*ELEMENT_CATEGORY*/
#define VARIABLE 1
#define PARAMETRO 2
#define FUNCION 3
/*BASIC TYPE*/
#define BOOLEAN 1
#define INT 2
/*CATEGORY*/
#define ESCALAR 1
#define VECTOR 2

/*Returning*/
#define ERROR -1
#define INSERTED 0
#define FOUND 1

#define NO_CHANGE -1

typedef struct Value value;
typedef struct Tuple tuple;
typedef struct Hash_table hash_table;

struct Value
{
  int element_category;
  int basic_type; /*tipo*/
  int category;   /*clase*/
  int size;       /*size will be 0 if the element is not a vector*/
  int num_params; /*These only apply if the element is a function*/
  int pos_param;
  int num_local_variables;
  int pos_local_variable;
};

struct Tuple
{
  char name[100];
  value *val;
};

struct Hash_table
{
  tuple **tuples;
  int n_elems;
};

hash_table *create_table();
int hash(char *name);
value *get(char *name, hash_table *hash_table);
int insert(char *name, int element_category, int basic_type, int category, int size,
           int num_params, int pos_param, int num_local_variables, int pos_local_variable, hash_table *ht);
int wipe(hash_table *ht);
int set(char *name, int element_category, int basic_type, int category,
        int size, int num_params, int pos_param, int num_local_variables,
        int pos_local_variable, hash_table *ht);

tuple **extract_table_contents(hash_table *ht);
void print_table(hash_table *ht);
#endif
