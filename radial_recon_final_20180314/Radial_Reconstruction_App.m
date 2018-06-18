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

% Last Modified by GUIDE v2.5 15-Jun-2018 15:47:30

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
handles.debug = false;
handles.continue = true;
handles.quit_batch = false;

% Update handles structure
guidata(hObject, handles);

% clears workspace
clear;

% UIWAIT makes Radial_Reconstruction_App wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Radial_Reconstruction_App_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% run the reconstruction.
% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)    
set(handles.update, 'String', ''); % initialize update box
try
    disable_gui(handles);
    validate_inputs;
catch M
    switch M.message
        case 'known error'
            reset_gui(handles, hObject);
            return;
        otherwise
            reset_gui(handles, hObject);
            rethrow(M);
    end
end
run_reconstruction(handles, hObject);
reset_gui(handles, hObject);

function prepts_Callback(hObject, eventdata, handles)
% hObject    handle to prepts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prepts as text
%        str2double(get(hObject,'String')) returns contents of prepts as a double



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



function firstpt_Callback(hObject, eventdata, handles)
% hObject    handle to firstpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstpt as text
%        str2double(get(hObject,'String')) returns contents of firstpt as a double


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

%% closes all open figures
% --- Executes on button press in close_all.
function close_all_Callback(hObject, eventdata, handles)
% hObject    handle to close_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'HandleVisibility', 'off');
answer = questdlg('Close all figures?','Confirm Closing','Confirm','Cancel', 'Confirm');
switch answer 
    case 'Confirm'
        close all;
end
set(handles.figure1, 'HandleVisibility', 'on');
drawnow;



function numpts_Callback(hObject, eventdata, handles)
% hObject    handle to numpts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numpts as text
%        str2double(get(hObject,'String')) returns contents of numpts as a double


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



function recon_matrix_size_Callback(hObject, eventdata, handles)
% hObject    handle to recon_matrix_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of recon_matrix_size as text
%        str2double(get(hObject,'String')) returns contents of recon_matrix_size as a double


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

%% select folder to be used
% --- Executes on button press in choose_file.
function choose_file_Callback(hObject, eventdata, handles)
% hObject    handle to choose_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.data_path = uigetdir('../');
    [~, folder] = fileparts(handles.data_path);
    set(handles.folder_display, 'String', folder);
    guidata(hObject, handles);   % Store handles


%% allows option for command line errors to be shown in popup instead
% --- Executes on button press in show_errors.
function show_errors_Callback(hObject, eventdata, handles)
% hObject    handle to show_errors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_errors
handles.debug = ~get(hObject,'Value');
guidata(hObject, handles);


%% legacy code, due to MATLAB guide error
function figure1_SizeChangedFcn(hObject, eventdata, handles)

%% return key presses run button
% https://www.mathworks.com/matlabcentral/answers/1450-gui-for-keyboard-pressed-representing-the-push-button
% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key
    case 'return'
        if get(handles.pause, 'userdata') == 0 % make sure we're not paused
            uicontrol(handles.run); % need to deselect other fields so they can update
            run_Callback(handles.run, eventdata, handles);
        end
end

%% For debugging purposes
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard

%% batch run of subfolders in folder
% --- Executes on button press in batch_run.
function batch_run_Callback(hObject, eventdata, handles)
% hObject    handle to batch_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% validate inputs
try
    disable_gui(handles);
    validate_inputs;
catch M
    switch M.message
        case 'known error'
            reset_gui(handles, hObject);
            return;
        otherwise
            reset_gui(handles, hObject);
            rethrow(M);
    end
end

% https://www.mathworks.com/matlabcentral/answers/166629-is-there-any-way-to-list-all-folders-only-in-the-level-directly-below-a-selected-directory
files = dir(handles.data_path);
dirFlags = [files.isdir] & ~strcmp({files.name},'.') & ~strcmp({files.name},'..'); % takes all folders except '.' and '..'
subFolders = files(dirFlags);
folder_path = handles.data_path; % save path to current folder

% initialize update box and buttons
processed_so_far = [];
set(handles.update, 'String', '');
set(handles.pause, 'enable', 'on');
set(handles.batch_run, 'enable', 'off');

% iterate through subfolders, skipping ones that cause errors
for ii = 1:length(subFolders)
    handles = guidata(hObject); % update handles
    
    % pause if pause button has been pressed
    if get(handles.pause, 'userdata') == 1
        figure(handles.figure1);
        set(handles.pause, 'enable', 'on');
        set(handles.pause, 'String', 'Continue');
        add_string_gui(handles, [newline 'paused']);
        while ~handles.continue
            % quit, if selected
            if handles.quit_batch
                % reset everything and quit
                reset_gui(handles, hObject);
                add_string_gui(handles, 'Batch job aborted');
                return;
            end
            pause(0.1);
            handles = guidata(hObject);
        end
        set(handles.cancel_batch, 'visible', 'off');
    end
    
    % run next folder
    add_string_gui(handles, ['Processing folder ' subFolders(ii).name]);
    handles.data_path = [folder_path filesep subFolders(ii).name];
    try
        run_reconstruction(handles, hObject);
        processed_so_far = [processed_so_far string(['processed folder ' subFolders(ii).name])];
        set(handles.update, 'String', processed_so_far);
        drawnow;
    catch M
        processed_so_far = [processed_so_far newline string(['ERROR IN PROCESSING FOLDER ' subFolders(ii).name ':' newline, M.message newline])];
        set(handles.update, 'String', processed_so_far);
    end
end
% clean up
reset_gui(handles, hObject);

%% Pauses/unpauses batch run
% --- Executes on button press in pause.
function pause_Callback(hObject, eventdata, handles)
% hObject    handle to pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.pause, 'userdata') == 0 
    set(handles.pause, 'userdata', 1);
    handles.continue = false;
    guidata(hObject, handles);
    add_string_gui(handles, [newline 'Pausing after current reconstruction...' newline]);
    set(handles.pause, 'String', 'pausing...');
    set(handles.pause, 'enable', 'off');
    set(handles.cancel_batch, 'visible', 'on');
    drawnow;
else
    set(handles.pause, 'userdata', 0);
    handles.continue = true;
    guidata(hObject, handles);
    add_string_gui(handles, 'Continuing...');
    set(handles.pause, 'String', 'Pause batch job');
    set(handles.pause, 'enable', 'on');
    set(handles.cancel_batch, 'visible', 'off');
end


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


% --- Executes during object creation, after setting all properties.
function update_CreateFcn(hObject, eventdata, handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
