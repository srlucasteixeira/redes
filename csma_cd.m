clc; clear all; close all;
recuo_binario=1;
%PARAMETROS DE SIMULAÇÃO
%simulação do protocolo CSMA/CD 1-persistente
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

% variação da taxa de geração de quadros
pontos=20;
taxas_quadro=taxa_max_quadro*(1/pontos:1/pontos:1);

fig=1;

for a=[0.02]
    
% resultados da simulação
quadros_entregues = zeros(1,taxa_max_quadro);
quadros_gerados = zeros(1,taxa_max_quadro);
quadros_colididos = zeros(1,taxa_max_quadro);
quadros_bloqueados = zeros(1,taxa_max_quadro);

tic;

for taxa=1:pontos; 
    taxa_quadro=taxas_quadro(taxa);
	%taxa média de chegada de quadros por instante de simulação
    tm_q=taxa_quadro*dt_sim;
    %janela de tempo de espera aleatório em número de instantes de simulação
	
    if recuo_binario==1
        espera_min = 1*tam_quadro;  % será duplicando antes de qualquer transmissão
    else
        espera_min = 20*tam_quadro;
    end
        %número de repetições da simulação - para tirar a média
	rodadas = 5;
	for r=1:rodadas	
		%VARIAVEIS DOS EVENTOS
        espera_atual=espera_min;
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
        % armazenador de bloqueios
        bloqueios = 0;   % backoffs
        % guarda o estado do meio (com atraso)
        tx_ativo_atr=0;        
        % atraso de propagação
        atraso = ceil(a*tam_quadro/taxa_bits/dt_sim);
		for k=1:t_sim            
            % guarda o estado do meio (com atraso!)
            if k>atraso
                tx_ativo_atr=transmis(:,k-atraso);
            end
            
			for j=1:n_est
			    %verificar se o transmissor está ativo
			    if tx_ativo(j)==1
			        transmis(j,k)=1;
			    end
			    %verificar se o quadro foi enviado
			    if tx_cnt(j)>0			        			        
                    %verificar se a transmissão sofreu colisão
                    if colin(j)==1
                        tx_cnt(j) = 0; % aborta transmissão
                        tx_ativo(j)=0;
                        %tx_espera(j)= 2*atraso; % aguarda o tempo de 1 mini-slot = 2a
                        
                        if recuo_binario==1
                            espera_atual=espera_atual*2;
                        end
                        tx_espera(j)=ceil(espera_atual*rand(1)); % aguarda um tempo aleatório p=1/espera_max
                        tx_fila(j)=tx_fila(j)+1;
                        colin(j)=0;
                        colisoes = colisoes + 1;
                    else
                        tx_cnt(j)=tx_cnt(j)-1;
                        if tx_cnt(j)==0
                            espera_atual=espera_min;    % sucesso, reduz espera ao mínimo
                            tx_ativo(j)=0;
                            entregues = entregues + 1;
                        end
                    end

			    else
			    	% verificar se tem quadros em espera e se o meio está
			    	% livre
			        if (tx_fila(j)>0) 
                        if (tx_espera(j)==0) && (nnz(tx_ativo_atr)==0)
                            tx_ativo(j)=1;
                            tx_cnt(j)=ceil(tam_quadro/taxa_bits/dt_sim);
                            tx_fila(j)=tx_fila(j)-1;                        
                        elseif tx_espera(j)>0
                            %decrementar o contador do tempo de espera
                            tx_espera(j) = tx_espera(j)-1;                          
                        elseif (nnz(tx_ativo_atr)>0)
                            % meio está ocupado - modo 1-persistente
                            % bloqueado!
                            if recuo_binario==1
                                espera_atual=espera_atual*2;
                                tx_espera(j)= ceil(espera_atual*rand(1)); % aguarda o tempo de 1 mini-slot
                            else
                                tx_espera(j)= 2; % aguarda o tempo de 1 mini-slot
                            end
                            %tx_espera(j)=ceil(espera_max*rand(1)); % aguarda um tempo aleatório
                            bloqueios = bloqueios + 1;
                        end
                    end
			    end
			    % verificar se chegou um novo quadro
                p_novo=rand(1);
                if p_novo < tm_q
                    chegada_quadros=chegada_quadros+1;
                    %verificar se o transmissor está pronto
                    if (tx_ativo(j)==0) && (tx_espera(j)==0) && (nnz(tx_ativo_atr)==0)
                       tx_ativo(j)=1;
                       tx_cnt(j)=ceil(tam_quadro/taxa_bits/dt_sim);
                    else
                       tx_fila(j)=tx_fila(j)+1;
                       if (tx_espera(j)==0) && (nnz(tx_ativo_atr)>0) % meio ocupado
                            tx_espera(j)=2*atraso; % aguarda o tempo de 1 mini-slot
                            bloqueios = bloqueios + 1;
                       end
                    end
                end
            end   
            
            %verifica se houve colisão
            if nnz(tx_ativo)>1
                colis(k)=1;
                colin=(colin|tx_ativo);
            end
        end        
        		
        quadros_entregues(taxa)=quadros_entregues(taxa) + entregues/rodadas;
		quadros_gerados(taxa)=quadros_gerados(taxa) + chegada_quadros/rodadas;
        quadros_colididos(taxa) = quadros_colididos(taxa) + colisoes/rodadas;
        quadros_bloqueados(taxa) = quadros_bloqueados(taxa) + bloqueios/rodadas;

    end
    disp(['Taxa ' num2str(taxa/pontos*100) '%'])
end
toc;    
% número médio de slots gastos em contenção    
NS=1/((1-1/n_est)^(n_est-1)); 
% modelo CSMA/CD p-persistente (p=1/k)
U=1/(1+2*a*NS);
G=0:0.01:1;
S=U*G;

figure(fig); fig=fig+1;
plot((quadros_colididos+quadros_entregues)*tam_quadro/tempo,quadros_entregues*tam_quadro/tempo,'ro', G*taxa_bits,S*taxa_bits,'-');
hold on;
grid
xlabel('Taxa de geração de quadros (bps)');
ylabel('Taxa de entrega de quadros - capacidade (bps)');
title(['a=' sprintf('%2.2f',a)])
end

