function [Sfmcorr,pc] = sfmrefract(pcname,eoname,ioname,tideval,varargin)
% SFMREFRACT applies refraction correction to pointcloud data
%   Uses the Dietrich algorithm, or optionally a constant scalar depth
%   correction 
%
% Required Inputs:
%	- pcname    : pointcloud filename
%	- eoname    : Exterior Orientation trajectory filename
%	- ioname    : Interior Orientation trajectory filename
%	- tideval   : Z tideval/filename of mesh
%
% Optional Inputs: (default)
%	- 'constsf' : ([]) if empty, do dietrich, else, do depth scaling
%   - 'ior'     : (1.33) Index of refraction
%
% Outputs:
%   - Sfmcorr   : Structure of sfm data corrected for refraction
%   - pc        : corrected pointcloud structure output from LASread
%                  LAS intensity      = depth correction ratio *10000
%                  LAS classification = (1=unclass, 9=underwater)
%                  LAS user_data      = # Cameras
%                  LAS z              = Depth corrected Z value
%
% Examples:
%   - n/a
%
% Dependencies:
%   - isXYZinFrame.m
%   - xyz2uv.m
%   - euler2dcm.m
%   - xml2struct.m
%   - loopStatus.m
%   - LASread.m
%   - readsensor.m
%   - readtrajectory.m
%
% Toolboxes Required:
%   - n/a
%
% Author        : Richie Slocum
% Email         : richie@cormorantanalytics.com
% Date Created  : 13-May-2019
% Date Modified : 14-May-2019
% Github        : https://github.com/hokiespurs/sfmrefract

%% Function Call
[pcname,eoname,ioname,tideval,constsf,ior] = parseInputs(pcname,eoname,ioname,tideval,varargin{:});

%% Read Data
try
    pc     = LASread(pcname);
catch
    error('Couldnt load LAS file');
end

traj   = readtrajectory(eoname);
sensor = readsensor(ioname);

%% Organize Data
xyz = [pc.record.x pc.record.y pc.record.z];
npoints  = size(xyz,1);
ncameras = numel(traj.name);

h_a = tideval - xyz(:,3); %if tideval is a mesh, need to interpolate

pointclass = ones(size(h_a),'uint8');
%% IF Constant Scalar factor, rather than Dietrich
if ~isempty(constsf)
    h_corr = h_a;
    h_corr(h_corr>0) = h_corr(h_corr>0) * constsf;
    zNew = tideval - h_corr;
    ncams = zeros(size(zNew));
    pointclass(h_corr>0)=8;
else
    
    zNew  = nan(size(pc.record.x));
    ncams = nan(npoints,1);
    
    %% FOR Loop through every point
    starttime = now;
    for ipoint = 1:npoints
        %%   IF point below water
        if h_a(ipoint)>0 % point is below water
            Zcorr          = nan(ncameras,1);
            elevationangle = nan(ncameras,1);
            %%     FOR each camera
            for jcamera = 1:ncameras
                iK = sensor.K;
                iR = traj.R{jcamera};
                iT = [traj.E(jcamera); traj.N(jcamera); traj.Z(jcamera);];
                pixx = sensor.pixx;
                pixy = sensor.pixy;
                
                [~,~,~,isinframe]=isXYZinFrame(iK,iR,iT,xyz(ipoint,1),xyz(ipoint,2),xyz(ipoint,3),pixx,pixy);
                %%       IF point visible by camera, compute correction
                if isinframe %if camera sees the point
                    % Compute angle relative to flat water (az-el)
                    D = sqrt((iT(1)-xyz(ipoint,1))^2+(iT(2)-xyz(ipoint,2))^2);
                    dH = iT(3)-xyz(ipoint,3);
                    
                    r = atan2(D,dH);
                    
                    elevationangle(jcamera)=r*180/pi; % just for debugging
                    
                    i = asin(1/ior*sin(r));
                    
                    x = h_a(ipoint) * tan(r);
                    
                    h = x/tan(i);
                    
                    % Calculate Z_corr
                    Zcorr(jcamera) = tideval - h;
                end
            end
            %%     average camera corrections to new depth
            % average Z_corr
            zNew(ipoint) = mean(Zcorr(~isnan(Zcorr)));
            ncams(ipoint) = sum(~isnan(Zcorr));
            pointclass(ipoint) = 8;
        else
            zNew(ipoint)=tideval - h_a(ipoint);
            ncams(ipoint)=0;
        end
    loopStatus(starttime,ipoint,npoints,round(npoints/10));    
    end
    
end

%% Organize Data
Sfmcorr.x          = xyz(:,1);
Sfmcorr.y          = xyz(:,2);
Sfmcorr.zraw       = xyz(:,3);
Sfmcorr.znew       = zNew;
Sfmcorr.ncams      = ncams;
Sfmcorr.pointclass = pointclass;
Sfmcorr.ratiocorr  = (tideval-Sfmcorr.znew)./(tideval-Sfmcorr.zraw);

pc.record.classification    = pointclass;
pc.record.z                 = zNew;
pc.record.user_data         = uint8(ncams);
pc.record.intensity         = uint16(Sfmcorr.ratiocorr *10000);

end

function [pcname,eoname,ioname,tideval,constsf,ior] = parseInputs(pcname,eoname,ioname,tideval,varargin)
%%	 Call this function to parse the inputs

% Default Values
default_constsf  = [];
default_ior      = 1.33;

% Check Values
check_pcname   = @(x) true;
check_eoname   = @(x) true;
check_ioname   = @(x) true;
check_tideval  = @(x) true;
check_constsf  = @(x) true;
check_ior      = @(x) true;

% Parser Values
p = inputParser;
% Required Arguments:
addRequired(p, 'pcname'  , check_pcname  );
addRequired(p, 'eoname'  , check_eoname  );
addRequired(p, 'ioname'  , check_ioname  );
addRequired(p, 'tideval' , check_tideval );
% Parameter Arguments
addParameter(p, 'constsf' , default_constsf, check_constsf );
addParameter(p, 'ior'     , default_ior    , check_ior     );

% Parse
parse(p,pcname,eoname,ioname,tideval,varargin{:});
% Convert to variables
pcname  = p.Results.('pcname');
eoname  = p.Results.('eoname');
ioname  = p.Results.('ioname');
tideval = p.Results.('tideval');
constsf = p.Results.('constsf');
ior     = p.Results.('ior');
end