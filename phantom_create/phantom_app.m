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

% Last Modified by GUIDE v2.5 18-Jun-2018 12:06:19

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
