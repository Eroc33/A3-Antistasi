_unit = _this select 0;
_truck = _this select 1;

if ((isPlayer _unit) or (player != leader group player)) exitWith {};
if !([_unit] call A3A_fnc_canFight) exitWith {};
//_ayudando = _unit getVariable "ayudando";
if (_unit getVariable ["ayudando",false]) exitWith {_unit groupChat "I cannot rearm right now. I'm healing a comrade"};
_rearming = _unit getVariable "rearming";
if (_rearming) exitWith {_unit groupChat "I am currently rearming. Cancelling."; _unit setVariable ["rearming",false]};
if (_unit == gunner _truck) exitWith {_unit groupChat "I cannot rearm right now. I'm manning this gun"};
if (!canMove _truck) exitWith {_unit groupChat "It is useless to load my vehicle, as it needs repairs"};

_objects = [];
_hasBox = false;
_weapon = "";
_weapons = [];
_bigTimeOut = time + 120;
_objects = nearestObjects [_unit, ["WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"], 50];
if (count _objects == 0) exitWith {_unit groupChat "I see no corpses here to loot"};

_target = objNull;
_distance = 51;
{
_object = _x;
if (_unit distance _object < _distance) then
	{
	if ((count weaponCargo _object > 0) and !(_object getVariable ["busy",false])) then
		{
		_weapons = weaponCargo _object;
		for "_i" from 0 to (count _weapons - 1) do
			{
			_posible = _weapons select _i;
			_basePosible = [_posible] call BIS_fnc_baseWeapon;
			//if ((not(_basePosible in unlockedWeapons)) and ((_basePosible in arifles) or (_basePosible in srifles) or (_basePosible in mguns) or (_posible in mlaunchers) or (_posible in rlaunchers))) then
			if ((_basePosible in arifles) or (_basePosible in srifles) or (_basePosible in mguns) or (_posible in mlaunchers) or (_posible in rlaunchers)) then
				{
				_target = _object;
				_distance = _unit distance _object;
				_weapon = _posible;
				};
			};
		};
	};
} forEach _objects;

if (isNull _target) exitWith {_unit groupChat "There is nothing to loot"};
_target setVariable ["busy",true];
_unit setVariable ["rearming",true];
_unit groupChat "Starting looting";

_originalLoadout = getUnitLoadout _unit;

removeBackpackGlobal _unit;
removeVest _unit;
{_unit unlinkItem _x} forEach assignedItems _unit;
removeAllItemsWithMagazines _unit;
{_unit removeWeaponGlobal _x} forEach weapons _unit;
removeHeadgear _unit;
//_Pweapon = primaryWeapon _unit;
//_Sweapon = secondaryWeapon _unit;

_unit action ["GetOut",_truck];
[_unit] orderGetin false;
//sleep 3;

//if (_Pweapon != "") then {_unit action ["DropWeapon",_truck,_Pweapon]; sleep 3};
//if (_Sweapon != "") then {_unit action ["DropWeapon",_truck,_Sweapon]};

_continuar = true;

while {_continuar and ([_unit] call A3A_fnc_canFight) and (_unit getVariable "rearming") and (alive _truck) and (_bigTimeout > time)} do
	{
	if (isNull _target) exitWith {_continuar = false};
	_target setVariable ["busy",true];
	_unit doMove (getPosATL _target);
	_timeOut = time + 60;
	waitUntil {sleep 1; (!alive _unit) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
	if (_unit distance _target < 3) then
		{
		_unit action ["TakeWeapon",_target,_weapon];
		sleep 3;
		};
	_target setVariable ["busy",false];
	_tempPrimary = primaryWeapon _unit;
	if (_tempPrimary != "") then
		{
		_magazines = getArray (configFile / "CfgWeapons" / _tempPrimary / "magazines");
		_nearbyDead = allDead select {(_x distance _unit < 51) and (!(_x getVariable ["busy",false]))};
		_hasBox = false;
		_distance = 51;
		{
		_dead = _x;
		if (({_x in _magazines} count (magazines _dead) > 0) and (_unit distance _dead < _distance)) then
			{
			_target = _dead;
			_hasBox = true;
			_distance = _dead distance _unit;
			};
		} forEach _nearbyDead;
		if ((_hasBox) and (_unit getVariable "rearming")) then
			{
			_unit stop false;
			_target setVariable ["busy",true];
			_unit doMove (getPosATL _target);
			_timeOut = time + 60;
			waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
			if (_unit distance _target < 3) then
				{
				{if (!(_x in unlockedMagazines) and !(_x in unlockedItems)) then {_unit addItemToUniform _x}} forEach (uniformItems _target);
				if (backPack _target != "") then
					{
					_unit addBackpack ((backpack _target) call BIS_fnc_basicBackpack);
					{if (!(_x in unlockedMagazines) and !(_x in unlockedItems)) then {_unit addItemToBackpack _x}} forEach backpackItems _target;
					removeBackpack _target;
					};
				_unit addVest (vest _target);
				{if (!(_x in unlockedMagazines) and !(_x in unlockedItems)) then {_unit addItemToVest _x}} forEach vestItems _target;
				_unit action ["rearm",_target];
				removeVest _target;
				if (((headgear _target) in helmets) and !((headgear _target) in unlockedItems)) then
					{
					_unit addHeadgear (headGear _target);
					removeHeadgear _target;
					};
				{if !(_x in unlockedItems) then {_unit linkItem _x}} forEach assignedItems _target;
				{if !(_x in unlockedItems) then {_target unlinkItem _x}} forEach assignedItems _target;
				/*
				_targetLoadout = getUnitLoadout _target; diag_log format ["Target: %1",_targetLoadout];
				_currentLoadout = getUnitLoadout _unit; diag_log format ["Unit current: %1",_currentLoadout];
				_unit setUnitLoadout [_currentLoadout select 0,_currentLoadout select 1,_targetLoadout select 2,[(_currentLoadout select 3) select 0,(_targetLoadout select 3) select 1],_targetLoadout select 4,_targetLoadout select 4,_targetLoadout select 5,_currentLoadout select 6,_targetLoadout select 7]; diag_log format ["Unit new: %1",getUnitLoadout _unit];
				*/
				};
			_target setVariable ["busy",false];
			};
		};

	_unit doMove (getPosATL _truck);
	_timeOut = time + 60;
	waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (!alive _truck) or (_unit distance _truck < 8) or (_timeOut < time)};
	if ((alive _truck) and ([_unit] call A3A_fnc_canFight)) then
		{
		if (_tempPrimary != "") then
			{
			_unit action ["DropWeapon",_truck,_tempPrimary];
			sleep 3;
			};
		if (secondaryWeapon _unit != "") then
			{
			_unit action ["DropWeapon",_truck,secondaryWeapon _unit];
			sleep 3;
			};
		{_truck addItemCargoGlobal [_x,1]} forEach ((assignedItems _unit) + (vestItems _unit) + (backPackItems _unit) + [headgear _unit,backpack _unit,vest _unit]);
		removeBackpackGlobal _unit;
		removeVest _unit;
		{_unit unlinkItem _x} forEach assignedItems _unit;
		removeAllItemsWithMagazines _unit;
		{_unit removeWeaponGlobal _x} forEach weapons _unit;
		removeHeadgear _unit;
		};
	_target = objNull;
	_distance = 51;
	{
	_object = _x;
	if (_unit distance _object < _distance) then
		{
		if ((count weaponCargo _object > 0) and !(_object getVariable ["busy",false])) then
			{
			_weapons = weaponCargo _object;
			for "_i" from 0 to (count _weapons - 1) do
				{
				_posible = _weapons select _i;
				_basePosible = [_posible] call BIS_fnc_baseWeapon;
				if ((not(_basePosible in unlockedWeapons)) and ((_basePosible in arifles) or (_basePosible in srifles) or (_basePosible in mguns) or (_posible in mlaunchers) or (_posible in rlaunchers))) then
					{
					_target = _object;
					_distance = _unit distance _object;
					_weapon = _posible;
					};
				};
			};
		};
	} forEach _objects;
	};
if (!_continuar) then
	{
	_unit groupChat "No more weapons to loot"
	};
//if (primaryWeapon _unit == "") then {_unit action ["TakeWeapon",_truck,_Pweapon]; sleep 3};
//if ((secondaryWeapon _unit == "") and (_Sweapon != "")) then {_unit action ["TakeWeapon",_truck,_Sweapon]};
_unit doFollow player;
_unit setVariable ["rearming",false];
_unit setUnitLoadout _originalLoadout;
