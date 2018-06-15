% prints a given string to the gui
function add_string_gui(handles, addition)
    old_update = get(handles.update, 'String');
    old_update = mat_to_string(old_update); % handles.update String is stored as multidimensional matrix. Must be converted to string
    set(handles.update, 'String', sprintf('%s%s', old_update, addition));
    drawnow;
end

% coverts matrix representation of string to datatype string, preserving newlines
function str = mat_to_string(mat)
    mat(:,end + 1) = '\'; mat(:,end + 1) = 'n';
    mat = mat'; 
    mat = mat(:);
    mat = mat';
    str = compose(mat);
    if isa(str, 'cell')
        str = cell2mat(str);
    end
end