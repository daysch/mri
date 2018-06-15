%% validates inputs. throws error 'known error' if input is bad, to be picked up function that calls this script
handles.firstpt_val = str2double(get(handles.firstpt, 'String'));
handles.prepts_val = str2double(get(handles.prepts, 'String'));
handles.recon_matrix_size_val = str2double(get(handles.recon_matrix_size, 'String'));

% make sure all values filled out
if isnan(handles.firstpt_val) || isnan(handles.prepts_val) || ... 
        isnan(handles.recon_matrix_size_val)
    errordlg('Please fill out parameters');
    error('known error');
elseif ~isfield(handles, 'data_path') || isa(handles.data_path, 'double')
    errordlg('Please select folder');
    error('known error');
end

% confirm validity of inputs
if mod(handles.firstpt_val, 1) ~= 0 || mod(handles.prepts_val, 1) ~= 0 || mod(handles.recon_matrix_size_val, 1) ~= 0
    errordlg('parameters must be integers');
    error('known error');
elseif handles.firstpt_val <= handles.prepts_val
    errordlg('First point must be greater than zero point');
    error('known error');
elseif handles.prepts_val < 0
    errordlg('zero point cannot be negative');
    error('known error');
elseif handles.recon_matrix_size_val <= 0 || mod(handles.recon_matrix_size_val, 2) ~= 0
    errordlg('recon matrix must be a positive multiple of two');
    error('known error');
end

% check and validate optional field: number of points to be used
if ~isempty(get(handles.numpts, 'String'))
    handles.numpts_val = str2double(get(handles.numpts, 'String'));
    if mod(handles.numpts_val, 1) ~= 0 || handles.numpts_val <= 0
        errordlg('number of points must be a positive integer');
        error('known error');
    end
else
    handles.numpts_val = NaN;
end

guidata(hObject, handles);   % Store handles