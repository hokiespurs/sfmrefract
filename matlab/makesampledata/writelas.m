function writelas(x,y,z,outname)
% WRITELAS outputs an las file
%   Detailed explanation goes here
% 
% Inputs:
%   - x       : x data
%   - y       : y data
%   - z       : z data
%   - outname : output filename
% 
% Outputs:
%   - n/a 
% 
% Examples:
%   writelas([1 2 3],[2 3 1],[1 1 2],'test.las')
% 
% Dependencies:
%   - LASread.m
%   - LASwrite.m
% 
% Toolboxes Required:
%   - Statistics and Machine Learning Toolbox
% 
% Author        : Richie Slocum
% Email         : richie@cormorantanalytics.com
% Date Created  : 14-May-2019
% Date Modified : 14-May-2019
% Github        : https://github.com/hokiespurs/sfmrefract

p = fileparts(mfilename('fullpath'));

S = LASread([p '/template.las']);

%% Make Header
S.header.system_identifier              = 'MATLAB writelas.m';
S.header.generating_software            = 'MATLAB writelas.m';
% S.header.file_creation_doy              = round((now-year(now))*365);
% S.header.file_creation_year             = year(now);
S.header.x_scale_factor                 = 0.001;
S.header.y_scale_factor                 = 0.001;
S.header.z_scale_factor                 = 0.001;

S.record.x                              = x(:);
S.record.y                              = y(:);
S.record.z                              = z(:);
S.record.intensity                      = zeros(size(x(:)));
S.record.return_number                  = zeros(size(x(:)));
S.record.number_of_returns              = zeros(size(x(:)));
S.record.scan_direction_flag            = zeros(size(x(:)));
S.record.flightline_edge_flag           = zeros(size(x(:)));
S.record.classification                 = zeros(size(x(:)));
S.record.classification_synthetic       = zeros(size(x(:)));
S.record.classification_keypoint        = zeros(size(x(:)));
S.record.classification_withheld        = zeros(size(x(:)));
S.record.scan_angle                     = zeros(size(x(:)));
S.record.user_data                      = zeros(size(x(:)));
S.record.point_source_id                = zeros(size(x(:)));
S.record.gps_time                       = zeros(size(x(:)));
S.record.red                            = 255*ones(size(x(:)));
S.record.green                          = 255*ones(size(x(:)));
S.record.blue                           = 255*ones(size(x(:)));

%% Use LASwrite
LASwrite(S,outname,'version', 12);
end
