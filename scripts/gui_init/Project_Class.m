classdef Project_Class < handle
    
	properties
		Data
		GUI_Handles
	end
    
    methods
        function obj = Project_Class() % Constructor.
			obj.Data = struct('Field_1',{},'Field_2',{},'Parameters','Info',{});
			obj.GUI_Handles = struct();
        end
		
		function S = project_init(obj)
			ff = fieldnames(obj.Data)';
			ff{2,1} = {};
			S = struct(ff{:}); % Create an empty struct with the same fields as in obj.Data.
			
			S(1).Info(1).Experiment = struct('Identifier',{},'Username',{},'Date',{},'Temperature',{},'Scale_Factor',{},'Time',{},'Duration',{});
			S.Info.Analysis = struct('Commit',{},'Username',{},'Date',{});
			S.Info.Files = struct('Input_File',{});
			
			% The second row is used for units:
			S.Info.Experiment(2).Date = 'YYYYMMDD';
			S.Info.Experiment(2).Temperature = '°C';
			S.Info.Experiment(2).Duration = 'seconds';
			S.Info.Experiment(2).Time = 'hh:mm:ss';
			
			S.Info.Analysis(1).Commit = [];
			S.Info.Analysis(2).Date = 'YYYYMMDD';
		end
    end
end