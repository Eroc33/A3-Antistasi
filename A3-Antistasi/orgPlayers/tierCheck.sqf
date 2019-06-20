_sitios = marcadores select {sides getVariable [_x,sideUnknown] == good};
_tierWar = 1 + (floor (((5*({(_x in puestos) or (_x in recursos) or (_x in ciudades)} count _sitios)) + (10*({_x in puertos} count _sitios)) + (20*({_x in airports} count _sitios)))/10));
if (_tierWar > 10) then {_tierWar = 10};
if (_tierWar != tierWar) then
	{
	tierWar = _tierWar;
	publicVariable "tierWar";
	[petros,"tier",""] remoteExec ["A3A_fnc_commsMP",[good,civilian]];
	//[] remoteExec ["A3A_fnc_statistics",[good,civilian]];
	};