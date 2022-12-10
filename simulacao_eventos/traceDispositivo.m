function traceDispositivo (num)

clc
disp('==============================================')
global Log_eventos

c=0;
e = Log_eventos(num);
for n=1:length(Log_eventos)
    if (Log_eventos(n).id == num)
        e=Log_eventos(n);
        if size(e.pct)>0
            % imprimir somente eventos nos quais este dispositivo tenha
            % participação como destino ou origem
            if (num == e.pct.dst) || (num == e.pct.src)
                %         for i=0:c
                %             fprintf('>');
                %         end
                %         if c<1
                %             fprintf('   %d\n',c);
                %         else
                %             fprintf('  Parent %d\n',c);
                %         end
                vals={};
                vals{1}=sprintf('%2.3fms',e.instante*1000);
                vals{2}=e.tipo;
                if size(e.pct)>0
                    vals{3}=[ num2str(e.pct.src) ' -> ' num2str(e.pct.dst)];
                end
                disp(vals)
                %         c=c+1;
                %         disp('----------------------------------------------')
            end
        end
    end
end
disp('==============================================')
global nos
nos(num).stat
disp('==============================================')