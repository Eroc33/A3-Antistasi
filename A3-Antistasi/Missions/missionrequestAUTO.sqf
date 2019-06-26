if (!isServer) exitWith {};

if (leader group Petros != Petros) exitWith {};

_types = ["CON","DES","LOG","RES","CONVOY"];

_type = selectRandom (_types select {!([_x] call BIS_fnc_taskExists)});
if (isNil "_type") exitWith {};
_nul = [_type,true] call A3A_fnc_missionRequest;
