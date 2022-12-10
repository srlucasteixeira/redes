total_dados_enviados=0;
total_dados_recebidos=0;
for id=1:length(nos)
   %{nos(id).Rx nos(id).Tx length(nos(id).fila) nos(id).stat.total_dados_enviados/tam_quadro  nos(id).stat.total_dados_recebidos/tam_quadro nos(id).stat.col}
   total_dados_recebidos=total_dados_recebidos+nos(id).stat.total_dados_recebidos;
   total_dados_enviados=total_dados_enviados+nos(id).stat.total_dados_enviados;
end

taxa_dados_entregues(end+1)=total_dados_recebidos/tempo_simulacao
eficiencia(1:2,end+1)=[total_dados_enviados total_dados_recebidos]/taxa_bits/tempo_simulacao;
eficiencia(1:2,end)/taxa_dados_gerados(end)