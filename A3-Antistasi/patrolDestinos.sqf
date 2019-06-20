private ["_marcadores","_array","_pos","_marcador","_destinos","_posicion"];

_marcadores = _this select 0;
_posicion = _this select 1;
_array = (_marcadores - controles) select {getMarkerPos _x distance2D _posicion < distanceForLandAttack};
_destinos = [];
if !(isMultiplayer) then
	{
	{
	_destino = _x;
	_pos = getMarkerPos _destino;
	if (marcadores findIf {(sides getVariable [_x,sideUnknown] == good) and (getMarkerPos _x distance2d _pos < 2000)} != -1) then {_destinos pushBack _destino};
	} forEach _array;
	}
else
	{
	{
	_destino = _x;
	_pos = getMarkerPos _destino;
	if (playableUnits findIf {(side (group _x) == good) and (_x distance2d _pos < 2000)} != -1) then {_destinos pushBack _destino};
	} forEach _array;
	};
_destinos