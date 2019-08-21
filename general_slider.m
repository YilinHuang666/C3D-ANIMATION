function varargout = general_slider(varargin)
% Last Modified by GUIDE v2.5 20-Aug-2019 17:17:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @general_slider_OpeningFcn, ...
                   'gui_OutputFcn',  @general_slider_OutputFcn, ...
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


% --- Executes just before general_slider is made visible.
function general_slider_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to general_slider (see VARARGIN)
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Initialization
set(handles.filein, 'String', '');
set(handles.jsonin, 'String', '');
set(handles.frame_num, 'String', "frame: ");
set(handles.slider1, 'Value',1, 'Min',1, 'Max', 100);
set(handles.cluster_num, 'String', '');
set(handles.refpoin, 'String', '');
set(handles.coor_num, 'String', '');

% --- Outputs from this function are returned to the command line.
function varargout = general_slider_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla
frame = round(get(hObject,'Value'));
set(handles.frame_num, 'String', strcat("frame: ", num2str(frame)));
XYZPOS_table = getappdata(handles.pushbutton1,"XYZPOS");
MarkerNames = getappdata(handles.pushbutton1,"Marker");
cluster_num = getappdata(handles.pushbutton1, "cluster_num"); % total number of clusters
cluster_name = getappdata(handles.pushbutton1, "cluster_name"); % this cell array contains the cluster name
cluster_on_or_off = getappdata(handles.pushbutton1,"cluster"); % 1 for cluster on, 0 for cluster off
start_po_table = getappdata(handles.pushbutton1, "start_po_table");
x_vec = getappdata(handles.pushbutton1, "x_vec");
y_vec = getappdata(handles.pushbutton1, "y_vec");
z_vec = getappdata(handles.pushbutton1, "z_vec");
coor_num = getappdata(handles.pushbutton1, "coor_num");
set(handles.axes1, 'XLim', [min(min(XYZPOS_table(:,1:3:end))) max(max(XYZPOS_table(:,1:3:end)))], ...
                   'YLim', [min(min(XYZPOS_table(:,2:3:end))) max(max(XYZPOS_table(:,2:3:end)))], ...
                   'ZLim', [min(min(XYZPOS_table(:,3:3:end))) max(max(XYZPOS_table(:,3:3:end)))], ...
                   'View', [70 30]);    
               
addlistener(hObject, 'Value', 'PostSet', @callbackfn);       
if (cluster_on_or_off == 0) % in case of cluster off
    
    plot3(XYZPOS_table(frame,1:3:end),XYZPOS_table(frame,2:3:end),XYZPOS_table(frame,3:3:end),'o')
    for k=1:3:49
         text(double(XYZPOS_table(frame,k)),double(XYZPOS_table(frame,k+1)),double(XYZPOS_table(frame,k+2)),MarkerNames(((k+2)/3)+1),'Fontsize',5) % label each marker
    end
    zoom on
    hold on
    grid on
    rotate3d on
end
if (cluster_on_or_off == 1) % incase of custer on
    %plot markers in clusters
    [~,mar_num_tot] = size(MarkerNames); 
    xs2_pre = -2; % previous x coordinate step 1
    for i = 1:cluster_num
        [mar_num,~] = size(cluster_name{i,1});
        xs1 = xs2_pre+3; % x coordinate step 1
        xs2 = xs1 + 3*(mar_num-1);
        xs3 = ((mar_num_tot-1)*3+1) + (i-1)*3;
        plot3(XYZPOS_table(frame, [xs1:3:xs2 xs3]), XYZPOS_table(frame, [(xs1+1):3:(xs2+1) (xs3+1)]), XYZPOS_table(frame,[(xs1+2):3:(xs2+2) (xs3+2)]), '-o');
        xs2_pre = xs2;
    end
    
    %draw the coordinate system
    for i = 1:3:(1+3*(coor_num-1))
        scale = 50;
        quiver3(start_po_table(frame,i),start_po_table(frame,(i+1)),start_po_table(frame,(i+2)),x_vec(frame,i),x_vec(frame,(i+1)),x_vec(frame,(i+2)),scale,'Linewidth',3,'Color','r') % plot x_vec
        quiver3(start_po_table(frame,i),start_po_table(frame,(i+1)),start_po_table(frame,(i+2)),y_vec(frame,i),y_vec(frame,(i+1)),y_vec(frame,(i+2)),scale,'Linewidth',3,'Color','b') % plot y_vec
        quiver3(start_po_table(frame,i),start_po_table(frame,(i+1)),start_po_table(frame,(i+2)),z_vec(frame,i),z_vec(frame,(i+1)),z_vec(frame,(i+2)),scale,'Linewidth',3,'Color','g') % plot z_vec
    end
    %label all markers
    for k=1:3:49
        text(double(XYZPOS_table(frame,k)),double(XYZPOS_table(frame,k+1)),double(XYZPOS_table(frame,k+2)),MarkerNames(((k+2)/3)+1),'Fontsize',5) % label each marker
    end
    xlabel("x-axis")
    ylabel("y-axis")
    zlabel("z-axis")
    hold on
    zoom on
    grid on
    rotate3d on
    
end

function callbackfn(source, eventdata) % this is how to continuously update the frame number and the plot while draging the slider
handles = guidata(eventdata.AffectedObject);
update_frame  = round(get(eventdata.AffectedObject, 'Value'));
set(handles.frame_num, 'String', strcat("frame: ", num2str(update_frame)));
drawnow



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function sidein_Callback(hObject, eventdata, handles)
% hObject    handle to sidein (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function sidein_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sidein (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filein_Callback(hObject, eventdata, handles)
% hObject    handle to filein (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function filein_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filein (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frame_num_Callback(hObject, eventdata, handles)
% hObject    handle to frame_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function frame_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function jsonin_Callback(hObject, eventdata, handles)
% hObject    handle to jsonin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jsonin as text
%        str2double(get(hObject,'String')) returns contents of jsonin as a double


% --- Executes during object creation, after setting all properties.
function jsonin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jsonin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cluster_on.
function cluster_on_Callback(hObject, eventdata, handles)
% hObject    handle to cluster_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cluster_off.
function cluster_off_Callback(hObject, eventdata, handles)
% hObject    handle to cluster_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addpath C3DSERVER
file_name = getappdata(handles.c3d_select, 'file_name');
cluster_on = get(handles.cluster_on, 'Value');
cluster_off = get(handles.cluster_off, 'Value');
json_file = getappdata(handles.json_select, 'json_file')
cluster_num = str2num(get(handles.cluster_num, 'String'));
coor_num = str2num(get(handles.coor_num, 'String'));
coor_file = getappdata(handles.ref_select, 'coor_file');
itf = c3dserver();
if (cluster_off == 1)
        openc3d(itf, 0, file_name);
        MarkerNames = getmarkernames(itf);
        [~, marker_col] = size(MarkerNames);
        XYZPOS_table = get3dtarget(itf, MarkerNames(2),0);
        for i = 3:marker_col
            XYZPOS = get3dtarget(itf, MarkerNames(i),0);
            XYZPOS_table = [XYZPOS_table XYZPOS]; %write all coordinate in to XYZPOS_table
        end
        [frame_tot,~] = size(XYZPOS_table);
        check_na = isnan(XYZPOS_table);
        nan_frame_total = 0;
        for j = 1:frame_tot 
            nan_frame = 0;
            for l=1:51
                if (check_na(j,l)==1) 
                    nan_frame = nan_frame+1; % count the number of NaN in each frame
                end
            end
            if (nan_frame == 51) nan_frame_total = nan_frame_total + 1; % count the total invalid frame number;
            end
        end
        frame_tot = frame_tot - nan_frame_total; % this is the total valid frame number;
        set(handles.frame_num, 'String', "frame: 1");
        set(handles.slider1, 'Max', frame_tot, 'SliderStep', [1/(frame_tot-1) 1/(frame_tot-1)]); %slider step = desired step / (rangeMax - rangeMin)
        setappdata(handles.pushbutton1, 'XYZPOS',XYZPOS_table);
        setappdata(handles.pushbutton1, 'Marker',MarkerNames);
        setappdata(handles.pushbutton1, 'cluster', cluster_on);
end
if (cluster_on == 1)
    cluster_set = jsondecode(fileread(json_file)); %read the json file
    cluster_name = struct2cell(cluster_set); % read markers' name in each cluster
    coor_set = jsondecode(fileread(coor_file));
    coor_name = struct2cell(coor_set);
    itf = c3dserver();
    openc3d(itf, 0, file_name);
    MarkerNames = [""];
    MarkerNames_coor = [];
    for num = 1:cluster_num  % withdraw the markers' name in each cluster
        mar_name = string(cluster_name{num,1});
        [row,~] = size(mar_name);
        for r = 1:row
            MarkerNames = [MarkerNames mar_name(r)]; % store the markers in order so that they can be plotted in cluster later
        end
    end
    [~, marker_col] = size(MarkerNames);
    XYZPOS_table = get3dtarget(itf, MarkerNames(2),0);
    %add the connected point at the end of table
    XYZPOS_C1 = get3dtarget(itf, MarkerNames(2), 0);
    for i=3:marker_col   % store all markers' coordinate into XYZPOS_table first
        XYZPOS = get3dtarget(itf,MarkerNames(i),0);
        XYZPOS_table = [XYZPOS_table XYZPOS];
    end
    XYZPOS_table = [XYZPOS_table XYZPOS_C1];
    for h=3:marker_col   % find out the coordinate of the connected point then store them at the end of XYZPOS_table
        XYZPOS = get3dtarget(itf,MarkerNames(h),0);
        for k=2:cluster_num
            str_mar_name = string(cluster_name{k,1});
            if (strcmp(MarkerNames(h), str_mar_name(1)) == 1) XYZPOS_table = [XYZPOS_table XYZPOS];
            end
        end
    end
%     XYZPOS_table = [XYZPOS_table XYZPOS_C7 XYZPOS_RARM1 XYZPOS_RFARML XYZPOS_REPICWL]; % add the coordinate of the connection marker to the final coordinate table
    [frame_tot,~] = size(XYZPOS_table);
    check_na = isnan(XYZPOS_table);  % check the NaN in the table
    nan_frame_total = 0;
    for j = 1:frame_tot %plot each point frame by frame
        nan_frame = 0;
        for l=1:51
            if (check_na(j,l)==1) 
                nan_frame = nan_frame+1; % count the number of NaN in each frame
            end
        end
        if (nan_frame == 51) nan_frame_total = nan_frame_total + 1; % count the total invalid frame number;
        end
    end
    frame_tot = frame_tot - nan_frame_total; % this is the total valid frame number;
    
    %setup for the coordinate system
    for num = 1:coor_num
        mar_name = string(coor_name{num,1});
        [row,~] = size(mar_name);
        for r = 1:row
            MarkerNames_coor = [MarkerNames_coor mar_name(r)]; %extract marker names in coor_file
        end
    end
    [~, marker_col] = size(MarkerNames_coor);
    COOR_table = [];
    for i=1:marker_col   % store all markers' coordinate into COOR_table first
        COOR = get3dtarget(itf,MarkerNames_coor(i),0);
        COOR_table = [COOR_table COOR]; % now COOR_table contains the coordinate for all ref. markers
    end
    % creat the coordinate table for start points in each cluster
    start_po_table = [];
    frame_tot = 1422;
    p = 1;
    for col = 1:9:(1+9*(coor_num-1))
        for row = 1:frame_tot
            start_po_table(row,p) = COOR_table(row,col)+(COOR_table(row,(col+3)) - COOR_table(row,col))*0.5;
            start_po_table(row,p+1) = COOR_table(row,col+1)+(COOR_table(row,(col+3+1)) - COOR_table(row,col+1))*0.5;
            start_po_table(row,p+2) = COOR_table(row,col+2)+(COOR_table(row,(col+3+2)) - COOR_table(row,col+2))*0.5;
        end
        p = p+3;
    end
    % find out the expression for x vectors and w vectors and therefore find
    % out the expression for z vector
    % x vector = (second marker) - (start point)
    p = 1;
    x_vec = [];
    for col = 4:9:(4+9*(coor_num-1))
        for row = 1:frame_tot
            x_vec(row,p) = start_po_table(row,p) - COOR_table(row,col);
            x_vec(row,p+1) = start_po_table(row,p+1) - COOR_table(row,col+1);
            x_vec(row,p+2) = start_po_table(row,p+2) - COOR_table(row,col+2);
            % normalized the vector 
            temp = sqrt((x_vec(row,p))^2 + (x_vec(row,p+1))^2 + (x_vec(row,p+2))^2);
            x_vec(row,p) = x_vec(row,p)/temp;
            x_vec(row,p+1) = x_vec(row,p+1)/temp;
            x_vec(row,p+2) = x_vec(row,p+2)/temp;
        end
        p = p+3;
    end
    % w vector = (third marker) - (start point)
    p = 1;
    w_vec = [];
    for col = 7:9:(7+9*(coor_num-1))
        for row = 1:frame_tot
            w_vec(row,p) = start_po_table(row,p) - COOR_table(row,col);
            w_vec(row,p+1) = start_po_table(row,p+1) - COOR_table(row,col+1);
            w_vec(row,p+2) = start_po_table(row,p+2) - COOR_table(row,col+2);
            %normalized the vector
            temp = sqrt((w_vec(row,p))^2 + (w_vec(row,p+1))^2 + (w_vec(row,p+2))^2);
            w_vec(row,p) = w_vec(row,p)/temp;
            w_vec(row,p+1) = w_vec(row,p+1)/temp;
            w_vec(row,p+2) = w_vec(row,p+2)/temp;
        end
        p = p+3;
    end
    % z vector = cross(x,w)
    z_vec = [];
    z_vec_temp = [];
    for col = 1:3:(1+3*(coor_num-1))
        for row = 1:frame_tot
            x_vec_temp = [x_vec(row,col) x_vec(row,col+1) x_vec(row,col+2)];
            w_vec_temp = [w_vec(row,col) w_vec(row,col+1) w_vec(row,col+2)];
            z_vec_temp = [z_vec_temp;cross(x_vec_temp, w_vec_temp)];
        end
        z_vec = [z_vec z_vec_temp];
        z_vec_temp = [];
    end
    % y vector can be found by crossing product x vector and z vector
    y_vec = [];
    y_vec_temp = [];
    for col = 1:3:(1+3*(coor_num-1))
        for row = 1:frame_tot
            x_vec_temp = [x_vec(row,col) x_vec(row,col+1) x_vec(row,col+2)];
            z_vec_temp = [z_vec(row,col) z_vec(row,col+1) z_vec(row,col+2)];
            y_vec_temp = [y_vec_temp;cross(x_vec_temp, z_vec_temp)];
        end
        y_vec = [y_vec y_vec_temp];
        y_vec_temp = [];
    end
    
    set(handles.frame_num, 'String', "frame: 1");
    set(handles.slider1, 'Max', frame_tot, 'SliderStep', [1/(frame_tot-1) 1/(frame_tot-1)]); %slider step = desired step / (rangeMax - rangeMin)
    setappdata(handles.pushbutton1, 'XYZPOS',XYZPOS_table);
    setappdata(handles.pushbutton1, 'Marker',MarkerNames);    
    setappdata(handles.pushbutton1, 'cluster', cluster_on);
    setappdata(handles.pushbutton1, 'cluster_num', cluster_num);
    setappdata(handles.pushbutton1, 'cluster_name', cluster_name);
    setappdata(handles.pushbutton1, 'start_po_table', start_po_table);
    setappdata(handles.pushbutton1, 'y_vec', y_vec);
    setappdata(handles.pushbutton1, 'x_vec', x_vec);
    setappdata(handles.pushbutton1, 'z_vec', z_vec);
    setappdata(handles.pushbutton1, 'coor_num', coor_num);
end
        

function cluster_num_Callback(hObject, eventdata, handles)
% hObject    handle to cluster_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function cluster_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cluster_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function refpoin_Callback(hObject, eventdata, handles)
% hObject    handle to refpoin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function refpoin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to refpoin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function coor_num_Callback(hObject, eventdata, handles)
% hObject    handle to coor_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function coor_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coor_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in c3d_select.
function c3d_select_Callback(hObject, eventdata, handles)
% hObject    handle to c3d_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file_name = uigetfile('*.c3d');
set(handles.filein, 'String', file_name);
setappdata(handles.c3d_select, 'file_name',file_name);


% --- Executes on button press in json_select.
function json_select_Callback(hObject, eventdata, handles)
% hObject    handle to json_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
json_file = uigetfile('*.json');
set(handles.jsonin, 'String', json_file);
setappdata(handles.json_select, 'json_file', json_file);

% --- Executes on button press in ref_select.
function ref_select_Callback(hObject, eventdata, handles)
% hObject    handle to ref_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
coor_file = uigetfile('*.json');
set(handles.refpoin, 'String', coor_file);
setappdata(handles.ref_select, 'coor_file', coor_file);