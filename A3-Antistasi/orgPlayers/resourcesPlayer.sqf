_money = _this select 0;

_money = _money + (player getVariable "dinero");
if (_money < 0) then {_money = 0};
player setVariable ["dinero",_money,true];
[] spawn A3A_fnc_statistics;
["dinero",_money] call fn_SaveStat;
true
