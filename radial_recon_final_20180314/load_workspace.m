% loads the workspace in the current folder into the base matlab workspace
myvars = load('workspace');
for v = fieldnames(myvars)'
    assignin('base', v{1}, myvars.(v{1}));
end