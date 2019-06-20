params ["_position","_side","_type",["_override",false],["_canBypass",false]];
//private ["_group","_count","_rankCounts","_leader","_units","_index","_position","_side","_type","_override","_canBypass"];
private ["_group","_count","_rankCounts","_leader","_units","_index"];

/*_position = _this select 0;
_side = _this select 1;
_type = _this select 2;
_override = if (count _this >3) then {_this select 3} else {false};
_canBypass = if (count _this > 4) then {_this select 4} else {false};*/

_allUnits = {(local _x) and (alive _x)} count allUnits;
_allUnitsSide = 0;
_maxUnitsSide = maxUnits;

if (gameMode <3) then
	{
	_allUnitsSide = {(local _x) and (alive _x) and (side group _x == _side)} count allUnits;
	_maxUnitsSide = round (maxUnits * 0.7);
	};
if (_canBypass) then
	{
	if ((_allUnits + 1 <= maxUnits) or (_allUnitsSide + 1 <= _maxUnitsSide)) then {_canBypass = false};
	};
if (_canBypass) exitWith {grpNull};
_group = createGroup _side;
_ranks = ["LIEUTENANT","SERGEANT","CORPORAL"];
_count = count _type;
if (_count < 4) then
	{
	_ranks = _ranks - ["LIEUTENANT","SERGEANT"];
	}
else
	{
	if (_count < 8) then {_ranks = _ranks - ["LIEUTENANT"]};
	};
_rankCounts = (count _ranks - 1);
for "_i" from 0 to (_count - 1) do
	{
	if ((_i == 0) or (((_allUnits + 1) < maxUnits) and ((_allUnitsSide + 1) < _maxUnitsSide)) or _override) then
		{
		_unit = _group createUnit [(_type select _i), _position, [], 0, "NONE"];
		_unit allowDamage false;
		_allUnits = _allUnits + 1;
		_allUnitsSide = _allUnitsSide + 1;
		if (_i <= _rankCounts) then
			{
			_unit setRank (_ranks select _i);
			};
		if ((_type select _i) in squadLeaders) then {_group selectLeader _unit};
		sleep 0.5;
		};
	};
//_units = units _group;
//_index = _units findIf {(typeOf _x in squadLeaders)};
//if (_index == -1) then {_group selectLeader (_units select 0)} else {_group selectLeader (_units select _index)};
{_x allowDamage true} forEach units _group;
_group




