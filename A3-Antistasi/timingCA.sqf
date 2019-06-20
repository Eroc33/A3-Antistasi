_weather = _this select 0;
if (isNil "_weather") exitWith {};
if !(_weather isEqualType 0) exitWith {};
_mayor = if (_weather >= 3600) then {true} else {false};
_weather = _weather - (((tierWar + difficultyCoef)-1)*400);

if (_weather < 0) then {_weather = 0};

cuentaCA = cuentaCA + round (random _weather);

if (_mayor and (cuentaCA < 1200)) then {cuentaCA = 1200};
publicVariable "cuentaCA";




