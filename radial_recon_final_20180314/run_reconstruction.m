function run_reconstruction(handles, hObject)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% run reconstruction. inform gui user of errors (if desired)
if ~get(handles.show_errors, 'Value')
    radial_recon_rs2d_20180314_two_grads(handles);
else
    try
        radial_recon_rs2d_20180314_two_grads(handles);
    catch M
        errordlg(['Unexpected error in execution of reconstruction:' newline M.message]);
        add_string_gui(handles, ['Unexpected error in execution of reconstruction:' newline M.message])
        error(['Unexpected error in execution of reconstruction:' newline M.message]);
    end
end