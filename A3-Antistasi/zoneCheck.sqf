if (!isServer) exitWith {};

private ["_marker","_side","_exit","_enemy1","_enemy2","_winner"];

_marker = _this select 0;
_side = _this select 1;
if ((isNil "_marker") or (isNil "_side")) exitWith {};
waitUntil {!zoneCheckInProgress};
zoneCheckInProgress = true;
_exit = true;
_enemy1 = "";
_enemy2 = "";

if ((_side == good) and (sides getVariable [_marker,sideUnknown] == good)) then
	{
	_exit = false;
	_enemy1 = veryBad;
	_enemy2 = bad;
	}
else
	{
	if ((_side == bad) and (sides getVariable [_marker,sideUnknown] == bad)) then
		{
		_exit = false;
		_enemy1 = veryBad;
		_enemy2 = good;
		}
	else
		{
		if ((_side == veryBad) and (sides getVariable [_marker,sideUnknown] == veryBad)) then
			{
			_exit = false;
			_enemy1 = bad;
			_enemy2 = good;
			};
		};
	};

if (_exit) exitWith {zoneCheckInProgress = false};
_exit = true;

if ({((_x getVariable ["spawner",false]) and ((side group _x) in [_enemy1,_enemy2])) and ([_x,_marker] call A3A_fnc_canConquer)} count allUnits > 3*({([_x,_marker] call A3A_fnc_canConquer) and (_x getVariable ["marcador",""] == _marker)} count allUnits)) then
	{
	_exit = false;
	};
if (_exit) exitWith {zoneCheckInProgress = false};

_winner = _enemy1;
if ({(_x getVariable ["spawner",false]) and (side group _x == _enemy1) and ([_x,_marker] call A3A_fnc_canConquer)} count allUnits <= {(_x getVariable ["spawner",false]) and (side group _x == _enemy2) and ([_x,_marker] call A3A_fnc_canConquer)} count allUnits) then {_winner = _enemy2};

[_winner,_marker] remoteExec ["A3A_fnc_markerChange",2];

waitUntil {sleep 1; sides getVariable [_marker,sideUnknown] == _winner};
zoneCheckInProgress = false;
