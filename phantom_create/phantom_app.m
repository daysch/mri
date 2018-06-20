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

% Last Modified by GUIDE v2.5 20-Jun-2018 09:45:45

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
handles.matrix_size = 64;

% set up variables/gui
handles.real_phans = {};
set(handles.remove, 'enable', 'off');
set(handles.phan_list, 'enable', 'off');

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


% --- Executes on button press in generate.
function generate_Callback(hObject, eventdata, handles)
% hObject    handle to generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)
% hObject    handle to add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% only allow one process at a time, to avoid race conditions
set(handles.generate, 'enable', 'off');
set(handles.add, 'enable', 'off');
set(handles.remove, 'enable', 'off');

% validate inputs
try
    validate_inputs;
catch M
    set(handles.generate, 'enable', 'on');
    set(handles.add, 'enable', 'on');
    if handles.phan_list.String ~= ' '
        set(handles.remove, 'enable', 'on');
    end
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
new_phan = phantom_mhd_new(handles.matrix_size, phan_type_val, phan_extent_val, ...
                           phan_offset_val, intensity_val);

% save phantom matrix
handles.real_phans = [handles.real_phans; new_phan];
old_list = get(handles.phan_list, 'String');
if old_list(1) == ' '
    old_list = old_list(2:end); % deletes blank line (if this is the first shape)
end
addition = string(sprintf('ellipsoidal_OO=[%d %d %d]_E=[%d %d %d]_I=%d', ...
                          handles.phan_offset_val, handles.phan_extent_val, ...
                          handles.intensity_val));
set(handles.phan_list, 'String', [old_list;addition]);
guidata(hObject, handles);

% clean up
set(handles.generate, 'enable', 'on');
set(handles.remove, 'enable', 'on');
set(handles.add, 'enable', 'on');



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


% --- Executes on button press in debug.
function debug_Callback(hObject, eventdata, handles)
% hObject    handle to debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard;


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

if isempty(handles.real_phans)
    set(handles.phan_list, 'String', ' ')
end

guidata(hObject, handles);