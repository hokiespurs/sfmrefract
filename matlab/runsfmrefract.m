%% RUNSFMREFRACT
%% CONSTANTS 
p = fileparts(mfilename('fullpath'));
PCNAME  = [p '/../testdata/points/pc_1e0_PYRAMID.las'];
EONAME  = [p '/../testdata/eo/eo_003_nadiryawlock_opk.txt'];
IONAME  = [p '/../testdata/io/ioFoo.xml'];
OUTNAME = [p '/../testdata/foo.las'];
TIDEVAL = 0;

%% Run Script
[Sfmcorr, pc] = sfmrefract(PCNAME,EONAME,IONAME,TIDEVAL,'constsf',[]);

%% Save Data
LASwrite(pc,OUTNAME,'version', 12);

%% Make Plot
figure(1);
subplot(2,2,1)
ratiocorr = (TIDEVAL-Sfmcorr.znew)./(TIDEVAL-Sfmcorr.zraw);
histogram(ratiocorr,0.99:0.01:2);
title('Ratio Correction');

subplot(2,2,2)
waterind = Sfmcorr.pointclass==8;
plot(Sfmcorr.x(~waterind),Sfmcorr.y(~waterind),'r.');
hold on
plot(Sfmcorr.x(waterind),Sfmcorr.y(waterind),'b.');
title('Red=Land, Blue=Water');

subplot(2,2,3)
scatter(Sfmcorr.x(waterind),Sfmcorr.y(waterind),20,Sfmcorr.ncams(waterind),'fill');
colorbar
title('# Cameras');

subplot(2,2,4)
scatter(Sfmcorr.x(waterind),Sfmcorr.y(waterind),20,ratiocorr(waterind),'fill');
colorbar
title('Depth Correction Ratio');
