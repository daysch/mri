% prints the time elapsed to the gui
function update_gui_time(handles)
    add_string_gui(handles, sprintf('Elapsed time is %s seconds', num2str(toc)));
end