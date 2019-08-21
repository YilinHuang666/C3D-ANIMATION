function slider_animation(c3d_file,json_file,cluster_num)% input of cluster_num is the total number of clusters that are plotted.
   	addpath C3DSERVER
    itf = c3dserver();
    openc3d(itf, 0, c3d_file);
    cluster_set = jsondecode(fileread(json_file)); %read the json file
    cluster_name = struct2cell(cluster_set); % read markers' name in each cluster
    MarkerNames = [""];
    for num = 1:cluster_num   % withdraw the markers' name in each cluster
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
    
    [frame_tot,~] = size(XYZPOS_table);
    check_na = isnan(XYZPOS_table);  % check the NaN in the table
    nan_frame_total = 0;
    for j = 1:frame_tot %plot each point frame by frame
        cla
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
    %create slider
    j = 1;
    Fig1 = figure('position',[360 550 700 700]);
    slider = uicontrol('style','slider','position',[250 10 200 20],'min', 1, 'max', frame_tot,'Value', 1, 'SliderStep', [1/(frame_tot-1) 1/(frame_tot-1)]);
    axes('XLim', [min(min(XYZPOS_table(:,1:3:end))) max(max(XYZPOS_table(:,1:3:end)))],...
        'YLim', [min(min(XYZPOS_table(:,2:3:end))) max(max(XYZPOS_table(:,2:3:end)))],...
        'ZLim', [min(min(XYZPOS_table(:,3:3:end))) max(max(XYZPOS_table(:,3:3:end)))],...
        'units','pixels', 'NextPlot', 'add');
    TextH = uicontrol('style','text','position',[300 40 100 15]);
    addlistener(slider, 'Value', 'PostSet', @callbackfn);
    [~,mar_num_tot] = size(MarkerNames);
    xs2_pre = -2; % previous x coordinate step 1
    for i = 1:cluster_num
        [mar_num,~] = size(cluster_name{i,1});
        xs1 = xs2_pre+3; % x coordinate step 1
        xs2 = xs1 + 3*(mar_num-1);
        xs3 = ((mar_num_tot-1)*3+1) + (i-1)*3;
        plot3(XYZPOS_table(1, [xs1:3:xs2 xs3]), XYZPOS_table(1, [(xs1+1):3:(xs2+1) (xs3+1)]), XYZPOS_table(1,[(xs1+2):3:(xs2+2) (xs3+2)]), '-o');
        xs2_pre = xs2;
    end
    for k=1:3:49
        text(double(XYZPOS_table(1,k)),double(XYZPOS_table(1,k+1)),double(XYZPOS_table(1,k+2)),MarkerNames(((k+2)/3)+1),'Fontsize',5) % label each marker
    end
    xlabel("x-axis")
    ylabel("y-axis")
    zlabel("z-axis")
    grid on
    hold on
    movegui(Fig1, 'center');
    function callbackfn(source, eventdata)
        cla
        update_frame = round(get(eventdata.AffectedObject, 'Value'));
        %update the position of the labels of the markers
        xs2_pre = -2;
        for i = 1:cluster_num
            [mar_num,~] = size(cluster_name{i,1});
            xs1 = xs2_pre+3; % x coordinate step 1
            xs2 = xs1 + 3*(mar_num-1);
            xs3 = ((mar_num_tot-1)*3+1) + (i-1)*3;
            plot3(XYZPOS_table(update_frame, [xs1:3:xs2 xs3]), XYZPOS_table(update_frame, [(xs1+1):3:(xs2+1) (xs3+1)]), XYZPOS_table(update_frame, [(xs1+2):3:(xs2+2) (xs3+2)]), '-o');
            xs2_pre = xs2;
        end
        for k=1:3:49
            text(double(XYZPOS_table(update_frame,k)),double(XYZPOS_table(update_frame,k+1)),double(XYZPOS_table(update_frame,k+2)),MarkerNames(((k+2)/3)+1),'Fontsize',5) % label each marker
        end
        TextH.String = strcat("frame: ",num2str(update_frame));
        drawnow
    end
end

