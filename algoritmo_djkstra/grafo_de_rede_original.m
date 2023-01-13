clear all; close all; clc;
rand('twister', 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% geração do grafo que 
% representa uma rede de comunicação

% configuração original
num_nos  = 100;
L = 1000; % lado da área onde estão os nós
R = 200;  % alcance maximo direto de um nó até seus vizinhos 
% num_nos  = 6;
% L = 1000; % lado da área onde estão os nós
% R = 400;  % alcance maximo direto de um nó até seus vizinhos 

figure(1);clf;hold on;
posX = rand(1,num_nos)*L;
posY = rand(1,num_nos)*L;
matriz = zeros(num_nos); % matriz de conectividade
custo = ones(num_nos)*inf; % custo dos enlaces
for k = 1:num_nos
    plot(posX(k), posY(k), '.');
    text(posX(k), posY(k), num2str(k));
    for j = 1:num_nos
        if k==j
            rand(1);custo (k,j) = 0;
            continue
        end
        distancia = sqrt((posX(k) - posX(j))^2 + (posY(k) - posY(j))^2);
        if distancia <= R
            matriz(k,j) = 1;   % tem um enlace;
            custo (k,j) = rand(1); % com custo aleatório entre 0 e 1
            line([posX(k) posX(j)], [posY(k) posY(j)], 'LineStyle', ':', 'Color', 'b');
            if j>k
                text(mean([posX(k) posX(j)]),mean([posY(k) posY(j)])-5,sprintf('%1.2f',custo(k,j)))
            else
                text(mean([posX(k) posX(j)]),mean([posY(k) posY(j)])+5,sprintf('%1.2f',custo(k,j)))
            end
%         else
%             matriz(k,j) = 0;
%             custo (k,j) = inf;
        end;
    end;
end;