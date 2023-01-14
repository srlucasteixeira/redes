% Implementação do algoritmo de Djkstra para descoberta do melhor caminho
% Djkstra
clc; clear all
% matriz de interconexões e custos exemplo da aula slide 14/16
X = inf;% peso infinito
% custo = [0 2 5 1 X X;...
%        2 0 3 2 X X;...
%        5 3 0 3 1 5;...
%        1 2 3 0 1 X;...
%        X X 1 1 0 2
%        X X 5 X 2 0];

% Implementação do algoritmo de Djkstra para descoberta do melhor caminho
% Djkstra

% matriz de interconexões e custos
[matriz,custo,posX,posY] = grafo_de_rede;
num_nos=length(custo)
antecessor = zeros(1,num_nos)
vetor_n=[];
origem=67
% destino=3
% implementação
T = origem;
nos_nao_visitados=1:num_nos
nos_nao_visitados(origem)=[];   % remove nó origem

L(1:num_nos) = inf;
L(origem) = 0;

for n = nos_nao_visitados
   L(n) =   custo(origem,n);
   if L(n) < Inf
      antecessor(n) = origem; 
   end
end
[valor,x] = min(L(nos_nao_visitados))
T(end+1) = nos_nao_visitados(x) % guarda este como visitado
n=nos_nao_visitados(x)
antecessor(n) = origem;
nos_nao_visitados(find(nos_nao_visitados(x)==nos_nao_visitados)) = []; % remove dos não visitados
nos_nao_visitados
vetor_n(end+1)=n
disp('Criar vetor "path"')
while(length(nos_nao_visitados)>0)
    fprintf('Visitando %d\n',n)
    L
    for x = nos_nao_visitados
        [n L(n) x L(x) custo(x,n)]
        if L(x) > L(n)+custo(x,n)
            antecessor(x) = n;
            L(x) = L(n)+custo(x,n);
        end
        %L(n) = min(L(n), L(x)+custo(x,n));
    end
    %L
    nos_nao_visitados
    L(nos_nao_visitados)
    [valor,x] = min(L(nos_nao_visitados))
    n=nos_nao_visitados(x)
    vetor_n(end+1)=n
    T(end+1) = nos_nao_visitados(x); % guarda este como visitado
    nos_nao_visitados
    nos_nao_visitados(find(nos_nao_visitados(x)==nos_nao_visitados)) = []; % remove dos não visitados
    nos_nao_visitados
end
[valor,final] = max(L); % determina caminho com maior custo
% desenha o caminho


figure(1);hold on;
a=final;
fprintf('\n\nO caminho terminado em %d tem custo %f\n\n',final,L(final))
while a ~= origem
    b = antecessor(a); 
    line([posX(a) posX(b)], [posY(a) posY(b)], 'LineWidth', 3, 'Color', 'r');
    text(mean([posX(a) posX(b)]),mean([posY(a) posY(b)]),sprintf('%1.2f',custo(a,b)))
    a = b;
%         else
%             matriz(k,j) = 0;
%             custo (k,j) = inf;
end;
