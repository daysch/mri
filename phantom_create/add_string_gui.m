function add_string_gui(handles, addition)
% prints a given string to the gui
%
% handles: struct containing a figure handle to a textbox called 'update'
% addition: string to be added to update textbox
    old_update = get(handles.update, 'String');
    set(handles.update, 'String', [old_update; string(addition)]);
    drawnow;
end
