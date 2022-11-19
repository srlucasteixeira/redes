%clc;
clear;% close all;
figure(1); hold off;

%inicializa plot(0,0) com legenda
legenda=mapeiaEventoSimbolo([1 1]);
for i=1:length(legenda.string)
    plot(0,0,[ legenda.valores(i) 'k']);
    hold on
end
legend(legenda.string , ...
    'Location','EastOutside');
    
    
    disp('    Simulação CDMA/CA em rede sem fio')
    disp('    Condições da simulação:')
    disp('    1-Todos pacotes são enviados em broadcast')
    disp('    2-Existe canal virtual por meio de requisicoes RTS/CTS (Request to Send/Clear to Send).')
    disp('    3-Cada nó mantém o status reconhecendo canal virtual ocupado:')
    disp('       Nó fonte envia RTS')
    disp('       Nó destino responde CTS')
    disp('       Nó fonte envia dados')
    disp('       Nó destino responde ACK')
    
    
%PARAMETROS DE SIMULAÇÃO - geração aleatória de transmissões
%global n;       n=10; % numero de nos da rede % substituído por num_estacoes
%simulação do protocolo CSMA/CA
 
% Parametros principais
global tempo_simulacao;
tempo_simulacao =1000; % tempo de simulacao (segundos)
%número total de estações
global num_estacoes;
num_estacoes = 5;
%taxa de transmissão do meio em bits por segundo
global taxa_bits;
taxa_bits = 1;
%tamanho médio do quadro em bits
global tam_quadro;
tam_quadro = 20;
global desv_pad_quadro;
desv_pad_quadro = 10;
global max_nova_tentativa;  % tempo max. para esperar por liberação do canal
max_nova_tentativa = 10*tam_quadro;
% duração de pacotes auxiliares
global duracao_RTS, global duracao_CTS, global duracao_ACK;
duracao_RTS=tam_quadro/20/taxa_bits;    % 5% do quadro médio
duracao_CTS=duracao_RTS;
duracao_ACK=duracao_RTS;
%tempo de transmissão do quadro em segundos
%global t_quadro;
%t_quadro = tam_quadro/taxa_bits;
% FRAÇÃO da taxa de dados total produzida
global taxa_max_quadro;
taxa_max_quadro=(taxa_bits/tam_quadro/num_estacoes);
global fracao_taxa_quadro;
fracao_taxa_quadro = 0.3;
global taxa_quadro_atual;
taxa_quadro_atual = taxa_max_quadro * fracao_taxa_quadro;
%%




% resultados da simulação
quadros_transmitidos = 0;
quadros_entregues = 0;
quadros_gerados = 0;
quadros_colididos = 0;

    
% Inicia o gerador de numeros aleatorios
rand('state', 0);
%prevS = rng(0)

global DEBUG;
DEBUG=1;

% Lista de eventos executados
global Log_eventos;
Log_eventos = [];
global eventos_executados;
eventos_executados = 0;

global msg;     msg = {'ola'};
global rede; % matriz de conectividade da rede
                rede = ~eye(num_estacoes); % matriz de conectividade da rede
global nos;     nos = [];% estados dos nós da rede

%% Configura a simulacao por eventos
tempo_inicial = clock;
Lista_eventos = config_sim(num_estacoes, tempo_simulacao);



% Executa a simulacao
Log_eventos = exec_simulador(Lista_eventos, Log_eventos, tempo_simulacao);
for i=1:length (Log_eventos)
   ev = Log_eventos(i);
    if (ev.id>0)
        plotEventos(ev,ev.instante);
    end
end
%print_struct_array_contents(1);
%Log_eventos(:).instante
%Log_eventos(:).tipo
disp(['---Total de eventos=' num2str(eventos_executados)]);
disp(sprintf('---Tempo da simulacao=%g segundos', etime(clock, tempo_inicial)));

