if (!isServer and hasInterface) exitWith {};

private ["_marker","_destination","_origin","_groups","_soldiers","_vehicles","_size","_group","_truck","_tam","_roads","_road","_pos"];

_marker = _this select 0;
if (not(_marker in smallCAmrk)) exitWith {};

_destination = getMarkerPos _marker;
_origin = getMarkerPos respawnGood;

_groups = [];
_soldiers = [];
_vehicles = [];

_size = [_marker] call A3A_fnc_sizeMarker;

_divisor = 50;

if (_marker in airports) then {_divisor = 100};

_size = round (_size / _divisor);

if (_size == 0) then {_size = 1};

_groupTypes = [groupsSDKmid,groupsSDKAT,groupsSDKSquad,groupsSDKSniper];

while {(_size > 0)} do
	{
	_groupType = selectRandom _groupTypes;
	_format = [];
	{
	if (random 20 <= skillFIA) then {_format pushBack (_x select 1)} else {_format pushBack (_x select 0)};
	} forEach _groupType;
	_group = [_origin, good, _format,false,true] call A3A_fnc_spawnGroup;
	if !(isNull _group) then
		{
		_groups pushBack _group;
		{[_x] spawn A3A_fnc_FIAinit; _soldiers pushBack _x} forEach units _group;
		_Vwp1 = _group addWaypoint [_destination, 0];
		_Vwp1 setWaypointType "MOVE";
		_Vwp1 setWaypointBehaviour "AWARE";
		sleep 30;
		};
	_size = _size - 1;
	};

waitUntil {sleep 1;((not(_marker in smallCAmrk)) or (sides getVariable [_marker,sideUnknown] == bad) or (sides getVariable [_marker,sideUnknown] == veryBad))};
/*
{_vehicle = _x;
waitUntil {sleep 1; {_x distance _vehicle < distanceSPWN} count (allPlayers - (entities "HeadlessClient_F")) == 0};
deleteVehicle _vehicle;
} forEach _vehicles;*/
{_soldier = _x;
waitUntil {sleep 1; {_x distance _soldier < distanceSPWN} count (allPlayers - (entities "HeadlessClient_F")) == 0};
deleteVehicle _soldier;
} forEach _soldiers;
{deleteGroup _x} forEach _groups;