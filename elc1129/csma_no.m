clc;clear all;close all;

%PARAMETROS DE SIMULA��O
%simula��o do protocolo CSMA n�o-persistente
%tempo total da simula��o em segundos
tempo = 1;
%n�mero total de esta��es
n_est = 10;
%taxa de transmiss�o do meio em bits por segundo
taxa_bits = 1e4;
%tamanho do quadro em bits
tam_quadro = 100;
%tempo de transmiss�o do quadro em segundos
t_quadro = tam_quadro/taxa_bits;
%intervalo de tempo da simula��o
dt_sim = t_quadro/tam_quadro;
%tempo total da simula��o em instantes
t_sim = ceil(tempo/dt_sim);

%taxa media maxima de chegada de quadros por segundo para cada esta��o
taxa_max_quadro=ceil(taxa_bits/tam_quadro/n_est);

tam_q = ceil(tam_quadro/taxa_bits/dt_sim);

% varia��o da taxa de gera��o de quadros
pontos=10;
taxas_quadro=taxa_max_quadro*(1/pontos:1/pontos:1);

fig=1;

for d=1:5

for a=[0.05]
    
% resultados da simula��o
quadros_transmitidos = zeros(1,pontos);
quadros_entregues = zeros(1,pontos);
quadros_gerados = zeros(1,pontos);
quadros_colididos = zeros(1,pontos);
quadros_bloqueados = zeros(1,pontos);
quadros_fila = zeros(1,pontos);

tic;

for taxa=1:pontos; 
  %taxa media de chegada de quadros por instante de simula��o
  taxa_quadro=taxas_quadro(taxa);
  
  %Progresso da simula��o
  clc;disp(['Progresso: ' num2str(100*taxa/pontos) '%']);
  
	tm_q=taxa_quadro*dt_sim;
	%janela de tempo de espera aleatorio em n�mero de instantes de simula��o
	espera_max = 10*tam_quadro;
	%n�mero de repeti��es da simula��o - para tirar a media
	rodadas = 1;
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
		%indices das esta��es com colis�o
		colin=zeros(1,n_est);
		%espera aleatória em caso de colis�o
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
    tx_ativo_atr=zeros(1,n_est);        
    % atraso de propaga��o
    atraso = ceil(a*tam_quadro/taxa_bits/dt_sim);
        
		for k=1:t_sim
            
      % guarda o estado do meio (com atraso )
      if k>atraso
          tx_ativo_atr=transmis(:,k-atraso)';
      end
            
			for j=1:n_est
			    %verificar se o transmissor est� ativo
			    if tx_ativo(j)==1
			        transmis(j,k)=1;
			    end
          
          % para simular n�s ocultos, acrescenta "uma dist�ncia de alcance
          % do sinal r". Assim, o n� "j" s� ouve os demais n�s separados por 
          % mais ou menos "d". Por exemplo, j = 3 e d = 2, escuta ids (j-d = 3-2=1)
          % at� (j+d = 3+2 = 5) = {1,2,4,5}
          jo = [1:n_est];jo = [jo(end-d+1:end), jo, jo(1:d)];
          jo=jo(j:j+2*d); % mant�m apenas os n�s n�o ocultos
			    
          %verificar se o quadro foi enviado
			    if tx_cnt(j)>0
			        tx_cnt(j)=tx_cnt(j)-1;
			        if tx_cnt(j)==0
			            tx_ativo(j)=0;
			            %verificar se a transmiss�o sofreu colis�o
			            if colin(j)==1
			                tx_espera(j)=ceil(espera_max*rand(1)); % aguarda um tempo aleatório
			                tx_fila(j)=tx_fila(j)+1;
			                colin(j)=0;
                      colisoes = colisoes + 1;
                  else
                      entregues = entregues + 1;
			            end
			        end
			    else
			    	% verificar se tem quadros em espera e se o meio est�
			    	% livre
			        if (tx_fila(j)>0) 
                  if (tx_espera(j)==0) && (nnz(tx_ativo_atr(jo))==0)
                      tx_ativo(j)=1;
                      tx_cnt(j)=tam_q;
                      tx_fila(j)=tx_fila(j)-1;                        
                  elseif tx_espera(j)>0
                      %decrementar o contador do tempo de espera
                      tx_espera(j) = tx_espera(j)-1;                          
                  elseif (nnz(tx_ativo_atr(jo))>0)
                      % meio est� ocupado - modo n�o-persistente
                      tx_espera(j)=ceil(espera_max*rand(1)); % aguarda um tempo aleatorio p/ tentar novamente    
                      bloqueios = bloqueios + 1;
                  end
              end
			    end
			    % verificar se chegou um novo quadro
              p_novo=rand(1);
              if p_novo < tm_q
                  chegada_quadros=chegada_quadros+1;
                  %verificar se o transmissor est� pronto
                  if (tx_ativo(j)==0) && (tx_espera(j)==0) && (nnz(tx_ativo_atr(jo))==0)
                     tx_ativo(j)=1;
                     tx_cnt(j)=tam_q;
                  else
                     tx_fila(j)=tx_fila(j)+1;
                     if (tx_espera(j)==0) && (nnz(tx_ativo_atr(jo))>0) % meio ocupado
                          tx_espera(j)=ceil(espera_max*rand(1)); % aguarda um tempo aleat�rio p/ tentar novamente  
                          bloqueios = bloqueios + 1;
                     end
                  end
              end
       end   
            
        %verifica se houve colis�o
        if nnz(tx_ativo)>1
            colis(k)=1;
            colin=tx_ativo;
        end
    end
        
        
	quadros_transmitidos(taxa)=quadros_transmitidos(taxa) + ((chegada_quadros-sum(tx_fila)))/rodadas;
    quadros_entregues(taxa)=quadros_entregues(taxa) + entregues/rodadas;
	quadros_gerados(taxa)=quadros_gerados(taxa) + chegada_quadros/rodadas;
    quadros_colididos(taxa) = quadros_colididos(taxa) + colisoes/rodadas;
    quadros_bloqueados(taxa) = quadros_bloqueados(taxa) + bloqueios/rodadas;
    quadros_fila(taxa) = quadros_fila(taxa) + sum(tx_fila)/rodadas;

    end
end
toc;    
    

% CSMA n�o-persistente
G = 0:0.01:2;
S = (G.*exp(-a*G))./(G*(1+2*a) + exp(-a*G)); % n�o slotted
%S = a*G.*exp(-a*G)./(1-exp(-a*G) + a); % slotted

% CSMA 1-persistente
%S=((G.*(1 + G + a*G.*(1 + G + a*G/2))).*exp(-G*(1+2*a)))./(G*(1+2*a)-(1-exp(-a*G))+(1+a*G).*(exp(-G*(1+a))));

figure;
bar([quadros_gerados', quadros_entregues', quadros_colididos', quadros_fila']);

figure(fig); fig=fig+1;
plot((quadros_colididos+quadros_entregues+quadros_bloqueados)*tam_quadro/tempo,quadros_entregues*tam_quadro/tempo,'ro',G*taxa_bits,S*taxa_bits,'-')
hold on;
grid
title(["distancia = " num2str(d)]);
xlabel('Taxa de gera��o de quadros (bps)');
ylabel('Taxa de entrega de quadros - capacidade (bps)');

end
end