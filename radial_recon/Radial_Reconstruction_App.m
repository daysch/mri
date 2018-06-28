function varargout = Radial_Reconstruction_App(varargin)
% RADIAL_RECONSTRUCTION_APP MATLAB code for Radial_Reconstruction_App.fig
%      RADIAL_RECONSTRUCTION_APP, by itself, creates a new RADIAL_RECONSTRUCTION_APP or raises the existing
%      singleton*.
%
%      H = RADIAL_RECONSTRUCTION_APP returns the handle to a new RADIAL_RECONSTRUCTION_APP or the handle to
%      the existing singleton*.
%
%      RADIAL_RECONSTRUCTION_APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RADIAL_RECONSTRUCTION_APP.M with the given input arguments.
%
%      RADIAL_RECONSTRUCTION_APP('Property','Value',...) creates a new RADIAL_RECONSTRUCTION_APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Radial_Reconstruction_App_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Radial_Reconstruction_App_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Radial_Reconstruction_App

% Last Modified by GUIDE v2.5 26-Jun-2018 15:03:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Radial_Reconstruction_App_OpeningFcn, ...
                   'gui_OutputFcn',  @Radial_Reconstruction_App_OutputFcn, ...
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


% --- Executes just before Radial_Reconstruction_App is made visible.
function Radial_Reconstruction_App_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Radial_Reconstruction_App (see VARARGIN)

% Choose default command line output for Radial_Reconstruction_App
handles.output = hObject;

% set up variables
handles.continue = true;
handles.quit_batch = false;

% load paths for 3d viewing/rotation
if ~exist('vi', 'dir')
    addpath([fileparts(fileparts(mfilename('fullpath'))) filesep '3D Viewers' filesep 'vi']); 
end

% Update handles structure
guidata(hObject, handles);

% clears workspace
clear;

% UIWAIT makes Radial_Reconstruction_App wait for user response (see UIRESUME)
% uiwait(handles.Radial_Reconstruction_App);


% --- Outputs from this function are returned to the command line.
function varargout = Radial_Reconstruction_App_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% run the reconstruction on single folder
% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)    

% initialize update box
set(handles.update, 'String', '');

% parse and validate inputs
try
    disable_gui(handles);
    validate_recon_inputs;
catch M
    reset_gui(handles, hObject);
    switch M.message
        case 'known error'
            return;
        otherwise
            rethrow(M);
    end
end

% run reconstruction and reset for next
try
    add_string_gui(handles, 'Running individual reconstruction ....')
    run_reconstruction(handles, hObject);
    reset_gui(handles, hObject);
catch M
    add_string_gui(handles, ['FAILURE:' newline M.message]);
    reset_gui(handles, hObject);
    rethrow(M);
end


%% batch run of subfolders in folder
% --- Executes on button press in batch_run.
function batch_run_Callback(hObject, eventdata, handles)
% hObject    handle to batch_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% parse and validate inputs
try
    disable_gui(handles);
    validate_recon_inputs;
catch M
    reset_gui(handles, hObject);
    switch M.message
        case 'known error'
            return;
        otherwise
            rethrow(M);
    end
end

% get list of subfolders
% https://www.mathworks.com/matlabcentral/answers/166629-is-there-any-way-to-list-all-folders-only-in-the-level-directly-below-a-selected-directory
files = dir(handles.data_path);
dirFlags = [files.isdir] & ~strcmp({files.name},'.') & ~strcmp({files.name},'..'); % takes all folders except '.' and '..'
subFolders = files(dirFlags);
folder_path = handles.data_path; % save path to outer folder

% initialize update box, progress bar, and buttons
processed_so_far = string('Running batch reconstruction...'); % string to update user on progress of batch
set(handles.update, 'String', 'Running batch reconstruction...');
set(handles.pause, 'enable', 'on');
wbar = waitbar(0, sprintf('Completed 0 out of %d reconstructions', length(subFolders)), ...
               'Name', 'Running Batch Reconstruction');
movegui(wbar,'northeast');

% iterate through subfolders, skipping ones that cause errors
for ii = 1:length(subFolders)
    % update handles
    handles = guidata(hObject);
    % bring gui to front
    figure(handles.Radial_Reconstruction_App);
    
    % pause if pause button has been pressed
    if get(handles.pause, 'userdata') == 1
        set(handles.pause, 'enable', 'on');
        set(handles.pause, 'String', 'Continue');
        add_string_gui(handles, [newline 'paused']);
        uicontrol(handles.pause);
        % wait until unpaused
        while ~handles.continue
            % quit, if selected
            if handles.quit_batch
                reset_gui(handles, hObject);
                handles.data_path = folder_path;
                handles.quit_batch = false;
                guidata(hObject, handles);
                if ishandle(wbar)
                    close(wbar);
                end
                add_string_gui(handles, 'Batch job aborted');
                return;
            end
            pause(0.1);
            handles = guidata(hObject);
        end
        set(handles.cancel_batch, 'visible', 'off');
    end
    
    % process next folder
    add_string_gui(handles, ['Processing folder ' subFolders(ii).name]);
    handles.data_path = [folder_path filesep subFolders(ii).name];
    try
        run_reconstruction(handles, hObject);
        processed_so_far = [processed_so_far string(['processed folder ' subFolders(ii).name])];
        set(handles.update, 'String', processed_so_far);
        drawnow;
    catch M
        processed_so_far = [processed_so_far newline string(['ERROR IN PROCESSING FOLDER ' subFolders(ii).name ':' newline, M.message newline 'Skipping...' newline])];
        set(handles.update, 'String', processed_so_far);
        for jj = 0:4
            old_update = get(handles.update, 'String');
            add_string_gui (handles, sprintf('waiting for %d seconds', 5-jj));
            pause(1);
        end
        add_string_gui(handles, newline);
    end
    
    % if waitbar still on screen, update it
    if ishandle(wbar)
        waitbar(ii/length(subFolders), wbar, ...
        sprintf('Completed %d out of %d reconstructions', ii, length(subFolders)));
        figure(wbar);
    end
end
add_string_gui(handles, 'done.')

% clean up
reset_gui(handles, hObject);
handles.data_path = folder_path;
guidata(hObject, handles);
if ishandle(wbar)
    close(wbar);
end
figure(handles.Radial_Reconstruction_App);

%% Pauses/unpauses batch run
% --- Executes on button press in pause.
function pause_Callback(hObject, eventdata, handles)
% hObject    handle to pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if unpaused, pause. If paused, unpause
if get(handles.pause, 'userdata') == 0 
    % set internal variables
    set(handles.pause, 'userdata', 1);
    handles.continue = false;
    guidata(hObject, handles);
    
    % set gui
    add_string_gui(handles, [newline 'Pausing after current reconstruction...' newline]);
    set(handles.pause, 'String', 'pausing...');
    set(handles.pause, 'enable', 'off');
    set(handles.cancel_batch, 'visible', 'on');
    drawnow;
else
    % set internal variables
    set(handles.pause, 'userdata', 0);
    handles.continue = true;
    guidata(hObject, handles);
    
    % set gui
    add_string_gui(handles, 'Continuing...');
    set(handles.pause, 'String', 'Pause batch job');
    set(handles.pause, 'enable', 'on');
    set(handles.cancel_batch, 'visible', 'off');
    drawnow;
    uicontrol(handles.close_all);
end

%% cancels a batch run
% --- Executes on button press in cancel_batch.
function cancel_batch_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.quit_batch = true;
set(handles.cancel_batch, 'enable', 'off');
set(handles.pause, 'String', 'canceling...');
set(handles.cancel_batch, 'String', 'canceling...');
add_string_gui(handles, [newline 'Canceling after current reconstruction ...' newline]);
guidata(hObject, handles);


%% closes all open figures
% --- Executes on button press in close_all.
function close_all_Callback(hObject, eventdata, handles)
% hObject    handle to close_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ask user to confirm closing, close if confirmed
answer = questdlg('Close all figures?','Confirm Closing','Confirm','Cancel', 'Confirm');
switch answer 
    case 'Confirm'
        set(handles.Radial_Reconstruction_App, 'HandleVisibility', 'off'); % keeps this gui from being closed
        pa = findobj('Tag','phantom_app');
        if ~isempty(pa)
            set(pa, 'HandleVisibility', 'off'); % keeps phantom app from being closed
        end
        close all;
        set(handles.Radial_Reconstruction_App, 'HandleVisibility', 'on');
        if ~isempty(pa)
            set(pa, 'HandleVisibility', 'on');
        end
        drawnow;
end


%% select folder to be used
% --- Executes on button press in choose_file.
function choose_file_Callback(hObject, eventdata, handles)
% hObject    handle to choose_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.data_path = uigetdir;
    if isequal(handles.data_path, 0) % check whether user pressed cancel
        return
    end
    [~, folder] = fileparts(handles.data_path);
    set(handles.folder_display, 'String', folder);
    guidata(hObject, handles);   % Store handles


%% For debugging purposes
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard


%% return key presses appropriate button
% --- Executes on key press with focus on prepts and none of its controls.
function prepts_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to prepts (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.firstpt, @NOP);

% --- Executes on key press with focus on firstpt and none of its controls.
function firstpt_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to firstpt (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.numpts, @NOP);

% --- Executes on key press with focus on numpts and none of its controls.
function numpts_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to numpts (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.recon_matrix_size, @NOP);

% --- Executes on key press with focus on recon_matrix_size and none of its controls.
function recon_matrix_size_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to recon_matrix_size (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.choose_file, @NOP);

% --- Executes on key press with focus on run and none of its controls.
function run_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.run, @run_Callback);

% --- Executes on key press with focus on choose_file and none of its controls.
function choose_file_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to choose_file (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.run, @choose_file_Callback);
uicontrol(handles.run);

% --- Executes on key press with focus on batch_run and none of its controls.
function batch_run_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to batch_run (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.batch_run, @batch_run_Callback);

% --- Executes on key press with focus on close_all and none of its controls.
function close_all_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to close_all (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.close_all, @close_all_Callback);

% --- Executes on key press with focus on pause and none of its controls.
function pause_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pause (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.pause, @pause_Callback);

% --- Executes on key press with focus on cancel_batch and none of its controls.
function cancel_batch_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to cancel_batch (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.cancel_batch, @cancel_batch_Callback);

% --- Executes on key press with focus on show_errors and none of its controls.
function show_errors_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to show_errors (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.show_errors, @toggle_switch);

% --- Executes on key press with focus on warn_overwrite and none of its controls.
function warn_overwrite_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to warn_overwrite (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return_press_do(hObject, eventdata, handles, handles.warn_overwrite, @toggle_switch);


%% Toggles given switch
function toggle_switch(swtch, ~, ~)
set(swtch, 'Value', ~swtch.Value);


%% opens previously performed reconstruction
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
    % display figure
    scale = 64/length(reconstruction)*8;
    fig = vi(abs(reconstruction), 'aspect', [scale scale scale]);
    
    % change figure title
    [~, figname] = fileparts(pathname(1:end-1)); % strips away filesep to treat folder as filename
    set(fig, 'Name', [figname filesep filename]);
catch M
    errordlg(['unable to load reconstruction:' newline M.message]);
    rethrow(M);
end

%% basically unused create functions
% --- Executes during object creation, after setting all properties.
function numpts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numpts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function recon_matrix_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recon_matrix_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function prepts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prepts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function firstpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
