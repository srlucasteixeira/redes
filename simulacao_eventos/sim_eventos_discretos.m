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
    
    
    disp('    Simula��o CDMA/CA em rede sem fio')
    disp('    Condi��es da simula��o:')
    disp('    1-Todos pacotes s�o enviados em broadcast')
    disp('    2-Existe canal virtual por meio de requisicoes RTS/CTS (Request to Send/Clear to Send).')
    disp('    3-Cada n� mant�m o status reconhecendo canal virtual ocupado:')
    disp('       N� fonte envia RTS')
    disp('       N� destino responde CTS')
    disp('       N� fonte envia dados')
    disp('       N� destino responde ACK')
    
    
%PARAMETROS DE SIMULA��O - gera��o aleat�ria de transmiss�es
%global n;       n=10; % numero de nos da rede % substitu�do por num_estacoes
%simula��o do protocolo CSMA/CA
 
% Parametros principais
global tempo_simulacao;
tempo_simulacao =0.3/1000; % tempo de simulacao (segundos)
%n�mero total de esta��es
global num_estacoes;
num_estacoes = 5;
%taxa de transmiss�o do meio em bits por segundo
global taxa_bits;
taxa_bits = 1e6;
%tamanho m�dio do quadro em bits
global tam_quadro;  % em bits
tam_quadro = 100;
global desv_pad_quadro;
desv_pad_quadro = 10;
global max_nova_tentativa;  % tempo max. para esperar por libera��o do canal
max_nova_tentativa = 10*tam_quadro/taxa_bits;
% dura��o de pacotes auxiliares
global duracao_RTS, global duracao_CTS, global duracao_ACK;
duracao_RTS=tam_quadro/taxa_bits/100;    % 1% do quadro m�dio
duracao_CTS=duracao_RTS;
duracao_ACK=duracao_RTS;
%tempo de transmiss�o do quadro em segundos
%global t_quadro;
%t_quadro = tam_quadro/taxa_bits;
% FRA��O da taxa de dados total produzida
global taxa_max_quadro;
taxa_max_quadro=(taxa_bits/tam_quadro/num_estacoes);
global fracao_taxa_quadro;  % fra��o da taxa m�xima de dados gerada
fracao_taxa_quadro = 2;
global taxa_quadro_atual;
taxa_quadro_atual = taxa_max_quadro * fracao_taxa_quadro;


% configuracao geom�trica
dist = 600; % m
global tempo_prop;
tempo_prop = dist/3e8; %tempo de propagacao = distancia/velocidade do sinal

global tempo_entre_quadros;
tempo_entre_quadros = 2*tempo_prop+0.001*tam_quadro/taxa_bits; %20\% do tempo de transmissao

%%




% resultados da simula��o
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
global nos;     nos = [];% estados dos n�s da rede

%% Configura a simulacao por eventos
tempo_inicial = clock;
global Lista_eventos
Lista_eventos = config_sim(num_estacoes, tempo_simulacao);

disp('Alterando Lista de eventos para for�ar colis�o')
%Lista_eventos

% Executa a simulacao
Log_eventos = exec_simulador(Lista_eventos, Log_eventos, tempo_simulacao);

ylim([0 0.001] );
xlim([0 0.001] );
% for i=1:length (Log_eventos)
%    ev = Log_eventos(i);
%     if (ev.id>0)
%         plotEventos(ev,ev.instante);
%     end
% end
plotEventos(Log_eventos);

ylim([0.1 num_estacoes+0.5])
xlim([Log_eventos(1).instante Log_eventos(end).instante] );
%print_struct_array_contents(1);
%Log_eventos(:).instante
%Log_eventos(:).tipo
disp(['---Total de eventos=' num2str(eventos_executados)]);
disp(sprintf('---Tempo da simulacao=%g segundos', etime(clock, tempo_inicial)));

