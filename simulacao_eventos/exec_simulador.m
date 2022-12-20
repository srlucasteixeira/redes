
function exec_simulador(Lista_eventos, tempo_final)

global Log_eventos;
global eventos_executados;
global tempo_simulacao;
global DEBUG
    
  if(DEBUG)
      
  end
  ultimo_impresso=0;
  fprintf('|----------|\n|');
% Simulacao discreta por eventos
  while 1
    [min_instante, min_indice] = min([Lista_eventos(:).instante]);
    if isempty(min_instante)
        break;
    end
    if min_instante > tempo_final
        break;
    end
    ev = Lista_eventos(min_indice);
    Lista_eventos(min_indice) = []; % Apaga o evento, sera executado.
    tempo_atual = min_instante;
    %Log_eventos = [Log_eventos;ev];
    Log_eventos{end+1} = ev;

    Novos_eventos = executa_evento(ev, tempo_atual);    % Retorna os novos eventos apos executar o ultimo evento
    eventos_executados =eventos_executados+ 1;
    if strcmp(class(Novos_eventos),'double')
        if Novos_eventos==-1
            break
        end
    end
%     if (ev.id>0)
%         plotEventos(ev,tempo_atual);
%     end
    for k=1:length(Novos_eventos)
       Novos_eventos(k).parent=ev;
       if sum(size(Novos_eventos(k).parent.parent))>0
            Novos_eventos(k).parent.parent=[];
       end
    end
    if ~isempty(Novos_eventos)
      Lista_eventos = [Lista_eventos;Novos_eventos];
    end
    if ((tempo_atual/tempo_simulacao)-ultimo_impresso) > 10/100 % imprime progresso a cada 10% do tempo
        fprintf('.');
        ultimo_impresso=ultimo_impresso+10/100;
    end
  end
  fprintf('\n');
end