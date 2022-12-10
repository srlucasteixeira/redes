function traceEvento (num)

clc
disp('==============================================')
global Log_eventos
c=0;
e = Log_eventos(num);
while(size(e)>0)
    for i=0:c
        fprintf('>');
    end
    if c<1
        fprintf('   %d\n',c);
    else
        fprintf('  Parent %d\n',c);
    end
    Log_eventos(num)
    Log_eventos(num).pct
    c=c+1;
    e = e.parent;
    disp('----------------------------------------------')    
end
disp('==============================================')