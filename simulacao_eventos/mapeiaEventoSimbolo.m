function simbolo =  mapeiaEventoSimbolo(evento)

tipos    = {'RTS','CTS','DADOS','ACK','N_pct','N_cfg','T_ini','T_ini_r','FIM_NAV'};
simbolos = 'ohdpO+xsO*';

if any(size(evento)>1)
    % gera legenda
    simbolo.string = tipos;
    simbolo.string =strrep(simbolo.string ,'_','\_');

    simbolo.valores = simbolos;
    return
end

for i =1:length(tipos)
    if (strfind(evento.tipo,tipos{i}))
        simbolo=simbolos(i);
        return
    end
end
% default
simbolo='.';

end