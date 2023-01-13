% Implementação do algoritmo de Djkstra para descoberta do melhor caminho
% Djkstra
clc; clear all
% matriz de interconexões e custos exemplo da aula slide 14/16
X = inf;% peso infinito
custo = [0 2 5 1 X X;...
       2 0 3 2 X X;...
       5 3 0 3 1 5;...
       1 2 3 0 1 X;...
       X X 1 1 0 2
       X X 5 X 2 0];

% Implementação do algoritmo de Djkstra para descoberta do melhor caminho
% Djkstra

% matriz de interconexões e custos
% [matriz,custo] = grafo_de_rede;
num_nos=length(custo)
antecessor = zeros(1,num_nos)

origem=1
% destino=3
% implementação
T = origem;
nos_nao_visitados=1:num_nos
nos_nao_visitados(origem)=[]

L(1:num_nos) = inf;
for n = nos_nao_visitados
   L(n) =   custo(origem,n);
end
[valor,x] = min(L(nos_nao_visitados))
T(end+1) = nos_nao_visitados(x); % guarda este como visitado
nos_nao_visitados
n=nos_nao_visitados(x)
nos_nao_visitados(find(nos_nao_visitados(x)==nos_nao_visitados)) = []; % remove dos não visitados
nos_nao_visitados

while(length(nos_nao_visitados)>0)
    L
    for x = nos_nao_visitados
        if L(n) > L(x)+custo(x,n)
            antecessor(n) = x;
            L(n) = L(x)+custo(x,n);
        end
        %L(n) = min(L(n), L(x)+custo(x,n));
    end
    L
    [valor,x] = min(L(nos_nao_visitados))

    T(end+1) = nos_nao_visitados(x); % guarda este como visitado
    nos_nao_visitados
    nos_nao_visitados(find(nos_nao_visitados(x)==nos_nao_visitados)) = []; % remove dos não visitados
    nos_nao_visitados
    pause(1)
end