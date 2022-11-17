
function [NovosEventos] = executa_evento(evento, tempo_atual)
    global msg, global rede, global nos;

    NovosEventos = [];

    % configuracao
    dist = 100; % 100m
    tempo_prop = dist/3e8; %tempo de propagacao = distancia/velocidade do sinal
    taxa_dados = 1e5; % 100kbps
    erro_col = 0;

    [t,tipo_evento, id, pct]= evento_desmonta(evento); % retorna os campos do 'evento'

    disp(['EV: ' tipo_evento ' @t=' num2str(t) ' id=' num2str(id)]);

    switch tipo_evento
        case 'N_cfg' % configura nos, inicia variaveis de estado, etc.
            nos(id).Tx = 'desocupado';
            nos(id).Rx = 'desocupado';
            nos(id).ocupado_ate = 0;
            nos(id).stat = struct('tx', 0, 'rx', 0, 'rxok', 0, 'col', 0);

            % adiciona uma trasmissao na fila
            % pacote contem origem (src), destino (dst), tamanho (tam) e os dados
            pct =  struct('src', id, 'dst', 1, 'tam', 20, 'dados', []);
            
            if (pct.dst ~= id)   % evita enviar pacote para ele mesmo
                e = evento_monta(tempo_atual, 'T_ini', id, pct);
                NovosEventos =[NovosEventos;e];
            end
            % exemplo: adiciona mais uma trasmissao na fila
            if erro_col ==1
                e = evento_monta(tempo_atual, 'T_ini', id, pct);
                NovosEventos =[NovosEventos;e];
            end

      case 'T_ini' %inicio de transmissao
           if strcmp(nos(id).Tx, 'ocupado') % transmissor ocupado?
             tempo_entre_quadros = 0.2*8*pct.tam/taxa_dados; %20\% do tempo de transmissao
             e = evento_monta(nos(id).ocupado_ate+tempo_entre_quadros, 'T_ini', id, pct);
             NovosEventos =[NovosEventos;e];
           else
             if pct.dst == 0 %pacote de broadcast
                for nid = find(rede(id,:)>0) % envia uma copia do pacote para cada vizinho
                  disp(['INI T de ' num2str(id) ' para ' num2str(nid)]);
                  e = evento_monta((tempo_atual+tempo_prop), 'R_ini', nid, pct);
                  NovosEventos =[NovosEventos;e];
                end
             else % envia um pacote para o vizinho, se conectado
                if find(rede(id,:) == pct.dst)
                  disp(['INI T de ' num2str(id) ' para ' num2str(pct.dst)]);
                  e = evento_monta((tempo_atual+tempo_prop), 'R_ini', pct.dst, pct);
                  NovosEventos =[NovosEventos;e];
                end
             end
             tempo_transmissao = 8*pct.tam/taxa_dados;
             e = evento_monta((tempo_atual+tempo_transmissao), 'T_fim', id, pct);
             NovosEventos =[NovosEventos;e];
             nos(id).Tx = 'ocupado';
             nos(id).ocupado_ate = tempo_atual+tempo_transmissao;
        end
      case 'T_fim' %fim de transmissao
             nos(id).stat.tx =nos(id).stat.tx+1;
             nos(id).Tx = 'desocupado';
             nos(id).ocupado_ate = 0;
      case 'R_ini' %inicio de recepcao
             %if ~isempty(pct); disp(pct); end;
             if strcmp(nos(id).Rx, 'ocupado') ||  strcmp(nos(id).Rx, 'colisao')
               nos(id).Rx  = 'colisao';
               nos(id).stat.rx =nos(id).stat.rx+1;
               disp(['EV: COLISAO INICIA no n� ' num2str(id)])
             else
               nos(id).Rx  = 'ocupado';
               nos(id).stat.rx = 1;
             end;
             e = evento_monta((tempo_atual+8*pct.tam/taxa_dados), 'R_fim', id, pct);
             NovosEventos =[NovosEventos;e];
    case 'R_fim' %fim de recepcao
            nos(id).stat.rx =nos(id).stat.rx-1;
            if strcmp(nos(id).Rx, 'ocupado')
                disp(['FIM R de ' num2str(pct.src) ' para ' num2str(pct.dst)]);
                %if ~isempty(pct); disp(pct); end;
                nos(id).Rx  = 'desocupado';
                nos(id).stat.rxok=nos(id).stat.rxok+1;
                nos(id).stat.rx = 0;
            elseif  strcmp(nos(id).Rx, 'colisao')
                if(nos(id).stat.rx == 0)
                  nos(id).Rx  = 'desocupado';
                  nos(id).stat.col =nos(id).stat.col+1;
               disp(['EV: COLISAO ACABOU no n� ' num2str(id)])
                end
            else
              disp('ERRO: Estado Rx errado.');
            end
       case 'S_fim' %fim de simulacao
             disp('Simulacao encerrada!');
        otherwise
            disp(['exec_evento: Evento desconhecido: ' tipo_evento]);
    end

end