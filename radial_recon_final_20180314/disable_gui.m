function disable_gui(handles)
    set(handles.prepts, 'enable', 'off');
    set(handles.firstpt, 'enable', 'off');
    set(handles.numpts, 'enable', 'off');
    set(handles.choose_file, 'enable', 'off');
    set(handles.run, 'enable', 'off');
    set(handles.batch_run, 'enable', 'off');
    set(handles.recon_matrix_size, 'enable', 'off');
    set(handles.show_errors, 'enable', 'off');
    set(handles.warn_overwrite, 'enable', 'off');