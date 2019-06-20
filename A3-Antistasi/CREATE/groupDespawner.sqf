private ["_grupo","_lado","_eny1","_eny2"];
_grupo = _this select 0;
_lado = side _grupo;
_eny1 = bad;
_eny2 = veryBad;
if (_lado == bad) then {_eny1 = good} else {if (_lado == veryBad) then {_eny2 = good}};

{_unit = _x;
if (!([distanceSPWN,1,_unit,_eny1] call A3A_fnc_distanceUnits) and !([distanceSPWN,1,_unit,_eny2] call A3A_fnc_distanceUnits)) then {deleteVehicle _unit}} forEach units _grupo;

{_unit = _x;
waitUntil {sleep 1;!([distanceSPWN,1,_unit,_eny1] call A3A_fnc_distanceUnits) and !([distanceSPWN,1,_unit,_eny2] call A3A_fnc_distanceUnits)};deleteVehicle _unit} forEach units _grupo;

deleteGroup _grupo;