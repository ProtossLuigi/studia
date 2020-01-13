%code top{
    #include <iostream>
    #include <unordered_map>
    #define RESERVED_SLOTS 7
}
%code requires{
    #include <string>
    #include <vector>
    struct YYSTYPE{
        long long       intval;
        std::string     str;

        std::string     code;
        std::vector<std::pair<std::string,long long>>   instructions;
        int             lines = 0;
        bool            literal = false;
        bool            double_identifier = false;
        long long       second_identifier;
    };
}
%code {
    int yylex();
    int yyerror(const char *);
    extern FILE *yyin;
    extern FILE *yyout;

    struct variable {
        std::string     name;
        long long       loc;
        bool            arr = false;
        long long       begin;
        long long       end;
    };

    bool error = false;
    long long no_variables = 0;
    std::unordered_map<std::string,struct variable> global_variables;

    std::vector<std::pair<std::string,long long>> ll_to_instructions(long long x) {
        std::vector<std::pair<std::string,long long>> v;
        v.emplace_back("SUB",0);
        if (x != 0) {
            bool neg = x < 0;
            if (neg) {
                x = -x;
            }
            std::vector<bool> bin;
            while (x > 0) {
                bin.push_back(x & 1);
                x = x >> 1;
            }
            for (int i = bin.size()-1; i >= 0; i--) {
                if (bin[i]) {
                    if (neg) {
                        v.emplace_back("DEC",0);
                    } else {
                        v.emplace_back("INC",0);
                    }
                }
                if (i > 0) {
                    v.emplace_back("SHIFT",1);
                }
            }
        }
        return v;
    }

    void move_jumps(int n, std::vector<std::pair<std::string,long long>> &instructions){
        for (std::pair<std::string,long long> &instruction : instructions) {
            if (instruction.first.compare("JUMP") == 0 || instruction.first.compare("JPOS") == 0 || instruction.first.compare("JZERO") == 0 || instruction.first.compare("JNEG") == 0) {
                instruction.second += n;
            }
        }
    }

    void print_instructions(std::vector<std::pair<std::string,long long>> instructions) {
        std::string program;
        for (std::pair<std::string,long long> instruction : instructions) {
            if (instruction.first.compare("GET") == 0 || instruction.first.compare("PUT") == 0 || instruction.first.compare("INC") == 0 || instruction.first.compare("DEC") == 0){
                program += instruction.first + "\n";
            } else {
                program += instruction.first + " " + std::to_string(instruction.second) + "\n";
            }
        }
        program += "HALT";
        fprintf(yyout,"%s",program.c_str());
    }

    template <typename T> std::vector<T> operator+(const std::vector<T> &a, const std::vector<T> &b){
        std::vector<T> v = a;
        v.insert(v.end(),b.begin(),b.end());
        return v;
    }

    template <typename T> std::vector<T> operator+=(std::vector<T> &a, const std::vector<T> &b){
        a.insert(a.end(),b.begin(),b.end());
        return a;
    }
}
%define api.value.type {struct YYSTYPE}
%token num
%token pidentifier
%token DECLARE BEG END
%token COMMA COLON SEMICOLON
%token READ WRITE
%token ASSIGN
%token LPAR RPAR
%token PLUS MINUS TIMES DIV MOD
%token EQ NEQ LE GE LEQ GEQ
%token IF ELSE THEN ENDIF
%token WHILE ENDWHILE DO ENDDO FOR FROM TO DOWNTO ENDFOR
%%
program:          DECLARE declarations BEG commands END                                         {
                                                                                                $$.instructions.emplace_back("INC",0);
                                                                                                $$.instructions.emplace_back("STORE",1);
                                                                                                move_jumps(2,$4.instructions);
                                                                                                $$.instructions += $4.instructions;
                                                                                                print_instructions($$.instructions);
                                                                                                }
                | BEG commands END                                                              {
                                                                                                $$.instructions.emplace_back("INC",0);
                                                                                                $$.instructions.emplace_back("STORE",1);
                                                                                                move_jumps(2,$2.instructions);
                                                                                                $$.instructions += $2.instructions;
                                                                                                print_instructions($$.instructions);
                                                                                                }
                | error                                                                         {yyerror(nullptr);}
;
declarations:     declarations COMMA pidentifier                                                {
                                                                                                struct variable new_var = {$3.str,no_variables+RESERVED_SLOTS,false,0,0};
                                                                                                global_variables.emplace(new_var.name,new_var);
                                                                                                no_variables++;
                                                                                                }
                | declarations COMMA pidentifier LPAR num COLON num RPAR                        {
                                                                                                struct variable new_var = {$3.str,RESERVED_SLOTS-$5.intval,true,$5.intval,$7.intval};
                                                                                                global_variables.emplace(new_var.name,new_var);
                                                                                                no_variables += new_var.end - new_var.begin + 1;
                                                                                                }
                | pidentifier                                                                   {
                                                                                                struct variable new_var = {$1.str,RESERVED_SLOTS,false,0,0};
                                                                                                global_variables.emplace(new_var.name,new_var);
                                                                                                no_variables = 1;
                                                                                                }
                | pidentifier LPAR num COLON num RPAR                                           {
                                                                                                struct variable new_var = {$1.str,RESERVED_SLOTS-$3.intval,true,$3.intval,$5.intval};
                                                                                                global_variables.emplace(new_var.name,new_var);
                                                                                                no_variables = new_var.end - new_var.begin + 1;
                                                                                                }
;
commands:         commands command                                                              {
                                                                                                move_jumps($1.instructions.size(),$2.instructions);
                                                                                                $$.instructions = $1.instructions + $2.instructions;
                                                                                                }
                | command                                                                       {
                                                                                                $$.instructions = $1.instructions;
                                                                                                }
;
command:          identifier ASSIGN expression SEMICOLON                                        {
                                                                                                if ($1.double_identifier) {
                                                                                                    $$.instructions = ll_to_instructions($1.intval);
                                                                                                    $$.instructions.emplace_back("ADD",$1.second_identifier);
                                                                                                    $$.instructions.emplace_back("STORE",2);
                                                                                                    move_jumps($$.instructions.size(),$3.instructions);
                                                                                                    $$.instructions += $3.instructions;
                                                                                                    $$.instructions.emplace_back("STOREI",2);
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE",$1.intval);
                                                                                                }
                                                                                                }
                | IF condition THEN commands ELSE commands ENDIF                                //TODO
                | IF condition THEN commands ENDIF                                              //TODO
                | WHILE condition DO commands ENDWHILE                                          //TODO
                | DO commands WHILE condition ENDDO                                             //TODO
                | FOR pidentifier FROM value TO value DO commands ENDFOR                        //TODO
                | FOR pidentifier FROM value DOWNTO value DO commands ENDFOR                    //TODO
                | READ identifier SEMICOLON                                                     {
                                                                                                if ($2.double_identifier) {
                                                                                                    $$.instructions = ll_to_instructions($2.intval);
                                                                                                    $$.instructions.emplace_back("ADD",$2.second_identifier);
                                                                                                    $$.instructions.emplace_back("STORE",2);
                                                                                                    $$.instructions.emplace_back("GET",0);
                                                                                                    $$.instructions.emplace_back("STOREI",2);
                                                                                                } else {
                                                                                                    $$.instructions.emplace_back("GET",0);
                                                                                                    $$.instructions.emplace_back("STORE",$2.intval);
                                                                                                }
                                                                                                }
                | WRITE value SEMICOLON                                                         {
                                                                                                $$.instructions = $2.instructions;
                                                                                                $$.instructions.emplace_back("PUT",0);
                                                                                                }
;
expression:       value                                                                         {
                                                                                                $$ = $1;
                                                                                                }
                | value PLUS value                                                              {
                                                                                                if ($1.literal && $3.literal) {
                                                                                                    $$.instructions = ll_to_instructions($1.intval + $3.intval);
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("ADD",3);
                                                                                                }
                                                                                                }
                | value MINUS value                                                             {
                                                                                                if ($1.literal && $3.literal) {
                                                                                                    $$.instructions = ll_to_instructions($1.intval - $3.intval);
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                }
                                                                                                }
                | value TIMES value                                                             {
                                                                                                if ($1.literal && $3.literal) {
                                                                                                    $$.instructions = ll_to_instructions($1.intval * $3.intval);
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE",4);
                                                                                                    $$.instructions.emplace_back("JPOS",$$.instructions.size()+2);
                                                                                                    $$.instructions.emplace_back("SUB",4);
                                                                                                    $$.instructions.emplace_back("SUB",4);
                                                                                                    $$.instructions.emplace_back("STORE",5);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions.emplace_back("JPOS",$$.instructions.size()+3);
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                    $$.instructions.emplace_back("SUB",5);
                                                                                                    $$.instructions.emplace_back("JPOS",$$.instructions.size()+13);
                                                                                                    $$.instructions.emplace_back("SUB",0);
                                                                                                    $$.instructions.emplace_back("STORE",5);
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                    $$.instructions.emplace_back("JPOS",$$.instructions.size()+22);
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+36);
                                                                                                    $$.instructions.emplace_back("STORE",6);
                                                                                                    $$.instructions.emplace_back("LOAD",5);
                                                                                                    $$.instructions.emplace_back("ADD",4);
                                                                                                    $$.instructions.emplace_back("STORE",5);
                                                                                                    $$.instructions.emplace_back("LOAD",6);
                                                                                                    $$.instructions.emplace_back("INC",0);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()-7);
                                                                                                    $$.instructions.emplace_back("SUB",0);
                                                                                                    $$.instructions.emplace_back("STORE",5);
                                                                                                    $$.instructions.emplace_back("SUB",4);
                                                                                                    $$.instructions.emplace_back("JPOS",$$.instructions.size()+18);
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+24);
                                                                                                    $$.instructions.emplace_back("STORE",6);
                                                                                                    $$.instructions.emplace_back("LOAD",5);
                                                                                                    $$.instructions.emplace_back("ADD",3);
                                                                                                    $$.instructions.emplace_back("STORE",5);
                                                                                                    $$.instructions.emplace_back("LOAD",6);
                                                                                                    $$.instructions.emplace_back("INC",0);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()-7);
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+16);
                                                                                                    $$.instructions.emplace_back("STORE",6);
                                                                                                    $$.instructions.emplace_back("LOAD",5);
                                                                                                    $$.instructions.emplace_back("SUB",4);
                                                                                                    $$.instructions.emplace_back("STORE",5);
                                                                                                    $$.instructions.emplace_back("LOAD",6);
                                                                                                    $$.instructions.emplace_back("DEC",0);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()-7);
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+8);
                                                                                                    $$.instructions.emplace_back("STORE",6);
                                                                                                    $$.instructions.emplace_back("LOAD",5);
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                    $$.instructions.emplace_back("STORE",5);
                                                                                                    $$.instructions.emplace_back("LOAD",6);
                                                                                                    $$.instructions.emplace_back("DEC",0);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()-7);
                                                                                                    $$.instructions.emplace_back("LOAD",5);
                                                                                                }
                                                                                                }
                | value DIV value                                                               {
                                                                                                if ($3.literal && $3.intval == 0) {
                                                                                                    $$.instructions.emplace_back("SUB",0);
                                                                                                } else if ($1.literal && $3.literal) {
                                                                                                    $$.instructions = ll_to_instructions($1.intval / $3.intval);
                                                                                                } else {
                                                                                                    //TODO
                                                                                                }
                                                                                                }
                | value MOD value                                                               {
                                                                                                if ($3.literal && $3.intval == 0) {
                                                                                                    $$.instructions.emplace_back("SUB",0);
                                                                                                } else if ($1.literal && $3.literal) {
                                                                                                    long long val = $1.intval % $3.intval;
                                                                                                    if (val * $3.intval < 0) {
                                                                                                        val += $3.intval;
                                                                                                    }
                                                                                                    $$.instructions = ll_to_instructions(val);
                                                                                                } else {
                                                                                                    //TODO
                                                                                                }
                                                                                                }
;
condition:        value EQ value                                                                //TODO
                | value NEQ value                                                               //TODO
                | value LE value                                                                //TODO
                | value GE value                                                                //TODO
                | value LEQ value                                                               //TODO
                | value GEQ value                                                               //TODO
;
value:            num                                                                           {
                                                                                                $$.literal = true;
                                                                                                $$.intval = $1.intval;
                                                                                                $$.instructions = ll_to_instructions($$.intval);
                                                                                                }
                | identifier                                                                    {
                                                                                                if ($1.double_identifier) {
                                                                                                    $$.instructions = ll_to_instructions($1.intval);
                                                                                                    $$.instructions.emplace_back("ADD",$1.second_identifier);
                                                                                                    $$.instructions.emplace_back("LOADI",0);
                                                                                                } else {
                                                                                                    $$.instructions.emplace_back("LOAD",$1.intval);
                                                                                                }
                                                                                                }
;
identifier:       pidentifier                                                                   {
                                                                                                if (global_variables.count($1.str)) {
                                                                                                    struct variable var = global_variables[$1.str];
                                                                                                    if (!var.arr) {
                                                                                                        $$.intval = global_variables[$1.str].loc;
                                                                                                    } else {
                                                                                                        error = true;
                                                                                                        std::string msg = "variable '" + var.name + "' is an array"; //TODO
                                                                                                        yyerror(msg.c_str());
                                                                                                    }
                                                                                                } else {
                                                                                                    error = true;
                                                                                                    std::string msg = "unknown variable '" + $1.str + "'"; //TODO
                                                                                                    yyerror(msg.c_str());
                                                                                                }
                                                                                                }
                | pidentifier LPAR pidentifier RPAR                                             {
                                                                                                if (global_variables.count($1.str) && global_variables.count($3.str)) {
                                                                                                    struct variable var1 = global_variables[$1.str];
                                                                                                    struct variable var2 = global_variables[$3.str];
                                                                                                    if (!var1.arr) {
                                                                                                        error = true;
                                                                                                        std::string msg = "variable '" + var1.name + "' not an array"; //TODO
                                                                                                        yyerror(msg.c_str());
                                                                                                    } else if (var2.arr) {
                                                                                                        error = true;
                                                                                                        std::string msg = "variable '" + var2.name + "' is an array"; //TODO
                                                                                                        yyerror(msg.c_str());
                                                                                                    } else {
                                                                                                        $$.double_identifier = true;
                                                                                                        $$.intval = var1.loc;
                                                                                                        $$.second_identifier = var2.loc;
                                                                                                    }
                                                                                                } else {
                                                                                                    error = true;
                                                                                                    if (!global_variables.count($1.str)) {
                                                                                                        std::string msg = "unknown variable '" + $1.str + "'"; //TODO
                                                                                                        yyerror(msg.c_str());
                                                                                                    }
                                                                                                    if (!global_variables.count($3.str)) {
                                                                                                        std::string msg = "unknown variable '" + $3.str + "'"; //TODO
                                                                                                        yyerror(msg.c_str());
                                                                                                    }
                                                                                                }
                                                                                                }
                | pidentifier LPAR num RPAR                                                     {
                                                                                                if (global_variables.count($1.str)) {
                                                                                                    struct variable var = global_variables[$1.str];
                                                                                                    if (var.arr) {
                                                                                                        if ($3.intval >= var.begin && $3.intval <= var.end) {
                                                                                                            $$.intval = var.loc + $3.intval;
                                                                                                        } else {
                                                                                                            error = true;
                                                                                                            std::string msg = "array index out of bounds '" + $1.str + "(" + std::to_string($3.intval) + ")'"; //TODO
                                                                                                            yyerror(msg.c_str());
                                                                                                        }
                                                                                                    } else {
                                                                                                        error = true;
                                                                                                        std::string msg = "variable '" + $1.str + "' not an array"; //TODO
                                                                                                        yyerror(msg.c_str());
                                                                                                    }
                                                                                                } else {
                                                                                                    error = true;
                                                                                                    std::string msg = "unknown variable '" + $1.str + "'"; //TODO
                                                                                                    yyerror(msg.c_str());
                                                                                                }
                                                                                                }
;
%%

int yyerror(const char* s){
    if (s == nullptr){
        std::cerr << "Error" << std::endl;
    } else {
        std::cerr << "Error: " << std::string(s) << std::endl;
    }
}

int main(int argc,char** argv){
    if (argc < 2){
        yyin = stdin;
    } else {
        yyin = fopen(argv[1], "r");
    }
    if (argc < 3){
        yyout = stdout;
    } else {
        yyout = fopen(argv[2], "w");
    }
    yyparse();
    fclose(yyin);
    fclose(yyout);
    return 0;
}