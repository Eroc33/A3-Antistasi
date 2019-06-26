private ["_marker","_position","_size","_buildings"];

_marker = _this select 0;

_position = getMarkerPos _marker;
_size = [_marker] call A3A_fnc_sizeMarker;

_buildings = _position nearobjects ["house",_size];

{
if (random 100 < 70) then
	{
	for "_i" from 1 to 7 do
		{
		_x sethit [format ["dam%1",_i],1];
		_x sethit [format ["dam %1",_i],1];
		};
	}
} forEach _buildings;

[_marker,false] spawn A3A_fnc_apagon;
