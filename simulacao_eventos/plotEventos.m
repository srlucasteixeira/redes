function plotEventos(Novos_eventos)
figure(1); 
for i=1:length(Novos_eventos)
    e=Novos_eventos(i)
    global n
    cm=colormap(hsv(n));% cria mapa de cores
    %keyboard
    plot(e.instante,e.id,'o', ...
    'LineWidth',1, ...
    'MarkerEdgeColor','k', ...
    'MarkerFaceColor',cm(e.id,:));
    hold on; grid on;
    if strcmp(e.tipo,'R_fim') 
        % desenha linha desde inicio da ocorrencia que criou este evento
        if ~isempty(e.parent)
            e.parent.id
            plot([e.parent.instante e.instante],[e.parent.id e.id], ...
            'LineWidth',1,'Color',cm(e.id,:));
            %keyboard
            
        end
    end
    
end
end