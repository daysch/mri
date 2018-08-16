try
    add_string_gui(handles, string('updating phantom viewer...'));
    if isfield(handles, 'phan_viewer') && ishandle(handles.phan_viewer)
        pos = get(handles.phan_viewer, 'Position');
        close(handles.phan_viewer);
    else
        pos = [0 0];
    end
    
    if ~isempty(handles.real_phans)
        phan_true = cat(4, handles.real_phans{:});
        phan_true = sum(phan_true, 4);
        scale = 64/handles.recon_matrix_size*6.8;
        
        % display and move viewer
        handles.phan_viewer = vi(phan_true, 'aspect', [scale scale scale]);
        set(handles.phan_viewer, 'Name', 'Phantom Preview');
        movegui(handles.phan_viewer, [pos(1), pos(2)]);
        phantom_app;
    end
catch M
    uiwait(errordlg('unable to display phantom'));
    unpause_gui;
    rethrow(M);
end