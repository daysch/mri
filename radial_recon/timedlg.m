function answer = timedlg(prompt, title, timeout)
% Timed dialogue box. Informs user of time left to respond
% Returns value of edit box if input, {''} on
% cancel, and 0×0 empty char array on empty edit box (note these last two
% are opposite of standard inputdlg).
% If user has started typing or edit box is selected, will wait.
% 
% prompt and title: same as inputdlg
% timeout: seconds to wait before canceling
    
    typing = false;
    timeout = floor(timeout);
    message = [string(prompt);string(''); ...
               string(sprintf('(This dialogue will close in %d seconds without input)', timeout))];
    
    d = dialog('Position',[300 300 300 150],'Name',title);
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[20 100 260 40],...
           'String', message);
       
    edit_box = uicontrol('Parent',d,...
           'Style','edit',...
           'Position',[105 60 100 25],...
           'KeyPressFcn', @edit_box_callback);

    cancel = uicontrol('Parent',d,...
           'Position',[82 20 70 25],...
           'String','Cancel',...
           'Callback','delete(gcf)');
       
    choose = uicontrol('Parent',d,...
           'Position',[152 20 70 25],...
           'String','Submit',...
           'Callback',@choose_callback);
       
    answer = {''};
              
    % Wait for d to close before running to completion
    % If user has typed something in, continue waiting
    for ii = 1:timeout
        
        if ~ishandle(d)
            break;
        end
        uiwait(d, 1);
        if ~ishandle(d)
            break;
        end
        
        % update time/stop if user is typing
        message = [string(prompt);string(''); ...
        string(sprintf('(This dialogue will close in %d seconds without input)', timeout - ii))];
        set(txt, 'String', message);
        if typing || isequal(gco, edit_box)
            set(txt, 'String', prompt);
            break;
        end
    end
       
    if ~typing && ishandle(d) && ~isequal(gco, edit_box)
        close(d);
    elseif ishandle(d)
        uiwait(d);
    end
        
    % Choose new name
    function choose_callback(~,~)
        uicontrol(choose);
        answer = edit_box.String;
        delete(gcf);
    end
    
    % indicate typing/acknowledge enter key
    function edit_box_callback(~, event)
        typing = true;
        switch event.Key
            case 'return'
                choose_callback;
        end
    end
end