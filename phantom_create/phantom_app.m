%% main phantom app code
function varargout = phantom_app(varargin)
% PHANTOM_APP MATLAB code for phantom_app.fig
%      PHANTOM_APP, by itself, creates a new PHANTOM_APP or raises the existing
%      singleton*.
%
%      H = PHANTOM_APP returns the handle to a new PHANTOM_APP or the handle to
%      the existing singleton*.
%
%      PHANTOM_APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHANTOM_APP.M with the given input arguments.
%
%      PHANTOM_APP('Property','Value',...) creates a new PHANTOM_APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before phantom_app_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to phantom_app_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help phantom_app

% Last Modified by GUIDE v2.5 13-Aug-2018 10:52:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @phantom_app_OpeningFcn, ...
                   'gui_OutputFcn',  @phantom_app_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before phantom_app is made visible.
function phantom_app_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to phantom_app (see VARARGIN)

% Choose default command line output for phantom_app
handles.output = hObject;

% set up constants
handles.recon_matrix_size = 64;

% load paths for 3d viewing/rotation
if ~exist('3D Rotation', 'dir')
    addpath([fileparts(fileparts(mfilename('fullpath'))) filesep '3dRotation']);
end
if ~exist('vi', 'dir')
    addpath([fileparts(fileparts(mfilename('fullpath'))) filesep '3D Viewers' filesep 'vi']); 
end

% set up variables/gui
handles.real_phans = {};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes phantom_app wait for user response (see UIRESUME)
% uiwait(handles.phantom_app);


% --- Outputs from this function are returned to the command line.
function varargout = phantom_app_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% validates and adds selected shape to list
% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)
% hObject    handle to add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB 
% handles    structure with handles and user data (see GUIDATA)

% only allow one process at a time, to avoid race conditions
pause_gui;

% validate inputs
try
    validate_phantom_inputs;
catch M
    unpause_gui;
    switch M.message
        case 'known error'
            return;
        otherwise
            uiwait(errordlg(M.message));
            rethrow(M);
    end
end

% select shape type
switch get(handles.phan_type, 'Value')
    case 1
        phan_type_val = 'ellipsoidal';
    case 2
        phan_type_val = 'rectangular';
end

% generate phantom matrix
try
    new_phan = phantom_mhd_new(handles.recon_matrix_size, phan_type_val, phan_extent_val, ...
                               phan_offset_val, intensity_val, rotAng, rotDir);
catch M
    uiwait(errordlg(['unable to generate shape:' newline M.message]));
    unpause_gui;
    rethrow(M);
end

% replace NaNs with 0s
new_phan(isnan(new_phan)) = 0;

% shape cannot be all 0s
if ~any(new_phan(:))
    uiwait(errordlg('shape completely out of bounds of matrix'));
    unpause_gui;
    error('shape completely out of bounds of matrix');
end

% save phantom matrix
old_list = get(handles.phan_list, 'String');
addition = string(sprintf('%s_OO=[%d %d %d]_E=[%d %d %d]_D=[%d %d %d]_R=%.2f_I=%d', phan_type_val, ...
                          phan_offset_val, phan_extent_val, rotDir, rad2deg(rotAng), intensity_val));
add_string_gui(handles, [string('added shape:'); addition]);

if isequal(old_list(1), ' ')
    set(handles.phan_list, 'String', addition);
    handles.real_phans = {new_phan};
else
    set(handles.phan_list, 'String', [old_list;addition]);
    handles.real_phans = [handles.real_phans; new_phan];
end

% display phantom so far
if handles.preview.Value
    disp_cur_phan;
end

guidata(hObject, handles);

% clean up
unpause_gui;


%% removes selected shape from list
% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get gui data
index = handles.phan_list.Value;
old_list = handles.phan_list.String;

% remove from internal list and gui list
set(handles.phan_list, 'String', [old_list(1:index-1); old_list(index+1:end)]);
handles.real_phans = [handles.real_phans(1:index-1); handles.real_phans(index+1:end)];

% move menu back to top
set(handles.phan_list, 'Value', 1)

% deal with empty phantom
if isempty(handles.real_phans)
    set(handles.phan_list, 'String', ' ');
    pause_gui;
    unpause_gui;
end

% gui update box
add_string_gui(handles, [string('removed shape:'); old_list(index, :)]);

% display phantom so far
if handles.preview.Value
    disp_cur_phan;
end

guidata(hObject, handles);


%% removes all shapes from list
% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = questdlg('Clear all shapes?','Confirm Clearing','Confirm','Cancel', 'Confirm');
switch answer 
    case 'Confirm'
        handles.real_phans = {};
        set(handles.phan_list, 'String', ' ');
        set(handles.phan_list, 'Value', 1);
        pause_gui;
        unpause_gui;
        add_string_gui(handles, [newline newline newline 'cleared shapes' newline newline newline]);
        % display phantom so far
        if handles.preview.Value
            disp_cur_phan;
        end
end


%% generates the phantom data from the list of cartesian matrices of shapes
% --- Executes on button press in generate.
function generate_Callback(hObject, eventdata, handles)
% hObject    handle to generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pause_gui;

% validate folder name
folder = get(handles.folder_name, 'String');
if isempty(folder)
    uiwait(errordlg('please specify name to save as'));
    unpause_gui;
    uicontrol(handles.folder_name);
    return;
end
if exist([fileparts(fileparts(mfilename('fullpath'))) filesep 'phantom_objects' filesep folder], 'dir')
    answer = questdlg('A phantom with that name already exists. Overwrite phantom?', ...
                      'Overwrite phantom?', 'Overwrite', 'Cancel', 'Cancel');
    switch answer
        case 'Cancel'
            unpause_gui;
            uicontrol(handles.folder_name);
            return;
    end
end

% sum up phantoms
phan_true=cat(4, handles.real_phans{:});
phan_true = sum(phan_true, 4);

% generate phantom
add_string_gui(handles, [newline 'generating phantom...']);
try
    pseudo_data_phantom(phan_true, folder, handles.recon_matrix_size, handles);
catch M
    unpause_gui;
    add_string_gui(handles, [string(''); string('UNABLE TO GENERATE PHANTOM:'); string(M.message); string(''); string(''); string('')]);
    errordlg(['unable to generate phantom:' newline M.message]);
    rethrow(M);
end

if get(handles.disp_phan, 'Value') 
    try
        % display original phantom
        add_string_gui(handles, 'loading phantom ...');
        scale = 64/handles.recon_matrix_size*6.8;
        fig = vi(abs(phan_true), 'aspect', [scale scale scale]);

        % change figure title
        set(fig, 'Name', [folder filesep 'phan_true.mat']);
    catch M
        unpause_gui;
        add_string_gui(handles, [string(''); string('UNABLE TO LOAD GENERATED PHANTOM:'); string(M.message); string(''); string(''); string('')]);
        errordlg(['unable to load generates phantom:' newline M.message]);
        rethrow(M); 
    end
end
add_string_gui(handles, ['done' newline newline newline]);
unpause_gui;

%% opens a 3D matrix dataset
% --- Executes on button press in open_recon.
function open_recon_Callback(hObject, eventdata, handles)
% hObject    handle to open_recon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile;
if isequal(filename, 0) % check whether user pressed cancel
    return
end

% try to load reconstruction
try
    vars = load([pathname filename]);
catch
    uiwait(errordlg('Unable to find data'));
    return;
end

% try to load reconstruction
if isfield(vars, 'phan_true')
    reconstruction = vars.phan_true;
elseif isfield(vars, 'recon_final')
    reconstruction = vars.recon_final;
else
    uiwait(errordlg('unable to load reconstructed matrix (must contain variable called phan_true or recon_final'));
    return;
end

% display reconstruction 
try
    scale = 64/length(reconstruction)*6.8;
    fig = vi(abs(reconstruction), 'aspect', [scale scale scale]);
    
    % change figure title
    [~, figname] = fileparts(pathname(1:end-1)); % strips away filesep to treat folder as filename
    set(fig, 'Name', [figname filesep filename]);
catch M
    errordlg(['unable to load reconstruction:' newline M.message]);
    rethrow(M);
end


%% Toggles given switch
function toggle_switch(swtch, ~, ~)
set(swtch, 'Value', ~swtch.Value);


%% clears update box
% --- Executes on button press in clear_updates.
function clear_updates_Callback(hObject, eventdata, handles)
% hObject    handle to clear_updates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.update, 'String', string(''));


%% functions to use return key to add/remove/generate/move focus
% --- Executes on key press with focus on phan_type and none of its controls.
function phan_type_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to phan_type (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.x_offset, @NOP);

% --- Executes on key press with focus on x_offset and none of its controls.
function x_offset_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to x_offset (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.y_offset, @NOP);

% --- Executes on key press with focus on y_offset and none of its controls.
function y_offset_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to y_offset (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.z_offset, @NOP);

% --- Executes on key press with focus on z_offset and none of its controls.
function z_offset_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to z_offset (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.x_extent, @NOP);

% --- Executes on key press with focus on x_extent and none of its controls.
function x_extent_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to x_extent (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.y_extent, @NOP);

% --- Executes on key press with focus on y_extent and none of its controls.
function y_extent_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to y_extent (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.z_extent, @NOP);

% --- Executes on key press with focus on z_extent and none of its controls.
function z_extent_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to z_extent (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.xDir, @NOP);

% --- Executes on key press with focus on xDir and none of its controls.
function xDir_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to xDir (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.yDir, @NOP);

% --- Executes on key press with focus on yDir and none of its controls.
function yDir_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to yDir (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.zDir, @NOP);

% --- Executes on key press with focus on zDir and none of its controls.
function zDir_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to zDir (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.angle, @NOP);

% --- Executes on key press with focus on angle and none of its controls.
function angle_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to angle (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.intensity, @NOP);

% --- Executes on key press with focus on intensity and none of its controls.
function intensity_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to intensity (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.add, @NOP);

% --- Executes on key press with focus on add and none of its controls.
function add_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to add (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.add, @add_Callback);
uicontrol(handles.add);

% --- Executes on key press with focus on phan_list and none of its controls.
function phan_list_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to phan_list (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.remove, @NOP);

% --- Executes on key press with focus on remove and none of its controls.
function remove_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.remove, @remove_Callback);

% --- Executes on key press with focus on clear and none of its controls.
function clear_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.clear, @clear_Callback);

% --- Executes on key press with focus on folder_name and none of its controls.
function folder_name_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to folder_name (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.generate, @generate_Callback);

% --- Executes on key press with focus on generate and none of its controls.
function generate_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to generate (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.generate, @generate_Callback);

% --- Executes on key press with focus on clear_updates and none of its controls.
function clear_updates_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to clear_updates (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.clear_updates, @clear_updates_Callback);

% --- Executes on key press with focus on disp_phan and none of its controls.
function disp_phan_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to disp_phan (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.disp_phan, @toggle_switch);

% --- Executes on key press with focus on open_recon and none of its controls.
function open_recon_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to open_recon (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.open_recon, @open_recon_Callback);

% --- Executes on key press with focus on preview and none of its controls.
function preview_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to preview (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.preview, @toggle_switch);


%% allows for debugging with variables in scope
% --- Executes on button press in debug.
function debug_Callback(hObject, eventdata, handles)
% hObject    handle to debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard;


%% assorted, basically unused, create functions
% --- Executes during object creation, after setting all properties.
function phan_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phan_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function phan_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phan_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function y_extent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_extent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function z_extent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_extent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function x_extent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_extent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function y_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function z_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function x_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function folder_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to folder_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function intensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function update_CreateFcn(hObject, eventdata, handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function zDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function yDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function xDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in preview.
function preview_Callback(hObject, eventdata, handles)
% hObject    handle to preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of preview
