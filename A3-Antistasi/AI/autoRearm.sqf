private ["_unit","_Pweapon","_Sweapon","_count","_magazines","_hasBox","_distance","_objects","_target","_dead","_check","_timeOut","_weapon","_weapons","_rearming","_basePosible","_hmd","_helmet","_truck","_autoLoot","_itemsUnit"];

_unit = _this select 0;

if (isPlayer _unit) exitWith {};
if !([_unit] call A3A_fnc_canFight) exitWith {};
_inPlayerGroup = (isPlayer (leader _unit));
//_ayudando = _unit getVariable "ayudando";
if (_unit getVariable ["ayudando",false]) exitWith {if (_inPlayerGroup) then {_unit groupChat "I cannot rearm right now. I'm healing a comrade"}};
_rearming = _unit getVariable ["rearming",false];
if (_rearming) exitWith {if (_inPlayerGroup) then {_unit groupChat "I am currently rearming. Cancelling."; _unit setVariable ["rearming",false]}};
if (vehicle _unit != _unit) exitWith {};
_unit setVariable ["rearming",true];

_Pweapon = primaryWeapon _unit;
_Sweapon = secondaryWeapon _unit;

_objects = [];
_hasBox = false;
_weapon = "";
_weapons = [];
_distance = 51;
_objects = nearestObjects [_unit, ["ReammoBox_F","LandVehicle","WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"], 50];
if (caja in _objects) then {_objects = _objects - [caja]};

_required = false;

if ((_Pweapon in initialRifles) or (_Pweapon == "")) then
	{
	_required = true;
	if (count _objects > 0) then
		{
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
					if ((not(_basePosible in ["hgun_PDW2000_F","hgun_Pistol_01_F","hgun_ACPC2_F","arifle_AKM_F","arifle_AKS_F","SMG_05_F","LMG_03_F"])) and ((_basePosible in arifles) or (_basePosible in srifles) or (_basePosible in mguns))) then
						{
						_target = _object;
						_hasBox = true;
						_distance = _unit distance _object;
						_weapon = _posible;
						};
					};
				};
			};
		} forEach _objects;
		};
	if ((_hasBox) and (_unit getVariable "rearming")) then
		{
		_unit stop false;
		if ((!alive _target) or (not(_target isKindOf "ReammoBox_F"))) then {_target setVariable ["busy",true]};
		_unit doMove (getPosATL _target);
		if (_inPlayerGroup) then {_unit groupChat "Picking a better weapon"};
		_timeOut = time + 60;
		waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if ((unitReady _unit) and ([_unit] call A3A_fnc_canFight) and (_unit distance _target > 3) and (_target isKindOf "ReammoBox_F") and (!isNull _target)) then {_unit setPos position _target};
		if (_unit distance _target < 3) then
			{
			_unit action ["TakeWeapon",_target,_weapon];
			sleep 5;
			if (primaryWeapon _unit == _weapon) then
				{
				if (_inPlayerGroup) then {_unit groupChat "I have a better weapon now"};
				if (_target isKindOf "ReammoBox_F") then {_unit action ["rearm",_target]};
				};
			};
		_target setVariable ["busy",false];
		};
	_distance = 51;
	_Pweapon = primaryWeapon _unit;
	sleep 3;
	};
_hasBox = false;
_count = 4;
if (_Pweapon in mguns) then {_count = 2};
_magazines = getArray (configFile / "CfgWeapons" / _Pweapon / "magazines");
if ({_x in _magazines} count (magazines _unit) < _count) then
	{
	_required = true;
	_hasBox = false;
	if (count _objects > 0) then
		{
		{
		_object = _x;
		if (({_x in _magazines} count magazineCargo _object) > 0) then
			{
			if (_unit distance _object < _distance) then
				{
				_target = _object;
				_hasBox = true;
				_distance = _unit distance _object;
				};
			};
		} forEach _objects;
		};
	_nearbyDead = allDead select {(_x distance _unit < 51) and (!(_x getVariable ["busy",false]))};
	{
	_dead = _x;
	if (({_x in _magazines} count (magazines _dead) > 0) and (_unit distance _dead < _distance)) then
		{
		_target = _dead;
		_hasBox = true;
		_distance = _dead distance _unit;
		};
	} forEach _nearbyDead;
	};
if ((_hasBox) and (_unit getVariable "rearming")) then
	{
	_unit stop false;
	if ((!alive _target) or (not(_target isKindOf "ReammoBox_F"))) then {_target setVariable ["busy",true]};
	_unit doMove (getPosATL _target);
	if (_inPlayerGroup) then {_unit groupChat "Rearming"};
	_timeOut = time + 60;
	waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
	if ((unitReady _unit) and ([_unit] call A3A_fnc_canFight) and (_unit distance _target > 3) and (_target isKindOf "ReammoBox_F") and (!isNull _target)) then {_unit setPos position _target};
	if (_unit distance _target < 3) then
		{
		_unit action ["rearm",_target];
		if ({_x in _magazines} count (magazines _unit) >= _count) then
			{
			if (_inPlayerGroup) then {_unit groupChat "Rearmed"};
			}
		else
			{
			if (_inPlayerGroup) then {_unit groupChat "Partially Rearmed"};
			};
		};
	_target setVariable ["busy",false];
	}
else
	{
	if (_inPlayerGroup) then {_unit groupChat "No source to rearm my primary weapon"};
	};
_hasBox = false;
if ((_Sweapon == "") and (loadAbs _unit < 340)) then
	{
	if (count _objects > 0) then
		{
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
					if ((_posible in mlaunchers) or (_posible in rlaunchers)) then
						{
						_target = _object;
						_hasBox = true;
						_distance = _unit distance _object;
						_weapon = _posible;
						};
					};
				};
			};
		} forEach _objects;
		};
	if ((_hasBox) and (_unit getVariable "rearming")) then
		{
		_unit stop false;
		if ((!alive _target) or (not(_target isKindOf "ReammoBox_F"))) then {_target setVariable ["busy",true]};
		_unit doMove (getPosATL _target);
		if (_inPlayerGroup) then {_unit groupChat "Picking a secondary weapon"};
		_timeOut = time + 60;
		waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if ((unitReady _unit) and ([_unit] call A3A_fnc_canFight) and (_unit distance _target > 3) and (_target isKindOf "ReammoBox_F") and (!isNull _target)) then {_unit setPos position _target};
		if (_unit distance _target < 3) then
			{
			_unit action ["TakeWeapon",_target,_weapon];
			sleep 3;
			if (secondaryWeapon _unit == _weapon) then
				{
				if (_inPlayerGroup) then {_unit groupChat "I have a secondary weapon now"};
				if (_target isKindOf "ReammoBox_F") then {sleep 3;_unit action ["rearm",_target]};
				};
			};
		_target setVariable ["busy",false];
		};
	_Sweapon = secondaryWeapon _unit;
	_distance = 51;
	sleep 3;
	};
_hasBox = false;
if (_Sweapon != "") then
	{
	_magazines = getArray (configFile / "CfgWeapons" / _Sweapon / "magazines");
	if ({_x in _magazines} count (magazines _unit) < 2) then
		{
		_required = true;
		_hasBox = false;
		_distance = 50;
		if (count _objects > 0) then
			{
			{
			_object = _x;
			if ({_x in _magazines} count magazineCargo _object > 0) then
				{
				if (_unit distance _object < _distance) then
					{
					_target = _object;
					_hasBox = true;
					_distance = _unit distance _object;
					};
				};
			} forEach _objects;
			};
		_nearbyDead = allDead select {(_x distance _unit < 51) and (!(_x getVariable ["busy",false]))};
		{
		_dead = _x;
		if (({_x in _magazines} count (magazines _dead) > 0) and (_unit distance _dead < _distance)) then
			{
			_target = _dead;
			_hasBox = true;
			_distance = _dead distance _unit;
			};
		} forEach _nearbyDead;
		};
	if ((_hasBox) and (_unit getVariable "rearming")) then
		{
		_unit stop false;
		if (!alive _target) then {_target setVariable ["busy",true]};
		_unit doMove (position _target);
		if (_inPlayerGroup) then {_unit groupChat "Rearming"};
		_timeOut = time + 60;
		waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if ((unitReady _unit) and ([_unit] call A3A_fnc_canFight) and (_unit distance _target > 3) and (_target isKindOf "ReammoBox_F") and (!isNull _target)) then {_unit setPos position _target};
		if (_unit distance _target < 3) then
			{
			if ((backpack _unit == "") and (backPack _target != "")) then
				{
				_unit addBackPackGlobal ((backpack _target) call BIS_fnc_basicBackpack);
				_unit action ["rearm",_target];
				sleep 3;
				{_unit addItemToBackpack _x} forEach (backpackItems _target);
				removeBackpackGlobal _target;
				}
			else
				{
				_unit action ["rearm",_target];
				};

			if ({_x in _magazines} count (magazines _unit) >= 2) then
				{
				if (_inPlayerGroup) then {_unit groupChat "Rearmed"};
				}
			else
				{
				if (_inPlayerGroup) then {_unit groupChat "Partially Rearmed"};
				};
			};
		_target setVariable ["busy",false];
		}
	else
		{
		if (_inPlayerGroup) then {_unit groupChat "No source to rearm my secondary weapon"};
		};
	sleep 3;
	};
_hasBox = false;
if ((not("ItemRadio" in assignedItems _unit)) and !haveRadio) then
	{
	_required = true;
	_hasBox = false;
	_distance = 50;
	_nearbyDead = allDead select {(_x distance _unit < 51) and (!(_x getVariable ["busy",false]))};
	{
	_dead = _x;
	if (("ItemRadio" in (assignedItems _dead)) and (_unit distance _dead < _distance)) then
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
		if (_inPlayerGroup) then {_unit groupChat "Picking a Radio"};
		_timeOut = time + 60;
		waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if (_unit distance _target < 3) then
			{
			_unit action ["rearm",_target];
			_unit linkItem "ItemRadio";
			_target unlinkItem "ItemRadio";
			};
		_target setVariable ["busy",false];
		};
	};
_hasBox = false;
if (hmd _unit == "") then
	{
	_required = true;
	_hasBox = false;
	_distance = 50;
	_nearbyDead = allDead select {(_x distance _unit < 51) and (!(_x getVariable ["busy",false]))};
	{
	_dead = _x;
	if ((hmd _dead != "") and (_unit distance _dead < _distance)) then
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
		_hmd = hmd _target;
		_unit doMove (getPosATL _target);
		if (_inPlayerGroup) then {_unit groupChat "Picking NV Googles"};
		_timeOut = time + 60;
		waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if (_unit distance _target < 3) then
			{
			_unit action ["rearm",_target];
			_unit linkItem _hmd;
			_target unlinkItem _hmd;
			};
		_target setVariable ["busy",false];
		};
	};
_hasBox = false;
if (not(headgear _unit in helmets)) then
	{
	_required = true;
	_hasBox = false;
	_distance = 50;
	_nearbyDead = allDead select {(_x distance _unit < 51) and (!(_x getVariable ["busy",false]))};
	{
	_dead = _x;
	if (((headgear _dead) in helmets) and (_unit distance _dead < _distance)) then
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
		_helmet = headgear _target;
		_unit doMove (getPosATL _target);
		if (_inPlayerGroup) then {_unit groupChat "Picking a Helmet"};
		_timeOut = time + 60;
		waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if (_unit distance _target < 3) then
			{
			_unit action ["rearm",_target];
			_unit addHeadgear _helmet;
			removeHeadgear _target;
			};
		_target setVariable ["busy",false];
		};
	};
_hasBox = false;
_minFA = if ([_unit] call A3A_fnc_isMedic) then {10} else {1};

if ({_x == "FirstAidKit"} count (items _unit) < _minFA) then
	{
	_required = true;
	_hasBox = false;
	_distance = 50;
	_nearbyDead = allDead select {(_x distance _unit < 51) and (!(_x getVariable ["busy",false]))};
	{
	_dead = _x;
	if (("FirstAidKit" in items _dead) and (_unit distance _dead < _distance)) then
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
		if (_inPlayerGroup) then {_unit groupChat "Picking a First Aid Kit"};
		_timeOut = time + 60;
		waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if (_unit distance _target < 3) then
			{
			while {{_x == "FirstAidKit"} count (items _unit) < _minFA} do
				{
				_unit action ["rearm",_target];
				_unit addItem "FirstAidKit";
				_target removeItem "FirstAidKit";
				if ("FirstAidKit" in items _dead) then {sleep 3};
				};
			};
		_target setVariable ["busy",false];
		};
	};
_hasBox = false;
_number = getNumber (configfile >> "CfgWeapons" >> vest cursortarget >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Chest" >> "armor");
_distance = 50;
_nearbyDead = allDead select {(_x distance _unit < 51) and (!(_x getVariable ["busy",false]))};
{
_dead = _x;
if ((getNumber (configfile >> "CfgWeapons" >> vest _dead >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Chest" >> "armor") > _number) and (_unit distance _dead < _distance)) then
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
	if (_inPlayerGroup) then {_unit groupChat "Picking a a better vest"};
	_timeOut = time + 60;
	waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
	if (_unit distance _target < 3) then
		{
		_itemsUnit = vestItems _unit;
		_unit addVest (vest _target);
		{_unit addItemToVest _x} forEach _itemsUnit;
		_unit action ["rearm",_target];
		//{_unit addItemCargoGlobal [_x,1]} forEach ((backpackItems _target) + (backpackMagazines _target));
		_things = nearestObjects [_target, ["WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"], 5];
		if (count _things > 0) then
			{
			_thing = _things select 0;
			{_thing addItemCargoGlobal [_x,1]} forEach (vestItems _target);
			};
		removeVest _target;
		};
	_target setVariable ["busy",false];
	};

if (backpack _unit == "") then
	{
	_required = true;
	_hasBox = false;
	_distance = 50;
	_nearbyDead = allDead select {(_x distance _unit < 51) and (!(_x getVariable ["busy",false]))};
	{
	_dead = _x;
	if ((backpack _dead != "") and (_unit distance _dead < _distance)) then
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
		if (_inPlayerGroup) then {_unit groupChat "Picking a Backpack"};
		_timeOut = time + 60;
		waitUntil {sleep 1; !([_unit] call A3A_fnc_canFight) or (isNull _target) or (_unit distance _target < 3) or (_timeOut < time) or (unitReady _unit)};
		if (_unit distance _target < 3) then
			{
			_unit addBackPackGlobal ((backpack _target) call BIS_fnc_basicBackpack);
			_unit action ["rearm",_target];
			//{_unit addItemCargoGlobal [_x,1]} forEach ((backpackItems _target) + (backpackMagazines _target));
			_things = nearestObjects [_target, ["WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"], 5];
			if (count _things > 0) then
				{
				_thing = _things select 0;
				{_thing addItemCargoGlobal [_x,1]} forEach (backpackItems _target);
				};
			removeBackpackGlobal _target;
			};
		_target setVariable ["busy",false];
		};
	};
_unit doFollow (leader _unit);
if (!_required) then {if (_inPlayerGroup) then {_unit groupChat "No need to rearm"}} else {if (_inPlayerGroup) then {_unit groupChat "Rearming Done"}};
_unit setVariable ["rearming",false];
