

function Lista_eventos = config_sim(n, tempo_simulacao)
  Lista_eventos = [];
  for k=1:n
    e = evento_monta(0, 'N_cfg', k);
    Lista_eventos = [Lista_eventos;e];
  end

  ev_fim = evento_monta(tempo_simulacao, 'S_fim', 0);
  Lista_eventos = [Lista_eventos; ev_fim];

end