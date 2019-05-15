function sensor = readsensor(fname)
try
    % read sensor K parameters and pixx and pixy
    rawdat = xml2struct(fname);
    sensor.pixx = getsensorval(rawdat.calibration,'width',0);
    sensor.pixy = getsensorval(rawdat.calibration,'height',0);
    sensor.f = getsensorval(rawdat.calibration,'f',0);
    sensor.cx = getsensorval(rawdat.calibration,'cx',0);
    sensor.cy = getsensorval(rawdat.calibration,'cy',0);
    sensor.b1 = getsensorval(rawdat.calibration,'b1',0);
    sensor.b2 = getsensorval(rawdat.calibration,'b2',0);
    sensor.k1 = getsensorval(rawdat.calibration,'k1',0);
    sensor.k2 = getsensorval(rawdat.calibration,'k2',0);
    sensor.k3 = getsensorval(rawdat.calibration,'k3',0);
    sensor.k4 = getsensorval(rawdat.calibration,'k4',0);
    sensor.p1 = getsensorval(rawdat.calibration,'p1',0);
    sensor.p2 = getsensorval(rawdat.calibration,'p2',0);
    
    sensor.K = [sensor.f 0 sensor.pixx/2+sensor.cx;0 sensor.f sensor.pixy/2+sensor.cy;0 0 1];
catch
    error('Couldnt load IO file');
end
end

function val = getsensorval(calibration,strval,defaultval)

if isfield(calibration,strval)
    valtext = getfield(calibration,strval);
    val = str2double(valtext.Text);
else
    val = defaultval;
end

end