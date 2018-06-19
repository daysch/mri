%% validates inputs. throws error 'known error' if input is bad, to be picked up function that calls this script
% collect values
handles.phan_extent_val = [str2double(get(handles.x_extent, 'String')) ...
                           str2double(get(handles.y_extent, 'String')) ...
                           str2double(get(handles.z_extent, 'String'))];
handles.phan_offset_val = [str2double(get(handles.x_offset, 'String')) ...
                           str2double(get(handles.y_offset, 'String')) ...
                           str2double(get(handles.z_offset, 'String'))];
handles.intensity_val = str2double(get(handles.intensity, 'String'));

% make sure all values filled out
if any(isnan(handles.phan_extent_val)) || any(isnan(handles.phan_offset_val)) || ... 
    isnan(handles.intensity_val)
        errordlg('Please fill out parameters');
        error('known error');
end

% only intensity can be a float
if any(mod(handles.phan_extent_val, 1))
    errordlg('extents must be integers');
    error('known error');
elseif any(mod(handles.phan_offset_val, 1))
    errordlg('offsets must be integers');
    error('known error');
end

% validate values in inputs
if max(handles.phan_extent_val)>handles.matrix_size/2
    errordlg('phantom too big for matrix');
    error('known error');
elseif max(abs(handles.phan_offset_val) + handles.phan_extent_val)>handles.matrix_size
    errordlg('phantom too far offcenter')
    error('known error');
elseif any(handles.phan_extent_val <= 0)
    errordlg('extents must be positive')
    error('known error');
end

guidata(hObject, handles);