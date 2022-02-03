#include "tabla_hash.h"

hash_table *create_table()
{
  hash_table *ht = NULL;
  ht = (hash_table *)calloc(sizeof(hash_table), 1);
  if (ht == NULL)
  {
    printf("Error creating the hash table!");
    exit(1);
  }
  ht->n_elems = 0;
  ht->tuples = NULL;
  ht->tuples = (tuple **)calloc(sizeof(tuple*), MAX_SIZE);
  if (ht->tuples == NULL)
  {
    printf("Error creating tuples for the hash table!");
    exit(1);
  }

  return ht;
}

int hash(char *name)
{
  int hash_val = 5381;
  int c;

  while ((c = *name++))
  {
    hash_val = ((hash_val << 5) + hash_val) + c; /* hash * 33 + c */
  }

  return (abs(hash_val) % MAX_SIZE);
}

value *get(char *name, hash_table *ht)
{
  int hash_val = 0;
  tuple *tuple_found;
  int i;
  hash_val = hash(name);
  for (i = 0; i < MAX_SIZE; i++)
  {
    tuple_found = ht->tuples[hash_val];
    if (tuple_found == NULL)
    {
      return NULL;
    }
    else if (strcmp(tuple_found->name, name) == 0)
    {
      return tuple_found->val;
    }
    else
    {
      /*Si encuentras algo y no es la tuple a insertar, colisión.*/
      hash_val = (hash_val + 1) % MAX_SIZE;
    }
  }
  return NULL;
}

int insert(char *name, int element_category, int basic_type, int category,
           int size, int num_params, int pos_param, int num_local_variables,
           int pos_local_variable, hash_table *ht)
{
  int i;
  int hash_val = 0;
  tuple *tuple_found = NULL;
  tuple *tuple_new = NULL;
  value *val = NULL;

  hash_val = hash(name);
  tuple_found = NULL;

  for (i = 0; i < MAX_SIZE; i++)
  {
    tuple_found = ht->tuples[hash_val];
    if (tuple_found == NULL)
    {
      /*Creamos el val*/
      val = (value *)malloc(sizeof(value));
      val->element_category = element_category;
      val->basic_type = basic_type;
      val->category = category;
      val->size = size;
      val->num_params = num_params;
      val->pos_param = pos_param;
      val->num_local_variables = num_local_variables;
      val->pos_local_variable = pos_local_variable;

      /*Creamos la tupla*/
      tuple_new = (tuple*)malloc(sizeof(tuple));
      strcpy(tuple_new->name, name);
      tuple_new->val = val;
      ht->tuples[hash_val] = tuple_new;
      ht->n_elems += 1;
      return INSERTED;
    }
    else if (strcmp(tuple_found->name, name) == 0)
    {
      return FOUND;
    }
    else
    {
      /*Si encuentras algo y no es la tuple a insertar, colisión.*/
      hash_val = (hash_val + 1) % MAX_SIZE;
    }
  }
  return ERROR;
}

int set(char *name, int element_category, int basic_type, int category,
        int size, int num_params, int pos_param, int num_local_variables,
        int pos_local_variable, hash_table *ht)
{
  value *val;
  val = get(name, ht);
  if (val != NULL)
  {
    if (element_category != NO_CHANGE)
      val->element_category = element_category;
    if (basic_type != NO_CHANGE)
      val->basic_type = basic_type;
    if (category != NO_CHANGE)
      val->category = category;
    if (size != NO_CHANGE)
      val->size = size;
    if (num_params != NO_CHANGE)
      val->num_params = num_params;
    if (pos_param != NO_CHANGE)
      val->pos_param = pos_param;
    if (num_local_variables != NO_CHANGE)
      val->num_local_variables = num_local_variables;
    if (pos_local_variable != NO_CHANGE)
      val->pos_local_variable = pos_local_variable;
    return INSERTED;
  }
  else
  {
    return ERROR;
  }
}

int wipe(hash_table *ht)
{
  int i;
  if (ht == NULL)
  {
    return -1;
  }
  for (i = 0; i < MAX_SIZE; i++)
  {
    if (ht->tuples[i] != NULL)
    {
      if(ht->tuples[i]->val != NULL){
        free(ht->tuples[i]->val);
      }
      /*If the element at hash position i exists we free it*/
      free(ht->tuples[i]);
    }
  }
  if(ht->tuples != NULL){
    free(ht->tuples);
  }
  free(ht);
  return 0;
}

tuple **extract_table_contents(hash_table *ht)
{
  int i = 0;
  int index = 0;
  tuple **content = (tuple**)calloc(sizeof(tuple*), ht->n_elems);

  for (i = 0; i < MAX_SIZE; i++)
  {
    if (ht->tuples[i] != NULL)
    {
      content[index] = ht->tuples[i];
      index++;
    }
  }
  return content;
}

void print_table(hash_table *ht){
  int i;
  tuple **contents;
  contents = extract_table_contents(ht);
  for(i = 0; i < ht->n_elems; i++){
    printf("%s: tipo %d, size %d\n", contents[i]->name, contents[i]->val->basic_type, contents[i]->val->size);
  }
}
