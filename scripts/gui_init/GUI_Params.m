function GUI_Params(P)
	
	P(1).GUI_Handles.Multi_View = 0; % 0 = Single-view project. Multiple files are loaded as separate projects. 1 = Multi-view project. All files are loaded as one project.
	
	P.GUI_Handles.Input_Data_Formats = {'*.png;*.tif'};
	
	P.GUI_Handles.Buttons_Names = {'Load Data','Load Project','Button','Button','Button','Button','Save Image','Save Figure','Save Project'};
	P.GUI_Handles.Step_Buttons_Names = {'Back','Screen 1','Screen 2','Screen 3','Screen 4','Screen 5','Screen 6','Next'};
	P.GUI_Handles.Info_Fields_List = {'Experiment','Analysis'}; % Fields to include as tabs and tables in the info panel.
	
	P.GUI_Handles.Buttons_FontSize = 16;
	P.GUI_Handles.Step_Buttons_FontSize = 16;
	
	P.GUI_Handles.BG_Color_1 = [.25,.25,.25];
	P.GUI_Handles.BG_Color_2 = [1,1,1];
	
	P.GUI_Handles.Step_BG_Before = [.7,.2,.2];
	P.GUI_Handles.Step_BG_Active = [.8,.8,0];
	P.GUI_Handles.Step_BG_Done = [.1,.5,.1];
	
	P.GUI_Handles.Button_BG_Neurtral = [0.0980,0.0980,0.4392]; % [0,0,0.5]; [0.2549,0.4118,0.8824]; [.1,.1,.9];
end