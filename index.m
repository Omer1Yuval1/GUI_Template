function index()
	
	% This is the root script for the GUI.
	% Project_Xp is a pointer to structure Project_X, defined as a class handle in Project_Class.m.
	
	close all;
	clear;
	
	folder = fileparts(which(mfilename)); % Determine where the m-file's folder is.
	cd(folder);
	addpath(genpath(pwd)); % Add to path.
	
	Project_Xp = Project_Class; % This creates an object of the Project_Class class.
	
	GUI_Params(Project_Xp);
	
	% Set_Objects(Project_Xp);
	Set_Objects_UI(Project_Xp);
	% return;
    
	Set_Callbacks(Project_Xp);
	Project_Xp.GUI_Handles.Current_Step = 0;
	Project_Xp.GUI_Handles.Current_Project = 1;
	assignin('base','Project_Xp',Project_Xp);
	
	function Load_Data_Func(source,event,P)
		
		if(~isempty(event))
			P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		end
		
		CurrentDir = pwd;
		
		if(~isempty(source)) % If a button is used to run this callback.
			[File1,Path1,Selection_Index] = uigetfile(P.GUI_Handles.Input_Data_Formats,'MultiSelect','on');
		elseif(isempty(source)) % If this callback is called from "Load_Project_Func" after loading a project file.
			Selection_Index = 1;
		else
			Selection_Index = 0;
		end
		
		if(Selection_Index == 0)
			disp('Files not found.');
		elseif(~isempty(source))
			if(~iscell(File1))
				File1 = {File1};
			end
			P.Data(1).Info.Experiment(1).Identifier = File1{1}(1:end-4);
		end
		
		cd(CurrentDir); % Return to the main directory.
		
		if(~P.GUI_Handles.Multi_View) % single-view project. Create a project for each loaded file.
			P.GUI_Handles.View_Axes = gobjects(1);
			P.GUI_Handles.Axes_Grid = uigridlayout(P.GUI_Handles.Main_Panel_1,[1,1],'RowHeight',{'1x'},'ColumnWidth',{'1x'},'BackgroundColor',P.GUI_Handles.BG_Color_1);
			if(~isempty(source)) % If data was loaded.
				for ff=1:length(File1) % For each file.
					
					P.Data(ff) = project_init(P); % Initialize project struct.
					
					[filepath,filename,ext] = fileparts(File1{ff});
					P.Data(ff).Info.Experiment(1).Identifier = filename;
					
					if(P.GUI_Handles.Save_Input_Data_Path) % Save path to input files.
						P.Data(ff).Info.Files(1).Raw_Image = File1{ff};
					else % Save input data explicitly.
						P.Data(ff).Info.Files(1).Raw_Image = imread([Path1,filesep,File1{ff}]);
					end
					
					Label_ff = ['Project_X',num2str(ff),'_',P.Data(ff).Info.Experiment(1).Identifier];
					uimenu(P.GUI_Handles.Menus(1),'Text',Label_ff,'UserData',ff,'Callback',{@Switch_Project_Func,P});
					
					P.GUI_Handles.Waitbar.Value = ff ./ length(File1);
				end
			else % If a project file(s) was loaded.
				for pp=1:numel(P.Data) % For each project.
					
					if(P.GUI_Handles.Save_Input_Data_Path) % Validate path. If it is not found, ask the user to specify a new path and save it.
						[filepath,filename,ext] = fileparts(P.Data(pp).Info.Files(1).Raw_Image);
						
						if(~exist(filepath,'dir') == 7 || isfile(P.Data(pp).Info.Files(1).Raw_Image)) % If the path or file don't exist.
							[File1,Path1,Selection_Index] = uigetfile(P.GUI_Handles.Input_Data_Formats); % Ask the user to select the file.
						else
							Selection_Index = 0;
						end
						
						if(Selection_Index) % If the path should be updated.
							[filepath1,filename1,ext1] = fileparts(File1);
							if(~isequal(filename,filename1))
								warning('File name does not match the original file name.');
							end
							P.Data(pp).Info.Experiment(1).Identifier = filename1;
							P.Data(pp).Info.Files(1).Raw_Image = [File1{1}]; % A single file for project pp.
						end
					end
					
					Label_pp = ['Project_X',num2str(pp),'_',P.Data(pp).Info.Experiment(1).Identifier];
					uimenu(P.GUI_Handles.Menus(1),'Text',Label_pp,'UserData',pp,'Callback',{@Switch_Project_Func,P});
					
					P.GUI_Handles.Waitbar.Value = pp ./ numel(P.Data);
				end
			end
			
			% Create axes and display the image of the first project:
			P.GUI_Handles.View_Axes(1) = uiaxes(P.GUI_Handles.Axes_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1);
			% P.GUI_Handles.View_Axes(1) = uiaxes(P.GUI_Handles.Main_Panel_1,'Position',[1,1,P.GUI_Handles.Main_Panel_1.InnerPosition(3:4)],'BackgroundColor',P.GUI_Handles.BG_Color_1);
			
			title(P.GUI_Handles.View_Axes(1),[]);
			xlabel(P.GUI_Handles.View_Axes(1),[]);
			ylabel(P.GUI_Handles.View_Axes(1),[]);
			P.GUI_Handles.View_Axes(1).XAxis.TickLabels = {};
			P.GUI_Handles.View_Axes(1).YAxis.TickLabels = {};
			
			drawnow;
			imshow(P.Data(1).Info.Files(1).Raw_Image,'Parent',P.GUI_Handles.View_Axes(1));
			P.GUI_Handles.View_Axes.XLim = P.GUI_Handles.View_Axes.Children(1).XData;
			P.GUI_Handles.View_Axes.YLim = P.GUI_Handles.View_Axes.Children(1).YData;
			
		else % Multi-view project.
			if(~isempty(source)) % If data was loaded, create a single project.
				P.GUI_Handles.View_Axes = gobjects(1,length(File1));
				P.GUI_Handles.Axes_Grid = uigridlayout(P.GUI_Handles.Main_Panel_1,[1,length(File1)],'RowHeight',repmat({'1x'},1,1),'ColumnWidth',repmat({'1x'},1,length(File1)),'BackgroundColor',P.GUI_Handles.BG_Color_1);
				P.Data(1) = project_init(P);
				for vv=1:length(File1) % For each view.
					
					if(P.GUI_Handles.Save_Input_Data_Path) % Save only the path of the input files.
						P.Data(1).Info.Files(vv).Raw_Image = File1{vv};
					else % Save input data explicitly.
						P.Data(1).Info.Files(vv).Raw_Image = imread([Path1,filesep,File1{vv}]);
					end
					
					P.GUI_Handles.View_Axes(vv) = uiaxes(P.GUI_Handles.Axes_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1);
					% P.GUI_Handles.View_Axes(vv) = uiimage(P.GUI_Handles.Axes_Grid); % For testing.
					
					P.GUI_Handles.View_Axes(vv).Layout.Row = 1;
					P.GUI_Handles.View_Axes(vv).Layout.Column = vv;
					
					% continue; % For testing.
					title(P.GUI_Handles.View_Axes(vv),[]);
					xlabel(P.GUI_Handles.View_Axes(vv),[]);
					ylabel(P.GUI_Handles.View_Axes(vv),[]);
					P.GUI_Handles.View_Axes(vv).XAxis.TickLabels = {};
					P.GUI_Handles.View_Axes(vv).YAxis.TickLabels = {};
					
					imshow(P.Data(1).Info.Files(vv).Raw_Image,'Parent',P.GUI_Handles.View_Axes(vv));
					P.GUI_Handles.View_Axes(vv).XLim = P.GUI_Handles.View_Axes(vv).Children(1).XData;
					P.GUI_Handles.View_Axes(vv).YLim = P.GUI_Handles.View_Axes(vv).Children(1).YData;
					
					P.GUI_Handles.Waitbar.Value = vv ./ length(File1);
				end
				[filepath,filename,ext] = fileparts(File1{1});
				P.Data(1).Info.Experiment(1).Identifier = filename;
				Label_1 = ['Project_X1','_',P.Data(1).Info.Experiment(1).Identifier];
				uimenu(P.GUI_Handles.Menus(1),'Text',Label_1,'UserData',1,'Callback',{@Switch_Project_Func,P});
			else % If a project file(s) was loaded.
				P.GUI_Handles.View_Axes = gobjects(1,numel(P.Data(1).Info.Files));
				P.GUI_Handles.Axes_Grid = uigridlayout(P.GUI_Handles.Main_Panel_1,[1,numel(P.Data(1).Info.Files)],'RowHeight',repmat({'1x'},1,1),'ColumnWidth',repmat({'1x'},1,numel(P.Data(1).Info.Files)),'BackgroundColor',P.GUI_Handles.BG_Color_1);
				for pp=1:numel(P.Data) % For each project.
					
					if(P.GUI_Handles.Save_Input_Data_Path) % Validate path. If it is not found, ask the user to specify a new path and save it.
						[filepath,filename,ext] = fileparts(P.Data(pp).Info.Files(1).Raw_Image);
						if(~exist(filepath,'dir') == 7 || isfile(P.Data(pp).Info.Files(1).Raw_Image)) % If the path or file don't exist.
							[File1,Path1,Selection_Index] = uigetfile(P.GUI_Handles.Input_Data_Formats,'MultiSelect','on'); % Ask the user to select the file.
						else
							Selection_Index = 0;
						end
						
						if(Selection_Index)
							[filepath1,filename1,ext1] = fileparts(File1{1});
							if(~isequal(filename,filename1))
								warning('File name does not match the original file name.');
							end
							P.Data(pp).Info.Experiment(1).Identifier = filename1;
							
							for vv=1:length(File1) % For each view.
								P.Data(pp).Info.Files(vv).Raw_Image = File1{vv};
							end
						end
					end
					
					Label_pp = ['Project_X',num2str(pp),'_',P.Data(pp).Info.Experiment(1).Identifier];
					uimenu(P.GUI_Handles.Menus(1),'Text',Label_pp,'UserData',pp,'Callback',{@Switch_Project_Func,P});
					
					P.GUI_Handles.Waitbar.Value = pp ./ numel(P.Data);
				end
				
				for vv=1:numel(P.Data(1).Info.Files) % For each view.
					P.GUI_Handles.View_Axes(vv) = uiaxes(P.GUI_Handles.Axes_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1); % P.GUI_Handles.View_Axes(v) = uiimage(P.GUI_Handles.Axes_Grid);
					P.GUI_Handles.View_Axes(vv).Layout.Row = 1;
					P.GUI_Handles.View_Axes(vv).Layout.Column = vv;
					
					title(P.GUI_Handles.View_Axes(vv),[]);
					xlabel(P.GUI_Handles.View_Axes(vv),[]);
					ylabel(P.GUI_Handles.View_Axes(vv),[]);
					P.GUI_Handles.View_Axes(vv).XAxis.TickLabels = {};
					P.GUI_Handles.View_Axes(vv).YAxis.TickLabels = {};
					
					imshow(P.Data(1).Info.Files(vv).Raw_Image,'Parent',P.GUI_Handles.View_Axes(vv));
					P.GUI_Handles.View_Axes(vv).XLim = P.GUI_Handles.View_Axes(vv).Children(1).XData;
					P.GUI_Handles.View_Axes(vv).YLim = P.GUI_Handles.View_Axes(vv).Children(1).YData;
				end
			end
		end
		
		figure(P.GUI_Handles.Main_Figure);
		
		Display_Project_Info(P);
		
		set(P.GUI_Handles.Menus(1),'UserData',1);
		set(P.GUI_Handles.Menus(1).Children(end),'Checked','on');
		
		set(P.GUI_Handles.Buttons(1),'Backgroundcolor',P.GUI_Handles.Step_BG_Done);
		
		if(P.GUI_Handles.Current_Step == 0)
			P.GUI_Handles.Current_Step = 1;
			set(P.GUI_Handles.Step_Buttons(P.GUI_Handles.Current_Step+1),'Backgroundcolor',P.GUI_Handles.Step_BG_Active);
			Screen_1(P);
		end
		
		if(~isempty(event))
			close(P.GUI_Handles.Waitbar);
		end
	end
	
	function Load_Project_Func(source,~,P)
		
		[File,Path,Selection_Index] = uigetfile('*.mat','MultiSelect','on');
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		
		if(Selection_Index == 0)
			close(P.GUI_Handles.Waitbar);
			return;
		end
		
		if(~iscell(File))
			File = {File};
		end
		
		pp = 0;
		for ii=1:length(File) % For each loaded project file (may contain one or more projects).
			
			Loaded_File = load([Path,File{ii}]);
			
			if(isfield(Loaded_File,'Project_X')) % If a project struct exists for the first loaded project.
				for jj=1:numel(Loaded_File.Project_X) % For each project within the ii project file.
					pp = pp + 1;
					P.Data(pp) = Loaded_File.Project_X(pp);
				end
			end
		end
		Load_Data_Func([],[],P);
		
		set(source,'Enable','on','Backgroundcolor',P.GUI_Handles.Step_BG_Done);
		set(allchild(P.GUI_Handles.Menus(1)),'Enable','on');
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Step_Buttons_Func(source,event,P)
		
		if(~isempty(event))
			P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		end
		
		if(~isempty(source)) % If source is [], then the function is called from somewhere else (such as "Switch_Project_Func").
			if(source.UserData > 0 && source.UserData < 7) % If not the "Back" (0) or "Next" (7) button.
				P.GUI_Handles.Current_Step = source.UserData;
			elseif(source.UserData == 0 && P.GUI_Handles.Current_Step > 1) % Go one step back.
				P.GUI_Handles.Current_Step = P.GUI_Handles.Current_Step - 1;
			elseif(source.UserData == 7 && P.GUI_Handles.Current_Step < 7) % Go one step forward.
				P.GUI_Handles.Current_Step = P.GUI_Handles.Current_Step + 1;
				
				if(P(1).GUI_Handles.Current_Step > 1)
					set(P.GUI_Handles.Step_Buttons(P.GUI_Handles.Current_Step),'Backgroundcolor',P.GUI_Handles.Step_BG_Done);
				end
				
				if(P(1).GUI_Handles.Current_Step < 7)
					set(P.GUI_Handles.Step_Buttons(P.GUI_Handles.Current_Step+1),'Backgroundcolor',P.GUI_Handles.Step_BG_Active);
				end
			end
		end
		
		switch P.GUI_Handles.Current_Step % Load step.
			case 1
				Screen_1(P);
			case 2
				Screen_1(P);
			case 3
				Screen_1(P);
			case 4
				Screen_1(P);
			case 5
				Screen_1(P);
		end
		
		if(~isempty(event))
			close(P.GUI_Handles.Waitbar);
		end
	end
	
	function Switch_Project_Func(source,event,P)
		
		if(~isempty(event))
			P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		end
		
		if(~isempty(source))
			P.GUI_Handles.Current_Project = source.UserData;
			pp = P.GUI_Handles.Current_Project;
			
			set(P.GUI_Handles.Menus(1),'UserData',source.UserData);
			set(allchild(P.GUI_Handles.Menus(1)),'Checked','off');
			set(source,'Checked','on');
			
			% Display project data:
			if(~P.GUI_Handles.Multi_View) % single-view project. Create a project for each loaded file.
				imshow(P.Data(pp).Info.Files(1).Raw_Image,'Parent',P.GUI_Handles.View_Axes(1));
			else % Multi-view project.
				for vv=1:length(File1) % For each view.
					imshow(P.Data(pp).Info.Files(vv).Raw_Image,'Parent',P.GUI_Handles.View_Axes(vv));
				end
			end
			
			Display_Project_Info(P);
		end
		
		Step_Buttons_Func([],[],P);
		
		if(~isempty(event))
			close(P.GUI_Handles.Waitbar);
		end
	end
	
	function Display_Project_Info(P)
		
		pp = P.GUI_Handles.Current_Project;
		
		for tt=1:length(P.GUI_Handles.Info_Fields_List) % For each menu.
			FF = fields(P.Data(pp).Info.(P.GUI_Handles.Info_Fields_List{tt}));
			Data = P.GUI_Handles.Info_Tables(tt).Data;
			Info_tt = P.Data(pp).Info.(P.GUI_Handles.Info_Fields_List{tt});
			for ii=1:length(FF) % For each field in the experiment struct.
				Data{ii,1} = FF{ii}; % Field name.
				Data{ii,2} = Info_tt(1).(FF{ii}); % Value.
				Data{ii,3} = Info_tt(2).(FF{ii}); % Unit.
			end
			P.GUI_Handles.Info_Tables(tt).Data = Data;
		end
		
	end
	
	function Update_Info_Func(source,event,P)
		pp = P.GUI_Handles.Current_Project;
		
		tt = source.UserData; % Table index.
		ff = P.GUI_Handles.Info_Fields_List{tt}; % Corresponding field name in P(pp).Data.Info.
		rr = event.Indices(1); % Table rows correspond to struct fields.
		cc = event.Indices(2); % Second column is the value and the third is the unit. First column is read-only (field name).
		FF = fields(P.Data(pp).Info.(ff));
		
		P.Data(pp).Info.(ff)(cc-1).(FF{rr}) = event.NewData;
	end
	
	function Menus_Func(source,event,P)
		
		if(~isempty(event))
			P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...');
		end
		pp = P.GUI_Handles.Current_Project;
		
		switch(source.UserData)
		case 2 % Menu 2.
			set(allchild(P.GUI_Handles.Menus(2)),'Checked','off');
			set(source,'Checked','on');
			Get_Menu_2(P,source.Label);
		case 3 % Menu 3.
			set(allchild(P.GUI_Handles.Menus(3)),'Checked','off');
			set(source,'Checked','on');
			Get_Menu_2(P,source.Label);
		end
		
		if(~isempty(event))
			close(P.GUI_Handles.Waitbar);
		end
		
		% Useful commands:
			% Menus_Func(findall([P.GUI_Handles.Menus(2),'Checked','on'),[],P); % Re-select the selected option programmatically.
			% Menus_Func(findall([P.GUI_Handles.Menus(2),'Label','Option 3'),[],P); % Select an option programmatically.
	end
	
	function Save_Image_Func(~,~,P)
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		
		Filename = sprintf('Screenshot_%s.svg', datestr(now,'mm-dd-yyyy HH-MM'));
		[File1,Path1] = uiputfile(Filename);
		
		if(Path1)
			disp('TODO: image saving not implemented');
		end
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Save_Figure_Func(~,~)
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Save_Project_Func(~,~,P)
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		
		if(P.GUI_Handles.Control_Panel_Objects(1,1).Value) % Save the selected project only.
			pp = P.GUI_Handles.Current_Project;
			
			if(isempty(P.Data(pp).Info) || isempty(P.Data(pp).Info.Experiment(1).Identifier))
				P.Data(pp).Info.Experiment(1).Identifier = '';
			end
			
			A = ['Project_X_',P.Data(pp).Info.Experiment(1).Identifier,'.mat'];
			A = strrep(A,':','-');
			A = strrep(A,' ','_');
			A = strrep(A,'?','_');
			
			Project_X = P.Data(pp);
			uisave('Project_X',A);
		else % Save all projects.
			Project_X = P.Data;
			uisave('Project_X','Project_X');
		end
		
		close(P.GUI_Handles.Waitbar);
	end
	
	function Set_Callbacks(P)
		
		P.GUI_Handles.Waitbar = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...','Indeterminate','on');
		
		set(P.GUI_Handles.Buttons(1,1),'ButtonPushedFcn',{@Load_Data_Func,P}); % UI: ButtonPushedFcn
		set(P.GUI_Handles.Buttons(1,2),'ButtonPushedFcn',{@Load_Project_Func,P});
		set(P.GUI_Handles.Buttons(3,1),'ButtonPushedFcn',{@Save_Image_Func,P});
		set(P.GUI_Handles.Buttons(3,2),'ButtonPushedFcn',@Save_Figure_Func);
		set(P.GUI_Handles.Buttons(3,3),'ButtonPushedFcn',{@Save_Project_Func,P});
		
		% set(P.GUI_Handles.Control_Panel_Objects(1,1),'ValueChangedFcn',{@Checkbox_1_Func,P});
		
		set(P.GUI_Handles.Step_Buttons(:),'ButtonPushedFcn',{@Step_Buttons_Func,P});
		
		for tt=1:length(P.GUI_Handles.Info_Tables) % For each info table.
			set(P.GUI_Handles.Info_Tables(tt),'CellEditCallback',{@Update_Info_Func,P});
		end
		
		set(findall(P.GUI_Handles.Menus(2),'UserData',2),'Callback',{@Menus_Func,P});
		set(findall(P.GUI_Handles.Menus(3),'UserData',3),'Callback',{@Menus_Func,P});
		
		close(P.GUI_Handles.Waitbar);
	end
end