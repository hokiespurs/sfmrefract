%% CONSTANTS
% Make sample pointcloud las data
OUTNAME = 'PYRAMID';
NPTS = 1e0;
XI = linspace(0,100,round(sqrt(NPTS)));
YI = linspace(0,100,round(sqrt(NPTS)));
% XI = 50;
% YI = 50;
ZEQN = @(x,y) (abs(x-50)+abs(y-50))/20-4;

%% Compute Data
[xg,yg]=meshgrid(XI,YI);
zg = ZEQN(xg,yg);

%% Output LAS
p = fileparts(mfilename('fullpath'));

outname = [p '/../../testdata/points/' sprintf('pc_1e%.0f_%s.las',log10(NPTS),OUTNAME)];

writelas(xg,yg,zg,outname)