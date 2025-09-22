%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
FILE *resultado_analisis_lexico;
const char *pr[] = {"alternative","big","evaluate",
                    "instead","large","loop","make",
                    "number","other","real",
                    "repeat","select","small","step",
                    "stop","symbol","throw"};
const int pr_len = 17;
const char *opari[] = {"+","-","*","/","%","\\", "^"};
const int opari_len = 7;
const char *opasi[] = {"="};
const int opasi_len = 1;
const char *se[] = {"{","}","(",")","[","]",",",":",";"};
const int se_len = 9;
const char *oprel[] = {"<",">","<=",">=","==","!="};
const int oprel_len = 6;
char **tabla_simbolos;
int t_tabla_simbolos = 0;
char **tabla_literales_enteros;
int t_tabla_literales_enteros = 0;
char **tabla_literales_reales;
int t_tabla_literales_reales = 0;
char **tabla_literales_cadenas;
int t_tabla_literales_cadenas = 0;
int busquedaLinealValor(const char *objetivo,const char **catalogo, const int lon_catalogo)
{
    int i;
    for(i = 0; i < lon_catalogo;  i++)
    {
        if(strcmp(objetivo, *(catalogo + i)) == 0)
            return i;
    }
    return -1;
}
void agregar_cadena(char ***tabla, int *tamano, const char *cadena) {
    // Incrementar el tamaño del arreglo
    (*tamano)++;

    // Redimensionar el arreglo de punteros
    *tabla = realloc(*tabla, (*tamano) * sizeof(char *));

    // Reservar memoria para la nueva cadena y copiarla
    (*tabla)[*tamano - 1] = malloc((strlen(cadena) + 1) * sizeof(char));
    strcpy((*tabla)[*tamano - 1], cadena);
}
void liberar_arreglo(char **arreglo, int tamano) 
{
    int i;
    for (int i = 0; i < tamano; i++) 
        free(arreglo[i]); // Liberar cada cadena

    free(arreglo); // Liberar el arreglo de punteros
}
void escribir_tabla(char **tabla, int tamano, FILE *salida, int sim)
{
    int i;
    if(sim == 0)
    {
        for(i = 0; i < tamano; i++)
            fprintf(salida,"%i %s %i\n",i,tabla[i],-1);
    }

    else
    {
        for(i = 0; i < tamano; i++)
            fprintf(salida,"%i %s\n",i,tabla[i]);
    }
}
int norepetido(char **tabla, int tamano, const char *var)
{
    int i;
    for(i = 0; i < tamano; i++)
    {
        if(strcmp(var, tabla[i])== 0)
            return i;
    }
    return -1;
}
%}
espacio [ ]
tab \t
nuevaL \n
delimitador ({espacio}|{tab}|{nuevaL})+
letM [A-Z]
letm [a-z]
leta [áéíóúñ]
letA [ÁÉÍÓÚÑ]
dig [0-9]
identificador \$({letM}|{letm}|{leta}|{letA})+
entero (0)|[1-9]+|[Oo][1-7]+
real {dig}?\.{dig}*
cadena ('[^\"']')|(\"'\")|(\"[^\"']{2,}\")
/*"*/
prx alternative
pr0 big
pr1 evaluate
pr2 instead
pr3 large
pr4 loop
pr5 make
pr6 number
pr7 other
pr8 real
pr9 repeat
pr10 select
pr11 small
pr12 step
pr13 stop
pr14 symbol
pr15 throw
pr ({pr0}|{pr1}|{pr2}|{pr3}|{pr4}|{pr5}|{pr6}|{pr7}|{pr8}|{pr9}|{pr10}|{pr11}|{pr12}|{pr13}|{pr14}|{pr15}|{prx})
opari0 \+
opari1 -
opari2 \*
opari3 \/
opari4 %
opari5 \\
opari6 \^
opari ({opari0}|{opari1}|{opari2}|{opari3}|{opari4}|{opari5}|{opari6})
opasi0 =
opasi ({opasi0})
se0 \{
se1 \}
se2 \(
se3 \)
se4 \[
se5 \]
se6 ,
se7 ;
se8 :
se ({se0}|{se1}|{se2}|{se3}|{se4}|{se5}|{se6}|{se7}|{se8})
oprel0 <
oprel1 > 
oprel2 <=
oprel3 >=
oprel4 ==
oprel5 !=
oprel ({oprel0}|{oprel1}|{oprel2}|{oprel3}|{oprel4}|{oprel5})
error (.)
%%
{delimitador}   { /* Ignorar delimitadores - no hacer nada */ }
{pr} fprintf(resultado_analisis_lexico,"%s (%i,%i)\n",yytext, 0, busquedaLinealValor(yytext,pr,pr_len));

{identificador} {
            int resultado = norepetido(tabla_simbolos,t_tabla_simbolos,yytext);
            if(resultado == -1)
            {
                agregar_cadena(&tabla_simbolos,&t_tabla_simbolos,yytext);
                fprintf(resultado_analisis_lexico,"%s (%i,%i)\n",yytext, 1, t_tabla_simbolos - 1);
            }
            else
            fprintf(resultado_analisis_lexico,"%s (%i,%i)\n",yytext, 1, resultado);
}

{entero} {
            agregar_cadena(&tabla_literales_enteros,&t_tabla_literales_enteros, yytext);
            fprintf(resultado_analisis_lexico,"%s (%i,%i)\n",yytext, 2, t_tabla_literales_enteros - 1);
        }
{real} {
            int resultado = norepetido(tabla_literales_reales,t_tabla_literales_reales,yytext);
            if(resultado == -1)
            {
                agregar_cadena(&tabla_literales_reales,&t_tabla_literales_reales,yytext);
                fprintf(resultado_analisis_lexico,"%s (%i,%i)\n",yytext, 3, t_tabla_literales_reales - 1);
            }
            else
            fprintf(resultado_analisis_lexico,"%s (%i,%i)\n",yytext, 3, resultado);
        }

{cadena} {
            int resultado = norepetido(tabla_literales_cadenas,t_tabla_literales_cadenas,yytext);
            if(resultado == -1)
            {
                agregar_cadena(&tabla_literales_cadenas,&t_tabla_literales_cadenas,yytext);
                fprintf(resultado_analisis_lexico,"%s (%i,%i)\n",yytext, 4, t_tabla_literales_cadenas - 1);
            }
            else
            fprintf(resultado_analisis_lexico,"%s (%i,%i)\n",yytext, 4, resultado);
        }

{se} fprintf(resultado_analisis_lexico,"%s (%i,%s)\n",yytext, 5, yytext);
{opari} fprintf(resultado_analisis_lexico,"%s (%i,%s)\n",yytext, 6, yytext);
{oprel} fprintf(resultado_analisis_lexico,"%s (%i,%i)\n",yytext, 7, busquedaLinealValor(yytext,oprel,oprel_len));
{opasi} fprintf(resultado_analisis_lexico,"%s (%i,%i)\n",yytext, 8, busquedaLinealValor(yytext,opasi,opasi_len));
{error} {}
%%
int main(int argc, char **argv) 
{
    if(argc < 2)
    {
        printf("DEBE ESPECIFICAR NOMBRE DEL ARCHIVO QUE SERÁ ANALIZADO\n");
        return -1;
    }
    yyin = fopen(argv[1],"r");
    if(yyin == NULL)
    {
        printf("ESPECIFIQUE UN ARCHIVO VÁLIDO PARA ANALIZAR\n");
        return -1;
    }
    resultado_analisis_lexico = fopen("salida.txt","w");
    yylex();
    int i;
    if(t_tabla_simbolos > 0)
    {
        fprintf(resultado_analisis_lexico,"\n\nPos.| Nombre | Tipo\n");
        escribir_tabla(tabla_simbolos, t_tabla_simbolos, resultado_analisis_lexico, 0);
        liberar_arreglo(tabla_simbolos, t_tabla_simbolos);
    }
        
    if(t_tabla_literales_cadenas > 0)
    {
        fprintf(resultado_analisis_lexico,"\n\nPos.| Dato\n");
        escribir_tabla(tabla_literales_cadenas, t_tabla_literales_cadenas, resultado_analisis_lexico, 1);
        liberar_arreglo(tabla_literales_cadenas, t_tabla_literales_cadenas);
    }
        
    if(t_tabla_literales_enteros > 0)
    {
        fprintf(resultado_analisis_lexico,"\n\nPos.| Dato\n");
        escribir_tabla(tabla_literales_enteros, t_tabla_literales_enteros, resultado_analisis_lexico, 1);
        liberar_arreglo(tabla_literales_enteros, t_tabla_literales_enteros);
    }
    if(t_tabla_literales_reales > 0)
    {
        fprintf(resultado_analisis_lexico,"\n\nPos.| Dato\n");
        escribir_tabla(tabla_literales_reales, t_tabla_literales_reales, resultado_analisis_lexico, 1);
        liberar_arreglo(tabla_literales_reales, t_tabla_literales_reales);
    }
    fclose(resultado_analisis_lexico);
    return 0;
}