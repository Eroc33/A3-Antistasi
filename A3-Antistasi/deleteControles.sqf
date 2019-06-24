private ["_marker","_control","_near","_pos"];

_marker = _this select 0;
_control = _this select 1;

_pos = getMarkerPos _control;

_near = [(marcadores - controles),_pos] call BIS_fnc_nearestPosition;

if (_near == _marker) then
	{
	waitUntil {sleep 1;(spawner getVariable _control == 2)};
	_side = sides getVariable [_marker,sideUnknown];
	sides setVariable [_control,_side,true];
	};
