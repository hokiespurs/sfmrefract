%% CONSTANTS
% make sample trajectory eo data
EONAME = 'nadiryawlock';
NCAMS = 3;
XI = linspace(20,80,round(sqrt(NCAMS)));
YI = linspace(20,80,round(sqrt(NCAMS)));
% XI = [20 40 60];
% YI = [50];
ZEQN = @(x,y) ones(size(x))*50;
OMEGASTD = 0;
PHISTD = 0;
KAPPASTD  = 0;

%% Compute Data
[xg,yg]=meshgrid(XI,YI);
zg = ZEQN(xg,yg);
omegag = randn(size(zg)) * OMEGASTD;
phig   = randn(size(zg)) * PHISTD;
kappag = randn(size(zg)) * KAPPASTD;

%% OutputData
p = fileparts(mfilename('fullpath'));

outname = [p '/../../testdata/eo/' sprintf('eo_%03.0f_%s_opk.txt',numel(xg),EONAME)];

fid=fopen(outname,'w+t');
fprintf(fid,'# Cameras (%.0f)\n',numel(xg));
fprintf(fid,'# PhotoID, X, Y, Z, Omega, Phi, Kappa, r11, r12, r13, r21, r22, r23, r31, r32, r33\n');

for i=1:numel(xg)
   fprintf(fid,'IMAGENAME%04.0f.JPG\t%.16f\t%.16f\t%.16f\t%.16f\t%.16f\t%.16f',...
       i,xg(i),yg(i),zg(i),omegag(i),phig(i),kappag(i));
   r = euler2dcm(omegag(i)*pi/180,phig(i)*pi/180,kappag(i)*pi/180,'xyz');
   fprintf(fid,'\t%.16f',r');
   fprintf(fid,'\n');
end
fclose(fid);