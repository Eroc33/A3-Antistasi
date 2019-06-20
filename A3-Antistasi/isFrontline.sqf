private ["_marcador","_isfrontier","_posicion","_mrkENY"];

_marcador = _this select 0;
_isfrontier = false;

_lado = sides getVariable [_marcador,sideUnknown];
_mrkENY = (airports + puestos + puertos) select {sides getVariable [_x,sideUnknown] != _lado};

if (count _mrkENY > 0) then
	{
	_posicion = getMarkerPos _marcador;
	{if (_posicion distance (getMarkerPos _x) < distanceSPWN) exitWith {_isFrontier = true}} forEach _mrkENY;
	};
_isfrontier