# batalha-naval-prolog
batalha naval em prolog num tabuleiro 8x8 com as posições dos barcos ja predefenidas

encotrar a diretoria do ficheiro
?- cd('C:/caminho/para/a/pasta').

compilar 
?- [batalha].
?- jogar.

modo ataque 
escrever "vou eu" e o sistema vai dar coordenadas de 0 7 de linhas e colunas respetivamente, estilo "tiro 0 0"
ele vai criar um ciclo depois de disparar vai esperar por uma das 4 respostas "agua","tiro porta-avioes,fragata x,torpedeiro x, etc..."
,"perdi"(vai assumir que ganhou e ira dar a resposta de vitoria) e "afundou porta-avioes,fragata x,torpedeiro x, etc...".

modo defesa
escrever "vai tu" e o sistema vai esperar pelas coordenadas de 0 7 de linhas e colunas respetivamente no estilo "tiro 0 1" 
