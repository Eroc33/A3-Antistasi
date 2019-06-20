private _group = _this select 0;
private _marker = _this select 1;
private _mode = _this select 2;
_objectives = _group call A3A_fnc_enemyList;
_group setVariable ["objetivos",_objectives];
private _size = [_marker] call A3A_fnc_sizeMarker;
if (_mode != "FORTIFY") then {_group setVariable ["tarea","PatrolSoft"]} else {_group setVariable ["tarea","FORTIFY"]};
private _side = side _group;
private _friendlies = if (_side == bad) then {[bad,civilian]} else {[_side]};
private _mortars = [];
private _mgs = [];
private _movable = [leader _group];
private _baseOfFire = [leader _group];

{
if (alive _x) then
	{
	_result = _x call A3A_fnc_typeOfSoldier;
	_x setVariable ["maniobrando",false];
	if (_result == "Normal") then
		{
		_movable pushBack _x;
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
		};
	};

_group setVariable ["movable",_movable];
_group setVariable ["baseOfFire",_baseOfFire];
if (side _group == good) then {_group setVariable ["autoRearmed",time + 300]};
_buildings = nearestTerrainObjects [getMarkerPos _marker, ["House"],true];
_buildings = _buildings select {((_x buildingPos -1) isEqualTo []) and !((typeof _bld) in UPSMON_Bld_remove) and (_x inArea _marker)};

if (_mode == "FORTIFY") then
	{
	_buildings = _buildings call BIS_fnc_arrayShuffle;
	_bldPos = [];
	_count = count _movable;
	_exit = false;
	{
	_building = _x;
	if (_exit) exitWith {};
	{
	if ([_x] call isOnRoof) then
		{
		_bldPos pushBack _x;
		if (count _bldPos == _count) then {_exit = true};
		};
	} forEach (_building buildingPos -1);
	} forEach _buildings;
	};
while {true} do
	{
	if (({alive _x} count (_group getVariable ["movable",[]]) == 0) or (isNull _group)) exitWith {};

	_objectives = _group call A3A_fnc_enemyList;
	_group setVariable ["objetivos",_objectives];
	if !(_objectives isEqualTo []) then
		{
		_air = objNull;
		_tanks = objNull;
		{
		_eny = assignedVehicle (_x select 4);
		if (_eny isKindOf "Tank") then
			{
			_tanks = _eny;
			}
		else
			{
			if (_eny isKindOf "Air") then
				{
				if (count (weapons _eny) > 1) then
					{
					_air = _eny;
					};
				};
			};
		if (!(isNull _air) and !(isNull _tanks)) exitWith {};
		} forEach _objectives;
		_leader = leader _group;
		_allNearFriends = allUnits select {(_x distance _leader < (distanceSPWN/2)) and (side _x in _friendlies) and ([_x] call A3A_fnc_canFight)};
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
		_air = objNull;
		_tanks = objNull;
		_numObjectives = count _objectives;
		_task = _group getVariable ["tarea","Patrol"];
		_near = _group call A3A_fnc_enemigoCercano;
		_soldiers = ((units _group) select {[_x] call A3A_fnc_canFight}) - [_group getVariable ["mortero",objNull]];
		_numSoliders = count _soldiers;
		if !(isNull _air) then
			{
			if ({(_x call A3A_fnc_typeOfSoldier == "AAMan") or (_x call A3A_fnc_typeOfSoldier == "StaticGunner")} count _allNearFriends == 0) then
				{
				if (_side != good) then {[[getPosASL _leader,_side,"Air",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2]};
				};
			//_nuevaTarea = ["Hide",_soldiers - (_soldiers select {(_x call A3A_fnc_typeOfSoldier == "AAMan") or (_x getVariable ["typeOfSoldier",""] == "StaticGunner")})];
			_group setVariable ["tarea","Hide"];
			_task = "Hide";
			};
		if !(isNull _tanks) then
			{
			if ({_x call A3A_fnc_typeOfSoldier == "ATMan"} count _allFriendlies == 0) then
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
						} forEach ((_group getVariable ["baseOfFire",[]]) select {([_x] call A3A_fnc_canFight) and ((_x getVariable ["typeOfSoldier",""] == "MGMan") or (_x getVariable ["typeOfSoldier",""] == "StaticGunner"))});
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
						_flankers = (_group getVariable ["flankers",[]]) select {([_x] call A3A_fnc_canFight) and !(_x getVariable ["maniobrando",false])};
						if (count _flankers != 0) then
							{
							{
							[_x,_x,_near] spawn A3A_fnc_cubrirConHumo;
							} forEach ((_group getVariable ["baseOfFire",[]]) select {([_x] call A3A_fnc_canFight) and (_x getVariable ["typeOfSoldier",""] == "Normal")});
							if ([getPosASL _near] call A3A_fnc_isBuildingPosition) then
								{
								_engineer = objNull;
								_building = nearestBuilding _near;
								if !(_building getVariable ["asaltado",false]) then
									{
									{
									if ((_x call A3A_fnc_typeOfSoldier == "Engineer") and {_x != leader _x} and {!(_x getVariable ["maniobrando",true])} and {_x distance _near < 50} and {[_x] call A3A_fnc_canFight}) exitWith {_engineer = _x};
									} forEach (_group getVariable ["baseOfFire",[]]);
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
				_movable = (_group getVariable ["movable",[]]) select {[_x] call A3A_fnc_canFight and !(_x getVariable ["maniobrando",false])};
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
				{[_x] spawn A3A_fnc_autoRearm; sleep 1} forEach ((_group getVariable ["movable",[]]) select {[_x] call A3A_fnc_canFight and !(_x getVariable ["maniobrando",false])});
				};
			};
		};
	diag_log format ["Tarea:%1.Movable:%2.Base:%3.Flankers:%4",_group getVariable "tarea",_group getVariable "movable",_group getVariable "baseOfFire",_group getVariable "flankers"];
	sleep 30;
	};
