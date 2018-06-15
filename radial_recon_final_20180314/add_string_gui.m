% prints a given string to the gui
function add_string_gui(handles, addition)
    old_update = get(handles.update, 'String');
    set(handles.update, 'String', [old_update; string(addition)]);
    drawnow;
end
