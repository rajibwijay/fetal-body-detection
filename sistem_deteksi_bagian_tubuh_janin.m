function varargout = sistem_deteksi_bagian_tubuh_janin(varargin)
% SISTEM_DETEKSI_BAGIAN_TUBUH_JANIN MATLAB code for sistem_deteksi_bagian_tubuh_janin.fig
%      SISTEM_DETEKSI_BAGIAN_TUBUH_JANIN, by itself, creates a new SISTEM_DETEKSI_BAGIAN_TUBUH_JANIN or raises the existing
%      singleton*.
%
%      H = SISTEM_DETEKSI_BAGIAN_TUBUH_JANIN returns the handle to a new SISTEM_DETEKSI_BAGIAN_TUBUH_JANIN or the handle to
%      the existing singleton*.
%
%      SISTEM_DETEKSI_BAGIAN_TUBUH_JANIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SISTEM_DETEKSI_BAGIAN_TUBUH_JANIN.M with the given input arguments.
%
%      SISTEM_DETEKSI_BAGIAN_TUBUH_JANIN('Property','Value',...) creates a new SISTEM_DETEKSI_BAGIAN_TUBUH_JANIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sistem_deteksi_bagian_tubuh_janin_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sistem_deteksi_bagian_tubuh_janin_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sistem_deteksi_bagian_tubuh_janin

% Last Modified by GUIDE v2.5 20-Sep-2021 22:11:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sistem_deteksi_bagian_tubuh_janin_OpeningFcn, ...
                   'gui_OutputFcn',  @sistem_deteksi_bagian_tubuh_janin_OutputFcn, ...
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


% --- Executes just before sistem_deteksi_bagian_tubuh_janin is made visible.
function sistem_deteksi_bagian_tubuh_janin_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sistem_deteksi_bagian_tubuh_janin (see VARARGIN)

% Choose default command line output for sistem_deteksi_bagian_tubuh_janin
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sistem_deteksi_bagian_tubuh_janin wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sistem_deteksi_bagian_tubuh_janin_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name_file1,name_path1] = uigetfile( ...
    {'*.bmp;*.jpg;*.tif','Files of type (*.bmp,*.jpg,*.tif)';
    '*.bmp','File Bitmap (*.bmp)';...
    '*.jpg','File jpeg (*.jpg)';
    '*.tif','File Tif (*.tif)';
    '*.*','All Files (*.*)'},...
    'Open Image');
 
if ~isequal(name_file1,0)
    handles.data1 = imread(fullfile(name_path1,name_file1));
    guidata(hObject,handles);
    axes(handles.axes1);
    imshow(handles.data1);
else
    return;
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('trainingFasterRCNN_nextLevel2.mat','detector');

handles.data2 = imresize(handles.data1,[512 680]);
%I2 = rgb2gray(I);
niter = 50;
kappa = 3;
lambda = 0.12;
option = 2;
handles.I3 = SRAD(double(handles.data2),niter,option,kappa,lambda);
handles.I4=uint8(handles.I3);

[bbox, score, label] = detect(detector, handles.I4);
% outputImage = insertObjectAnnotation(img, 'rectangle', bboxes, scores);%annotation);

[score, idx] = max(score);
% 
bbox = bbox(idx, : );
annotation = sprintf('%s : (Confidence = %f)', label(idx), score);
nama1 = string(label(idx));
str1 = strcat(nama1);
set(handles.text3, 'string', str1);

nama2 = string(score);
str2 = strcat(nama2);
set(handles.text4, 'string', str2);
handles.outputImage = insertObjectAnnotation(handles.I4, 'rectangle', bbox, annotation); %cellstr(labels));

guidata(hObject,handles);
axes(handles.axes6);
imshow(handles.outputImage);


% --- Executes during object creation, after setting all properties.
function text3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
