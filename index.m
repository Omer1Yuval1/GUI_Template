function index()
	
	% This is the root script for the GUI.
	% Project_Xp is a pointer to structure Project_X, defined as a class handle in Project_Class.m.
	
	close all;
	clear;
	
	folder = fileparts(which(mfilename)); % Determine where the m-file's folder is.
	cd(folder);
	cd ..;
	addpath(genpath(pwd)); % Add to path.
	
	Project_Xp = Project_Class; % This creates an object of the Project_Class class.
	
	GUI_Params(Project_Xp);
	Set_Objects_UI(Project_Xp);
	
	Set_Callbacks(Project_Xp);
	Project_Xp.GUI_Handles.Current_Step = 0;
	Project_Xp.GUI_Handles.Current_Project = 1;
	assignin('base','Project_X',Project_Xp);
	
	function Load_Data_Func(source,~,P)
		
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		dd = uiprogressdlg(P.GUI_Handles.Main_Figure,'Title','Please Wait','Message','Loading...');
		
		CurrentDir = pwd;
		
		if(~isempty(source)) % If a button is used to run this callback.
			[File1,Path1,Selection_Index] = uigetfile(P.GUI_Handles.Input_Data_Formats,'MultiSelect','on');
		elseif(isempty(source)) % If this callback is called from "Load_Project_Func" after loading a project file.
			Selection_Index = 1;
		else
			Selection_Index = 0;
		end
		
		if(Selection_Index == 0)
			set(All_Enabled_Objects,'Enable','on');
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
			P.GUI_Handles.Axes_Grid = uigridlayout(P.GUI_Handles.Main_Panel_1,[1,1]);
			if(~isempty(source)) % If data was loaded.
				for ff=1:length(File1) % For each file.
					
					P.Data(ff) = project_init(P); % Initialize project struct;
					
					[filepath,filename,ext] = fileparts(File1{ff});
					P.Data(ff).Info.Experiment(1).Identifier = filename;
					P.Data(ff).Info.Files(1).Input_File{1} = [Path1,filesep,File1{ff}];
					
					Label_ff = ['Project_X',num2str(ff),'_',P.Data(ff).Info.Experiment(1).Identifier];
					uimenu(P.GUI_Handles.Project_Menu,'Text',Label_ff,'UserData',ff,'Callback',{@Switch_Project_Func,P});
				end
			else % If a project file(s) was loaded.
				for pp=1:numel(P.Data) % For each project.
					[filepath,filename,ext] = fileparts(P.Data(pp).Files.Input_File{1});
					
					if(~exist(filepath,'dir') == 7 || isfile(P.Data(pp).Files.Input_File{1})) % If the path or file don't exist.
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
						P.Data(pp).Info.Files.Input_File{1} = [Path1,filesep,File1{1}]; % A single file for project pp.
					end
					
					Label_pp = ['Project_X',num2str(pp),'_',P.Data(pp).Info.Experiment(1).Identifier];
					uimenu(P.GUI_Handles.Project_Menu,'Text',Label_pp,'UserData',pp,'Callback',{@Switch_Project_Func,P});
				end
			end
			
			% Create axes and display the image of the first project:
			P.GUI_Handles.View_Axes(1) = uiaxes(P.GUI_Handles.Axes_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1);
			imshow(P.Data(1).Info.Files.Input_File{1},'Parent',P.GUI_Handles.View_Axes(1));
			
		else % Multi-view project.
			if(~isempty(source)) % If data was loaded, create a single project.
				P.GUI_Handles.View_Axes = gobjects(1,length(File1));
				P.GUI_Handles.Axes_Grid = uigridlayout(P.GUI_Handles.Main_Panel_1,[1,length(File1)],'RowHeight',repmat({'1x'},1,1),'ColumnWidth',repmat({'1x'},1,length(File1)));
				P.Data(1) = project_init(P);
				for vv=1:length(File1) % For each view.
					P.Data(1).Info.Files{vv}.Input_File{vv} = [Path1,filesep,File1{vv}];
					
					P.GUI_Handles.View_Axes(vv) = uiaxes(P.GUI_Handles.Axes_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1);
					% P.GUI_Handles.View_Axes(vv) = uiimage(P.GUI_Handles.Axes_Grid);
					
					P.GUI_Handles.View_Axes(vv).Layout.Row = 1;
					P.GUI_Handles.View_Axes(vv).Layout.Column = vv;
					
					% continue;
					title(P.GUI_Handles.View_Axes(vv),[]);
					xlabel(P.GUI_Handles.View_Axes(vv),[]);
					ylabel(P.GUI_Handles.View_Axes(vv),[]);
					P.GUI_Handles.View_Axes(vv).XAxis.TickLabels = {};
					P.GUI_Handles.View_Axes(vv).YAxis.TickLabels = {};
					
					imshow(P.Data(1).Info.Files.Input_File{vv},'Parent',P.GUI_Handles.View_Axes(vv));
				end
				[filepath,filename,ext] = fileparts(File1{1});
				P.Data(1).Info.Experiment(1).Identifier = filename;
				Label_1 = ['Project_X1','_',P.Data(1).Info.Experiment(1).Identifier];
				uimenu(P.GUI_Handles.Project_Menu,'Text',Label_1,'UserData',1,'Callback',{@Switch_Project_Func,P});
			else % If a project file(s) was loaded.
				P.GUI_Handles.View_Axes = gobjects(1,length(P.Data(1).Files.Input_File));
				P.GUI_Handles.Axes_Grid = uigridlayout(P.GUI_Handles.Main_Panel_1,[1,length(File1)],'RowHeight',repmat({'1x'},1,1),'ColumnWidth',repmat({'1x'},1,length(P.Data(1).Files.Input_File)));
				for pp=1:numel(P.Data) % For each project.
					[filepath,filename,ext] = fileparts(P.Data(pp).Files.Input_File{1});
					if(~exist(filepath,'dir') == 7 || isfile(P.Data(pp).Files.Input_File{1})) % If the path or file don't exist.
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
							P.Data(pp).Info.Files{vv}.Input_File{vv} = [Path1,filesep,File1{vv}];
						end
					end
					
					Label_pp = ['Project_X',num2str(pp),'_',P.Data(pp).Info.Experiment(1).Identifier];
					uimenu(P.GUI_Handles.Project_Menu,'Text',Label_pp,'UserData',pp,'Callback',{@Switch_Project_Func,P});
				end
				
				for vv=1:length(File1) % For each view.
					P.GUI_Handles.View_Axes(vv) = uiaxes(P.GUI_Handles.Axes_Grid,'BackgroundColor',P.GUI_Handles.BG_Color_1); % P.GUI_Handles.View_Axes(v) = uiimage(P.GUI_Handles.Axes_Grid);
					P.GUI_Handles.View_Axes(vv).Layout.Row = 1;
					P.GUI_Handles.View_Axes(vv).Layout.Column = vv;
					imshow(P.Data(1).Info.Files.Input_File{vv},'Parent',P.GUI_Handles.View_Axes(vv));
				end
			end
		end
		
		Display_Project_Info(P);
		
		set(P.GUI_Handles.Project_Menu,'UserData',1);
		set(P.GUI_Handles.Project_Menu.Children(end),'Checked','on');
		
		set(P.GUI_Handles.Buttons(1),'Backgroundcolor',P.GUI_Handles.Step_BG_Done);
		set(All_Enabled_Objects,'Enable','on');
		
		if(P.GUI_Handles.Current_Step == 0)
			P.GUI_Handles.Current_Step = 1;
			set(P.GUI_Handles.Step_Buttons(P.GUI_Handles.Current_Step+1),'Backgroundcolor',P.GUI_Handles.Step_BG_Active);
			Screen_1(P);
		end
		
		close(dd);
	end
	
	function Load_Project_Func(source,~,P)
		
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		[File,Path,Selection_Index] = uigetfile('*.mat','MultiSelect','on');
		
		if(Selection_Index == 0)
			set(All_Enabled_Objects,'Enable','on');
			return;
		end
		
		if(~iscell(File))
			File = {File};
		end
			
		for ii=1:length(File) % For each loaded project.
			
			Loaded_File = load([Path,File{ii}]);
			
			if(isfield(Loaded_File,'Project_X')) % If a project struct exists for the first loaded project.
				P.Data(ii) = Loaded_File.Project_X;
			end
		end
		
		Load_Data_Func([],[],P);
		
		set(source,'Enable','on','Backgroundcolor',P.GUI_Handles.Step_BG_Done);
		
		set(All_Enabled_Objects,'Enable','on');
		set(allchild(P.GUI_Handles.Project_Menu),'Enable','on');
	end
	
	function Step_Buttons_Func(source,~,P)
		
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
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
		
		set(All_Enabled_Objects,'Enable','on');
	end
	
	function Switch_Project_Func(source,~,P)
		
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		if(~isempty(source))
			P.GUI_Handles.Current_Project = source.UserData;
			pp = P.GUI_Handles.Current_Project;
			
			set(P.GUI_Handles.Project_Menu,'UserData',source.UserData);
			set(allchild(P.GUI_Handles.Project_Menu),'Checked','off');
			set(source,'Checked','on');
			
			% Display project data:
			if(~P.GUI_Handles.Multi_View) % single-view project. Create a project for each loaded file.
				imshow(P.Data(pp).Info.Files.Input_File{1},'Parent',P.GUI_Handles.View_Axes(1));
			else % Multi-view project.
				for vv=1:length(File1) % For each view.
					imshow(P.Data(pp).Info.Files.Input_File{vv},'Parent',P.GUI_Handles.View_Axes(vv));
				end
			end
			
			Display_Project_Info(P);
		end
		
		set(All_Enabled_Objects,'Enable','on');
		
		Step_Buttons_Func([],[],P);
	end
	
	function Display_Project_Info(P)
		
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		pp = P.GUI_Handles.Current_Project;
		
		for tt=1:length(P.GUI_Handles.Info_Fields_List)
			FF = fields(P.Data(pp).Info.(P.GUI_Handles.Info_Fields_List{tt}));
			for ii=1:length(FF) % For each field in the experiment struct.
				P.GUI_Handles.Info_Tables(tt).Data{ii,1} = FF{ii};
				P.GUI_Handles.Info_Tables(tt).Data{ii,2} = P.Data(pp).Info.(P.GUI_Handles.Info_Fields_List{tt})(1).(FF{ii});
			end
		end
		
		set(All_Enabled_Objects,'Enable','on');
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
	
	function Save_Image_Func(~,~,P)
		
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		Filename = sprintf('Screenshot_%s.svg', datestr(now,'mm-dd-yyyy HH-MM'));
		[File1,Path1] = uiputfile(Filename);
		
		if(Path1)
			disp('TODO: image saving not implemented');
		end
		
		set(All_Enabled_Objects,'Enable','on');
	end
	
	function Save_Figure_Func(~,~)
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		set(All_Enabled_Objects,'Enable','on');
	end
	
	function Save_Project_Func(~,~,P)
		
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
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
		
		set(All_Enabled_Objects,'Enable','on');
	end
	
	function Set_Callbacks(P)
		
		All_Enabled_Objects = findobj(P.GUI_Handles(1).Main_Figure,'Enable','on');
		set(All_Enabled_Objects,'Enable','off');
		
		set(P.GUI_Handles.Buttons(1),'ButtonPushedFcn',{@Load_Data_Func,P});
		set(P.GUI_Handles.Buttons(2),'ButtonPushedFcn',{@Load_Project_Func,P});
		set(P.GUI_Handles.Buttons(7),'ButtonPushedFcn',{@Save_Image_Func,P});
		set(P.GUI_Handles.Buttons(8),'ButtonPushedFcn',@Save_Figure_Func);
		set(P.GUI_Handles.Buttons(9),'ButtonPushedFcn',{@Save_Project_Func,P});
		
		set(P.GUI_Handles.Control_Panel_Objects(1,4),'ValueChangedFcn',{@Checkbox_1_Func,P});
		
		set(P.GUI_Handles.Step_Buttons(:),'ButtonPushedFcn',{@Step_Buttons_Func,P});
		
		for tt=1:length(P.GUI_Handles.Info_Tables) % For each info table.
			set(P.GUI_Handles.Info_Tables(tt),'CellEditCallback',{@Update_Info_Func,P});
		end
		
		set(All_Enabled_Objects,'Enable','on');
	end
end