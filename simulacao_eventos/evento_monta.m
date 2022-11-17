

function e=evento_monta(t, tipo, id, pct,parent)
  if nargin<5, parent=[]; end
  if nargin<4, pct=[]; end
  e=struct('instante', t, 'tipo', tipo, 'id', id);
  e.pct=pct;
  e.parent=parent;
end