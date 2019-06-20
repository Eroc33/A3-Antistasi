private ["_tiempo","_tsk"];

_tiempo = _this select 0;
_tsk = _this select 1;
if (isNil "_tsk") exitWith {};
if (_tiempo > 0) then {sleep ((_tiempo/2) + random _tiempo)};

if (count missions > 0) then
	{
	for "_i" from 0 to (count missions -1) do
		{
		_mision = (missions select _i) select 0;
		if (_mision == _tsk) exitWith {missions deleteAt _i; publicVariable "missions"};
		};
	};

_nul = [_tsk] call BIS_fnc_deleteTask;
