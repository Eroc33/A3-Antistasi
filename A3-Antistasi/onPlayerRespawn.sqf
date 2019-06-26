if (isDedicated) exitWith {};
private ["_new","_old"];
_new = _this select 0;
_old = _this select 1;

if (isNull _old) exitWith {};

waitUntil {alive player};

_nul = [_old] spawn A3A_fnc_postmortem;
if !(foundACEMedical) then
	{
	_old setVariable ["INCAPACITATED",false,true];
	_new setVariable ["INCAPACITATED",false,true];
	};
if (side group player == good) then
	{
	_owner = _old getVariable ["owner",_old];

	if (_owner != _old) exitWith {hint "Died while remote controlling AI"; selectPlayer _owner; disableUserInput false; deleteVehicle _new};

	_nul = [0,-1,getPos _old] remoteExec ["A3A_fnc_citySupportChange",2];

	_score = _old getVariable ["score",0];
	_punish = _old getVariable ["punish",0];
	_money = _old getVariable ["dinero",0];
	_money = round (_money - (_money * 0.1));
	_elegible = _old getVariable ["elegible",true];
	_rank = _old getVariable ["rango","PRIVATE"];

	_money = round (_money - (_money * 0.05));
	if (_money < 0) then {_money = 0};

	_new setVariable ["score",_score -1,true];
	_new setVariable ["owner",_new,true];
	_new setVariable ["punish",_punish,true];
	_new setVariable ["respawning",false];
	_new setVariable ["dinero",_money,true];
	//_new setUnitRank (rank _old);
	_new setVariable ["compromised",0];
	_new setVariable ["elegible",_elegible,true];
	_new setVariable ["spawner",true,true];
	_old setVariable ["spawner",nil,true];
	[_new,false] remoteExec ["setCaptive",0,_new];
	_new setCaptive false;
	_new setRank (_rank);
	_new setVariable ["rango",_rank,true];
	_new setUnitTrait ["camouflageCoef",0.8];
	_new setUnitTrait ["audibleCoef",0.8];
	{
    _new addOwnedMine _x;
    } count (getAllOwnedMines (_old));

	//if (!foundACEMedical) then {[_new] call A3A_fnc_initRevive};
	disableUserInput false;
	//_new enableSimulation true;
	if (_old == theBoss) then
		{
		[_new] call A3A_fnc_theBossInit;
		};


	removeAllItemsWithMagazines _new;
	{_new removeWeaponGlobal _x} forEach weapons _new;
	removeBackpackGlobal _new;
	removeVest _new;
	if ((not("ItemGPS" in unlockedItems)) and ("ItemGPS" in (assignedItems _new))) then {_new unlinkItem "ItemGPS"};
	if ((!foundTFAR) and (!foundACRE) and ("ItemRadio" in (assignedItems player)) and (!haveRadio)) then {player unlinkItem "ItemRadio"};
	if (!isPlayer (leader group player)) then {(group player) selectLeader player};
	player addEventHandler ["FIRED",
		{
		_player = _this select 0;
		if (captive _player) then
			{
			if ({if (((side _x == bad) or (side _x == veryBad)) and (_x distance player < 300)) exitWith {1}} count allUnits > 0) then
				{
				[_player,false] remoteExec ["setCaptive",0,_player];
				_player setCaptive false;
				}
			else
				{
				_city = [ciudades,_player] call BIS_fnc_nearestPosition;
				_size = [_city] call A3A_fnc_sizeMarker;
				_data = server getVariable _city;
				if (random 100 < _data select 2) then
					{
					if (_player distance getMarkerPos _city < _size * 1.5) then
						{
						[_player,false] remoteExec ["setCaptive",0,_player];
						_player setCaptive false;
						if (vehicle _player != _player) then
							{
							{if (isPlayer _x) then {[_x,false] remoteExec ["setCaptive",0,_x]; _x setCaptive false}} forEach ((assignedCargo (vehicle _player)) + (crew (vehicle _player)) - [_player]);
							};
						};
					};
				};
			}
		}
		];

	player addEventHandler ["InventoryOpened",
		{
		private ["_player","_container","_type"];
		_control = false;
		_player = _this select 0;
		if (captive _player) then
			{
			_container = _this select 1;
			_type = typeOf _container;
			if (((_container isKindOf "Man") and (!alive _container)) or (_type == NATOAmmoBox) or (_type == CSATAmmoBox)) then
				{
				if ({if (((side _x== veryBad) or (side _x== bad)) and (_x knowsAbout _player > 1.4)) exitWith {1}} count allUnits > 0) then
					{
					[_player,false] remoteExec ["setCaptive",0,_player];
					_player setCaptive false;
					}
				else
					{
					_city = [ciudades,_player] call BIS_fnc_nearestPosition;
					_size = [_city] call A3A_fnc_sizeMarker;
					_data = server getVariable _city;
					if (random 100 < _data select 2) then
						{
						if (_player distance getMarkerPos _city < _size * 1.5) then
							{
							[_player,false] remoteExec ["setCaptive",0,_player];
							_player setCaptive false;
							};
						};
					};
				};
			};
		_control
		}];
	/*
	player addEventHandler ["InventoryClosed",
		{
		_control = false;
		_uniform = uniform player;
		_typeSoldier = getText (configfile >> "CfgWeapons" >> _uniform >> "ItemInfo" >> "uniformClass");
		_sideType = getNumber (configfile >> "CfgVehicles" >> _typeSoldier >> "side");
		if ((_sideType == 1) or (_sideType == 0) and (_uniform != "")) then
			{
			if !(player getVariable ["disfrazado",false]) then
				{
				hint "You are wearing an enemy uniform, this will make the AI attack you. Beware!";
				player setVariable ["disfrazado",true];
				player addRating (-1*(2001 + rating player));
				};
			}
		else
			{
			if (player getVariable ["disfrazado",false]) then
				{
				hint "You removed your enemy uniform";
				player addRating (rating player * -1);
				};
			};
		_control
		}];
		*/
	if (tkPunish) then
		{
		player addEventHandler ["Fired",
				{
				_type = _this select 1;
				if ((_type == "Put") or (_type == "Throw")) then
					{
					if (player distance petros < 50) then
						{
						deleteVehicle (_this select 6);
						if (_type == "Put") then
							{
							if (player distance petros < 10) then {[player,60] spawn A3A_fnc_castigo};
							};
						};
					};
				}];
		};
	player addEventHandler ["HandleHeal",
		{
		_player = _this select 0;
		if (captive _player) then
			{
			if ({((side _x== veryBad) or (side _x== bad)) and (_x knowsAbout player > 1.4)} count allUnits > 0) then
				{
				[_player,false] remoteExec ["setCaptive",0,_player];
				_player setCaptive false;
				}
			else
				{
				_city = [ciudades,_player] call BIS_fnc_nearestPosition;
				_size = [_city] call A3A_fnc_sizeMarker;
				_data = server getVariable _city;
				if (random 100 < _data select 2) then
					{
					if (_player distance getMarkerPos _city < _size * 1.5) then
						{
						[_player,false] remoteExec ["setCaptive",0,_player];
						_player setCaptive false;
						};
					};
				};
			}
		}
		];
	player addEventHandler ["WeaponAssembled",
		{
		private ["_veh"];
		_veh = _this select 1;
		if (_veh isKindOf "StaticWeapon") then
			{
			if (not(_veh in staticsToSave)) then
				{
				staticsToSave pushBack _veh;
				publicVariable "staticsToSave";
				[_veh] call A3A_fnc_AIVEHinit;
				};
			}
		else
			{
			_veh addEventHandler ["Killed",{[_this select 0] remoteExec ["A3A_fnc_postmortem",2]}];
			};
		}];
	player addEventHandler ["WeaponDisassembled",
			{
			_bag1 = _this select 1;
			_bag2 = _this select 2;
			//_bag1 = objectParent (_this select 1);
			//_bag2 = objectParent (_this select 2);
			[_bag1] call A3A_fnc_AIVEHinit;
			[_bag2] call A3A_fnc_AIVEHinit;
			}
		];
	[true] execVM "reinitY.sqf";
	[player] execVM "OrgPlayers\unitTraits.sqf";
	[] spawn A3A_fnc_statistics;
	}
else
	{
	_old setVariable ["spawner",nil,true];
	_new setVariable ["spawner",true,true];
	if (foundRHS) then {[player] call A3A_fnc_RHSdress};
	if (foundACE) then {[] call A3A_fnc_ACEpvpReDress};
	};
