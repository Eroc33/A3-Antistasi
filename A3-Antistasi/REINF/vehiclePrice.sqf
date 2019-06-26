private ["_type","_cost"];

_type = _this select 0;

_cost = server getVariable _type;

if (isNil "_cost") then
	{
	diag_log format ["Antistasi Error en vehicleprice: %!",_type];
	_cost = 0;
	}
else
	{
	_cost = round (_cost - (_cost * (0.1 * ({sides getVariable [_x,sideUnknown] == good} count puertos))));
	};

_cost
