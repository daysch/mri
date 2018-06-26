function run_reconstruction(handles, hObject)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check whether reconstruction has already been performed
handles.savename = 'reconstruction';
while exist([handles.data_path filesep handles.savename '.mat'], 'file')
    answer = inputdlg('Choose new name, cancel, or leave blank to overwrite:', ...
                      'Reconstruction Already Exists');
    if isempty(answer) % cancel if cancel button pressed
        error('reconstruction already exists. Please rename reconstruction or select new name when prompted');
    elseif isequal(answer,{''})
        break; % overwrite reconstruction if left blank
    end
    handles.savename = cell2mat(answer);
end

% run reconstruction. inform gui user of errors (if desired)
if ~get(handles.show_errors, 'Value')
    radial_recon_rs2d_20180314_two_grads(handles);
else
    try
        radial_recon_rs2d_20180314_two_grads(handles);
    catch M
        errordlg(['Unexpected error in execution of reconstruction:' newline M.message]);
        add_string_gui(handles, ['Unexpected error in execution of reconstruction:' newline M.message])
        rethrow(M);
    end
end