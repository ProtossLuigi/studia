%code top{
    #include <iostream>
    #define RESERVED_SLOTS 7
}
%code requires{
    #include <string>
    #include <vector>
    #include <unordered_map>

    struct variable {
        std::string     name;
        long long       loc;
        bool            arr = false;
        long long       begin;
        long long       end;
    };

    struct YYSTYPE{
        long long       intval;
        std::string     str;

        std::vector<std::pair<std::string,long long>>   instructions;
        std::unordered_map<std::string,struct variable> local_variables;
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

    

    bool error = false;
    long long no_global_variables = 0;
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

    void sync_local_vars(struct YYSTYPE &command1,struct YYSTYPE &command2) {
        std::unordered_map<std::string,struct variable> new_local_variables = command1.local_variables;
        int no_vars1 = command1.local_variables.size();
        std::unordered_map<long long,long long> memory_changes;
        for (auto it = command2.local_variables.begin(); it != command2.local_variables.end(); it++) {

        }
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
                                                                                                struct variable new_var = {$3.str,no_global_variables+RESERVED_SLOTS,false,0,0};
                                                                                                global_variables.emplace(new_var.name,new_var);
                                                                                                no_global_variables++;
                                                                                                }
                | declarations COMMA pidentifier LPAR num COLON num RPAR                        {
                                                                                                struct variable new_var = {$3.str,RESERVED_SLOTS-$5.intval,true,$5.intval,$7.intval};
                                                                                                global_variables.emplace(new_var.name,new_var);
                                                                                                no_global_variables += new_var.end - new_var.begin + 1;
                                                                                                }
                | pidentifier                                                                   {
                                                                                                struct variable new_var = {$1.str,RESERVED_SLOTS,false,0,0};
                                                                                                global_variables.emplace(new_var.name,new_var);
                                                                                                no_global_variables = 1;
                                                                                                }
                | pidentifier LPAR num COLON num RPAR                                           {
                                                                                                struct variable new_var = {$1.str,RESERVED_SLOTS-$3.intval,true,$3.intval,$5.intval};
                                                                                                global_variables.emplace(new_var.name,new_var);
                                                                                                no_global_variables = new_var.end - new_var.begin + 1;
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
                | IF condition THEN commands ELSE commands ENDIF                                {
                                                                                                if ($2.literal) {
                                                                                                    if ($2.intval) {
                                                                                                        $$.instructions = $4.instructions;
                                                                                                    } else {
                                                                                                        $$.instructions = $6.instructions;
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $2.instructions;
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+$4.instructions.size()+2);
                                                                                                    move_jumps(1,$4.instructions);
                                                                                                    $$.instructions += $4.instructions;
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+$6.instructions.size()+1);
                                                                                                    move_jumps($$.instructions.size(),$6.instructions);
                                                                                                    $$.instructions += $6.instructions;
                                                                                                }
                                                                                                }
                | IF condition THEN commands ENDIF                                              {
                                                                                                if ($2.literal) {
                                                                                                    if ($2.intval) {
                                                                                                        $$.instructions = $4.instructions;
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $2.instructions;
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+$4.instructions.size()+1);
                                                                                                    move_jumps(1,$4.instructions);
                                                                                                    $$.instructions += $4.instructions;
                                                                                                }
                                                                                                }
                | WHILE condition DO commands ENDWHILE                                          {
                                                                                                if ($2.literal) {
                                                                                                    if ($2.intval) {
                                                                                                        $$.instructions = $4.instructions;
                                                                                                        $$.instructions.emplace_back("JUMP",0);
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $2.instructions;
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+$4.instructions.size()+2);
                                                                                                    move_jumps($$.instructions.size(),$4.instructions);
                                                                                                    $$.instructions += $4.instructions;
                                                                                                    $$.instructions.emplace_back("JUMP",0);
                                                                                                }
                                                                                                }
                | DO commands WHILE condition ENDDO                                             {
                                                                                                $$.instructions = $2.instructions;
                                                                                                if ($4.literal) {
                                                                                                    if ($4.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP",0);
                                                                                                    }
                                                                                                } else {
                                                                                                    move_jumps($$.instructions.size(),$4.instructions);
                                                                                                    $$.instructions += $4.instructions;
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+2);
                                                                                                    $$.instructions.emplace_back("JUMP",0);
                                                                                                }
                                                                                                }
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
                                                                                                    $$.instructions.emplace_back("SUB",0);
                                                                                                    $$.instructions.emplace_back("STORE",5);
                                                                                                    $$.instructions += $3.instructions;
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+$1.instructions.size()*2+47);
                                                                                                    $$.instructions.emplace_back("STORE",4);
                                                                                                    $$.instructions.emplace_back("JNEG",$$.instructions.size()+$1.instructions.size()+23);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+$1.instructions.size()+44);
                                                                                                    $$.instructions.emplace_back("JNEG",$$.instructions.size()+11);
                                                                                                    $$.instructions.emplace_back("INC",0);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+6);
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions.emplace_back("LOAD",5);
                                                                                                    $$.instructions.emplace_back("INC",0);
                                                                                                    $$.instructions.emplace_back("STORE",5);
                                                                                                    $$.instructions.emplace_back("LOAD",3);
                                                                                                    $$.instructions.emplace_back("SUB",4);
                                                                                                    $$.instructions.emplace_back("JPOS",$$.instructions.size()-6);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+$1.instructions.size()+35);
                                                                                                    $$.instructions.emplace_back("DEC",0);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+6);
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions.emplace_back("LOAD",5);
                                                                                                    $$.instructions.emplace_back("DEC",0);
                                                                                                    $$.instructions.emplace_back("STORE",5);
                                                                                                    $$.instructions.emplace_back("LOAD",3);
                                                                                                    $$.instructions.emplace_back("ADD",4);
                                                                                                    $$.instructions.emplace_back("JNEG",$$.instructions.size()-6);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+$1.instructions.size()+25);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+22);
                                                                                                    $$.instructions.emplace_back("JNEG",$$.instructions.size()+11);
                                                                                                    $$.instructions.emplace_back("INC",0);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+6);
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions.emplace_back("LOAD",5);
                                                                                                    $$.instructions.emplace_back("DEC",0);
                                                                                                    $$.instructions.emplace_back("STORE",5);
                                                                                                    $$.instructions.emplace_back("LOAD",3);
                                                                                                    $$.instructions.emplace_back("ADD",4);
                                                                                                    $$.instructions.emplace_back("JPOS",$$.instructions.size()-6);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+13);
                                                                                                    $$.instructions.emplace_back("DEC",0);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+6);
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions.emplace_back("LOAD",5);
                                                                                                    $$.instructions.emplace_back("INC",0);
                                                                                                    $$.instructions.emplace_back("STORE",5);
                                                                                                    $$.instructions.emplace_back("LOAD",3);
                                                                                                    $$.instructions.emplace_back("SUB",4);
                                                                                                    $$.instructions.emplace_back("JNEG",$$.instructions.size()-6);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+3);
                                                                                                    $$.instructions.emplace_back("SUB",0);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+2);
                                                                                                    $$.instructions.emplace_back("LOAD",5);
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
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+$1.instructions.size()*2+22);
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions.emplace_back("JNEG",$$.instructions.size()+$1.instructions.size()+11);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+$1.instructions.size()+19);
                                                                                                    $$.instructions.emplace_back("JNEG",$$.instructions.size()+6);
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                    $$.instructions.emplace_back("JPOS",$$.instructions.size()-1);
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+$1.instructions.size()+15);
                                                                                                    $$.instructions.emplace_back("ADD",3);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+$1.instructions.size()+13);
                                                                                                    $$.instructions.emplace_back("ADD",3);
                                                                                                    $$.instructions.emplace_back("JNEG",$$.instructions.size()-1);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+$1.instructions.size()+10);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+9);
                                                                                                    $$.instructions.emplace_back("JNEG",$$.instructions.size()+4);
                                                                                                    $$.instructions.emplace_back("ADD",3);
                                                                                                    $$.instructions.emplace_back("JPOS",$$.instructions.size()-1);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+5);
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                    $$.instructions.emplace_back("JNEG",$$.instructions.size()-1);
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+2);
                                                                                                    $$.instructions.emplace_back("ADD",3);
                                                                                                }
                                                                                                }
;
condition:        value EQ value                                                                {
                                                                                                if ($1.literal && $2.literal) {
                                                                                                    $$.literal = true;
                                                                                                    $$.intval = $1.intval == $2.intval;
                                                                                                    if ($$.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP",2);
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+2);
                                                                                                }
                                                                                                }
                | value NEQ value                                                               {
                                                                                                if ($1.literal && $2.literal) {
                                                                                                    $$.literal = true;
                                                                                                    $$.intval = $1.intval != $2.intval;
                                                                                                    if ($$.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP",2);
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                    $$.instructions.emplace_back("JZERO",$$.instructions.size()+2);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+2);
                                                                                                }
                                                                                                }
                | value LE value                                                                {
                                                                                                if ($1.literal && $2.literal) {
                                                                                                    $$.literal = true;
                                                                                                    $$.intval = $1.intval < $2.intval;
                                                                                                    if ($$.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP",2);
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                    $$.instructions.emplace_back("JNEG",$$.instructions.size()+2);
                                                                                                }
                                                                                                }
                | value GE value                                                                {
                                                                                                if ($1.literal && $2.literal) {
                                                                                                    $$.literal = true;
                                                                                                    $$.intval = $1.intval > $2.intval;
                                                                                                    if ($$.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP",2);
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                    $$.instructions.emplace_back("JPOS",$$.instructions.size()+2);
                                                                                                }
                                                                                                }
                | value LEQ value                                                               {
                                                                                                if ($1.literal && $2.literal) {
                                                                                                    $$.literal = true;
                                                                                                    $$.intval = $1.intval <= $2.intval;
                                                                                                    if ($$.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP",2);
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                    $$.instructions.emplace_back("JPOS",$$.instructions.size()+2);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+2);
                                                                                                }
                                                                                                }
                | value GEQ value                                                               {
                                                                                                if ($1.literal && $2.literal) {
                                                                                                    $$.literal = true;
                                                                                                    $$.intval = $1.intval >= $2.intval;
                                                                                                    if ($$.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP",2);
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE",3);
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB",3);
                                                                                                    $$.instructions.emplace_back("JNEG",$$.instructions.size()+2);
                                                                                                    $$.instructions.emplace_back("JUMP",$$.instructions.size()+2);
                                                                                                }
                                                                                                }
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
                                                                                                    std::string msg = "undeclared variable '" + $1.str + "'"; //TODO
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
                                                                                                        std::string msg = "undeclared variable '" + $1.str + "'"; //TODO
                                                                                                        yyerror(msg.c_str());
                                                                                                    }
                                                                                                    if (!global_variables.count($3.str)) {
                                                                                                        std::string msg = "undeclared variable '" + $3.str + "'"; //TODO
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
                                                                                                    std::string msg = "undeclared variable '" + $1.str + "'"; //TODO
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