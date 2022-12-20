total_dados_enviados(end+1)=0;
total_dados_recebidos(end+1)=0;

for id=1:length(nos)
   %{nos(id).Rx nos(id).Tx length(nos(id).fila) nos(id).stat.total_dados_enviados/tam_quadro  nos(id).stat.total_dados_recebidos/tam_quadro nos(id).stat.col}
   total_dados_recebidos(end)=total_dados_recebidos(end)+nos(id).stat.total_dados_recebidos;
   total_dados_enviados(end)=total_dados_enviados(end)+nos(id).stat.total_dados_enviados;
end
hist_nos{end+1} = nos;
taxa_dados_entregues(end+1)=total_dados_recebidos(end)/tempo_simulacao;
taxa_dados_enviados(end+1)=total_dados_enviados(end)/tempo_simulacao;
eficiencia(1:2,end+1)=[total_dados_enviados(end) total_dados_recebidos(end)]/taxa_bits/tempo_simulacao;

figure(1);
plot(taxa_dados_enviados/taxa_bits,taxa_dados_entregues/taxa_bits);
titulo=sprintf('fracao da taxa quadro max. %1.2f',fracao_taxa_quadro);
xlabel('Taxa dados enviados (norm)');
ylabel('Taxa dados entregues (norm)');
grid on
title(titulo)
drawnow

demora_entrega=[];
for k=1:length(pacotes_entregues)
    demora_entrega(k)=pacotes_entregues{k}.instante_entregue-pacotes_entregues{k}.instante_gerado;
end
% [nelements,centers] = hist(demora_entrega);

%exportafigura(1,'dist_10m')

resultados(end+1).titulo=titulo;
resultados(end).num_estacoes=num_estacoes;
resultados(end).tam_quadro=tam_quadro;
resultados(end).taxa_bits=taxa_bits;
resultados(end).tempo_prop=tempo_prop;
resultados(end).demora_entrega=demora_entrega;


if(0)
%%
for k=1:length(resultados)
    figure(2)
    [nelements,centers] = hist(resultados(k).demora_entrega,20);
    bar(centers,nelements/max(nelements))
    xlim([0 0.4]);
    ylim([0 1]);
    xlabel('Atraso (s)');ylabel('Probabilidade')
    pause(1)
end
%%
end