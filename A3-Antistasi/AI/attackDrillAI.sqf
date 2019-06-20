private _group = _this;
_objectives = _group call A3A_fnc_enemyList;
_group setVariable ["objetivos",_objectives];
_group setVariable ["tarea","Patrol"];
private _side = side _group;
private _friendlies = if ((_side == bad) or (_side == good)) then {[_side,civilian]} else {[_side]};
_mortars = [];
_mgs = [];
_movable = [leader _group];
_baseOfFire = [leader _group];
_flankers = [];

{
if (alive _x) then
	{
	_result = _x call A3A_fnc_typeOfSoldier;
	_x setVariable ["maniobrando",false];
	if (_result == "Normal") then
		{
		_movable pushBack _x;
		_flankers pushBack _x;
		}
	else
		{
		if (_result == "StaticMortar") then
			{
			_mortars pushBack _x;
			}
		else
			{
			if (_result == "StaticGunner") then
				{
				_mgs pushBack _x;
				};
			_movable pushBack _x;
			_baseOfFire pushBack _x;
			};
		};
	};
} forEach (units _group);

if (count _mortars == 1) then
	{
	_mortars append ((units _group) select {_x getVariable ["typeOfSoldier",""] == "StaticBase"});
	if (count _mortars > 1) then
		{
		//_mortars spawn A3A_fnc_mortarDrill;
		_mortars spawn A3A_fnc_staticMGDrill;//no olvides borrar la otra funci??n si esto funciona
		}
	else
		{
		_movable pushBack (_mortars select 0);
		_flankers pushBack (_mortars select 0);
		};
	};
if (count _mgs == 1) then
	{
	_mgs append ((units _group) select {_x getVariable ["typeOfSoldier",""] == "StaticBase"});
	if (count _mgs == 2) then
		{
		_mgs spawn A3A_fnc_staticMGDrill;
		}
	else
		{
		_movable pushBack (_mgs select 0);
		_flankers pushBack (_mgs select 0);
		};
	};

_group setVariable ["movable",_movable];
_group setVariable ["baseOfFire",_baseOfFire];
_group setVariable ["flankers",_flankers];
if (side _group == good) then {_group setVariable ["autoRearmed",time + 300]};
{
if (vehicle _x != _x) then
	{
	if !(vehicle _x isKindOf "Air") then
		{
		if ((assignedVehicleRole _x) select 0 == "Cargo") then
			{
			if (isNull(_group getVariable ["transporte",objNull])) then {_group setVariable ["transporte",vehicle _x]};
			};
		};
	};
} forEach units _group;

while {true} do
	{
	if !(isPlayer (leader _group)) then
		{
		_movable = _movable select {[_x] call A3A_fnc_canFight};
		_baseOfFire = _baseOfFire select {[_x] call A3A_fnc_canFight};
		_flankers = _flankers select {[_x] call A3A_fnc_canFight};
		_objectives = _group call A3A_fnc_enemyList;
		_group setVariable ["objetivos",_objectives];
		if !(_objectives isEqualTo []) then
			{
			_air = objNull;
			_tanks = objNull;
			{
			_veh = assignedVehicle (_x select 4);
			if (_veh isKindOf "Tank") then
				{
				_tanks = _veh;
				}
			else
				{
				if (_veh isKindOf "Air") then
					{
					if (count (weapons _veh) > 1) then
						{
						_air = _veh;
						};
					};
				};
			if (!(isNull _air) and !(isNull _tanks)) exitWith {};
			} forEach _objectives;
			_leader = leader _group;
			_allNearFriends = allUnits select {(_x distance _leader < (distanceSPWN/2)) and (side group _x in _friendlies)};
			{
			_unit = _x;
			{
			_objective = _x select 4;
			if (_leader knowsAbout _objective >= 1.4) then
				{
				_know = _unit knowsAbout _objective;
				if (_know < 1.2) then {_unit reveal [_objective,(_know + 0.2)]};
				};
			} forEach _objectives;
			} forEach (_allNearFriends select {_x == leader _x}) - [_leader];
			_numNearFriends = count _allNearFriends;
			//_air = objNull;
			//_tanks = objNull;
			_numObjectives = count _objectives;
			_task = _group getVariable ["tarea","Patrol"];
			_near = _group call A3A_fnc_enemigoCercano;
			_soldiers = ((units _group) select {[_x] call A3A_fnc_canFight}) - [_group getVariable ["mortero",objNull]];
			_numSoldados = count _soldiers;
			if !(isNull _air) then
				{
				if (_allNearFriends findIf {(_x call A3A_fnc_typeOfSoldier == "AAMan") or (_x call A3A_fnc_typeOfSoldier == "StaticGunner")} == -1) then
					{
					if (_side != good) then {[[getPosASL _leader,_side,"Air",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2]};
					};
				//_nuevaTarea = ["Hide",_soldiers - (_soldiers select {(_x call A3A_fnc_typeOfSoldier == "AAMan") or (_x getVariable ["typeOfSoldier",""] == "StaticGunner")})];
				_group setVariable ["tarea","Hide"];
				_task = "Hide";
				};
			if !(isNull _tanks) then
				{
				if (_allNearFriends findIf {_x call A3A_fnc_typeOfSoldier == "ATMan"} == -1) then
					{
					_mortar = _group getVariable ["morteros",objNull];
					if (!(isNull _mortar) and ([_mortar] call A3A_fnc_canFight)) then
						{
						if ({if (_x distance _tanks < 100) exitWith {1}} count _allNearFriends == 0) then {[_mortar,getPosASL _tanks,4] spawn A3A_fnc_mortarSupport};
						}
					else
						{
						if (_side != good) then {[[getPosASL _leader,_side,"Tank",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2]};
						};
					};
				//_nuevaTarea = ["Hide",_soldiers - (_soldiers select {(_x getVariable ["typeOfSoldier",""] == "ATMan")})];
				_group setVariable ["tarea","Hide"];
				_task = "Hide";
				};
			if (_numObjectives > 2*_numNearFriends) then
				{
				if !(isNull _near) then
					{
					if (_side != good) then {[[getPosASL _leader,_side,"Normal",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2]};
					_mortar = _group getVariable ["morteros",objNull];
					if (!(isNull _mortar) and ([_mortar] call A3A_fnc_canFight)) then
						{
						if ({if (_x distance _near < 100) exitWith {1}} count _allNearFriends == 0) then {[_mortar,getPosASL _near,1] spawn A3A_fnc_mortarSupport};
						};
					};
				_group setVariable ["tarea","Hide"];
				_task = "Hide";
				};
			_transport = _group getVariable ["transporte",objNull];
			if (isNull(_group getVariable ["transporte",objNull])) then
				{
				_exit = false;
				{
				_veh = vehicle _x;
				if (_veh != _x) then
					{
					if !(_veh isKindOf "Air") then
						{
						if ((assignedVehicleRole _x) select 0 == "Cargo") then
							{
							_group setVariable ["transporte",_veh];
							_transport = _veh;
							_exit = true;
							};
						};
					};
				if (_exit) exitWith {};
				} forEach units _group;
				};
			if !(isNull(_transport)) then
				{
				if !(_transport isKindOf "Tank") then
					{
					_driver = driver (_transport);
					if !(isNull _driver) then
						{
						[_driver]  allowGetIn false;
						};
					};
				(units _group select {(assignedVehicleRole _x) select 0 == "Cargo"}) allowGetIn false;
				};

			if (_task == "Patrol") then
				{
				if ((_near distance _leader < 150) and !(isNull _near)) then
					{
					_group setVariable ["tarea","Assault"];
					_task = "Assault";
					}
				else
					{
					if (_numObjectives > 1) then
						{
						_mortar = _group getVariable ["morteros",objNull];
						if (!(isNull _mortar) and ([_mortar] call A3A_fnc_canFight)) then
							{
							if ({if (_x distance _near < 100) exitWith {1}} count _allNearFriends == 0) then {[_mortar,getPosASL _near,1] spawn A3A_fnc_mortarSupport};
							};
						};
					};
				};

			if (_task == "Assault") then
				{
				if (_near distance _leader < 50) then
					{
					_group setVariable ["tarea","AssaultClose"];
					_task = "AssaultClose";
					}
				else
					{
					if (_near distance _leader > 150) then
						{
						_group setVariable ["tarea","Patrol"];
						}
					else
						{
						if !(isNull _near) then
							{
							{
							[_x,_near] call A3A_fnc_fuegoSupresor;
							} forEach _baseOfFire select {(_x getVariable ["typeOfSoldier",""] == "MGMan") or (_x getVariable ["typeOfSoldier",""] == "StaticGunner")};
							if (sunOrMoon < 1) then
								{
								if !(haveNV) then
									{
									if (foundIFA) then
										{
										if (([_leader] call A3A_fnc_canFight) and ((typeOf _leader) in squadLeaders)) then {[_leader,_near] call A3A_fnc_useFlares}
										}
									else
										{
										{
										[_x,_near] call A3A_fnc_fuegoSupresor;
										} forEach _baseOfFire select {(_x getVariable ["typeOfSoldier",""] == "Normal") and (count (getArray (configfile >> "CfgWeapons" >> primaryWeapon _x >> "muzzles")) == 2)};
										};
									};
								};
							_mortar = _group getVariable ["morteros",objNull];
							if (!(isNull _mortar) and ([_mortar] call A3A_fnc_canFight)) then
								{
								if ({if (_x distance _near < 100) exitWith {1}} count _allNearFriends == 0) then {[_mortar,getPosASL _near,1] spawn A3A_fnc_mortarSupport};
								};
							};
						};
					};
				};

			if (_task == "AssaultClose") then
				{
				if (_near distance _leader > 150) then
					{
					_group setVariable ["tarea","Patrol"];
					}
				else
					{
					if (_near distance _leader > 50) then
						{
						_group setVariable ["tarea","Assault"];
						}
					else
						{
						if !(isNull _near) then
							{
							_flankers = _flankers select {!(_x getVariable ["maniobrando",false])};
							if (count _flankers != 0) then
								{
								{
								[_x,_x,_near] spawn A3A_fnc_cubrirConHumo;
								} forEach (_baseOfFire select {(_x getVariable ["typeOfSoldier",""] == "Normal")});
								if ([getPosASL _near] call A3A_fnc_isBuildingPosition) then
									{
									_engineer = objNull;
									_building = nearestBuilding _near;
									if !(_building getVariable ["asaltado",false]) then
										{
										{
										if ((_x call A3A_fnc_typeOfSoldier == "Engineer") and {_x != leader _x} and {!(_x getVariable ["maniobrando",true])} and {_x distance _near < 50}) exitWith {_engineer = _x};
										} forEach _baseOfFire;
										if !(isNull _engineer) then
											{
											[_engineer,_near,_building] spawn A3A_fnc_destroyBuilding;
											}
										else
											{
											[[_flankers,_near] call BIS_fnc_nearestPosition,_near,_building] spawn A3A_fnc_assaultBuilding;
											};
										};
									}
								else
									{
									[_flankers,_near] spawn A3A_fnc_doFlank;
									};
								};
							};
						};
					};
				};

			if (_task == "Hide") then
				{
				if ((isNull _tanks) and {isNull _air} and {_numObjectives <= 2*_numNearFriends}) then
					{
					_group setVariable ["tarea","Patrol"];
					}
				else
					{
					_movable = _movable select {!(_x getVariable ["maniobrando",false])};
					_movable spawn A3A_fnc_hideInBuilding;
					};
				};
			}
		else
			{
			if (_group getVariable ["tarea","Patrol"] != "Patrol") then
				{
				if (_group getVariable ["tarea","Patrol"] == "Hide") then {_group call A3A_fnc_recallGroup};
				_group setVariable ["tarea","Patrol"];
				};
			if (side _group == good) then
				{
				if (time >= _group getVariable ["autoRearm",time]) then
					{
					_group setVariable ["autoRearm",time + 120];
					{[_x] spawn A3A_fnc_autoRearm; sleep 1} forEach (_movable select {!(_x getVariable ["maniobrando",false])});
					};
				};
			if !(isNull(_group getVariable ["transporte",objNull])) then
				{
				(units _group select {vehicle _x == _x}) allowGetIn true;
				};
			};
		//diag_log format ["Tarea:%1.Movable:%2.Base:%3.Flankers:%4",_group getVariable "tarea",_group getVariable "movable",_group getVariable "baseOfFire",_group getVariable "flankers"];
		sleep 30;
		_movable =  (_group getVariable ["movable",[]]) select {alive _x};
		if ((_movable isEqualTo []) or (isNull _group)) exitWith {};
		_group setVariable ["movable",_movable];
		_baseOfFire = (_group getVariable ["baseOfFire",[]]) select {alive _x};
		_group setVariable ["baseOfFire",_baseOfFire];
		_flankers = (_group getVariable ["flankers",[]]) select {alive _x};
		_group setVariable ["flankers",_flankers];
		};
	};
