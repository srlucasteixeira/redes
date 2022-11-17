

function [t, tipo, id, pct, parent]= evento_desmonta(e)
  t=e.instante;
  tipo=e.tipo;
  id = e.id;
  pct=e.pct;
  parent=e.parent;
end