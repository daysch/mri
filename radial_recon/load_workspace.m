% loads the workspace in the current folder into the base matlab workspace
if exist('workspace', 'file')
    myvars = load('workspace');
    for v = fieldnames(myvars)'
        assignin('base', v{1}, myvars.(v{1}));
    end
else
    msgbox('Image reconstruction is complete, but calculations could not be saved for future use. ','Unable to load workspace data.')
end