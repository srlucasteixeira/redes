%clc;clear all; %close all;
% Soposi��es diferentes da realidade: tempo � discreto na simula��o quando
% no mundo real � uma vari�vel cont�nua.

% Consideram-se eventos independentes para modelagem estat�stica, mas no
% mundo real retransmiss�es e fluxo de dados em rejadas tende a n�o serem
% independentes.

% Simula��o por tempo (passo a passo em todos os instantes)
%PARAMETROS DE SIMULA��O
%simula��o do protocolo Aloha puro
%n�mero de repeti��es da simula��o - para tirar a m�dia
rodadas = 15;
%tempo total da simula��o em segundos
tempo = 0.1;
%n�mero total de esta��es
num_estacoes = 40;
%taxa de transmiss�o do meio em bits por segundo
taxa_bits = 1e5;
%tamanho do quadro em bits
tam_quadro = 200;
%tempo de transmiss�o do quadro em segundos
t_quadro = tam_quadro/taxa_bits;
%intervalo de tempo da simula��o
dt_sim = t_quadro/tam_quadro;
%tempo total da simula��o em instantes
t_sim = ceil(tempo/dt_sim);
%taxa m�dia m�xima de chegada de quadros por segundo para cada esta��o
taxa_max_quadro=ceil(taxa_bits/tam_quadro/num_estacoes);
% resultados da simula��o
quadros_transmitidos = zeros(1,taxa_max_quadro);
quadros_entregues = zeros(1,taxa_max_quadro);
quadros_gerados = zeros(1,taxa_max_quadro);
quadros_colididos = zeros(1,taxa_max_quadro);
tic;
% numero de taxas de quadro diferentes que ser�o testados
num_taxas_quadro=20;

taxa_quadro_vals=1:ceil(taxa_max_quadro/num_taxas_quadro):taxa_max_quadro;
i=0;
%f = waitbar(0,'Progresso');
for taxa_quadro=taxa_quadro_vals
	%taxa m�dia de chegada de quadros por instante de simula��o
    % trafego m�dio gerado naquele instante/passo de simula��o
	tm_q=taxa_quadro*dt_sim;
	%janela de tempo de espera aleat�rio em n�mero de instantes de simula��o
	espera_max =10*tam_quadro;
	for r=1:rodadas	
		%VARIAVEIS DOS EVENTOS
		%transmissores ativos
		tx_ativo = zeros(1,num_estacoes);
		%fila de quadros do transmissor
		tx_fila = zeros(1,num_estacoes);
		%contador de progresso do transmissor
		tx_cnt=zeros(1,num_estacoes);
		%armazenador de colis�es
		colisao_vetor=zeros(1,t_sim);
		%indices das esta��es com colis�o
		colisao=zeros(1,num_estacoes);
		%espera aleat�ria em caso de colis�o
		tx_espera=zeros(1,num_estacoes);
		%armazenador das transmiss�es
		transmissores_ativos=zeros(num_estacoes,t_sim);
		%armazenador da chegada dos quadros
		chegada_quadros=0;
        % armazenador de quadros colididos
        colisoes = 0;
        % armazenador de quadros entregues
        entregues = 0;
        % la�o que ir� avaliar cada passo de simula��o
		for t=1:t_sim
            % la�o que ir� avaliar cada esta��o
			for estacao=1:num_estacoes                
			    %verificar se o transmissor est� ativo
			    if tx_ativo(estacao)==1
			        transmissores_ativos(estacao,t)=1;
			    end
			    %verificar se o quadro foi enviado
			    if tx_cnt(estacao)>0
			        tx_cnt(estacao)=tx_cnt(estacao)-1;
			        if tx_cnt(estacao)==0
			            tx_ativo(estacao)=0;
			            %verificar se a transmiss�o sofreu colis�o
			            if colisao(estacao)==1
			                tx_espera(estacao)=ceil(espera_max*rand(1));
			                tx_fila(estacao)=tx_fila(estacao)+1;
			                colisao(estacao)=0;
                            colisoes = colisoes + 1;
                        else
                            entregues = entregues + 1;
			            end
			        end
			    else
			    	% verificar se tem quadros em espera
			        if (tx_fila(estacao)>0) && (tx_espera(estacao)==0)
			            tx_ativo(estacao)=1;
			            tx_cnt(estacao)=ceil(tam_quadro/taxa_bits/dt_sim);
			            tx_fila(estacao)=tx_fila(estacao)-1;
                    else
                        if tx_espera(estacao)>0
                            %decrementar o contador do tempo de espera
                            tx_espera(estacao)=tx_espera(estacao)-1;
                        end
			        end
			    end
			    % verificar se chegou um novo quadro
                p_novo=rand(1);
                if p_novo < tm_q
                    chegada_quadros=chegada_quadros+1;
                    %verificar se o transmissor est� pronto
                    if (tx_ativo(estacao)==0) && (tx_espera(estacao)==0)
                       tx_ativo(estacao)=1;
                       tx_cnt(estacao)=ceil(tam_quadro/taxa_bits/dt_sim);
                    else
                       tx_fila(estacao)=tx_fila(estacao)+1;
                    end
                end
            end     
            %verifica se houve colis�o
            if sum(tx_ativo)>1
                colisao_vetor(t)=1;
                for estacao=1:num_estacoes
                    if tx_ativo(estacao)==1
                        colisao(estacao)=1;
                    end
                end
            end
        end
        
		quadros_transmitidos(taxa_quadro) = quadros_transmitidos(taxa_quadro) + ((chegada_quadros-sum(tx_fila)))/rodadas;
        quadros_entregues(taxa_quadro)    = quadros_entregues(taxa_quadro)    + entregues/rodadas;
		quadros_gerados(taxa_quadro)      = quadros_gerados(taxa_quadro)      + chegada_quadros/rodadas;
        quadros_colididos(taxa_quadro)    = quadros_colididos(taxa_quadro)    + colisoes/rodadas;

    end
    i=i+1;
    p=(100*i)/length(taxa_quadro_vals);
    fprintf('Progresso %3.0f%%\n',p);
    %waitbar(p/100,f);
    %%
    figure(2)
    hold off
    for k=1:num_estacoes
        transmissores_ativos(k,:)=transmissores_ativos(k,:)*k;
    end
    plot(1:t_sim,transmissores_ativos,'o')
    title('Ilustra��o das transmiss�es')
    xlabel('Tempo (passo)')
    ylabel('Esta��o ativa')
    grid on
    ylim([0.1 num_estacoes])
    %keyboard
    %%
end
toc;    
%close(f)
%%
G = 0:0.01:2;
S = G.*exp(-2*G);
hold on;
figure(1)
Gcalc=(quadros_entregues+quadros_colididos)*tam_quadro/tempo;
Scalc=quadros_entregues*tam_quadro/tempo;
plot(Gcalc,Scalc,'ro',G*taxa_bits,S*taxa_bits)
legend({'Simulado','Modelo estat�stico'})
grid
xlabel('Taxa de chegada de quadros (bps)');
ylabel('Taxa de entrega de quadros - capacidade (bps)');

taxa_transmissao=taxa_quadro*tam_quadro;
disp(['a) Tempo de simula��o ' num2str(t_sim) '.'])
disp(['b) N�mero de esta��es ' num2str(num_estacoes)  '.'])
disp(['c) Taxa de transmiss�o ' num2str(taxa_transmissao) '(bps)'])
disp(['d) Tamanho do quadro ' num2str(tam_quadro) ' bits.'])
disp(['e) Dura��o m�xima da janela de tempo de espera aleat�ria ' num2str(espera_max) '.']) 
disp(['f) N�mero de rodadas de simula��o ' num2str(rodadas) '.']) 





