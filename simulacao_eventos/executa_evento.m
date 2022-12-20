
function [NovosEventos] = executa_evento(evento, tempo_atual)
global msg, global rede, global nos;
global pacotes_entregues;
global max_nova_tentativa;
global taxa_bits;
global tam_quadro;
global DEBUG;
global duracao_RTS, global duracao_CTS, global duracao_ACK;
NovosEventos = [];
global tempo_entre_quadros;
global tempo_prop;
global taxa_bits;
erro_col = 0;

[t,tipo_evento, id, pct, parent]= evento_desmonta(evento); % retorna os campos do 'evento'
if (size(pct)>0) & (DEBUG==1)
    if (id ~= pct.src) && (evento.tipo(1)=='T') 
        disp('Ops!')
    end
end

if (DEBUG==1)  disp(['EV: ' tipo_evento ' @t=' num2str(t) ' id=' num2str(id)]); end

%keyboard
switch tipo_evento
    case 'COLISAO' % configura nos, inicia variaveis de estado, etc.
        % nada a fazer, marcar no gráfico somente
    case 'N_cfg' % configura nos, inicia variaveis de estado, etc.
        nos(id).Tx = 'desocupado';
        nos(id).Rx = 'desocupado';
        nos(id).ocupado_ate = 0;
        nos(id).stat = struct('tx', 0, 'rx', 0, 'rxok', 0, 'col', 0);
        nos(id).fila={}; % inicializa sem pacotes na fila
        nos(id).NAV_ate=-1;% inicializa sem estar ocupado o canal
        nos(id).stat.total_dados_enviados=0;
        nos(id).stat.total_dados_recebidos=0;
        nos(id).stat.bloqueios=0;
        % qual a probabilidade de enviar um novo pacote? Criar evento
        % na próxima vez que um pacote entrar na fila
        %             p_novo=rand(1);
        %             % adiciona uma trasmissao na fila
        %             % pacote contem origem (src), destino (dst), tamanho (tam) e os dados
        %             pct =  struct('src', id, 'dst', 1, 'tam', 20, 'dados', []);
        %
        %             if (pct.dst ~= id)   % evita enviar pacote para ele mesmo
        %                 e = evento_monta(tempo_atual, 'T_ini', id, pct, evento);
        %                 NovosEventos =[NovosEventos;e];
        %             end
        %             end
        %             % exemplo: adiciona mais uma trasmissao na fila
        %             if erro_col ==1
        %                 e = evento_monta(tempo_atual, 'T_ini', id, pct, evento);
        %                 NovosEventos =[NovosEventos;e];
        %             end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case 'N_pct' % Momento em que um novo pacote foi gerado
        if strcmp(nos(id).Tx, 'ocupado') | strcmp(nos(id).Rx, 'ocupado') % ocupado?
            nos(id).fila{end+1}=pct; % adiciona pacotes na fila
        else
            % agenda novo pacote para ser gerado imediatamente
            e = evento_monta(tempo_atual, 'T_ini', id, pct, []);
            NovosEventos =[NovosEventos;e];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case {'T_ini', 'T_ini_RETRY'} %inicio de transmissao ENVIANDO RTS
        if rem(nos(id).stat.bloqueios,50)==0
            if (DEBUG==1) disp(['Bloqueados: Rx ' nos(id).Rx]); end
%             nos(id).stat.bloqueios=0;
%             keyboard
        end
        if strcmp(nos(id).Tx, 'ocupado') % transmissor ocupado?
            e = evento_monta(nos(id).ocupado_ate+tempo_entre_quadros, 'T_ini_RETRY', id, pct,parent);
            NovosEventos =[NovosEventos;e];
            nos(id).stat.bloqueios=nos(id).stat.bloqueios+1;
        else
            % verifica se canal está disponível ou se o canal virtual está
            % ocupado
            if ((nos(id).NAV_ate > tempo_atual ) || (strcmp(nos(id).Rx, 'ocupado')==1) || (strcmp(nos(id).Tx, 'desocupado')~=1));
                % não pode enviar agora
                % agenda nova tentativa para ser gerada dentro de algum tempo
                e = evento_monta(tempo_atual+rand*max_nova_tentativa, 'T_ini_RETRY', id, pct, parent);
                NovosEventos =[NovosEventos;e];
                nos(id).stat.bloqueios=nos(id).stat.bloqueios+1;
            else % canal disponível, envia RTS
                e = evento_monta((tempo_atual), 'T_RTS_ini', id, pct,evento);
                NovosEventos =[NovosEventos;e];
            end
        end
        
    case 'T_RTS_ini' % inicio de transmissao de RTS
            for nid = find(rede(id,:)>0) % envia uma copia do pacote para cada vizinho
                %disp(['INI T_RTS de ' num2str(id) ' para ' num2str(nid)]);
                e = evento_monta((tempo_atual+tempo_prop), 'R_RTS_ini', nid, pct,evento);
                NovosEventos =[NovosEventos;e];
            end
            tempo_transmissao = duracao_RTS;
            e = evento_monta((tempo_atual+tempo_transmissao), 'T_RTS_fim', id, pct,evento);
            NovosEventos =[NovosEventos;e];
            nos(id).Tx = 'ocupado';
            nos(id).ocupado_ate = tempo_atual+tempo_transmissao;
        
        
        
    case 'T_RTS_fim' % fim de transmissao de RTS
        nos(id).Tx = 'desocupado';
        nos(id).Rx = 'espera_CTS';
        nos(id).ocupado_ate = 0;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 'R_RTS_ini' %inicio de recepcao DE RTS
        %if ~isempty(pct); disp(pct); end;
        if strcmp(nos(id).Rx, 'ocupado') ||  strcmp(nos(id).Rx, 'colisao')
            nos(id).Rx  = 'colisao';
            nos(id).stat.col =nos(id).stat.col+1;
            e = evento_monta((tempo_atual+1e-20), 'COLISAO', id, [],evento);NovosEventos =[NovosEventos;e];
            %disp(['EV: COLISAO INICIA no nó ' num2str(id) ' durante RTS'])
        else
            nos(id).Rx  = 'ocupado';
            nos(id).stat.rx = 1;
        end;
        e = evento_monta((tempo_atual+duracao_RTS), 'R_RTS_fim', id, pct,evento);
        NovosEventos =[NovosEventos;e];
        
    case 'R_RTS_fim' %fim de recepcao DE RTS
        if strcmp(nos(id).Rx, 'ocupado')
            %disp(['R_RTS_fim de ' num2str(pct.src) ' para ' num2str(pct.dst)]);
            %if ~isempty(pct); disp(pct); end;
            nos(id).Rx  = 'desocupado';
            %nos(id).stat.rxok=nos(id).stat.rxok+1;
            nos(id).stat.rx = 0;
            nos(id).NAV_ate = tempo_atual + pct.tam/taxa_bits + duracao_CTS + duracao_ACK + 4* (tempo_entre_quadros+tempo_prop);
            e = evento_monta(nos(id).NAV_ate, 'FIM_NAV', id, pct, evento);
            NovosEventos =[NovosEventos;e];
            if (pct.dst == id ) % destino a estes dispositivo
                X = pct.src; pct.src = pct.dst; pct.dst = X; % inverte origem e destino                   
                
                e = evento_monta((tempo_atual+tempo_entre_quadros), 'T_CTS_ini', id, pct,evento);
                NovosEventos =[NovosEventos;e];
            end
            
        elseif  strcmp(nos(id).Rx, 'colisao')
            if(nos(id).stat.rx == 0)
                nos(id).Rx  = 'desocupado';
                nos(id).stat.col =nos(id).stat.col+1;
                e = evento_monta((tempo_atual+1e-20), 'COLISAO', id, [],evento);NovosEventos =[NovosEventos;e];
                nos(id).NAV_ate=0;
                %disp(['EV: COLISAO ACABOU no nó ' num2str(id) ' durante RTS'])
            end
        else
            %warning('ERRO: Estado Rx errado.');            
            nos(id).NAV_ate=0;
            nos(id).Rx  = 'desocupado'; % ignora erro e segue em frente
        end
%         if (length(nos(id).fila) > 0)  % existem mais pacotes para transmitir
%             % agenda novo pacote para ser gerado imediatamente
%             e = evento_monta(tempo_atual, 'T_ini', id, pct, []);
%             NovosEventos =[NovosEventos;e];
%             nos(id).fila(1)=[]; % apaga primeiro pacote da fila
%         end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case 'T_CTS_ini' %inicio de transmissao DE CTS
        % ASSUME canal virtual disponível, envia RTS
        for nid = find(rede(id,:)>0) % envia uma copia do pacote para cada vizinho
            %disp(['INI T_CTS de ' num2str(id) ' para ' num2str(nid)]);
            e = evento_monta((tempo_atual+tempo_prop), 'R_CTS_ini', nid, pct,evento);
            NovosEventos =[NovosEventos;e];
        end
        tempo_transmissao = duracao_CTS;
        e = evento_monta((tempo_atual+tempo_transmissao), 'T_CTS_fim', id, pct,evento);
        NovosEventos =[NovosEventos;e];
        nos(id).Tx = 'ocupado';
        nos(id).ocupado_ate = tempo_atual+tempo_entre_quadros+tempo_transmissao;

        
    case 'T_CTS_fim' %fim de transmissao de CTS
        %nos(id).stat.tx =nos(id).stat.tx+1;
        nos(id).Tx = 'desocupado';
        nos(id).Rx = 'espera_DADOS';
        nos(id).ocupado_ate = 0;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 'R_CTS_ini' %inicio de recepcao DE CTS
        %if ~isempty(pct); disp(pct); end;
        if strcmp(nos(id).Rx, 'ocupado') ||  strcmp(nos(id).Rx, 'colisao')
            nos(id).Rx  = 'colisao';
            %nos(id).stat.rx =nos(id).stat.rx+1;
            %disp(['EV: COLISAO INICIA no nó ' num2str(id) ' durante RTS'])
        else
            if ~ strcmp(nos(id).Rx, 'espera_CTS')  nos(id).Rx  = 'ocupado';  end
            nos(id).stat.rx = 1;
        end;
        e = evento_monta((tempo_atual+duracao_CTS), 'R_CTS_fim', id, pct,evento);
        NovosEventos =[NovosEventos;e];
        
    case 'R_CTS_fim' %fim de recepcao DE CTS
        nos(id).stat.rx =nos(id).stat.rx-1;
        if strcmp(nos(id).Rx, 'ocupado') | strcmp(nos(id).Rx, 'espera_CTS')
            %disp(['R_RTS_fim de ' num2str(pct.src) ' para ' num2str(pct.dst)]);
            %if ~isempty(pct); disp(pct); end;
            %nos(id).stat.rxok=nos(id).stat.rxok+1;
            nos(id).stat.rx = 0;
            nos(id).NAV_ate = tempo_atual + pct.tam/taxa_bits + duracao_ACK + 3* (tempo_entre_quadros+tempo_prop);
            e = evento_monta(nos(id).NAV_ate, 'FIM_NAV', id, pct, evento);
            NovosEventos =[NovosEventos;e];
            if (pct.dst == id ) & strcmp(nos(id).Rx, 'espera_CTS') % destino a estes dispositivo
                X = pct.src; pct.src = pct.dst; pct.dst = X; % inverte origem e destino    NOVAMENTE               
                e = evento_monta((tempo_atual+tempo_entre_quadros), 'T_DADOS_ini', id, pct,evento);
                NovosEventos =[NovosEventos;e];
            end
            nos(id).Rx  = 'desocupado';
            
        elseif  strcmp(nos(id).Rx, 'colisao')
            if(nos(id).stat.rx == 0)
                nos(id).Rx  = 'desocupado';
                nos(id).stat.col =nos(id).stat.col+1;
                e = evento_monta((tempo_atual+1e-20), 'COLISAO', id, [],evento);NovosEventos =[NovosEventos;e];
                nos(id).NAV_ate=0;
                
%                 if id==1
%                     tempo_atual*1000
%                     keyboard
%                 end
                %disp(['EV: COLISAO ACABOU no nó ' num2str(id) ' durante RTS'])
            end
        else
            nos(id).Rx  = 'desocupado';
            nos(id).Tx  = 'desocupado';     
            nos(id).NAV_ate=0;
            %warning('ERRO: Estado Rx errado.');
        end
        if (length(nos(id).fila) > 0)  % existem mais pacotes para transmitir
            % agenda novo pacote para ser gerado imediatamente
            e = evento_monta(tempo_atual, 'T_ini', id, nos(id).fila{1}, []);
            nos(id).fila(1)=[];% apaga primeiro pacote da fila
            NovosEventos =[NovosEventos;e];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  case 'T_DADOS_ini' %inicio de transmissao
        for nid = find(rede(id,:)>0) % envia uma copia do pacote para cada vizinho
            %disp(['INI T_dado de ' num2str(id) ' para ' num2str(nid)]);
            e = evento_monta((tempo_atual+tempo_prop), 'R_DADOS_ini', nid, pct,evento);
            NovosEventos =[NovosEventos;e];
        end
        % monta seu evento de fim de transmissão
        tempo_transmissao = pct.tam/taxa_bits;
        e = evento_monta((tempo_atual+tempo_transmissao), 'T_DADOS_fim', id, pct,evento);
        NovosEventos =[NovosEventos;e];
        nos(id).Tx = 'ocupado';
        nos(id).ocupado_ate = tempo_atual+tempo_transmissao;
               
    case 'T_DADOS_fim' %fim de transmissao
        nos(id).stat.tx =nos(id).stat.tx+1;
        nos(id).Tx = 'desocupado';
        nos(id).ocupado_ate = 0;
        nos(id).Rx = 'espera_ACK';
        nos(id).stat.total_dados_enviados = nos(id).stat.total_dados_enviados+pct.tam;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    case 'R_DADOS_ini' %inicio de recepcao DE DADOS
        %if ~isempty(pct); disp(pct); end;
        if strcmp(nos(id).Rx, 'ocupado') ||  strcmp(nos(id).Rx, 'colisao')
            nos(id).Rx  = 'colisao';
            nos(id).stat.rx =nos(id).stat.rx+1;
            if (DEBUG==1) disp(['EV: COLISAO INICIA no nó ' num2str(id) ' (' sprintf('%3.2f',tempo_atual*1000) 'ms']); end
        else
            if ~ strcmp(nos(id).Rx, 'espera_DADOS')  nos(id).Rx  = 'ocupado';  end 
            nos(id).stat.rx = 1;
        end;
        tempo_transmissao = pct.tam/taxa_bits;
        e = evento_monta(tempo_atual+tempo_transmissao, 'R_DADOS_fim', id, pct,evento);
        NovosEventos =[NovosEventos;e];
    
    case 'R_DADOS_fim' %fim de recepcao DE DADOS
        nos(id).stat.rx =nos(id).stat.rx-1;
        if strcmp(nos(id).Rx, 'ocupado') |  strcmp(nos(id).Rx, 'espera_DADOS')
            if (DEBUG==1) disp(['FIM R de ' num2str(pct.src) ' para ' num2str(pct.dst)]); end
            %if ~isempty(pct); disp(pct); end;
            nos(id).stat.rxok=nos(id).stat.rxok+1;
            nos(id).stat.rx = 0;
            if (pct.dst == id ) & strcmp(nos(id).Rx, 'espera_DADOS') % destino a estes dispositivo
                X = pct.src; pct.src = pct.dst; pct.dst = X; % inverte origem e destino    NOVAMENTE               
                e = evento_monta((tempo_atual+tempo_entre_quadros), 'T_ACK_ini', id, pct,evento);
                NovosEventos =[NovosEventos;e];
            end
            nos(id).Rx  = 'desocupado';
        elseif  strcmp(nos(id).Rx, 'colisao')
            if(nos(id).stat.rx == 0)
                nos(id).Rx  = 'desocupado';
                nos(id).stat.col =nos(id).stat.col+1;
                e = evento_monta((tempo_atual), 'COLISAO', id, [],evento);NovosEventos =[NovosEventos;e];
                if (DEBUG==1) disp(['EV: COLISAO ACABOU no nó ' num2str(id)]); end
            end
        else
            %warning('ERRO: Estado Rx errado.');
            nos(id).Rx='desocupado';          
            nos(id).NAV_ate=0;
            % vai reiniciar transação gerando novo pacote
        end
        if ( length(nos(id).fila) > 0)  % existem mais pacotes para transmitir
            % agenda novo pacote para ser gerado imediatamente
            e = evento_monta(tempo_atual, 'T_ini', id, nos(id).fila{1}, []);
            NovosEventos =[NovosEventos;e];
            nos(id).fila(1)=[];% apaga primeiro pacote da fila
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case 'T_ACK_ini' %inicio de transmissao
        % ASSUME  canal disponível, envia ACK
            for nid = find(rede(id,:)>0) % envia uma copia do pacote para cada vizinho
                %disp(['INI T_RTS de ' num2str(id) ' para ' num2str(nid)]);
                e = evento_monta(tempo_atual+tempo_prop, 'R_ACK_ini', nid, pct,evento);
                NovosEventos =[NovosEventos;e];
            end
            tempo_transmissao = duracao_ACK;
            e = evento_monta(tempo_atual+tempo_transmissao, 'T_ACK_fim', id, pct,evento);
            NovosEventos =[NovosEventos;e];
            nos(id).Tx = 'ocupado';
            nos(id).ocupado_ate = tempo_atual+tempo_transmissao;
      
    case 'T_ACK_fim' %fim de transmissao de ACK
        %nos(id).stat.tx =nos(id).stat.tx+1;
        nos(id).Tx = 'desocupado';
        nos(id).Rx = 'desocupado';
        nos(id).ocupado_ate = 0;
        nos(id).stat.total_dados_recebidos = nos(id).stat.total_dados_recebidos+pct.tam;
        pct.instante_entregue=tempo_atual;
        pacotes_entregues{end+1}=pct;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
    case 'R_ACK_ini' %inicio de recepcao DE ACK
        if strcmp(nos(id).Rx, 'ocupado') ||  strcmp(nos(id).Rx, 'colisao')
            nos(id).Rx  = 'colisao';
            %nos(id).stat.rx =nos(id).stat.rx+1;
            %disp(['EV: COLISAO INICIA no nó ' num2str(id) ' durante RTS'])
        else
            
            if ~ strcmp(nos(id).Rx, 'espera_ACK') 
                nos(id).Rx  = 'ocupado'; 
            end
            nos(id).stat.rx = 1;
        end;
        e = evento_monta((tempo_atual+duracao_ACK), 'R_ACK_fim', id, pct,evento);
        NovosEventos =[NovosEventos;e];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case 'R_ACK_fim' %fim de recepcao DE ACK
        %nos(id).stat.rx =nos(id).stat.rx-1;
        if strcmp(nos(id).Rx, 'ocupado') || strcmp(nos(id).Rx, 'espera_ACK')
            if (DEBUG==1)  disp(['R_ACK_fim de ' num2str(pct.src) ' para ' num2str(pct.dst)]);             end
            %if ~isempty(pct); disp(pct); end;
            %nos(id).stat.rxok=nos(id).stat.rxok+1;
            nos(id).stat.rx = 0;
            nos(id).NAV_ate = 0; % libera canal virtual
            %{id pct.dst pct.src nos(id).Rx}
            if (pct.dst == id ) && strcmp(nos(id).Rx, 'espera_ACK')  % destino a estes dispositivo
                X = pct.src; pct.src = pct.dst; pct.dst = X; % inverte origem e destino    POR ULTIMA VEZ!    
                if (DEBUG==1)  fprintf('Pacote entregue com sucesso de %d para %d\n',pct.src,pct.dst); end
                
            end
            nos(id).Rx  = 'desocupado';
        elseif  strcmp(nos(id).Rx, 'colisao')
            if(nos(id).stat.rx == 0)
                nos(id).Rx  = 'desocupado';
                nos(id).stat.col =nos(id).stat.col+1;
                e = evento_monta((tempo_atual+1e-20), 'COLISAO', id, [],evento);NovosEventos =[NovosEventos;e];
                nos(id).NAV_ate=0;
                %disp(['EV: COLISAO ACABOU no nó ' num2str(id) ' durante RTS'])
            end
        else
            %warning('ERRO: Estado Rx errado.');
            nos(id).NAV_ate=0;
            nos(id).Rx  = 'desocupado'; % ignora erro e segue em frente
        end
        if (length(nos(id).fila) > 0)  % existem mais pacotes para transmitir
            % agenda novo pacote para ser gerado imediatamente
            e = evento_monta(tempo_atual, 'T_ini', id, nos(id).fila{1}, []);
            NovosEventos =[NovosEventos;e];
            nos(id).fila(1)=[]; % apaga pacote com transmissão agendada
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 'S_fim' %fim de simulacao
        disp('Simulacao encerrada!');
        NovosEventos=-1;
        %error('Simulacao encerrada');
    case 'FIM_NAV'
         % libera canal virtual mesmo se não receber ACK
        nos(id).NAV_ate = 0;    % não gera outros eventos, só desliga a FLAG de NAV
        % Se houverem pacotes na fila inicia uma possível transmissão
        if (length(nos(id).fila) > 0)  % existem mais pacotes para transmitir
            % agenda novo pacote para ser gerado imediatamente
%             if size(nos(id).fila{1})==1
%                 keyboard
%             end
            %nos(id).fila
            e = evento_monta(tempo_atual, 'T_ini', id, nos(id).fila{1}, []);
            NovosEventos =[NovosEventos;e];
            nos(id).fila(1)=[];
        end
    otherwise
        disp(['exec_evento: Evento desconhecido: ' tipo_evento]);
end

end