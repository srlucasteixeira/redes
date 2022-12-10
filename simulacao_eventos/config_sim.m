

function Lista_eventos = config_sim(n, tempo_simulacao)
rng default;
  Lista_eventos = [];
  for k=1:n
    e = evento_monta(0, 'N_cfg', k);
    Lista_eventos = [Lista_eventos;e];
  end

  ev_fim = evento_monta(tempo_simulacao, 'S_fim', 0);
  Lista_eventos = [Lista_eventos; ev_fim];

  global taxa_quadro_atual;
  global tam_quadro;
  global desv_pad_quadro;
  if (round(tempo_simulacao*taxa_quadro_atual))<1
      error('Tempo muito curto de simulação para a taxa de dados e quadro desejada!')
  end
    % cria todas as transmissões que ocorrerão
  for id=1:n  % para todos os nós
    for b=1:round(tempo_simulacao*taxa_quadro_atual) % tempo_simulacao  a quantidade provável
        tamanho=max(round(desv_pad_quadro*randn+tam_quadro),1); % tamanho mínimo 1
        v=1:n; i=randi(n-1); v(id)=[]; % gera destino aleatorio que não pode ser igual à origem
        %keyboard
        pct =  struct('src', id, 'dst', v(i), 'tam', tamanho, 'dados', []);
        %      evento_monta(t, tipo, id, pct,parent)
        e =    evento_monta(rand(1)*tempo_simulacao, 'N_pct', id, pct,[]);
        Lista_eventos = [Lista_eventos;e];
    end
  end
end