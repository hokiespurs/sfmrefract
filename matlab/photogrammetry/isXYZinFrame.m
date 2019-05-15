function [u,v,s,isinframe] = isXYZinFrame(K,R,T,xw,yw,zw,pixx,pixy)
% calculate if a point is in a camera fov
[u,v,s] = xyz2uv(K,R,T,xw,yw,zw);

inx = u<pixx & u>=1;
iny = v<pixy & v>=0;
isinfront = s>0;

isinframe = inx & iny & isinfront;

end