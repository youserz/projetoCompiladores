/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_ANALISADORSINTATICO_TAB_H_INCLUDED
# define YY_YY_ANALISADORSINTATICO_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 16 "analisadorSintatico.y"

    #include "analisadorSemantico.h"

#line 53 "analisadorSintatico.tab.h"

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    T_ID = 258,                    /* T_ID  */
    T_NUMBER = 259,                /* T_NUMBER  */
    T_STRING = 260,                /* T_STRING  */
    T_TRUE = 261,                  /* T_TRUE  */
    T_FALSE = 262,                 /* T_FALSE  */
    T_INT = 263,                   /* T_INT  */
    T_BOOL = 264,                  /* T_BOOL  */
    T_IF = 265,                    /* T_IF  */
    T_ELSE = 266,                  /* T_ELSE  */
    T_WHILE = 267,                 /* T_WHILE  */
    T_PRINT = 268,                 /* T_PRINT  */
    T_READ = 269,                  /* T_READ  */
    T_ASSIGN = 270,                /* T_ASSIGN  */
    T_EQ = 271,                    /* T_EQ  */
    T_NE = 272,                    /* T_NE  */
    T_LT = 273,                    /* T_LT  */
    T_LE = 274,                    /* T_LE  */
    T_GT = 275,                    /* T_GT  */
    T_GE = 276,                    /* T_GE  */
    T_AND = 277,                   /* T_AND  */
    T_OR = 278,                    /* T_OR  */
    T_NOT = 279,                   /* T_NOT  */
    T_PLUS = 280,                  /* T_PLUS  */
    T_MINUS = 281,                 /* T_MINUS  */
    T_TIMES = 282,                 /* T_TIMES  */
    T_DIV = 283,                   /* T_DIV  */
    T_SEMICOLON = 284,             /* T_SEMICOLON  */
    T_LPARENTESE = 285,            /* T_LPARENTESE  */
    T_RPARENTESE = 286,            /* T_RPARENTESE  */
    T_LCHAVES = 287,               /* T_LCHAVES  */
    T_RCHAVES = 288,               /* T_RCHAVES  */
    T_UMINUS = 289,                /* T_UMINUS  */
    T_IFX = 290                    /* T_IFX  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 20 "analisadorSintatico.y"

    char *lexeme;       
    DataType dtype;     
    ExprAttr expr;      

#line 111 "analisadorSintatico.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_ANALISADORSINTATICO_TAB_H_INCLUDED  */
