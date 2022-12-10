
function Log_eventos = exec_simulador(Lista_eventos, Log_eventos, tempo_final)


  global eventos_executados;
    global DEBUG
    
  if(DEBUG)
      
  end
  
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
    Log_eventos = [Log_eventos;ev];

    Novos_eventos = executa_evento(ev, tempo_atual);    % Retorna os novos eventos apos executar o ultimo evento
    eventos_executados =eventos_executados+ 1;
%     if (ev.id>0)
%         plotEventos(ev,tempo_atual);
%     end
    for k=1:length(Novos_eventos)
       Novos_eventos(k).parent=ev;
    end
    if ~isempty(Novos_eventos)
      Lista_eventos = [Lista_eventos;Novos_eventos];
    end
  end
end