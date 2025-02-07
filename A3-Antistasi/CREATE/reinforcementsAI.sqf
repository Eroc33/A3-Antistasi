private ["_aeropuertos","_reinfPlaces","_aeropuerto","_numero","_numGarr","_numReal","_lado","_posibles","_cuenta","_sitio","_posicion"];
_aeropuertos = airports select {(sides getVariable [_x,sideUnknown] != good) and (spawner getVariable _x == 2)};
if (count _aeropuertos == 0) exitWith {};
_reinfPlaces = [];
{
_aeropuerto = _x;
_numero = 8;
_numGarr = [_aeropuerto] call A3A_fnc_garrisonSize;
_numReal = count (garrison getVariable _aeropuerto);
_lado = sides getVariable [_aeropuerto,sideUnknown];
if (_numReal + 4 <= _numGarr) then
	{
	if (_numReal + 8 <= _numGarr) then
		{
		if (_lado == bad) then {[selectRandom groupsNATOSquad,_lado,_aeropuerto,0] remoteExec ["A3A_fnc_garrisonUpdate",2]} else {[selectRandom groupsCSATSquad,_lado,_aeropuerto,0] remoteExec ["A3A_fnc_garrisonUpdate",2]};
		_numero = 0;
		}
	else
		{
		if (_lado == bad) then {[selectRandom groupsNATOmid,_lado,_aeropuerto,0] remoteExec ["A3A_fnc_garrisonUpdate",2]} else {[selectRandom groupsCSATmid,_lado,_aeropuerto,0] remoteExec ["A3A_fnc_garrisonUpdate",2]};
		_numero = 4;
		};
	};
if ((_numero >= 4) and (reinfPatrols <= 4)) then
	{
	_posibles = (puestos + puertos - _reinfPlaces - (killZones getVariable [_aeropuerto,[]])) select {sides getVariable [_x,sideUnknown] == _lado};
	if (_posibles isEqualTo []) then
		{
		_posibles = (recursos + fabricas - _reinfPlaces - (killZones getVariable [_aeropuerto,[]])) select {sides getVariable [_x,sideUnknown] == _lado};
		};
	_posicion = getMarkerPos _aeropuerto;
	_posibles = _posibles select {((getMarkerPos _x distance2D _posicion) < distanceForAirAttack) and !(_x in forcedSpawn)};
	if (count _posibles > 0) then
		{
		_cuenta = 0;
		_sitio = "";
		{
		_numGarr = [_x] call A3A_fnc_garrisonSize;
		_numReal = count (garrison getVariable _x);
		if (_numGarr - _numReal > _cuenta) then
			{
			_cuenta = _numGarr - _numReal;
			_sitio = _x;
			};
		} forEach _posibles;
		if (_sitio != "") then
			{
			if ({(getMarkerPos _x distance2d getMarkerPos _sitio < distanceSPWN) and (sides getVariable [_x,sideUnknown] != _lado)} count airports == 0) then
				{
				if ({(_x distance2D _posicion < (2*distanceSPWN)) or (_x distance2D (getMarkerPos _sitio) < (2*distanceSPWN))} count allPlayers == 0) then
					{
					_tipoGrupo = if (_lado == bad) then {if (_numero == 4) then {selectRandom groupsNATOmid} else {selectRandom groupsNATOSquad}} else {if (_numero == 4) then {selectRandom groupsCSATmid} else {selectRandom groupsCSATSquad}};
					[_tipoGrupo,_lado,_sitio,2] remoteExec ["A3A_fnc_garrisonUpdate",2];
					}
				else
					{
					_reinfPlaces pushBack _sitio;
					[[_sitio,_aeropuerto,_numero,_lado],"A3A_fnc_patrolReinf"] call A3A_fnc_scheduler;
					};
				};
			};
		};
	};
if (count _reinfPlaces > 3) exitWith {};
} forEach _aeropuertos;

if ((count _reinfPlaces == 0) and (AAFpatrols <= 3)) then {[] spawn A3A_fnc_AAFroadPatrol};