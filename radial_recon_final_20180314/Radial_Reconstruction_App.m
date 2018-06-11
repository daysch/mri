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

% Last Modified by GUIDE v2.5 11-Jun-2018 11:56:52

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


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.firstpt_val = str2double(get(handles.firstpt, 'String'));
handles.prepts_val = str2double(get(handles.prepts, 'String'));
guidata(hObject, handles);   % Store handles
radial_recon_rs2d_20180314_two_grads(handles);



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
