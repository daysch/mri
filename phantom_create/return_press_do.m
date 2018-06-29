% https://www.mathworks.com/matlabcentral/answers/1450-gui-for-keyboard-pressed-representing-the-push-button
function return_press_do(hObject, eventdata, handles, button, fun)
% if "button" enabled, runs given function and moves focus to button

switch eventdata.Key
    case 'return'
        if isequal(get(button, 'enable'), 'on') % make sure we're not paused
            uicontrol(button); % need to deselect other fields so they can update
            fun(button, eventdata, handles);
        end
end