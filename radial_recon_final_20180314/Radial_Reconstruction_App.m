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

% Last Modified by GUIDE v2.5 14-Jun-2018 10:25:52

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
handles.firstpt_val = str2double(get(handles.firstpt, 'String'));
handles.prepts_val = str2double(get(handles.prepts, 'String'));
handles.recon_matrix_size_val = str2double(get(handles.recon_matrix_size, 'String'));

% make sure all values filled out
if isnan(handles.firstpt_val) || isnan(handles.prepts_val) || ... 
        isnan(handles.recon_matrix_size_val)
    errordlg('Please fill out parameters');
    return;
elseif ~isfield(handles, 'data_path') || isa(handles.data_path, 'double')
    errordlg('Please select folder');
    return;
end

% confirm validity of inputs
if mod(handles.firstpt_val, 1) ~= 0 || mod(handles.prepts_val, 1) ~= 0 || mod(handles.recon_matrix_size_val, 1) ~= 0
    errordlg('parameters must be integers');
    return;
elseif handles.firstpt_val <= handles.prepts_val
    errordlg('First point must be greater than zero point');
    return;
elseif handles.prepts_val < 0
    errordlg('zero point cannot be negative');
    return;
elseif handles.recon_matrix_size_val <= 0 || mod(handles.recon_matrix_size_val, 2) ~= 0
    errordlg('recon matrix must be a positive multiple of two');
    return
end

% check and validate optional field: number of points to be used
if ~isempty(get(handles.numpts, 'String'))
    handles.numpts_val = str2double(get(handles.numpts, 'String'));
    if mod(handles.numpts_val, 1) ~= 0 || handles.numpts_val <= 0
        errordlg('number of points must be a positive integer');
        return;
    end
else
    handles.numpts_val = NaN;
end

guidata(hObject, handles);   % Store handles

% run reconstruction. inform gui user of errors (if desired)
if handles.debug 
    radial_recon_rs2d_20180314_two_grads(handles);
else
    try
        radial_recon_rs2d_20180314_two_grads(handles);
    catch M
        errordlg(['Unexpected error in execution of reconstruction:' newline M.message]);
    end
end
    


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
        % need to deselect fields so they can update
        uicontrol(handles.run);
        run_Callback(handles.run, eventdata, handles);
end

%% For debugging purposes
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard
