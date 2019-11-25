%{
    #include <iostream>
    #include <cmath>
    #include <string>
    #include <queue>
    int yylex();
    int yyerror(const char*);
    std::queue<std::string> q;
%}
%define api.value.type {int}
%token VAL
%left ADD SUB
%left MUL DIV MOD
%precedence NEG
%right POW
%token LNAW
%token RNAW
%token END
%token ERROR
%%
input:
    | input line
;
line: exp END   {
                while(!q.empty()){
                    std::cout << q.front() << " ";
                    q.pop();
                }
                std::cout << std::endl << "Result:\t" << $1 << std::endl;
                }
    | END
    | error END {yyerror(nullptr);}
;
exp:
      VAL           {q.push(std::to_string(yylval));}
    | exp ADD exp   {$$ = $1 + $3; q.push("+");}
    | exp SUB exp   {$$ = $1 - $3; q.push("-");}
    | exp MUL exp   {$$ = $1 * $3; q.push("*");}
    | exp DIV exp   {$$ = $1 / $3; q.push("/");}
    | exp MOD exp   {$$ = $1 % $3; if($$ * $3 < 0){$$ += $3;} q.push("%");}
    | SUB exp %prec NEG {$$ = -$2; q.push("~");}
    | exp POW exp   {$$ = pow($1,$3); q.push("^");}
    | LNAW exp RNAW {$$ = $2;}
;
%%
int yyerror(const char* s){
    std::cout << "Error" << std::endl;
}
int main(){
    yyparse();
    return 0;
}