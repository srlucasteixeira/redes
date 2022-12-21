function plotEventos(Novos_eventos,textos,max_indice)
% Imprime gráfico gerado a partir dos eventos
%    plotEventos(Novos_eventos,textos)
% textos=1  gera labels, textos=0 ou omitir este parametro não gera textos (mais rápido)
% if gcf~=1
    h=gcf;
    dcobj=datacursormode(h);
    %global myupdatefcnRunning
    %myupdatefcnRunning=1;
    set(dcobj,'UpdateFcn',@myupdatefcn);
    hold off
    %inicializa plot(0,0) com legenda
    legenda=mapeiaEventoSimbolo([1 1]);
    for i=1:length(legenda.string)
        h0=plot(0,0,[ legenda.valores(i) 'k']);
        hold on
    end
    legend(legenda.string , ...
        'Location','EastOutside');
    
% end
if nargin<2
    textos=0;
end
if nargin<3
    max_indice=length(Novos_eventos);
end

ylim([0 0.001] );
xlim([0 0.001] );
global nos;
global num_estacoes
for i=1:max_indice%
    e=Novos_eventos{i};
    tempo_atual=e.instante;
    cm=colormap(hsv(num_estacoes));% cria mapa de cores
    %keyboard
    simbolo=mapeiaEventoSimbolo(e);
    if e.id==0
        break
    end
    cor = cm(e.id,:);
    h0=plot(e.instante,e.id,simbolo, ...
    'LineWidth',1, ...
    'MarkerEdgeColor','k', ...
    'MarkerFaceColor',cor);
    set(h0,'UserData',i);
    hold on; grid on;
    if (textos) % escreve nome dos tipos de eventos
        if size(e.pct)>0
            pcttxt=[num2str(e.pct.src) '>' num2str(e.pct.dst)]; 
        else
            pcttxt=[];
        end
        texto=[e.tipo ' ' num2str(e.id) ' ' pcttxt ' (' num2str(length(nos(e.id).fila)) ')'];
        texto=strrep(texto,'_','\_');
        h=text(e.instante,e.id+0.1,texto,...
            'Rotation',75,...
            'FontSize',10);
%         h=text(e.instante,e.id+0.1,texto,...
%             'Rotation',75,...
%             'FontSize',10,...
%             'Clipping', 'on','hittest', 'off');

    end
    if strfind(e.tipo,'_fim')
        % desenha linha desde inicio da ocorrencia que criou este evento
        if ~isempty(e.parent)
            %e.parent.id
            cor_linha=cm(e.id,:);
            LineWidth=4;
            %e
            if (e.id ~= e.pct.dst) && (e.id ~= e.pct.src)
                cor_linha=[0.5 0.5 0.5]; % algum tom de cinza
                LineWidth=1;
            end
            h0=plot([e.parent.instante e.instante],[e.parent.id e.id], ...
            'LineWidth',LineWidth,'Color',cor_linha);        
            set(h0,'UserData',i);
        end
    end
%     if strfind(e.tipo,'_ini') & ~isempty(e.parent)
%         anArrow = annotation('arrow') ;
% %         anArrow.Parent = gca;  % or any other existing axes or figure
%         %EDIT thanks to @Moshe: 
%         %anArrow.Position = [x_start, y_start, x_end, y_end] ;
%         anArrow.Position = [e.instante, e.id, e.instante, e.parent.id];
%         clear anArrow;
%     end
end

ylim([0.5 num_estacoes+0.5])
xlim([Novos_eventos{1}.instante Novos_eventos{max_indice}.instante] );
end