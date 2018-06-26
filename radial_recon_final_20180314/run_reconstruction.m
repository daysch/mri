function run_reconstruction(handles, hObject)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check whether reconstruction has already been performed
handles.savename = 'reconstruction';
while handles.warn_overwrite.Value && exist([handles.data_path filesep handles.savename '.mat'], 'file')
    answer = timedlg('Choose new name, cancel, or leave blank to overwrite:', ...
                      'Reconstruction Already Exists', 10);
    if isequal(answer,{''}) % cancel if cancel button pressed or timed out
        error('reconstruction already exists. Please rename reconstruction or select new name when prompted (or leave new name field blank to overwrite old reconstruction)');
    elseif isempty(answer)
        break; % overwrite reconstruction if left blank
    end
    handles.savename = answer;
end

% run reconstruction. inform gui user of errors (if desired)
if ~get(handles.show_errors, 'Value')
    radial_recon_rs2d_20180314_two_grads(handles);
else
    try
        radial_recon_rs2d_20180314_two_grads(handles);
    catch M
        errordlg(['Unexpected error in execution of reconstruction:' newline M.message]);
        rethrow(M);
    end
end