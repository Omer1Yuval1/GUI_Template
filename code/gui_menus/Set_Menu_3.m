function Set_Menu_3(P)
	
	% UserData = 0 means that the a callback function should not be called when it is clicked.
	% The value of non-zero UserData correspond to menu index (e.g. UserData = 3 for menu 3).
	
	m = 3;
	
	uimenu(P.GUI_Handles.Menus(m),'Label','Option 1','UserData',m);
	uimenu(P.GUI_Handles.Menus(m),'Label','Option 2','UserData',m);
	uimenu(P.GUI_Handles.Menus(m),'Label','Option 3','UserData',m);
	
	h4 = uimenu(P.GUI_Handles.Menus(m),'Label','Option 4','UserData',0);
		uimenu(h4,'Label','Option 4-1','UserData',m);
		uimenu(h4,'Label','Option 4-2','UserData',m);
end