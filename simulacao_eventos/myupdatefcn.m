function txt = myupdatefcn(empt,event_obj)
tic
% meu_profile_start;
global Log_eventos
myupdatefcnParams{1}=empt;
myupdatefcnParams{2}=event_obj;
global myupdatefcnRunning
maxSimultaneouseWaitTime=2; % max wait X seconds
global prev_txt;
if length(myupdatefcnRunning)==0 | isa(myupdatefcnRunning,'uint64')==0
    myupdatefcnRunning=uint64(0);
else
    if toc(myupdatefcnRunning) < maxSimultaneouseWaitTime
        % locked to single instance running!
        txt='Simultaneous call, wait previous processing to be ready.';
        return
    end
end
myupdatefcnRunning=tic; % locks to signal that a single instance of myupdatefcn is already running
% Customizes text of data tips
% (event_obj)
% get(0,'Children')
tic
alvo=get(event_obj,'Target');
objeto=get(alvo,'Parent');
currentFigNum=get(objeto,'Parent');
X=get(alvo,'XData');
Y=get(alvo,'YData');
global modSol
UserData=get(alvo,'UserData');

pos = get(event_obj,'Position');
txt_not_found = {['X: ',num2str(pos(1))],...
    ['Y: ',num2str(pos(2))],...
    ['Dado não pode ser encontrado']};

if length(prev_txt)==0
    prev_txt={''};
end
sou_eu=[];
currentPosition=get(event_obj,'Position');
for i=1:length(X)
    %      [get(event_obj,'Position')]
    if  all([X(i) Y(i)]==[currentPosition])
        % encontra o indice do vetor correspondente aquele ponto, dai podem ser extraidos os dados diversos
        if length(UserData)>=(i)
            sou_eu(end+1)=UserData(i);
        else
            txt=txt_not_found;
            break;
        end
        %         break
    end
end
fignum=get(get(gco,'Parent'),'Parent');
drawnow;
if length(sou_eu)==0
    txt = txt_not_found;
    myupdatefcnRunning=0; % release lock
    return
end

% avoids to reprint repetidly same point in sequential calls
global prev_sou_eu
if length(prev_sou_eu)>0
    %             [prev_sou_eu sou_eu]
    %             (ismember(prev_sou_eu,sou_eu))
    if all(ismember(prev_sou_eu,sou_eu))
        % equals to previous, nothing to do.
        prev_sou_eu=sou_eu;
        txt=prev_txt;
        myupdatefcnRunning=uint64(0); % release lock
        return
    end
    prev_sou_eu=sou_eu;
else
    prev_sou_eu=sou_eu;
end
if length(sou_eu)>1
    warning('myUpdateFunction:MultiplosPontos','Multiplos pontos encontrados.');
    meu_disable_last_warning();
end

for n=sou_eu
    n
    txt=descreverEvento(Log_eventos(n));
    txt{end+1} = ['Index:      ',num2str((n))]
    
%     if length(sou_eu)>0
    figure(currentFigNum);
    pc=plotConfig;
    pc.pointTo(currentPosition(1),currentPosition(2),[0.1 0.1],[]);

%     if n==sou_eu(1)
%         handleJanela=meu_janela_texto(meu_printcell(txt),'substituir');%,handleJanela);
%     else
%         handleJanela=meu_janela_texto(meu_printcell(txt),'adicionar');%,handleJanela);
%     end
    
    %         else
    %             handleJanela=meu_janela_texto(meu_printcell(txt),'criar');
    %         end
    %     else
    %         handleJanela=meu_janela_texto(meu_printcell(txt),'criar');
    %     end
end
drawnow;
% resume para não poluir grafico
% if length(sou_eu)>1
%     txt = ['Indexes:      ',num2str(sou_eu)];
% else
%     txt = ['Index:      ',num2str(sou_eu)];
% end
prev_txt=txt;


meu_janela_texto(sprintf('Took me %2.2f seconds to find and write, processing...',toc),'adicionar');%,handleJanela);

prev_txt=txt;
% meu_janela_texto(sprintf('Took %2.2f seconds to show graphics',toc),'adicionar');%,handleJanela);

meu_janela_texto(sprintf('Finished',toc),'adicionar');%,handleJanela);

figure(currentFigNum); % restore original active graphic window
myupdatefcnRunning=uint64(0); % release lock
% meu_profile_stop;
end