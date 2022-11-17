

function e=evento_monta(t, tipo, id, pct)
  if nargin<4, pct=[]; end
  e=struct('instante', t, 'tipo', tipo, 'id', id);
  e.pct=pct;
end