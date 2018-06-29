% unpauses gui
set(handles.add, 'enable', 'on');
if ~isequal(handles.phan_list.String, ' ')
    set(handles.remove, 'enable', 'on');
    set(handles.clear, 'enable', 'on');
    set(handles.generate, 'enable', 'on');
end