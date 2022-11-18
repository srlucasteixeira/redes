function plotEventos(Novos_eventos,tempo_atual)
figure(1); 
global nos;
for i=1:length(Novos_eventos)
    e=Novos_eventos(i);
    global num_estacoes
    cm=colormap(hsv(num_estacoes));% cria mapa de cores
    %keyboard
    plot(e.instante,e.id,'o', ...
    'LineWidth',1, ...
    'MarkerEdgeColor','k', ...
    'MarkerFaceColor',cm(e.id,:));
    hold on; grid on;
%     texto=[e.tipo ' ' num2str(e.id) ' (' num2str(nos(e.id).fila) ')'];
%     texto=strrep(texto,'_','\_');
%     h=text(e.instante,e.id+0.1,texto);
%     set(h,'Rotation',75)
%     set(h,'FontSize',10)
    if strfind(e.tipo,'_fim')
        % desenha linha desde inicio da ocorrencia que criou este evento
        if ~isempty(e.parent)
            %e.parent.id
            cor_linha=cm(e.id,:);
            LineWidth=4;
            if (e.id ~= e.pct.dst) && (e.id ~= e.pct.src)
                cor_linha=[0.5 0.5 0.5]; % algum tom de cinza
                LineWidth=1;
            end
            plot([e.parent.instante e.instante],[e.parent.id e.id], ...
            'LineWidth',LineWidth,'Color',cor_linha);
            
        end
    end
    
end
% xlim(xlim+[-0.1 +0.1])
global num_estacoes
ylim([0.1 num_estacoes+1] )
xlim([0 tempo_atual+0.1])
end