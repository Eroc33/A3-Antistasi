private _marcador = _this select 0;
if (!(_marcador in airports) and !(_marcador in puestos)) exitWith {false};
if !(dateToNumber date > server getVariable [_marcador,0]) exitWith {false};
private _isQRF = _this select 1;
if (_isQRF and (count (garrison getVariable [_marcador,[]]) <= 8)) exitWith {false};
if (!_isQRF and (count (garrison getVariable [_marcador,[]]) < 16)) exitWith {false};
if ([distanceSPWN/2,1,getMarkerPos _marcador,good] call A3A_fnc_distanceUnits) exitWith {false};
if (_marcador in forcedSpawn) exitWith {false};
true