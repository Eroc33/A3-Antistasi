if (!isServer) exitWith{};

//debugperf = false;

private ["_time","_markers","_marker","_mrkPosition","_count"];

waitUntil {!isNil "theBoss"};

_time = 1/(count marcadores);
_count = 0;
_greenfor = [];
_blufor = [];
_opfor = [];

while {true} do {
//sleep 0.01;
/*
if (time - _time >= 0.5) then
	{
	sleep 0.1;
	_count = _count + 0.1
	}
else
	{
	sleep 0.5 - (time - _time);
	_count = _count + (0.5 - (time-_time));
	};
//if (debugperf) then {hint format ["Tiempo transcurrido: %1 para %2 marcadores", time - _time, count marcadores]};
_time = time;
*/
//sleep 1;
_count = _count + 1;
if (_count > 5) then
	{
	_count = 0;
	_spawners = allUnits select {_x getVariable ["spawner",false]};
	_greenfor = [];
	_blufor = [];
	_opfor = [];
	{
	_side = side (group _x);
	if (_side == bad) then
		{
		_blufor pushBack _x;
		}
	else
		{
		if (_side == veryBad) then
			{
			_opfor pushBack _x;
			}
		else
			{
			_greenfor pushBack _x;
			};
		};
	} forEach _spawners;
	};

{
sleep _time;
_marker = _x;

_mrkPosition = getMarkerPos (_marker);

if (sides getVariable [_marker,sideUnknown] == bad) then
	{
	if (spawner getVariable _marker != 0) then
		{
		if (spawner getVariable _marker == 2) then
			{
			if (({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _greenfor > 0) or ({if ((_x distance2D _mrkPosition < distanceSPWN2)) exitWith {1}} count _opfor > 0) or ({if ((isPlayer _x) and (_x distance2D _mrkPosition < distanceSPWN2)) exitWith {1}} count _blufor > 0) or (_marker in forcedSpawn)) then
				{
				spawner setVariable [_marker,0,true];
				if (_marker in ciudades) then
					{
					if (({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _greenfor > 0) or ({if ((isPlayer _x) and (_x distance2D _mrkPosition < distanceSPWN2)) exitWith {1}} count _blufor > 0) or (_marker in forcedSpawn)) then {[[_marker],"A3A_fnc_createAIciudades"] call A3A_fnc_scheduler};
					if (not(_marker in destroyedCities)) then
						{
						if (({if ((isPlayer _x) and (_x distance2D _mrkPosition < distanceSPWN)) exitWith {1};false} count allUnits > 0) or (_marker in forcedSpawn)) then {[[_marker],"A3A_fnc_createCIV"] call A3A_fnc_scheduler};
						};
					}
				else
					{
					if (_marker in controles) then {[[_marker],"A3A_fnc_createAIcontroles"] call A3A_fnc_scheduler} else {
					if (_marker in airports) then {[[_marker],"A3A_fnc_createAIaerop"] call A3A_fnc_scheduler} else {
					if (((_marker in recursos) or (_marker in fabricas))) then {[[_marker],"A3A_fnc_createAIrecursos"] call A3A_fnc_scheduler} else {
					if ((_marker in puestos) or (_marker in puertos)) then {[[_marker],"A3A_fnc_createAIpuestos"] call A3A_fnc_scheduler};};};};
					};
				};
			}
		else
			{
			if (({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _greenfor > 0) or ({if ((_x distance2D _mrkPosition < distanceSPWN2)) exitWith {1}} count _opfor > 0) or ({if ((isPlayer _x) and (_x distance2D _mrkPosition < distanceSPWN2)) exitWith {1}} count _blufor > 0) or (_marker in forcedSpawn)) then
				{
				spawner setVariable [_marker,0,true];
				if (isMUltiplayer) then
					{
					{if (_x getVariable ["marcador",""] == _marker) then {if (vehicle _x == _x) then {_x enableSimulationGlobal true}}} forEach allUnits;
					}
				else
					{
					{if (_x getVariable ["marcador",""] == _marker) then {if (vehicle _x == _x) then {_x enableSimulation true}}} forEach allUnits;
					};
				}
			else
				{
				if (({if (_x distance2D _mrkPosition < distanceSPWN1) exitWith {1}} count _greenfor == 0) and ({if ((_x distance2D _mrkPosition < distanceSPWN)) exitWith {1}} count _opfor == 0) and ({if ((isPlayer _x) and (_x distance2D _mrkPosition < distanceSPWN)) exitWith {1}} count _blufor == 0) and (not(_marker in forcedSpawn))) then
					{
					spawner setVariable [_marker,2,true];
					};
				};
			};
		}
	else
		{
		if (({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _greenfor == 0) and ({if ((_x distance2D _mrkPosition < distanceSPWN2)) exitWith {1}} count _opfor == 0) and ({if ((isPlayer _x) and (_x distance2D _mrkPosition < distanceSPWN2)) exitWith {1}} count _blufor == 0) and (not(_marker in forcedSpawn))) then
			{
			spawner setVariable [_marker,1,true];
			if (isMUltiplayer) then
					{
					{if (_x getVariable ["marcador",""] == _marker) then {if (vehicle _x == _x) then {_x enableSimulationGlobal false}}} forEach allUnits;
					}
				else
					{
					{if (_x getVariable ["marcador",""] == _marker) then {if (vehicle _x == _x) then {_x enableSimulation false}}} forEach allUnits;
					};
			};
		};
	}
else
	{
	if (sides getVariable [_marker,sideUnknown] == good) then
		{
		if (spawner getVariable _marker != 0) then
			{
			if (spawner getVariable _marker == 2) then
				{
				if (({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _blufor > 0) or ({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _opfor > 0) or ({if (((_x getVariable ["owner",objNull]) == _x) and (_x distance2D _mrkPosition < distanceSPWN2)) exitWith {1}} count _greenfor > 0) or (_marker in forcedSpawn)) then
					{
					spawner setVariable [_marker,0,true];
					if (_marker in ciudades) then
						{
						//[_marker] remoteExec ["A3A_fnc_createAIciudades",HCGarrisons];
						if (not(_marker in destroyedCities)) then
							{
							if (({if ((isPlayer _x) and (_x distance2D _mrkPosition < distanceSPWN)) exitWith {1};false} count allUnits > 0) or (_marker in forcedSpawn)) then {[[_marker],"A3A_fnc_createCIV"] call A3A_fnc_scheduler};
							};
						};
					if (_marker in puestosFIA) then {[[_marker],"A3A_fnc_createFIApuestos2"] call A3A_fnc_scheduler} else {if (not(_marker in controles)) then {[[_marker],"A3A_fnc_createSDKGarrisons"] call A3A_fnc_scheduler}};
					};
				}
			else
				{
				if (({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _blufor > 0) or ({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _opfor > 0) or ({if (((_x getVariable ["owner",objNull]) == _x) and (_x distance2D _mrkPosition < distanceSPWN2) or (_marker in forcedSpawn)) exitWith {1}} count _greenfor > 0)) then
					{
					spawner setVariable [_marker,0,true];
					if (isMUltiplayer) then
						{
						{if (_x getVariable ["marcador",""] == _marker) then {if (vehicle _x == _x) then {_x enableSimulationGlobal true}}} forEach allUnits;
						}
					else
						{
						{if (_x getVariable ["marcador",""] == _marker) then {if (vehicle _x == _x) then {_x enableSimulation true}}} forEach allUnits;
						};
					}
				else
					{
					if (({if (_x distance2D _mrkPosition < distanceSPWN1) exitWith {1}} count _blufor == 0) and ({if (_x distance2D _mrkPosition < distanceSPWN1) exitWith {1}} count _opfor == 0) and ({if (((_x getVariable ["owner",objNull]) == _x) and (_x distance2D _mrkPosition < distanceSPWN)) exitWith {1}} count _greenfor == 0) and (not(_marker in forcedSpawn))) then
						{
						spawner setVariable [_marker,2,true];
						};
					};
				};
			}
		else
			{
			if (({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _blufor == 0) and ({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _opfor == 0) and ({if (((_x getVariable ["owner",objNull]) == _x) and (_x distance2D _mrkPosition < distanceSPWN2)) exitWith {1}} count _greenfor == 0) and (not(_marker in forcedSpawn))) then
				{
				spawner setVariable [_marker,1,true];
				if (isMUltiplayer) then
						{
						{if (_x getVariable ["marcador",""] == _marker) then {if (vehicle _x == _x) then {_x enableSimulationGlobal false}}} forEach allUnits;
						}
					else
						{
						{if (_x getVariable ["marcador",""] == _marker) then {if (vehicle _x == _x) then {_x enableSimulation false}}} forEach allUnits;
						};
				};
			};
		}
	else
		{
		if (spawner getVariable _marker != 0) then
			{
			if (spawner getVariable _marker == 2) then
				{
				if (({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _greenfor > 0) or ({if ((_x distance2D _mrkPosition < distanceSPWN2) and (isPlayer _x)) exitWith {1}} count _opfor > 0) or ({if (_x distance2D _mrkPosition < distanceSPWN2) exitWith {1}} count _blufor > 0) or (_marker in forcedSpawn)) then
					{
					spawner setVariable [_marker,0,true];
					if (_marker in controles) then {[[_marker],"A3A_fnc_createAIcontroles"] call A3A_fnc_scheduler} else {
					if (_marker in airports) then {[[_marker],"A3A_fnc_createAIaerop"] call A3A_fnc_scheduler} else {
					if (((_marker in recursos) or (_marker in fabricas))) then {[[_marker],"A3A_fnc_createAIrecursos"] call A3A_fnc_scheduler} else {
					if ((_marker in puestos) or (_marker in puertos)) then {[[_marker],"A3A_fnc_createAIpuestos"] call A3A_fnc_scheduler};};};};
					};
				}
			else
				{
				if (({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _greenfor > 0) or ({if ((_x distance2D _mrkPosition < distanceSPWN2) and (isPlayer _x)) exitWith {1}} count _opfor > 0) or ({if (_x distance2D _mrkPosition < distanceSPWN2) exitWith {1}} count _blufor > 0) or (_marker in forcedSpawn)) then
					{
					spawner setVariable [_marker,0,true];
					if (isMUltiplayer) then
						{
						{if (_x getVariable ["marcador",""] == _marker) then {if (vehicle _x == _x) then {_x enableSimulationGlobal true}}} forEach allUnits;
						}
					else
						{
						{if (_x getVariable ["marcador",""] == _marker) then {if (vehicle _x == _x) then {_x enableSimulation true}}} forEach allUnits;
						};
					}
				else
					{
					if (({if (_x distance2D _mrkPosition < distanceSPWN1) exitWith {1}} count _greenfor == 0) and ({if ((_x distance2D _mrkPosition < distanceSPWN2) and (isPlayer _x)) exitWith {1}} count _opfor == 0) and ({if ((_x distance2D _mrkPosition < distanceSPWN)) exitWith {1}} count _blufor == 0) and (not(_marker in forcedSpawn))) then
						{
						spawner setVariable [_marker,2,true];
						};
					};
				};
			}
		else
			{
			if (({if (_x distance2D _mrkPosition < distanceSPWN) exitWith {1}} count _greenfor == 0) and ({if ((_x distance2D _mrkPosition < distanceSPWN2) and (isPlayer _x)) exitWith {1}} count _opfor == 0) and ({if (_x distance2D _mrkPosition < distanceSPWN2) exitWith {1}} count _blufor == 0) and (not(_marker in forcedSpawn))) then
				{
				spawner setVariable [_marker,1,true];
				if (isMUltiplayer) then
						{
						{if (_x getVariable ["marcador",""] == _marker) then {if (vehicle _x == _x) then {_x enableSimulationGlobal false}}} forEach allUnits;
						}
					else
						{
						{if (_x getVariable ["marcador",""] == _marker) then {if (vehicle _x == _x) then {_x enableSimulation false}}} forEach allUnits;
						};
				};
			};
		};
	};
} forEach marcadores;

};
