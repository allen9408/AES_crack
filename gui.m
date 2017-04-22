function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 22-Apr-2017 00:57:01
m = 5;
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
%     axes(handles.axes1);
    fpath = './image/chip.jpg';
    imshow(imread(fpath));



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
num = textread('input.txt');
set(hObject, 'String', num2str(num(1,:)));


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(handles.edit2, 'String');
iteration = str2num(get(handles.text7, 'String'));
file_in = textread('input.txt');
[row,col] = size(file_in);

iteration = mod(iteration,row)+1;
plaintext = file_in(iteration,:);
if (iteration == row)
    iteration = 1;
else
    iteration = iteration + 1;
end
nexttext = file_in(iteration,:);
set(handles.edit2, 'String', num2str(plaintext));
set(handles.edit3, 'String', num2str(nexttext));
% msgbox(str);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
key_crack = zeros(32,8) - 1;
pushbutton1_Callback(hObject, eventdata, handles);
iteration = str2num(get(handles.text7, 'String')) + 1;
set(handles.text7, 'String', iteration);

plaintext = get(handles.edit2, 'String');
plaintext_dec = str2num(plaintext);
key_hex = {'00' '01' '02' '03' '04' '05' '06' '07' ...
			'08' '09' '0a' '0b' '0c' '0d' '0e' '0f'};
key = hex2dec(key_hex);
[s_box, inv_s_box, w, poly_mat, inv_poly_mat] = aes_init(key);
lfsr_reg = zeros(20, 1);
ciphertext = cipher(plaintext_dec, w ,s_box, poly_mat);
set(handles.text9, 'String', num2str(ciphertext));
file_in = textread('input.txt');

if (iteration == 1)
    delete('cap_out.txt');
end

cap_out = fopen('cap_out.txt', 'at');
[row,col] = size(file_in);
for r = 1:iteration
    r = mod(r-1, row) + 1;
    plaintext = file_in(r, :);
    if (r == 1)
		% Initial TSC reg[19:0] = data[19:0]
		for i = 1:8
			lfsr_reg(i) = bitshift(mod(plaintext(16), 2^i), -(i-1));
			lfsr_reg(i+8) = bitshift(mod(plaintext(15), 2^i), -(i-1));
		end
		for i = 1:4
			lfsr_reg(i + 16) = bitshift(mod(plaintext(14), 2^i), -(i-1));
		end
	end
    [cap(r,:), lfsr_reg] = tsc(plaintext, key, lfsr_reg,r);
end
fprintf(cap_out, '%g\t', cap(r,:));
fprintf(cap_out, '\r');
fclose(cap_out);
% Display leaked information
set(handles.text11, 'String', num2str(cap(r,:)));
% Decode information
for i = 1:iteration
    if i>32
        break;
    end
    if (mod(i,2)==0)
        key_crack(i-1,1) = 0;
        key_crack(i,1) = 1;
        for j = 2:8
            if (cap(i, j-1) == cap(i-1, j))
                key_crack(i-1, j) = key_crack(i-1, j-1);
                key_crack(i, j) = key_crack(i, j-1);
            else
                key_crack(i-1, j) = ~key_crack(i-1, j-1);
                key_crack(i, j) = ~key_crack(i, j-1);
            end
        end
    end
end
% Display Decoded nformation
set(handles.text13 , 'String', num2str(fliplr(key_crack(1, :))));
set(handles.text14 , 'String', num2str(fliplr(key_crack(2, :))));
set(handles.text15 , 'String', num2str(fliplr(key_crack(3, :))));
set(handles.text16 , 'String', num2str(fliplr(key_crack(4, :))));
set(handles.text37 , 'String', num2str(fliplr(key_crack(5, :))));
set(handles.text38 , 'String', num2str(fliplr(key_crack(6, :))));
set(handles.text39 , 'String', num2str(fliplr(key_crack(7, :))));
set(handles.text40 , 'String', num2str(fliplr(key_crack(8, :))));
set(handles.text41 , 'String', num2str(fliplr(key_crack(9, :))));
set(handles.text42 , 'String', num2str(fliplr(key_crack(10, :))));
set(handles.text43 , 'String', num2str(fliplr(key_crack(11, :))));
set(handles.text44 , 'String', num2str(fliplr(key_crack(12, :))));
set(handles.text45 , 'String', num2str(fliplr(key_crack(13, :))));
set(handles.text46 , 'String', num2str(fliplr(key_crack(14, :))));
set(handles.text47 , 'String', num2str(fliplr(key_crack(15, :))));
set(handles.text48 , 'String', num2str(fliplr(key_crack(16, :))));
set(handles.text53 , 'String', num2str(fliplr(key_crack(17, :))));
set(handles.text54 , 'String', num2str(fliplr(key_crack(18, :))));
set(handles.text55 , 'String', num2str(fliplr(key_crack(19, :))));
set(handles.text56 , 'String', num2str(fliplr(key_crack(20, :))));
set(handles.text57 , 'String', num2str(fliplr(key_crack(21, :))));
set(handles.text58 , 'String', num2str(fliplr(key_crack(22, :))));
set(handles.text59 , 'String', num2str(fliplr(key_crack(23, :))));
set(handles.text60 , 'String', num2str(fliplr(key_crack(24, :))));
set(handles.text61 , 'String', num2str(fliplr(key_crack(25, :))));
set(handles.text62 , 'String', num2str(fliplr(key_crack(26, :))));
set(handles.text63 , 'String', num2str(fliplr(key_crack(27, :))));
set(handles.text64 , 'String', num2str(fliplr(key_crack(28, :))));
set(handles.text65 , 'String', num2str(fliplr(key_crack(29, :))));
set(handles.text66 , 'String', num2str(fliplr(key_crack(30, :))));
set(handles.text67 , 'String', num2str(fliplr(key_crack(31, :))));
set(handles.text68 , 'String', num2str(fliplr(key_crack(32, :))));



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Keep Running
iteration = str2num(get(handles.edit4,'String'));
for i = 1:iteration
    pushbutton2_Callback(hObject, eventdata, handles);
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% RESET
set(handles.text7, 'String', '0');
set(handles.edit2, 'String', '0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0');
set(handles.edit3, 'String', '0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0');
set(handles.text9, 'String', '0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0');
set(handles.text11, 'String','');
set(handles.text13 , 'String', '');
set(handles.text14 , 'String', '');
set(handles.text15 , 'String', '');
set(handles.text16 , 'String', '');
set(handles.text37 , 'String', '');
set(handles.text38 , 'String', '');
set(handles.text39 , 'String', '');
set(handles.text40 , 'String', '');
set(handles.text41 , 'String', '');
set(handles.text42 , 'String', '');
set(handles.text43 , 'String', '');
set(handles.text44 , 'String', '');
set(handles.text45 , 'String', '');
set(handles.text46 , 'String', '');
set(handles.text47 , 'String', '');
set(handles.text48 , 'String', '');
set(handles.text53 , 'String', '');
set(handles.text54 , 'String', '');
set(handles.text55 , 'String', '');
set(handles.text56 , 'String', '');
set(handles.text57 , 'String', '');
set(handles.text58 , 'String', '');
set(handles.text59 , 'String', '');
set(handles.text60 , 'String', '');
set(handles.text61 , 'String', '');
set(handles.text62 , 'String', '');
set(handles.text63 , 'String', '');
set(handles.text64 , 'String', '');
set(handles.text65 , 'String', '');
set(handles.text66 , 'String', '');
set(handles.text67 , 'String', '');
set(handles.text68 , 'String', '');


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1
AboutMe();
