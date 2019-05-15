function cameras = readtrajectory(fname)
try
    fid = fopen(fname,'r');
    alldat = fread(fid,'*char');
    fclose(fid);
    alllines = strsplit(alldat','\n');
    
    cameras=[];
    for i=3:numel(alllines)
        if ~isempty(alllines{i})
            vals = strsplit(alllines{i},{'\t',',',' '});
            cameras.name{i-2} = vals{1};
            cameras.E(i-2) = str2double(vals{2});
            cameras.N(i-2) = str2double(vals{3});
            cameras.Z(i-2) = str2double(vals{4});
            opk = [str2double(vals{5}) str2double(vals{6}) str2double(vals{7})];
            
            R = euler2dcm(opk(1)*pi/180,opk(2)*pi/180,opk(3)*pi/180,'xyz');
            cameras.R{i-2} = diag([1, -1, -1]) * R;
        end
    end
catch
    error('Couldnt load EO file');
end
end
