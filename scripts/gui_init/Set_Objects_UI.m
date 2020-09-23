function Set_Objects_UI(P)
	
	P.GUI_Handles.Main_Figure = uifigure;
	clf(P.GUI_Handles.Main_Figure);
	set(P.GUI_Handles.Main_Figure,'WindowState','maximized','Color',[.2,.2,.2]);
	drawnow;
	
	dd = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...');
	
	Main_Grid = uigridlayout(P.GUI_Handles.Main_Figure,[25,10],'RowHeight',repmat({'1x'},1,25),'ColumnWidth',repmat({'1x'},1,10));
	
	P.GUI_Handles.Main_Panel_1 = uipanel(Main_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1);
	P.GUI_Handles.Main_Panel_1.Layout.Row = [1,18];
	P.GUI_Handles.Main_Panel_1.Layout.Column = [1,10];
	
	P.GUI_Handles.Buttons_Panel = uipanel(Main_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1);
	P.GUI_Handles.Buttons_Panel.Layout.Row = [19,23];
	P.GUI_Handles.Buttons_Panel.Layout.Column = [1,3];
	
	P.GUI_Handles.Control_Panel = uipanel(Main_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1);
	P.GUI_Handles.Control_Panel.Layout.Row = [19,23];
	P.GUI_Handles.Control_Panel.Layout.Column = [4,8];
	
	P.GUI_Handles.Info_Panel = uipanel(Main_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1);
	P.GUI_Handles.Info_Panel.Layout.Row = [19,23];
	P.GUI_Handles.Info_Panel.Layout.Column = [9,10];
	
	P.GUI_Handles.Steps_Panel = uipanel(Main_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1);
	P.GUI_Handles.Steps_Panel.Layout.Row = [24,25];
	P.GUI_Handles.Steps_Panel.Layout.Column = [1,10];
	
	P.GUI_Handles.Project_Menu = uimenu(P.GUI_Handles.Main_Figure,'Text','Project');
	P.GUI_Handles.Plot_Type_Menu = uimenu(P.GUI_Handles.Main_Figure,'Text','menu 2','Enable','off');
	
	% Control panel:
	P.GUI_Handles.Buttons = gobjects(1,9);
    Buttons_Grid = uigridlayout(P.GUI_Handles.Buttons_Panel,[3,3],'RowHeight',repmat({'1x'},1,3),'ColumnWidth',repmat({'1x'},1,3));
    for i=1:length(P.GUI_Handles.Buttons_Names)
        P.GUI_Handles.Buttons(i) = uibutton(Buttons_Grid,'Text',P.GUI_Handles.Buttons_Names{i},'FontSize',P.GUI_Handles.Buttons_FontSize);
    end
	
	set(P.GUI_Handles.Buttons(1),'Backgroundcolor',P.GUI_Handles.Step_BG_Before);
	set(P.GUI_Handles.Buttons(2),'Backgroundcolor',P.GUI_Handles.Step_BG_Before);
	set(P.GUI_Handles.Buttons(7),'Backgroundcolor',P.GUI_Handles.Button_BG_Neurtral,'FontColor',[1,1,1]);
	set(P.GUI_Handles.Buttons(8),'Backgroundcolor',P.GUI_Handles.Button_BG_Neurtral,'FontColor',[1,1,1]);
	set(P.GUI_Handles.Buttons(9),'Backgroundcolor',P.GUI_Handles.Button_BG_Neurtral,'FontColor',[1,1,1]);
    
	P.GUI_Handles.Control_Panel_Objects = gobjects(4,5);
	Control_Panel_Grid = uigridlayout(P.GUI_Handles.Control_Panel,[4,9],'RowHeight',repmat({'1x'},1,4),'ColumnWidth',{'.95x','0x','0.8x','0x','0.8x','0.1x','1x','0x','1x'});
	P.GUI_Handles.Radio_Group_1 = uibuttongroup(Control_Panel_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1,'BorderType','none');
	P.GUI_Handles.Radio_Group_1.Layout.Row = [1,4];
	P.GUI_Handles.Radio_Group_1.Layout.Column = 9;
	for i=1:4 % For each row.
		P.GUI_Handles.Control_Panel_Objects(i,1) = uilabel(Control_Panel_Grid,'Text',['label placeholder ',num2str(i),':'],'FontColor','w','UserData',[i,1],'FontSize',P.GUI_Handles.Buttons_FontSize);
		P.GUI_Handles.Control_Panel_Objects(i,2) = uieditfield(Control_Panel_Grid,'numeric','UserData',[i,2],'HorizontalAlignment','center');
		
		if(i <= 2)
			P.GUI_Handles.Control_Panel_Objects(i,3) = uispinner(Control_Panel_Grid,'UserData',[i,3],'HorizontalAlignment','center');
		else
			P.GUI_Handles.Control_Panel_Objects(i,3) = uidropdown(Control_Panel_Grid,'UserData',[i,3]);
		end
		P.GUI_Handles.Control_Panel_Objects(i,4) = uicheckbox(Control_Panel_Grid,'Text',['checkbox ',num2str(i)],'FontColor','w','UserData',[i,4],'FontSize',P.GUI_Handles.Buttons_FontSize);
		P.GUI_Handles.Control_Panel_Objects(5-i,5) = uiradiobutton(P.GUI_Handles.Radio_Group_1,'Text',['radiobutton ',num2str(5-i)],'UserData',[5-i,5],'FontSize',P.GUI_Handles.Buttons_FontSize,'FontColor','w');
		
        for j=1:4
            P.GUI_Handles.Control_Panel_Objects(i,j).Layout.Row = i;
			P.GUI_Handles.Control_Panel_Objects(i,j).Layout.Column = 1 + (2*(j-1));
        end
        
        P.GUI_Handles.Control_Panel_Objects(5-i,5).Position(2) = (i-1) .* P.GUI_Handles.Control_Panel_Objects(5-i,5).Position(4) .* 1.59;
		P.GUI_Handles.Control_Panel_Objects(5-i,5).Position(3) = P.GUI_Handles.Radio_Group_1.Position(3);
    end
	
	% Step buttons
	P.GUI_Handles.Step_Buttons = gobjects(1,length(P.GUI_Handles.Step_Buttons_Names));
	Step_Buttons_Grid = uigridlayout(P.GUI_Handles.Steps_Panel,[1,length(P.GUI_Handles.Step_Buttons_Names)]);
	for i=1:length(P.GUI_Handles.Step_Buttons_Names)
		P.GUI_Handles.Step_Buttons(i) = uibutton(Step_Buttons_Grid,'Text',P.GUI_Handles.Step_Buttons_Names{i},'UserData',i-1,'FontSize',P.GUI_Handles.Step_Buttons_FontSize);
	end
	
	set(P.GUI_Handles.Step_Buttons(1),'Backgroundcolor',P.GUI_Handles.Button_BG_Neurtral,'FontColor',[1,1,1]);
	set(P.GUI_Handles.Step_Buttons(end),'Backgroundcolor',P.GUI_Handles.Button_BG_Neurtral,'FontColor',[1,1,1],'Enable','on');
	
	% Info panel
	Info_Panel_Grid = uigridlayout(P.GUI_Handles.Info_Panel,[1,1],'Padding',[0,0,0,0]);
	Info_Tab_Group = uitabgroup(Info_Panel_Grid);
	Info_Tabs = gobjects(1,length(P.GUI_Handles.Info_Fields_List));
	Info_Grids = gobjects(1,length(P.GUI_Handles.Info_Fields_List));
	P.GUI_Handles.Info_Tables = gobjects(1,length(P.GUI_Handles.Info_Fields_List));
	
	s = uistyle;
	s.HorizontalAlignment = 'center';
	s.BackgroundColor = [];
	
	for t=1:length(Info_Tabs)
		Info_Tabs(t) = uitab(Info_Tab_Group,'Title',P.GUI_Handles.Info_Fields_List{t});
		Info_Grids(t) = uigridlayout(Info_Tabs(t),[1,1],'Padding',[0,0,0,0]);
		W = Info_Tabs(t).InnerPosition(3);
		P.GUI_Handles.Info_Tables(t) = uitable(Info_Grids(t),'Data',cell(10,3),'UserData',t,'ColumnWidth',{W.*0.4,W.*0.4,'auto'},'ColumnEditable',[false,true,true],'RowName',[],'ColumnName',[],'ForegroundColor','w','BackgroundColor',P.GUI_Handles.BG_Color_1); % {'1x','1x','0.2x'}
		addStyle(P.GUI_Handles.Info_Tables(t),s);
	end
    
	drawnow;
	
	close(dd);
end