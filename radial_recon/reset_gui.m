function reset_gui(handles, hObject)

    handles.quit_batch = false;
    handles.continue = true;
    
    set(handles.batch_run, 'enable', 'on');
    set(handles.run, 'enable', 'on');
    set(handles.prepts, 'enable', 'on');
    set(handles.firstpt, 'enable', 'on');
    set(handles.numpts, 'enable', 'on');
    set(handles.choose_file, 'enable', 'on');
    set(handles.recon_matrix_size, 'enable', 'on');
    set(handles.show_errors, 'enable', 'on');
    set(handles.warn_overwrite, 'enable', 'on');
    
    set(handles.pause, 'enable', 'off');
    set(handles.pause, 'String', 'Pause batch job');
    set(handles.pause, 'userdata', 0);
    
    set(handles.cancel_batch, 'visible', 'off');
    set(handles.cancel_batch, 'String', 'Cancel batch job');
    set(handles.cancel_batch, 'enable', 'on');
    set(handles.cancel_batch, 'visible', 'off');
    
    guidata(hObject, handles);