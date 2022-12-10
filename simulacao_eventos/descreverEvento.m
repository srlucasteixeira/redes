function txt = descreverEvento(e)

txt       ={sprintf('instante:%3.2fms',e.instante*1000)};
txt{end+1}=sprintf('    tipo:%s',e.tipo);
txt{end+1}=sprintf('    tipo:%d',e.id);
txt{end+1}=sprintf('    pacote: %d bytes de %d -> %d',e.pct.tam,e.pct.src,e.pct.dst);