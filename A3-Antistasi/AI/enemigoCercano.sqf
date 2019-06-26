private _group = _this;
private _result = objNull;

_enemies = _group getVariable ["objetivos",[]];
if (count _enemies > 0) then
	{
	for "_i" from 0 to (count _enemies) - 1 do
		{
		_eny = (_enemies select _i) select 4;
		if (vehicle _eny == _eny) exitWith {_result = _eny};
		};
	};
_result
