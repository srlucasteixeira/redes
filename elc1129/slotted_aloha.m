clc;
clear all;
%close all;

%PARAMETROS DE SIMULAÇÃO
%simulação do protocolo Aloha puro
%tempo total da simulação em segundos
tempo = 0.1;
%número total de estações
n_est = 10;
%taxa de transmissão do meio em bits por segundo
taxa_bits = 1e5;
%tamanho do quadro em bits
tam_quadro = 100;
%tempo de transmissão do quadro em segundos
t_quadro = tam_quadro/taxa_bits;
%intervalo de tempo da simulação
dt_sim = t_quadro/tam_quadro;
%tempo total da simulação em instantes
t_sim = ceil(tempo/dt_sim);

%taxa média máxima de chegada de quadros por segundo para cada estação
taxa_max_quadro=ceil(taxa_bits/tam_quadro/n_est);

% tamanho do slot
slot = tam_quadro;

% resultados da simulação
quadros_transmitidos = zeros(1,taxa_max_quadro);
quadros_entregues = zeros(1,taxa_max_quadro);
quadros_gerados = zeros(1,taxa_max_quadro);
quadros_colididos = zeros(1,taxa_max_quadro);

tic;

for taxa_quadro=1:ceil(taxa_max_quadro/20):taxa_max_quadro
	%taxa média de chegada de quadros por instante de simulação
	tm_q=taxa_quadro*dt_sim;
	%janela de tempo de espera aleatório em número de instantes de simulação
	espera_max =10*tam_quadro;
	%número de repetições da simulação - para tirar a média
	rodadas = 5;
	for r=1:rodadas	
		%VARIAVEIS DOS EVENTOS
		%transmissores ativos
		tx_ativo = zeros(1,n_est);
		%fila de quadros do transmissor
		tx_fila = zeros(1,n_est);
		%contador de progresso do transmissor
		tx_cnt=zeros(1,n_est);
		%armazenador de colisões
		colis=zeros(1,t_sim);
		%indices das estações com colisão
		colin=zeros(1,n_est);
		%espera aleatória em caso de colisão
		tx_espera=zeros(1,n_est);
		%armazenador das transmissões
		transmis=zeros(n_est,t_sim);
		%armazenador da chegada dos quadros
		chegada_quadros=0;
        % armazenador de quadros colididos
        colisoes = 0;
        % armazenador de quadros entregues
        entregues = 0;
		for t=1:t_sim
			for j=1:n_est
			    %verificar se o transmissor está ativo
			    if tx_ativo(j)==1
			        transmis(j,t)=1;
			    end
			    %verificar se o quadro foi enviado
			    if tx_cnt(j)>0
			        tx_cnt(j)=tx_cnt(j)-1;
			        if tx_cnt(j)==0
			            tx_ativo(j)=0;
			            %verificar se a transmissão sofreu colisão
			            if colin(j)==1
			                tx_espera(j)=ceil(espera_max*rand(1));
			                tx_fila(j)=tx_fila(j)+1;
			                colin(j)=0;
                            colisoes = colisoes + 1;
                        else
                            entregues = entregues + 1;
			            end
			        end
			    else
			    	% verificar se tem quadros em espera
			        if (tx_fila(j)>0) && (tx_espera(j)==0) && rem(t-1,slot)==0
			            tx_ativo(j)=1;
			            tx_cnt(j)=ceil(tam_quadro/taxa_bits/dt_sim);
			            tx_fila(j)=tx_fila(j)-1;
                    else
                        if tx_espera(j)>0
                            %decrementar o contador do tempo de espera
                            tx_espera(j)=tx_espera(j)-1;
                        end
			        end
			    end
			    % verificar se chegou um novo quadro
                p_novo=rand(1);
                if p_novo < tm_q
                    chegada_quadros=chegada_quadros+1;
                    %verificar se o transmissor está pronto
                    if (tx_ativo(j)==0) && (tx_espera(j)==0) && rem(t-1,slot)==0
                       tx_ativo(j)=1;
                       tx_cnt(j)=ceil(tam_quadro/taxa_bits/dt_sim);
                    else
                       tx_fila(j)=tx_fila(j)+1;
                    end
                end
            end     
            %verifica se houve colisão
            if sum(tx_ativo)>1
                colis(t)=1;
                for j=1:n_est
                    if tx_ativo(j)==1
                        colin(j)=1;
                    end
                end
            end
        end
        
		quadros_transmitidos(taxa_quadro)=quadros_transmitidos(taxa_quadro) + ((chegada_quadros-sum(tx_fila)))/rodadas;
        quadros_entregues(taxa_quadro)=quadros_entregues(taxa_quadro) + entregues/rodadas;
		quadros_gerados(taxa_quadro)=quadros_gerados(taxa_quadro) + chegada_quadros/rodadas;
        quadros_colididos(taxa_quadro) = quadros_colididos(taxa_quadro) + colisoes/rodadas;

    end
end
toc;    
    

G = 0:0.01:2;
S = G.*exp(-G);
hold on;
%figure(1)
plot((quadros_entregues+quadros_colididos)*tam_quadro/tempo,quadros_entregues*tam_quadro/tempo,'ro',G*taxa_bits,S*taxa_bits,'-')
grid
xlabel('Taxa de chegada de quadros (bps)');
ylabel('Taxa de entrega de quadros - capacidade (bps)');