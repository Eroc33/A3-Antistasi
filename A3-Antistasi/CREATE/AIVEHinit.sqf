private ["_veh","_type"];

_veh = _this select 0;
if (isNil "_veh") exitWith {};
if ((_veh isKindOf "FlagCarrier") or (_veh isKindOf "Building") or (_veh isKindOf "ReammoBox_F")) exitWith {};
//if (_veh isKindOf "ReammoBox_F") exitWith {[_veh] call A3A_fnc_NATOcrate};

_type = typeOf _veh;

if ((_type in vehNormal) or (_type in vehAttack) or (_type in vehBoats)) then
	{
	_veh addEventHandler ["Killed",
		{
		private _veh = _this select 0;
		(typeOf _veh) call A3A_fnc_removeVehFromPool;
		_veh removeAllEventHandlers "HandleDamage";
		}];
	if !(_type in vehAttack) then
		{
		if (_type in vehAmmoTrucks) then
			{
			if (_veh distance getMarkerPos respawnGood > 50) then {if (_type == vehNatoAmmoTruck) then {_nul = [_veh] call A3A_fnc_NATOcrate} else {_nul = [_veh] call A3A_fnc_CSATcrate}};
			};
		if (_veh isKindOf "Car") then
			{
			_veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and ((_this select 4=="") or (side (_this select 3) != good)) and (!isPlayer driver (_this select 0))) then {0} else {(_this select 2)}}];
			if ({"SmokeLauncher" in (_veh weaponsTurret _x)} count (allTurrets _veh) > 0) then
				{
				_veh setVariable ["dentro",true];
				_veh addEventHandler ["GetOut", {private ["_veh"]; _veh = _this select 0; if (side (_this select 2) != good) then {if (_veh getVariable "dentro") then {_veh setVariable ["dentro",false]; [_veh] call A3A_fnc_smokeCoverAuto}}}];
				_veh addEventHandler ["GetIn", {private ["_veh"]; _veh = _this select 0; if (side (_this select 2) != good) then {_veh setVariable ["dentro",true]}}];
				};
			};
		}
	else
		{
		if (_type in vehAPCs) then
			{
			_veh addEventHandler ["killed",
				{
				private ["_veh","_type"];
				_veh = _this select 0;
				_type = typeOf _veh;
				if (side (_this select 1) == good) then
					{
					if (_type in vehNATOAPC) then {[-2,2,position (_veh)] remoteExec ["A3A_fnc_citySupportChange",2]};
					};
				}];
			_veh addEventHandler ["HandleDamage",{private ["_veh"]; _veh = _this select 0; if (!canFire _veh) then {[_veh] call A3A_fnc_smokeCoverAuto; _veh removeEventHandler ["HandleDamage",_thisEventHandler]};if (((_this select 1) find "wheel" != -1) and (_this select 4=="") and (!isPlayer driver (_veh))) then {0;} else {(_this select 2);}}];
			_veh setVariable ["dentro",true];
			_veh addEventHandler ["GetOut", {private ["_veh"];  _veh = _this select 0; if (side (_this select 2) != good) then {if (_veh getVariable "dentro") then {_veh setVariable ["dentro",false];[_veh] call A3A_fnc_smokeCoverAuto}}}];
			_veh addEventHandler ["GetIn", {private ["_veh"];_veh = _this select 0; if (side (_this select 2) != good) then {_veh setVariable ["dentro",true]}}];
			}
		else
			{
			if (_type in vehTanks) then
				{
				_veh addEventHandler ["killed",
					{
					private ["_veh","_type"];
					_veh = _this select 0;
					_type = typeOf _veh;
					if (side (_this select 1) == good) then
						{
						if (_type == vehNATOTank) then {[-5,5,position (_veh)] remoteExec ["A3A_fnc_citySupportChange",2]};
						};
					}];
				_veh addEventHandler ["HandleDamage",{private ["_veh"]; _veh = _this select 0; if (!canFire _veh) then {[_veh] call A3A_fnc_smokeCoverAuto;  _veh removeEventHandler ["HandleDamage",_thisEventHandler]}}];
				}
			else
				{
				_veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and ((_this select 4=="") or (side (_this select 3) != good)) and (!isPlayer driver (_this select 0))) then {0} else {(_this select 2)}}];
				};
			};
		};
	}
else
	{
	if (_type in vehPlanes) then
		{
		_veh addEventHandler ["killed",
			{
			private ["_veh","_type"];
			_veh = _this select 0;
			(typeOf _veh) call A3A_fnc_removeVehFromPool;
			}];
		_veh addEventHandler ["GetIn",
			{
			_position = _this select 1;
			if (_position == "driver") then
				{
				_unit = _this select 2;
				if ((!isPlayer _unit) and (_unit getVariable ["spawner",false]) and (side group _unit == good)) then
					{
					moveOut _unit;
					hint "Only Humans can pilot an air vehicle";
					};
				};
			}];
		if (_veh isKindOf "Helicopter") then
			{
			if (_type in vehTransportAir) then
				{
				_veh setVariable ["dentro",true];
				_veh addEventHandler ["GetOut", {private ["_veh"];_veh = _this select 0; if ((isTouchingGround _veh) and (isEngineOn _veh)) then {if (side (_this select 2) != good) then {if (_veh getVariable "dentro") then {_veh setVariable ["dentro",false]; [_veh] call A3A_fnc_smokeCoverAuto}}}}];
				_veh addEventHandler ["GetIn", {private ["_veh"];_veh = _this select 0; if (side (_this select 2) != good) then {_veh setVariable ["dentro",true]}}];
				}
			else
				{
				_veh addEventHandler ["killed",
					{
					private ["_veh","_type"];
					_veh = _this select 0;
					_type = typeOf _veh;
					if (side (_this select 1) == good) then
						{
						if (_type in vehNATOAttackHelis) then {[-5,5,position (_veh)] remoteExec ["A3A_fnc_citySupportChange",2]};
						};
					}];
				};
			};
		if (_veh isKindOf "Plane") then
			{
			_veh addEventHandler ["killed",
				{
				private ["_veh","_type"];
				_veh = _this select 0;
				_type = typeOf _veh;
				if (side (_this select 1) == good) then
					{
					if ((_type == vehNATOPlane) or (_type == vehNATOPlaneAA)) then {[-8,8,position (_veh)] remoteExec ["A3A_fnc_citySupportChange",2]};
					};
				}];
			};
		}
	else
		{
		if (_veh isKindOf "StaticWeapon") then
			{
			_veh setCenterOfMass [(getCenterOfMass _veh) vectorAdd [0, 0, -1], 0];
			if ((not (_veh in staticsToSave)) and (side gunner _veh != good)) then
				{
				if (activeGREF and ((_type == staticATBuenos) or (_type == staticAABuenos))) then {[_veh,"moveS"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_veh]} else {[_veh,"steal"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_veh]};
				};
			if (_type == SDKMortar) then
				{
				if (!isNull gunner _veh) then
					{
					[_veh,"steal"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_veh];
					};
				_veh addEventHandler ["Fired",
					{
					_mortar = _this select 0;
					_data = _mortar getVariable ["detection",[position _mortar,0]];
					_position = position _mortar;
					_chance = _data select 1;
					if ((_position distance (_data select 0)) < 300) then
						{
						_chance = _chance + 2;
						}
					else
						{
						_chance = 0;
						};
					if (random 100 < _chance) then
						{
						{if ((side _x == bad) or (side _x == veryBad)) then {_x reveal [_mortar,4]}} forEach allUnits;
						if (_mortar distance posHQ < 300) then
							{
							if (!(["DEF_HQ"] call BIS_fnc_taskExists)) then
								{
								_leader = leader (gunner _mortar);
								if (!isPlayer _leader) then
									{
									[[],"A3A_fnc_ataqueHQ"] remoteExec ["A3A_fnc_scheduler",2];
									}
								else
									{
									if ([_leader] call A3A_fnc_isMember) then {[[],"A3A_fnc_ataqueHQ"] remoteExec ["A3A_fnc_scheduler",2]};
									};
								};
							}
						else
							{
							_bases = airports select {(getMarkerPos _x distance _mortar < distanceForAirAttack) and ([_x,true] call A3A_fnc_airportCanAttack) and (sides getVariable [_x,sideUnknown] != good)};
							if (count _bases > 0) then
								{
								_base = [_bases,_position] call BIS_fnc_nearestPosition;
								_side = sides getVariable [_base,sideUnknown];
								[[getPosASL _mortar,_side,"Normal",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2];
								};
							};
						};
					_mortar setVariable ["detection",[_position,_chance]];
					}];
				}
			else
				{
				_veh addEventHandler ["killed",
					{
					private ["_veh","_type"];
					_veh = _this select 0;
					(typeOf _veh) call A3A_fnc_removeVehFromPool;
					}];
				};
			}
		else
			{
			if ((_type in vehAA) or (_type in vehMRLS)) then
				{
				_veh addEventHandler ["killed",
					{
					private ["_veh","_type"];
					_veh = _this select 0;
					_type = typeOf _veh;
					if (side (_this select 1) == good) then
						{
						if (_type == vehNATOAA) then {[-5,5,position (_veh)] remoteExec ["A3A_fnc_citySupportChange",2]};
						};
					_type call A3A_fnc_removeVehFromPool;
					}];
				};
			};
		};
	};

[_veh] spawn A3A_fnc_cleanserVeh;

_veh addEventHandler ["Killed",{[_this select 0] spawn A3A_fnc_postmortem}];

if (not(_veh in staticsToSave)) then
	{
	if (((count crew _veh) > 0) and (not (_type in vehAA)) and (not (_type in vehMRLS) and !(_veh isKindOf "StaticWeapon"))) then
		{
		[_veh] spawn A3A_fnc_VEHdespawner
		}
	else
		{
		_veh addEventHandler ["GetIn",
			{
			_unit = _this select 2;
			if ((side _unit == good) or (isPlayer _unit)) then {[_this select 0] spawn A3A_fnc_VEHdespawner};
			}
			];
		};
	if (_veh distance getMarkerPos respawnGood <= 50) then
		{
		clearMagazineCargoGlobal _veh;
		clearWeaponCargoGlobal _veh;
		clearItemCargoGlobal _veh;
		clearBackpackCargoGlobal _veh;
		};
	};
