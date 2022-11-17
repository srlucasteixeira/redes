clc; clear all; close all;


% Inicia o gerador de numeros aleatorios
rand('state', 0);
%prevS = rng(0)
 
% Parametros principais
tempo_simulacao = 1; % tempo de simulacao

global DEBUG;
DEBUG=1;

% Lista de eventos executados
global Log_eventos;
Log_eventos = [];
global eventos_executados;
eventos_executados = 0;

n=10; % numero de nos da rede
global msg;
msg = {'ola'};
global rede; % matriz de conectividade da rede
rede = ~eye(n); % matriz de conectividade da rede
global nos;
nos = [];

%% Configura a simulacao
tempo_inicial = clock;
Lista_eventos = config_sim(n, tempo_simulacao);

% Executa a simulacao
Log_eventos = exec_simulador(Lista_eventos, Log_eventos, tempo_simulacao);
%print_struct_array_contents(1);
%Log_eventos(:).instante
%Log_eventos(:).tipo
disp(['---Total de eventos=' num2str(eventos_executados)]);
disp(sprintf('---Tempo da simulacao=%g segundos', etime(clock, tempo_inicial)));

