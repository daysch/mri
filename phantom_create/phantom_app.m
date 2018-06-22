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

% Last Modified by GUIDE v2.5 21-Jun-2018 11:41:15

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

% set up variables/gui
handles.real_phans = {};
set(handles.remove, 'enable', 'off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes phantom_app wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = phantom_app_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in generate.
function generate_Callback(hObject, eventdata, handles)
% hObject    handle to generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pause_gui;

% validate folder name
folder = get(handles.folder_name, 'String');
if isempty(folder)
    errordlg('please specify name to save as');
    unpause_gui;
    return;
end
if exist([fileparts(fileparts(mfilename('fullpath'))) filesep 'phantom_objects' filesep folder], 'dir')
    answer = questdlg('Overwrite phantom?', 'A phantom with that name already exists. Overwrite phantom?', ...
                      'Overwrite', 'Cancel', 'Cancel');
    switch answer
        case 'Cancel'
            unpause_gui;
            return;
    end
end

% sum up phantoms
phan_true=cat(4, handles.real_phans{:});
phan_true = sum(phan_true, 4);

add_string_gui(handles, [newline 'generating phantom...']);
try
    pseudo_data_phantom(phan_true, folder, handles.recon_matrix_size, handles);
    if get(handles.disp_phan, 'Value') 
        addpath([fileparts(fileparts(mfilename('fullpath'))) filesep '3D Viewers' filesep 'vi']); 
        vi(abs(phan_true), 'aspect', [5 5 5]);
    end
    add_string_gui(handles, ['done' newline newline newline]);
catch M
    unpause_gui;
    add_string_gui(handles, [string(''); string('UNABLE TO GENERATE PHANTOM:'); string(M.message); string(''); string(''); string('')]);
    errordlg(['unable to generate phantom:' newline M.message]);
end
unpause_gui;


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
new_phan = phantom_mhd_new(handles.recon_matrix_size, phan_type_val, phan_extent_val, ...
                           phan_offset_val, intensity_val);

% save phantom matrix
old_list = get(handles.phan_list, 'String');
addition = string(sprintf('%s_OO=[%d %d %d]_E=[%d %d %d]_I=%d', phan_type_val, ...
                          phan_offset_val, phan_extent_val, intensity_val));
add_string_gui(handles, [string('added shape:'); addition]);
                      
if isequal(old_list(1), ' ')
    set(handles.phan_list, 'String', addition);
    handles.real_phans = {new_phan};
else
    set(handles.phan_list, 'String', [old_list;addition]);
    handles.real_phans = [handles.real_phans; new_phan];
end
guidata(hObject, handles);

% clean up
unpause_gui;


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
        set(handles.remove, 'enable', 'off');
        set(handles.generate, 'enable', 'off');
        add_string_gui(handles, [newline newline newline 'cleared shapes' newline newline newline]);
end


% --- Executes on button press in clear_updates.
function clear_updates_Callback(hObject, eventdata, handles)
% hObject    handle to clear_updates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.update, 'String', string(''));

% --- Executes on button press in debug.
function debug_Callback(hObject, eventdata, handles)
% hObject    handle to debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard;


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
    set(handles.remove, 'enable', 'off');
    set(handles.generate, 'enable', 'off');
end

% gui update box
add_string_gui(handles, [string('removed shape:'); old_list(index, :)]);

guidata(hObject, handles);




% --- Executes on selection change in phan_list.
function phan_list_Callback(hObject, eventdata, handles)
% hObject    handle to phan_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns phan_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from phan_list



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



% --- Executes on button press in disp_phan.
function disp_phan_Callback(hObject, eventdata, handles)
% hObject    handle to disp_phan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of disp_phan

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



function y_extent_Callback(hObject, eventdata, handles)
% hObject    handle to y_extent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y_extent as text
%        str2double(get(hObject,'String')) returns contents of y_extent as a double


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



function z_extent_Callback(hObject, eventdata, handles)
% hObject    handle to z_extent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_extent as text
%        str2double(get(hObject,'String')) returns contents of z_extent as a double


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



function x_extent_Callback(hObject, eventdata, handles)
% hObject    handle to x_extent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x_extent as text
%        str2double(get(hObject,'String')) returns contents of x_extent as a double


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



function y_offset_Callback(hObject, eventdata, handles)
% hObject    handle to y_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y_offset as text
%        str2double(get(hObject,'String')) returns contents of y_offset as a double


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



function z_offset_Callback(hObject, eventdata, handles)
% hObject    handle to z_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_offset as text
%        str2double(get(hObject,'String')) returns contents of z_offset as a double


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



function x_offset_Callback(hObject, eventdata, handles)
% hObject    handle to x_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x_offset as text
%        str2double(get(hObject,'String')) returns contents of x_offset as a double


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



function folder_name_Callback(hObject, eventdata, handles)
% hObject    handle to folder_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of folder_name as text
%        str2double(get(hObject,'String')) returns contents of folder_name as a double


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


function intensity_Callback(hObject, eventdata, handles)
% hObject    handle to intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intensity as text
%        str2double(get(hObject,'String')) returns contents of intensity as a double


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


% --- Executes on selection change in phan_type.
function phan_type_Callback(hObject, eventdata, handles)
% hObject    handle to phan_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns phan_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from phan_type


function update_Callback(hObject, eventdata, handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of update as text
%        str2double(get(hObject,'String')) returns contents of update as a double


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
