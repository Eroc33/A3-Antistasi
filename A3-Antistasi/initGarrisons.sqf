

_mrkNATO = [];
_mrkCSAT = [];
_controlesNATO = [];
_controlesCSAT = [];

if (gameMode == 1) then
	{
    _controlesNATO = controles;
	if (worldName == "Tanoa") then
	    {
	    _mrkCSAT = ["airport_1","puerto_5","puesto_10","control_20"];
	    _controlesNATO = _controlesNATO - ["control_20"];
	    _controlesCSAT = ["control_20"];
	    }
	else
	    {
	    if (worldName == "Altis") then
	        {
	        _mrkCSAT = ["airport_2","puerto_4","puesto_5","control_52","control_33"];
	        _controlesNATO = _controlesNATO - ["control_52","control_33"];
	    	_controlesCSAT = ["control_52","control_33"];
	        }
        else
            {
            if (worldName == "chernarus_summer") then
                {
                _mrkCSAT = ["puesto_21"];
                };
            };
	    };
	_mrkNATO = marcadores - _mrkCSAT - ["Synd_HQ"];
	}
else
	{
	if (gameMode == 4) then
		{
		_mrkCSAT = marcadores - ["Synd_HQ"];
		_controlesCSAT = controles;
		}
	else
		{
		_mrkNATO = marcadores - ["Synd_HQ"];
		_controlesNATO = controles;
		};
	};
{sides setVariable [_x,bad,true]} forEach _controlesNATO;
{sides setVariable [_x,veryBad,true]} forEach _controlesCSAT;
{
_pos = getMarkerPos _x;
_dmrk = createMarker [format ["Dum%1",_x], _pos];
_dmrk setMarkerShape "ICON";
_garrNum = [_x] call A3A_fnc_garrisonSize;
_garrNum = _garrNum / 8;
_garrison = [];
killZones setVariable [_x,[],true];
if (_x in _mrkCSAT) then
    {
    _dmrk setMarkerType flagCSATmrk;
    _dmrk setMarkerText format ["%1 Airbase",nameMuyMalos];
    _dmrk setMarkerColor colorVeryBad;
    for "_i" from 1 to _garrNum do
        {
        _garrison append (selectRandom groupsCSATSquad);
        };
    garrison setVariable [_x,_garrison,true];
    sides setVariable [_x,veryBad,true];
    }
else
    {
    _dmrk setMarkerType flagNATOmrk;
    _dmrk setMarkerText format ["%1 Airbase",nameMalos];
    _dmrk setMarkerColor colorBad;
    for "_i" from 1 to _garrNum do
        {
        _garrison append (selectRandom groupsNATOSquad);
        };
    garrison setVariable [_x,_garrison,true];
    sides setVariable [_x,bad,true];
    };
_nul = [_x] call A3A_fnc_crearControles;
server setVariable [_x,0,true];//fecha en fomrato dateToNumber en la que estarán idle
} forEach airports;

{
_pos = getMarkerPos _x;
_dmrk = createMarker [format ["Dum%1",_x], _pos];
_dmrk setMarkerShape "ICON";
_garrNum = [_x] call A3A_fnc_garrisonSize;
_garrNum = _garrNum / 8;
_garrison = [];
_dmrk setMarkerType "loc_rock";
_dmrk setMarkerText "Resources";
for "_i" from 1 to _garrNum do
   {
   _garrison append (selectRandom groupsFIASquad);
   };
if (_x in _mrkCSAT) then
	{
	_dmrk setMarkerColor colorVeryBad;
	sides setVariable [_x,veryBad,true];
	}
else
	{
	_dmrk setMarkerColor colorBad;
	sides setVariable [_x,bad,true];
	};
garrison setVariable [_x,_garrison,true];
_nul = [_x] call A3A_fnc_crearControles;
} forEach recursos;

{
_pos = getMarkerPos _x;
_dmrk = createMarker [format ["Dum%1",_x], _pos];
_dmrk setMarkerShape "ICON";
_garrNum = [_x] call A3A_fnc_garrisonSize;
_garrNum = _garrNum / 8;
_garrison = [];
_dmrk setMarkerType "u_installation";
_dmrk setMarkerText "Factory";
for "_i" from 1 to _garrNum do
   {
   _garrison append (selectRandom groupsFIASquad);
   };
if (_x in _mrkCSAT) then
	{
	_dmrk setMarkerColor colorVeryBad;
    sides setVariable [_x,veryBad,true];
	}
else
	{
	_dmrk setMarkerColor colorBad;
    sides setVariable [_x,bad,true];
    };
garrison setVariable [_x,_garrison,true];
_nul = [_x] call A3A_fnc_crearControles;
} forEach fabricas;

{
_pos = getMarkerPos _x;
_dmrk = createMarker [format ["Dum%1",_x], _pos];
_dmrk setMarkerShape "ICON";
_garrNum = [_x] call A3A_fnc_garrisonSize;
_garrNum = _garrNum / 8;
_garrison = [];
killZones setVariable [_x,[],true];
_dmrk setMarkerType "loc_bunker";
if !(_x in _mrkCSAT) then
    {
    _dmrk setMarkerColor colorBad;
    _dmrk setMarkerText format ["%1 Outpost",nameMalos];
    for "_i" from 1 to _garrNum do
        {
        _garrison append (selectRandom groupsFIASquad);
        };
    sides setVariable [_x,bad,true];
    }
else
    {
    _dmrk setMarkerText format ["%1 Outpost",nameMuyMalos];
    _dmrk setMarkerColor colorVeryBad;
    if (gameMode == 4) then
    	{
    	for "_i" from 1 to _garrNum do
	       {
	       _garrison append (selectRandom groupsFIASquad);
	       };
    	}
    else
    	{
	    for "_i" from 1 to _garrNum do
	        {
	        _garrison append (selectRandom groupsCSATSquad);
	        };
	    };
    sides setVariable [_x,veryBad,true];
    };
garrison setVariable [_x,_garrison,true];
server setVariable [_x,0,true];
_nul = [_x] call A3A_fnc_crearControles;
} forEach puestos;

{
_pos = getMarkerPos _x;
_dmrk = createMarker [format ["Dum%1",_x], _pos];
_dmrk setMarkerShape "ICON";
_garrNum = [_x] call A3A_fnc_garrisonSize;
_garrNum = _garrNum / 8;
_garrison = [];
_dmrk setMarkerType "b_naval";
_dmrk setMarkerText "Sea Port";
if (_x in _mrkCSAT) then
    {
    _dmrk setMarkerColor colorVeryBad;
	for "_i" from 1 to _garrNum do
	   {
	   _garrison append (selectRandom groupsCSATSquad);
	   };
    sides setVariable [_x,veryBad,true];
    }
else
    {
    _dmrk setMarkerColor colorBad;
    for "_i" from 1 to _garrNum do
        {
        _garrison append (selectRandom groupsNATOSquad);
        };
    sides setVariable [_x,bad,true];
    };
garrison setVariable [_x,_garrison,true];
_nul = [_x] call A3A_fnc_crearControles;
} forEach puertos;

sides setVariable ["NATO_carrier",bad,true];
sides setVariable ["CSAT_carrier",veryBad,true];