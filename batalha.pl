% estado(N, Ataque, Defesa, Pendentes)
% N = 8
% Ataque   -> lista de L-C já disparados
% Defesa   -> lista de barcos barco(Nome, Posicoes)
% Pendentes-> lista de L-C a tentar após acerto

% Estado inicial com a frota do agente
estado_inicial(
    estado(8, [], Defesa, [])
) :-
    Defesa = [
        barco(porta-avioes, [1-1,1-2,1-3,0-3,0-4]),
        barco(destroyer,   [4-0,4-1,4-2,4-3]),
        barco(fragata1,    [6-0,6-1,6-2]),
        barco(fragata2,    [2-5,3-5,4-5]),
        barco(torpedeiro1,       [7-5,7-6]),
        barco(torpedeiro2,       [5-7,6-7]),
        barco(torpedeiro3,       [1-7,2-7]),
        barco(submarino,   [7-0])
    ].
% Arranque do jogo (ciclo infinito até fim_jogo)
jogar :-
    estado_inicial(Estado),
    catch(ciclo(Estado), fim_jogo, true).

% Ciclo principal: lê comandos e atualiza o estado
ciclo(Estado) :-
    read_line_to_string(user_input, Linha),
    atom_string(Cmd, Linha),
    processar(Cmd, Estado, NovoEstado),
    ciclo(NovoEstado).

% O agente ataca
processar('vou eu', Estado, NovoEstado) :-
    jogar_tiro(Estado, NovoEstado).

% O adversário ataca
processar('vai tu', Estado, Estado).

% Resposta a um tiro do adversário
processar(Cmd, Estado, NovoEstado) :-
    sub_atom(Cmd, 0, 4, _, tiro),
    responder_tiro(Cmd, Estado, NovoEstado),
    NovoEstado = estado(_, _, NovaDefesa, _),
    ( NovaDefesa = []
    -> write('lol perdi outra vez (:o}'), nl, flush_output, throw(fim_jogo)
    ;  true
    ).

processar(_, Estado, Estado).

% ================== ATAQUE ==================

% Escolha e execução de um tiro
jogar_tiro(
    estado(N, Ataque, Defesa, Pend),
    estado(N, NovoAtaque, Defesa, NovoPend)
) :-
    escolher_tiro(N, Ataque, Pend, L, C, Pend1),
    format("tiro ~w ~w~n", [L, C]),
    flush_output,
    read_line_to_string(user_input, RespStr),
    atom_string(Resp, RespStr),
    ( Resp == perdi
    -> write('Easy peazy!!!Sou o melhor almirante'), nl, flush_output, throw(fim_jogo)
    ;  atualizar_ataque(Resp, L, C, Ataque, NovoAtaque, Pend1, NovoPend)
    ).

% Prioriza caça; senão usa padrão xadrez
escolher_tiro(_, Ataque, [L-C|R], L, C, R) :-
    \+ member(L-C, Ataque),
    dentro(L), dentro(C), !.

escolher_tiro(N, Ataque, [_|R], L, C, Pend1) :-
    escolher_tiro(N, Ataque, R, L, C, Pend1).

escolher_tiro(N, Ataque, [], L, C, []) :-
    tiro_sequencial(N, Ataque, L, C).

% Disparo em padrão xadrez
tiro_sequencial(N, Ataque, L, C) :-
    N1 is N-1,
    between(0, N1, L),
    between(0, N1, C),
    (L + C) mod 2 =:= 0,
    \+ member(L-C, Ataque),
    !.
dentro(X) :- X >= 0, X < 8.

% Atualização do estado após resposta ao tiro
atualizar_ataque(agua, L, C, A, [L-C|A], Pend, Pend).

atualizar_ataque(Resp, L, C, A, [L-C|A], _PendAntigo, PendNovo) :-
    sub_atom(Resp, 0, 4, _, tiro),
    adjacentes(L, C, PendNovo).

atualizar_ataque(Resp, L, C, A, [L-C|A], _PendAntigo, []) :-
    sub_atom(Resp, 0, 8, _, afundado).

% Casas adjacentes válidas
adjacentes(L, C, Adj) :-
    L1 is L+1, L2 is L-1,
    C1 is C+1, C2 is C-1,
    findall(X-Y,
        ( member(X-Y, [L1-C, L2-C, L-C1, L-C2]),
          dentro(X), dentro(Y)
        ),
        Adj).

% ================== DEFESA ==================

% Processa um tiro recebido
responder_tiro(
    Cmd,
    estado(N,A,Defesa,P),
    estado(N,A,NovaDefesa,P)
) :-
    atomic_list_concat([tiro, LS, CS], ' ', Cmd),
    atom_number(LS, L),
    atom_number(CS, C),
    tratar_tiro(L-C, Defesa, NovaDefesa).

% Acerto ou afundamento
tratar_tiro(Pos, Defesa, NovaDefesa) :-
    member(barco(Nome, Posicoes), Defesa),
    member(Pos, Posicoes),
    remover_pos(Pos, Posicoes, NovasPos),
    ( NovasPos = []
    -> format("afundado ~w~n", [Nome]),
       remover_barco(Nome, Defesa, NovaDefesa)
    ;  format("tiro ~w~n", [Nome]),
       substituir_barco(Nome, NovasPos, Defesa, NovaDefesa)
    ),
    flush_output, !.

% Tiro em água
tratar_tiro(_, Defesa, Defesa) :-
    write("agua"), nl,
    flush_output.

% ================== AUXILIARES ==================
remover_pos(X, [X|R], R).
remover_pos(X, [Y|R], [Y|RR]) :-
    remover_pos(X, R, RR).
remover_barco(_, [], []).
remover_barco(N, [barco(N,_)|R], R).
remover_barco(N, [B|R], [B|RR]) :-
    remover_barco(N, R, RR).
substituir_barco(_, _, [], []).
substituir_barco(N, P, [barco(N,_)|R], [barco(N,P)|R]).
substituir_barco(N, P, [B|R], [B|RR]) :-
    substituir_barco(N, P, R, RR).







