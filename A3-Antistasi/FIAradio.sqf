private ["_chance","_pos","_marcador","_return"];

_chance = tierWar*3;
{_pos = getPos _x;
_marcador = [puestos,_pos] call BIS_fnc_nearestPosition;
if ((sides getVariable [_marcador,sideUnknown] == good) and (alive _x)) then {_chance = _chance + 4};
} forEach antenas;
_return = false;
if (debug) then {_chance = 100};

if (random 100 < _chance) then
	{
	if (count _this == 0) then
		{
		if (not revelar) then
			{
			["TaskSucceeded", ["", "Enemy Comms Intercepted"]] remoteExec ["BIS_fnc_showNotification",good];
			revelar = true; publicVariable "revelar";
			[] remoteExec ["A3A_fnc_revealToPlayer",good];
			};
		}
	else
		{
		_return = true;
		};
	}
else
	{
	if (count _this == 0) then
		{
		if (revelar) then
			{
			["TaskFailed", ["", "Enemy Comms Lost"]] remoteExec ["BIS_fnc_showNotification",good];
			revelar = false; publicVariable "revelar";
			};
		};
	};
_return