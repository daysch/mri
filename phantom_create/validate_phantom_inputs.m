%% validates inputs. throws error 'known error' if input is bad, to be picked up function that calls this script
% collect values
phan_extent_val = [str2double(get(handles.x_extent, 'String')) ...
                   str2double(get(handles.y_extent, 'String')) ...
                   str2double(get(handles.z_extent, 'String'))];
phan_offset_val = [str2double(get(handles.x_offset, 'String')) ...
                   str2double(get(handles.y_offset, 'String')) ...
                   str2double(get(handles.z_offset, 'String'))];
intensity_val = str2double(get(handles.intensity, 'String'));
rotAng = deg2rad(str2double(get(handles.angle, 'String')));
rotDir = [str2double(get(handles.xDir, 'String')) ...
          str2double(get(handles.yDir, 'String')) ...
          str2double(get(handles.zDir, 'String'))];

% make sure all values filled out
if any(isnan(phan_extent_val)) || any(isnan(phan_offset_val)) || ...
       isnan(intensity_val) || any(isnan(rotDir)) || length(rotAng) ~= 1 || ...
       isnan(rotAng)
        uiwait(errordlg('Please fill out parameters'));
        error('known error');
end

% only intensity and angles can be a float
if any(mod(phan_extent_val, 1))
    uiwait(errordlg('extents must be integers'));
    error('known error');
elseif any(mod(phan_offset_val, 1))
    uiwait(errordlg('offsets must be integers'));
    error('known error');
elseif any(mod(rotDir, 1))
    uiwait(errordlg('rotation direction must be integers'));
    error('known error');
end

% validate values in inputs
if isinf(rotAng)
    uiwait(errordlg('rotation angle must be finite'));
    error('known error');
elseif any(phan_extent_val <= 0)
    uiwait(errordlg('extents must be positive'));
    error('known error');
elseif isinf(intensity_val) || isnan(intensity_val) || intensity_val == 0
    uiwait(errordlg('intensity must be finite nonzero number'));
    error('known error');
end