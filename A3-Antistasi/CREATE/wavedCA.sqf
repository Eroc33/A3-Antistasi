if (!isServer and hasInterface) exitWith {};

private ["_originPos","_groupType","_originName","_markTsk","_wp1","_soldiers","_landpos","_pad","_vehicles","_wp0","_wp3","_wp4","_wp2","_group","_groups","_vehicleType","_vehicle","_heli","_heliCrew","_groupHeli","_pilots","_rnd","_resourcesAAF","_nVeh","_tam","_roads","_Vwp1","_road","_veh","_vehCrew","_groupVeh","_Vwp0","_size","_Hwp0","_group1","_uav","_groupUav","_uwp0","_tsk","_vehicle","_soldier","_pilot","_mrkDestination","_destinationPos","_prestigeCSAT","_mrkOrigin","_airport","_destinationName","_time","_solMax","_nul","_cost","_type","_threatEvalAir","_threatEvalLand","_pos","_timeOut","_side","_waves","_count","_tsk1","_spawnPoint","_vehPool"];

bigAttackInProgress = true;
publicVariable "bigAttackInProgress";
_firstWave = true;
_mrkDestination = _this select 0;
_mrkOrigin = _this select 1;
_waves = _this select 2;
if (_waves <= 0) then {_waves = -1};
_size = [_mrkDestination] call A3A_fnc_sizeMarker;
diag_log format ["Antistasi: Waved attack from %1 to %2. Waves: %3",_mrkOrigin,_mrkDestination,_waves];
_tsk = "";
_tsk1 = "";
_destinationPos = getMarkerPos _mrkDestination;
_originPos = getMarkerPos _mrkOrigin;

_groups = [];
_totalSoliders = [];
_pilots = [];
_vehicles = [];
_forced = [];

_destinationName = [_mrkDestination] call A3A_fnc_localizar;
_originName = [_mrkOrigin] call A3A_fnc_localizar;

_side = sides getVariable [_mrkOrigin,sideUnknown];
_taskSides = [good,civilian,veryBad];
_taskSides1 = [bad];
_enemyName = nameMalos;
//_config = cfgNATOInf;
if (_side == veryBad) then
	{
	_enemyName = nameMuyMalos;
	//_config = cfgCSATInf;
	_taskSides = [good,civilian,bad];
	_taskSides1 = [veryBad];
	};
_isSDK = if (sides getVariable [_mrkDestination,sideUnknown] == good) then {true} else {false};
_SDKShown = false;
if (_isSDK) then
	{
	_taskSides = [good,civilian,bad,veryBad] - [_side];
	}
else
	{
	if (not(_mrkDestination in _forced)) then {_forced pushBack _mrkDestination};
	};

//forcedSpawn = forcedSpawn + _forced; publicVariable "forcedSpawn";
forcedSpawn pushBack _mrkDestination; publicVariable "forcedSpawn";
diag_log format ["Antistasi: Side attacker: %1. Side defender (false, the other AI side):  %2",_side,_isSDK];
_destinationName = [_mrkDestination] call A3A_fnc_localizar;

[_taskSides,"AtaqueAAF",[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_originName,_enemyName],format ["%1 Attack",_enemyName],_mrkOrigin],getMarkerPos _mrkOrigin,false,0,true,"Defend",true] call BIS_fnc_taskCreate;
[_taskSides1,"AtaqueAAF1",[format ["We are attacking %2 from the %1. Help the operation if you can",_originName,_destinationName],format ["%1 Attack",_enemyName],_mrkDestination],getMarkerPos _mrkDestination,false,0,true,"Attack",true] call BIS_fnc_taskCreate;
//_tsk = ["AtaqueAAF",_taskSides,[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_originName,_enemyName],format ["%1 Attack",_enemyName],_mrkOrigin],getMarkerPos _mrkOrigin,"CREATED",10,true,true,"Defend"] call BIS_fnc_setTask;
//missions pushbackUnique "AtaqueAAF"; publicVariable "missions";
//_tsk1 = ["AtaqueAAF1",_taskSides1,[format ["We are attacking %2 from the %1. Help the operation if you can",_originName,_destinationName],format ["%1 Attack",_enemyName],_mrkDestination],getMarkerPos _mrkDestination,"CREATED",10,true,true,"Attack"] call BIS_fnc_setTask;

_time = time + 3600;

while {(_waves > 0)} do
	{
	_soldiers = [];
	_nVeh = 3 + (round random 1);
	_landOriginPos = [];
	_pos = [];
	_dir = 0;
	_spawnPoint = "";
	if !(_mrkDestination in blackListDest) then
		{
		if (_originPos distance _destinationPos < distanceForLandAttack) then
			{
			_index = airports find _mrkOrigin;
			_spawnPoint = spawnPoints select _index;
			_pos = getMarkerPos _spawnPoint;
			_landOriginPos = _originPos;
			_dir = markerDir _spawnPoint;
			}
		else
			{
			_points = puestos select {(sides getVariable [_x,sideUnknown] == _side) and (getMarkerPos _x distance _destinationPos < distanceForLandAttack)  and ([_x,false] call A3A_fnc_airportCanAttack)};
			if !(_points isEqualTo []) then
				{
				_point = selectRandom _points;
				_landOriginPos = getMarkerPos _point;
				//[_point,60] call A3A_fnc_addTimeForIdle;
				_spawnPoint = [_landOriginPos] call A3A_fnc_findNearestGoodRoad;
				_pos = position _spawnPoint;
				_dir = getDir _spawnPoint;
				};
			};
		};
	if !(_pos isEqualTo []) then
		{
		if ([_mrkDestination,true] call A3A_fnc_fogCheck < 0.3) then {_nveh = round (1.5*_nveh)};
		_vehPool = if (_side == bad) then {vehNATOAttack} else {vehCSATAttack};
		_vehPool = _vehPool select {[_x] call A3A_fnc_vehAvailable};
		if (_isSDK) then
			{
			_rnd = random 100;
			if (_side == bad) then
				{
				if (_rnd > prestigeNATO) then
					{
					_vehPool = _vehPool - [vehNATOTank];
					};
				}
			else
				{
				if (_rnd > prestigeCSAT) then
					{
					_vehPool = _vehPool - [vehCSATTank];
					};
				};
			};
		_road = [_destinationPos] call A3A_fnc_findNearestGoodRoad;
		if ((position _road) distance _destinationPos > 150) then {_vehPool = _vehPool - vehTanks};
		_count = 1;
		_landPosBlacklist = [];
		_spawnedSquad = false;
		while {(_count <= _nVeh) and (count _soldiers <= 80)} do
			{
			if (_vehPool isEqualTo []) then
				{
				if (_side == bad) then {_vehPool = vehNATOTrucks} else {_vehPool = vehCSATTrucks};
				};
			_vehicleType = selectRandom _vehPool;
			if ((_count == _nVeh) and (_vehicleType in vehTanks)) then
				{
				_vehicleType = if (_side == bad) then {selectRandom vehNATOTrucks} else {selectRandom vehCSATTrucks};
				};
			_proceed = true;
			if ((_vehicleType in (vehNATOTrucks+vehCSATTrucks)) and _spawnedSquad) then
				{
				_allUnits = {(local _x) and (alive _x)} count allUnits;
				_allUnitsSide = 0;
				_maxUnitsSide = maxUnits;

				if (gameMode <3) then
					{
					_allUnitsSide = {(local _x) and (alive _x) and (side group _x == _side)} count allUnits;
					_maxUnitsSide = round (maxUnits * 0.7);
					};
				if ((_allUnits + 4 > maxUnits) or (_allUnitsSide + 4 > _maxUnitsSide)) then {_proceed = false};
				};
			if (_proceed) then
				{
				_timeOut = 0;
				_pos = _pos findEmptyPosition [0,100,_vehicleType];
				while {_timeOut < 60} do
					{
					if (count _pos > 0) exitWith {};
					_timeOut = _timeOut + 1;
					_pos = _pos findEmptyPosition [0,100,_vehicleType];
					sleep 1;
					};
				if (count _pos == 0) then {_pos = getMarkerPos _spawnPoint};
				_vehicle=[_pos, _dir,_vehicleType, _side] call bis_fnc_spawnvehicle;

				_veh = _vehicle select 0;
				_vehCrew = _vehicle select 1;
				{[_x] call A3A_fnc_NATOinit} forEach _vehCrew;
				[_veh] call A3A_fnc_AIVEHinit;
				_groupVeh = _vehicle select 2;
				_soldiers append _vehCrew;
				_totalSoliders append _vehCrew;
				_groups pushBack _groupVeh;
				_vehicles pushBack _veh;
				_landPos = [_destinationPos,_pos,false,_landPosBlacklist] call A3A_fnc_findSafeRoadToUnload;
				if (not(_vehicleType in vehTanks)) then
					{
					_landPosBlacklist pushBack _landPos;
					_groupType = [_vehicleType,_side] call A3A_fnc_cargoSeats;
					_group = grpNull;
					if !(_spawnedSquad) then {_group = [_originPos,_side, _groupType,true,false] call A3A_fnc_spawnGroup; _spawnedSquad = true} else {_group = [_originPos,_side, _groupType] call A3A_fnc_spawnGroup};
					{
					_x assignAsCargo _veh;
					_x moveInCargo _veh;
					if (vehicle _x == _veh) then
						{
						_soldiers pushBack _x;
						_totalSoliders pushBack _x;
						[_x] call A3A_fnc_NATOinit;
						_x setVariable ["origen",_mrkOrigin];
						}
					else
						{
						deleteVehicle _x;
						};
					} forEach units _group;
					if (not(_vehicleType in vehTrucks)) then
						{
						{_x disableAI "MINEDETECTION"} forEach (units _groupVeh);
						(units _group) joinSilent _groupVeh;
						deleteGroup _group;
						_groupVeh spawn A3A_fnc_attackDrillAI;
						[_landOriginPos,_landPos,_groupVeh] call WPCreate;
						_Vwp0 = (wayPoints _groupVeh) select 0;
						_Vwp0 setWaypointBehaviour "SAFE";
						_Vwp0 = _groupVeh addWaypoint [_landPos, count (wayPoints _groupVeh)];
						_Vwp0 setWaypointType "TR UNLOAD";
						//_Vwp0 setWaypointStatements ["true", "(group this) spawn A3A_fnc_attackDrillAI"];
						_Vwp0 setWayPointCompletionRadius (10*_count);
						_Vwp1 = _groupVeh addWaypoint [_destinationPos, 1];
						_Vwp1 setWaypointType "SAD";
						_Vwp1 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
						_Vwp1 setWaypointBehaviour "COMBAT";
						_veh allowCrewInImmobile true;
						[_veh,"APC"] spawn A3A_fnc_inmuneConvoy;
						}
					else
						{
						(units _group) joinSilent _groupVeh;
						deleteGroup _group;
						_groupVeh selectLeader (units _groupVeh select 1);
						_groupVeh spawn A3A_fnc_attackDrillAI;
						[_landOriginPos,_landPos,_groupVeh] call WPCreate;
						_Vwp0 = (wayPoints _groupVeh) select 0;
						_Vwp0 setWaypointBehaviour "SAFE";
						_Vwp0 = _groupVeh addWaypoint [_landPos, count (wayPoints _groupVeh)];
						_Vwp0 setWaypointType "GETOUT";
						//_Vwp0 setWaypointStatements ["true", "(group this) spawn A3A_fnc_attackDrillAI"];
						_Vwp1 = _groupVeh addWaypoint [_destinationPos, count (wayPoints _groupVeh)];
						_Vwp1 setWaypointType "SAD";
						[_veh,"Inf Truck."] spawn A3A_fnc_inmuneConvoy;
						};
					}
				else
					{
					{_x disableAI "MINEDETECTION"} forEach (units _groupVeh);
					[_landOriginPos,_destinationPos,_groupVeh] call WPCreate;
					_Vwp0 = (wayPoints _groupVeh) select 0;
					_Vwp0 setWaypointBehaviour "SAFE";
					_Vwp0 = _groupVeh addWaypoint [_destinationPos, count (wayPoints _groupVeh)];
					_Vwp0 setWaypointType "MOVE";
					_Vwp0 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
					_Vwp0 = _groupVeh addWaypoint [_destinationPos, count (wayPoints _groupVeh)];
					_Vwp0 setWaypointType "SAD";
					[_veh,"Tank"] spawn A3A_fnc_inmuneConvoy;
					_veh allowCrewInImmobile true;
					};
				};
				sleep 15;
				_count = _count + 1;
				_vehPool = _vehPool select {[_x] call A3A_fnc_vehAvailable};
			};
		}
	else
		{
		_nVeh = 2*_nVeh;
		};

	_isMarine = false;
	if !(foundIFA) then
		{
		for "_i" from 0 to 3 do
			{
			_pos = _destinationPos getPos [1000,(_i*90)];
			if (surfaceIsWater _pos) exitWith
				{
				if ({sides getVariable [_x,sideUnknown] == _side} count puertos > 1) then
					{
					_isMarine = true;
					};
				};
			};
		};

	if ((_isMarine) and (_firstWave)) then
		{
		_pos = getMarkerPos ([seaAttackSpawn,_destinationPos] call BIS_fnc_nearestPosition);
		if (count _pos > 0) then
			{
			_vehPool = if (_side == bad) then {vehNATOBoats} else {vehCSATBoats};
			_vehPool = _vehPool select {[_x] call A3A_fnc_vehAvailable};
			_count = 0;
			_spawnedSquad = false;
			while {(_count < 3) and (count _soldiers <= 80)} do
				{
				_vehicleType = if (_vehPool isEqualTo []) then {if (_side == bad) then {vehNATORBoat} else {vehCSATRBoat}} else {selectRandom _vehPool};
				_proceed = true;
				if ((_vehicleType == vehNATOBoat) or (_vehicleType == vehCSATBoat)) then
					{
					_landPos = [_destinationPos, 10, 1000, 10, 2, 0.3, 0] call BIS_Fnc_findSafePos;
					}
				else
					{
					_allUnits = {(local _x) and (alive _x)} count allUnits;
					_allUnitsSide = 0;
					_maxUnitsSide = maxUnits;
					if (gameMode <3) then
						{
						_allUnitsSide = {(local _x) and (alive _x) and (side group _x == _side)} count allUnits;
						_maxUnitsSide = round (maxUnits * 0.7);
						};
					if (((_allUnits + 4 > maxUnits) or (_allUnitsSide + 4 > _maxUnitsSide)) and _spawnedSquad) then
						{
						_proceed = false
						}
					else
						{
						_groupType = [_vehicleType,_side] call A3A_fnc_cargoSeats;
						_landPos = [_destinationPos, 10, 1000, 10, 2, 0.3, 1] call BIS_Fnc_findSafePos;
						};
					};
				if ((count _landPos > 0) and _proceed) then
					{
					_vehicle=[_pos, random 360,_vehicleType, _side] call bis_fnc_spawnvehicle;

					_veh = _vehicle select 0;
					_vehCrew = _vehicle select 1;
					_groupVeh = _vehicle select 2;
					_pilots append _vehCrew;
					_groups pushBack _groupVeh;
					_vehicles pushBack _veh;
					{[_x] call A3A_fnc_NATOinit} forEach units _groupVeh;
					[_veh] call A3A_fnc_AIVEHinit;
					if ((_vehicleType == vehNATOBoat) or (_vehicleType == vehCSATBoat)) then
						{
						_wp0 = _groupVeh addWaypoint [_landpos, 0];
						_wp0 setWaypointType "SAD";
						//[_veh,"Boat"] spawn A3A_fnc_inmuneConvoy;
						}
					else
						{
						_group = grpNull;
						if !(_spawnedSquad) then {_group = [_originPos,_side, _groupType,true,false] call A3A_fnc_spawnGroup;_spawnedSquad = true} else {_group = [_originPos,_side, _groupType,false,true] call A3A_fnc_spawnGroup};
						{
						_x assignAsCargo _veh;
						_x moveInCargo _veh;
						if (vehicle _x == _veh) then
							{
							_soldiers pushBack _x;
							_totalSoliders pushBack _x;
							[_x] call A3A_fnc_NATOinit;
							_x setVariable ["origen",_mrkOrigin];
							}
						else
							{
							deleteVehicle _x;
							};
						} forEach units _group;
						if (_vehicleType in vehAPCs) then
							{
							_groups pushBack _group;
							_Vwp = _groupVeh addWaypoint [_landPos, 0];
							_Vwp setWaypointBehaviour "SAFE";
							_Vwp setWaypointType "TR UNLOAD";
							_Vwp setWaypointSpeed "FULL";
							_Vwp1 = _groupVeh addWaypoint [_destinationPos, 1];
							_Vwp1 setWaypointType "SAD";
							_Vwp1 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
							_Vwp1 setWaypointBehaviour "COMBAT";
							_Vwp2 = _group addWaypoint [_landPos, 0];
							_Vwp2 setWaypointType "GETOUT";
							_Vwp2 setWaypointStatements ["true", "(group this) spawn A3A_fnc_attackDrillAI"];
							//_group setVariable ["mrkAttack",_mrkDestination];
							_Vwp synchronizeWaypoint [_Vwp2];
							_Vwp3 = _group addWaypoint [_destinationPos, 1];
							_Vwp3 setWaypointType "SAD";
							_veh allowCrewInImmobile true;
							//[_veh,"APC"] spawn A3A_fnc_inmuneConvoy;
							}
						else
							{
							(units _group) joinSilent _groupVeh;
							deleteGroup _group;
							_groupVeh selectLeader (units _groupVeh select 1);
							_Vwp = _groupVeh addWaypoint [_landPos, 0];
							_Vwp setWaypointBehaviour "SAFE";
							_Vwp setWaypointSpeed "FULL";
							_Vwp setWaypointType "GETOUT";
							_Vwp setWaypointStatements ["true", "(group this) spawn A3A_fnc_attackDrillAI"];
							_Vwp1 = _groupVeh addWaypoint [_destinationPos, 1];
							_Vwp1 setWaypointType "SAD";
							_Vwp1 setWaypointBehaviour "COMBAT";
							//[_veh,"Boat"] spawn A3A_fnc_inmuneConvoy;
							};
						};
					};
				sleep 15;
				_count = _count + 1;
				_vehPool = _vehPool select {[_x] call A3A_fnc_vehAvailable};
				};
			};
		};
	if ([_mrkDestination,true] call A3A_fnc_fogCheck >= 0.3) then
		{
		if ((_originPos distance _destinationPos < distanceForLandAttack) and !(_mrkDestination in blackListDest)) then {sleep ((_originPos distance _destinationPos)/30)};
		_groundPos = [_originPos select 0,_originPos select 1,0];
		_originPos set [2,300];
		_groupUav = grpNull;
		if !(foundIFA) then
			{
			_vehicleType = if (_side == bad) then {vehNATOUAV} else {vehCSATUAV};

			_uav = createVehicle [_vehicleType, _originPos, [], 0, "FLY"];
			_vehicles pushBack _uav;
			//[_uav,"UAV"] spawn A3A_fnc_inmuneConvoy;
			[_uav,_mrkDestination,_side] spawn A3A_fnc_VANTinfo;
			createVehicleCrew _uav;
			_pilots append (crew _uav);
			_groupUav = group (crew _uav select 0);
			_groups pushBack _groupUav;
			{[_x] call A3A_fnc_NATOinit} forEach units _groupUav;
			[_uav] call A3A_fnc_AIVEHinit;
			_uwp0 = _groupUav addWayPoint [_destinationPos,0];
			_uwp0 setWaypointBehaviour "AWARE";
			_uwp0 setWaypointType "SAD";
			if (not(_mrkDestination in airports)) then {_uav removeMagazines "6Rnd_LG_scalpel"};
			sleep 5;
			}
		else
			{
			_groupUav = createGroup _side;
			//_originPos set [2,2000];
			_uwp0 = _groupUav addWayPoint [_destinationPos,0];
			_uwp0 setWaypointBehaviour "AWARE";
			_uwp0 setWaypointType "SAD";
			};
		_vehPool = if (_side == bad) then
					{
					if (_mrkDestination in airports) then {(vehNATOAir - [vehNATOPlaneAA]) select {[_x] call A3A_fnc_vehAvailable}} else {(vehNatoAir - vehFixedWing) select {[_x] call A3A_fnc_vehAvailable}};
					}
				else
					{
					if (_mrkDestination in airports) then {(vehCSATAir - [vehCSATPlaneAA]) select {[_x] call A3A_fnc_vehAvailable}} else {(vehCSATAir - vehFixedWing) select {[_x] call A3A_fnc_vehAvailable}};
					};
		if (_isSDK) then
			{
			_rnd = random 100;
			if (_side == bad) then
				{
				if (_rnd > prestigeNATO) then
					{
					_vehPool = _vehPool - [vehNATOPlane];
					};
				}
			else
				{
				if (_rnd > prestigeCSAT) then
					{
					_vehPool = _vehPool - [vehCSATPlane];
					};
				};
			};
		if ((_waves != 1) and (_firstWave) and (!foundIFA)) then
			{
			if (count (_vehPool - vehTransportAir) != 0) then {_vehPool = _vehPool - vehTransportAir};
			};
		_count = 1;
		_pos = _originPos;
		_ang = 0;
		_size = [_mrkOrigin] call A3A_fnc_sizeMarker;
		_buildings = nearestObjects [_originPos, ["Land_LandMark_F","Land_runway_edgelight"], _size / 2];
		if (count _buildings > 1) then
			{
			_pos1 = getPos (_buildings select 0);
			_pos2 = getPos (_buildings select 1);
			_ang = [_pos1, _pos2] call BIS_fnc_DirTo;
			_pos = [_pos1, 5,_ang] call BIS_fnc_relPos;
			};
		_spawnedSquad = false;
		while {(_count <= _nVeh) and (count _soldiers <= 80)} do
			{
			_proceed = true;
			if (_count == _nveh) then {if (_side == bad) then {_vehPool = _vehPool select {_x in vehNATOTransportHelis}} else {_vehPool = _vehPool select {_x in vehCSATTransportHelis}}};
			_vehicleType = if !(_vehPool isEqualTo []) then {selectRandom _vehPool} else {if (_side == bad) then {vehNATOPatrolHeli} else {vehCSATPatrolHeli}};
			if ((_vehicleType in vehTransportAir) and !(_spawnedSquad)) then
				{
				_allUnits = {(local _x) and (alive _x)} count allUnits;
				_allUnitsSide = 0;
				_maxUnitsSide = maxUnits;
				if (gameMode <3) then
					{
					_allUnitsSide = {(local _x) and (alive _x) and (side group _x == _side)} count allUnits;
					_maxUnitsSide = round (maxUnits * 0.7);
					};
				if ((_allUnits + 4 > maxUnits) or (_allUnitsSide + 4 > _maxUnitsSide)) then
					{
					_proceed = false
					};
				};
			if (_proceed) then
				{
				_vehicle=[_pos, _ang + 90,_vehicleType, _side] call bis_fnc_spawnvehicle;
				_veh = _vehicle select 0;
				if (foundIFA) then {_veh setVelocityModelSpace [((velocityModelSpace _veh) select 0) + 0,((velocityModelSpace _veh) select 1) + 150,((velocityModelSpace _veh) select 2) + 50]};
				_vehCrew = _vehicle select 1;
				_groupVeh = _vehicle select 2;
				_pilots append _vehCrew;
				_vehicles pushBack _veh;
				{[_x] call A3A_fnc_NATOinit} forEach units _groupVeh;
				[_veh] call A3A_fnc_AIVEHinit;
				if (not (_vehicleType in vehTransportAir)) then
					{
					(units _groupVeh) joinSilent _groupUav;
					deleteGroup _groupVeh;
					//[_veh,"Air Attack"] spawn A3A_fnc_inmuneConvoy;
					}
				else
					{
					_groups pushBack _groupVeh;
					_groupType = [_vehicleType,_side] call A3A_fnc_cargoSeats;
					_group = grpNull;
					if !(_spawnedSquad) then {_group = [_groundPos,_side, _groupType,true,false] call A3A_fnc_spawnGroup;_spawnedSquad = true} else {_group = [_groundPos,_side, _groupType] call A3A_fnc_spawnGroup};
					_groups pushBack _group;
					{
					_x assignAsCargo _veh;
					_x moveInCargo _veh;
					if (vehicle _x == _veh) then
						{
						_soldiers pushBack _x;
						_totalSoliders pushBack _x;
						[_x] call A3A_fnc_NATOinit;
						_x setVariable ["origen",_mrkOrigin];
						}
					else
						{
						deleteVehicle _x;
						};
					} forEach units _group;
					if (!(_veh isKindOf "Helicopter") or (_mrkDestination in airports)) then
						{
						[_veh,_group,_mrkDestination,_mrkOrigin] spawn A3A_fnc_airdrop;
						}
					else
						{
						_landPos = _destinationPos getPos [300, random 360];
						_landPos = [_landPos, 0, 550, 10, 0, 0.20, 0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
						if !(_landPos isEqualTo [0,0,0]) then
							{
							_landPos set [2, 0];
							_pad = createVehicle ["Land_HelipadEmpty_F", _landPos, [], 0, "NONE"];
							_vehicles pushBack _pad;
							_wp0 = _groupVeh addWaypoint [_landpos, 0];
							_wp0 setWaypointType "TR UNLOAD";
							_wp0 setWaypointStatements ["true", "(vehicle this) land 'GET OUT';[vehicle this] call A3A_fnc_smokeCoverAuto"];
							_wp0 setWaypointBehaviour "CARELESS";
							_wp3 = _group addWaypoint [_landpos, 0];
							_wp3 setWaypointType "GETOUT";
							_wp3 setWaypointStatements ["true", "(group this) spawn A3A_fnc_attackDrillAI"];
							//_group setVariable ["mrkAttack",_mrkDestination];
							//_wp3 setWaypointStatements ["true","nul = [this, (group this getVariable ""mrkAttack""), ""SPAWNED"",""NOVEH2"",""NOFOLLOW"",""NOWP3""] execVM ""scripts\UPSMON.sqf"";"];
							_wp0 synchronizeWaypoint [_wp3];
							_wp4 = _group addWaypoint [_destinationPos, 1];
							_wp4 setWaypointType "SAD";
							//_wp4 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
							//_wp4 setWaypointStatements ["true","nul = [this, (group this getVariable ""mrkAttack""), ""SPAWNED"",""NOVEH2"",""NOFOLLOW"",""NOWP3""] execVM ""scripts\UPSMON.sqf"";"];
							_wp4 = _group addWaypoint [_destinationPos, 1];
							//_wp4 setWaypointType "SAD";
							_wp2 = _groupVeh addWaypoint [_originPos, 1];
							_wp2 setWaypointType "MOVE";
							_wp2 setWaypointStatements ["true", "deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList"];
							[_groupVeh,1] setWaypointBehaviour "AWARE";
							}
						else
							{
							{_x disableAI "TARGET"; _x disableAI "AUTOTARGET"} foreach units _groupVeh;
							if ((_vehicleType in vehFastRope) and ((count(garrison getVariable _mrkDestination)) < 10)) then
								{
								//_group setVariable ["mrkAttack",_mrkDestination];
								[_veh,_group,_destinationPos,_originPos,_groupVeh] spawn A3A_fnc_fastrope;
								}
							else
								{
								[_veh,_group,_mrkDestination,_mrkOrigin] spawn A3A_fnc_airdrop;
								}
							};
						};
					};
				};
			sleep 1;
			_pos = [_pos, 80,_ang] call BIS_fnc_relPos;
			_count = _count + 1;
			_vehPool = _vehPool select {[_x] call A3A_fnc_vehAvailable};
			};
		};
	_plane = if (_side == bad) then {vehNATOPlane} else {vehCSATPlane};
	if (_side == bad) then
		{
		if (((not(_mrkDestination in puestos)) and (not(_mrkDestination in puertos)) and (_mrkOrigin != "NATO_carrier")) or foundIFA) then
			{
			[_mrkOrigin,_mrkDestination,_side] spawn A3A_fnc_artilleria;
			diag_log "Antistasi: Arty Spawned";
			if (([_plane] call A3A_fnc_vehAvailable) and (not(_mrkDestination in ciudades)) and _firstWave) then
				{
				sleep 60;
				_rnd = if (_mrkDestination in airports) then {round random 4} else {round random 2};
				for "_i" from 0 to _rnd do
					{
					if ([_plane] call A3A_fnc_vehAvailable) then
						{
						diag_log "Antistasi: Airstrike Spawned";
						if (_i == 0) then
							{
							if (_mrkDestination in airports) then
								{
								_nul = [_mrkDestination,_side,"HE"] spawn A3A_fnc_airstrike;
								}
							else
								{
								_nul = [_mrkDestination,_side,selectRandom ["HE","CLUSTER","NAPALM"]] spawn A3A_fnc_airstrike;
								};
							}
						else
							{
							_nul = [_mrkDestination,_side,selectRandom ["HE","CLUSTER","NAPALM"]] spawn A3A_fnc_airstrike;
							};
						sleep 30;
						};
					};
				};
			};
		}
	else
		{
		if (((not(_mrkDestination in recursos)) and (not(_mrkDestination in puertos)) and (_mrkOrigin != "CSAT_carrier")) or foundIFA) then
			{
			if !(_landOriginPos isEqualTo []) then {[_landOriginPos,_mrkDestination,_side] spawn A3A_fnc_artilleria} else {[_mrkOrigin,_mrkDestination,_side] spawn A3A_fnc_artilleria};
			diag_log "Antistasi: Arty Spawned";
			if (([_plane] call A3A_fnc_vehAvailable) and (_firstWave)) then
				{
				sleep 60;
				_rnd = if (_mrkDestination in airports) then {if ({sides getVariable [_x,sideUnknown] == veryBad} count airports == 1) then {8} else {round random 4}} else {round random 2};
				for "_i" from 0 to _rnd do
					{
					if ([_plane] call A3A_fnc_vehAvailable) then
						{
						diag_log "Antistasi: Airstrike Spawned";
						if (_i == 0) then
							{
							if (_mrkDestination in airports) then
								{
								_nul = [_mrkDestination,_side,"HE"] spawn A3A_fnc_airstrike;
								}
							else
								{
								_nul = [_mrkDestination,_side,selectRandom ["HE","CLUSTER","NAPALM"]] spawn A3A_fnc_airstrike;
								};
							}
						else
							{
							_nul = [_destinationPos,_side,selectRandom ["HE","CLUSTER","NAPALM"]] spawn A3A_fnc_airstrike;
							};
						sleep 30;
						};
					};
				};
			};
		};

	if (!_SDKShown) then
		{
		if !([true] call A3A_fnc_FIAradio) then {sleep 100};
		_SDKShown = true;
		["TaskSucceeded", ["", "Attack Destination Updated"]] remoteExec ["BIS_fnc_showNotification",good];
		["AtaqueAAF",[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_originName,_enemyName],format ["%1 Attack",_enemyName],_mrkDestination],getMarkerPos _mrkDestination,"CREATED"] call A3A_fnc_taskUpdate;
		};
	_solMax = round ((count _soldiers)*0.6);
	_waves = _waves -1;
	_firstWave = false;
	diag_log format ["Antistasi: Reached end of spawning attack, wave %1. Vehicles: %2. Wave Units: %3. Total units: %4 ",_waves, count _vehicles, count _soldiers, count _totalSoliders];
	if (sides getVariable [_mrkDestination,sideUnknown] != good) then {_soldiers spawn A3A_fnc_remoteBattle};
	if (_side == bad) then
		{
		waitUntil {sleep 5; (({!([_x] call A3A_fnc_canFight)} count _soldiers) >= _solMax) or (time > _time) or (sides getVariable [_mrkDestination,sideUnknown] == bad) or (({[_x,_mrkDestination] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _side) and (side _x != civilian) and ([_x,_mrkDestination] call A3A_fnc_canConquer)} count allUnits))};
		if  ((({[_x,_mrkDestination] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _side) and (side _x != civilian) and ([_x,_mrkDestination] call A3A_fnc_canConquer)} count allUnits)) or (sides getVariable [_mrkDestination,sideUnknown] == bad)) then
			{
			_waves = 0;
			if ((!(sides getVariable [_mrkDestination,sideUnknown] == bad)) and !(_mrkDestination in ciudades)) then {[bad,_mrkDestination] remoteExec ["A3A_fnc_markerChange",2]};
			["AtaqueAAF",[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_originName,_enemyName],format ["%1 Attack",_enemyName],_mrkOrigin],getMarkerPos _mrkOrigin,"FAILED"] call A3A_fnc_taskUpdate;
			["AtaqueAAF1",[format ["We are attacking an %2 from the %1. Help the operation if you can",_originName,_destinationName],format ["%1 Attack",_enemyName],_mrkDestination],getMarkerPos _mrkDestination,"SUCEEDED"] call A3A_fnc_taskUpdate;
			if (_mrkDestination in ciudades) then
				{
				[0,-100,_mrkDestination] remoteExec ["A3A_fnc_citySupportChange",2];
				["TaskFailed", ["", format ["%1 joined %2",[_mrkDestination, false] call A3A_fnc_fn_location,nameMalos]]] remoteExec ["BIS_fnc_showNotification",good];
				sides setVariable [_mrkDestination,bad,true];
				_nul = [-5,0] remoteExec ["A3A_fnc_prestige",2];
				_mrkD = format ["Dum%1",_mrkDestination];
				_mrkD setMarkerColor colorBad;
				garrison setVariable [_mrkDestination,[],true];
				};
			};
		sleep 10;
		if (!(sides getVariable [_mrkDestination,sideUnknown] == bad)) then
			{
			_time = time + 3600;
			if (sides getVariable [_mrkOrigin,sideUnknown] == bad) then
				{
				_killZones = killZones getVariable [_mrkOrigin,[]];
				_killZones append [_mrkDestination,_mrkDestination,_mrkDestination];
				killZones setVariable [_mrkOrigin,_killZones,true];
				};

			if !(_landOriginPos isEqualTo []) then
				{
				if ({[_x] call A3A_fnc_vehAvailable} count vehNATOAPC == 0) then {_waves = _waves -1};
				if !([vehNATOTank] call A3A_fnc_vehAvailable) then {_waves = _waves - 1};
				};
			if ({[_x] call A3A_fnc_vehAvailable} count vehNATOAttackHelis == 0) then
				{
				if (_landOriginPos isEqualTo []) then {_waves = _waves -2} else {_waves = _waves -1};
				};
			if !([vehNATOPlane] call A3A_fnc_vehAvailable) then
				{
				if (_landOriginPos isEqualTo []) then {_waves = _waves -2} else {_waves = _waves -1};
				};

			if ((_waves <= 0) or (!(sides getVariable [_mrkOrigin,sideUnknown] == bad))) then
				{
				{_x doMove _originPos} forEach _totalSoliders;
				if (_waves <= 0) then {[_mrkDestination,_mrkOrigin] call A3A_fnc_minefieldAAF};

				["AtaqueAAF",[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_originName,_enemyName],format ["%1 Attack",_enemyName],_mrkOrigin],getMarkerPos _mrkOrigin,"SUCCEEDED"] call A3A_fnc_taskUpdate;
				["AtaqueAAF1",[format ["We are attacking an %2 from the %1. Help the operation if you can",_originName,_destinationName],format ["%1 Attack",_enemyName],_mrkDestination],getMarkerPos _mrkDestination,"FAILED"] call A3A_fnc_taskUpdate;
				};
			};
		}
	else
		{
		waitUntil {sleep 5; (({!([_x] call A3A_fnc_canFight)} count _soldiers) >= _solMax) or (time > _time) or (sides getVariable [_mrkDestination,sideUnknown] == veryBad) or (({[_x,_mrkDestination] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _side) and (side _x != civilian) and ([_x,_mrkDestination] call A3A_fnc_canConquer)} count allUnits))};
		//diag_log format ["1:%1,2:%2,3:%3,4:%4",(({!([_x] call A3A_fnc_canFight)} count _soldiers) >= _solMax),(time > _time),(sides getVariable [_mrkDestination,sideUnknown] == veryBad),(({[_x,_mrkDestination] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _side) and (side _x != civilian) and ([_x,_mrkDestination] call A3A_fnc_canConquer)} count allUnits))];
		if  ((({[_x,_mrkDestination] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _side) and (side _x != civilian) and ([_x,_mrkDestination] call A3A_fnc_canConquer)} count allUnits)) or (sides getVariable [_mrkDestination,sideUnknown] == veryBad))  then
			{
			_waves = 0;
			if (not(sides getVariable [_mrkDestination,sideUnknown] == veryBad)) then {[veryBad,_mrkDestination] remoteExec ["A3A_fnc_markerChange",2]};
			["AtaqueAAF",[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_originName,_enemyName],format ["%1 Attack",_enemyName],_mrkOrigin],getMarkerPos _mrkOrigin,"FAILED"] call A3A_fnc_taskUpdate;
			["AtaqueAAF1",[format ["We are attacking an %2 from the %1. Help the operation if you can",_originName,_destinationName],format ["%1 Attack",_enemyName],_mrkDestination],getMarkerPos _mrkDestination,"SUCCEEDED"] call A3A_fnc_taskUpdate;
			};
		sleep 10;
		if (!(sides getVariable [_mrkDestination,sideUnknown] == veryBad)) then
			{
			_time = time + 3600;
			diag_log format ["Antistasi debug wavedCA: Wave number %1 on wavedCA lost",_waves];
			if (sides getVariable [_mrkOrigin,sideUnknown] == veryBad) then
				{
				_killZones = killZones getVariable [_mrkOrigin,[]];
				_killZones append [_mrkDestination,_mrkDestination,_mrkDestination];
				killZones setVariable [_mrkOrigin,_killZones,true];
				};

			if !(_landOriginPos isEqualTo []) then
				{
				if ({[_x] call A3A_fnc_vehAvailable} count vehCSATAPC == 0) then {_waves = _waves -1};
				if !([vehCSATTank] call A3A_fnc_vehAvailable) then {_waves = _waves - 1};
				};
			if ({[_x] call A3A_fnc_vehAvailable} count vehCSATAttackHelis == 0) then
				{
				if (_landOriginPos isEqualTo []) then {_waves = _waves -2} else {_waves = _waves -1};
				};
			if !([vehCSATPlane] call A3A_fnc_vehAvailable) then
				{
				if (_landOriginPos isEqualTo []) then {_waves = _waves -2} else {_waves = _waves -1};
				};

			if ((_waves <= 0) or (sides getVariable [_mrkOrigin,sideUnknown] != veryBad)) then
				{
				{_x doMove _originPos} forEach _totalSoliders;
				if (_waves <= 0) then {[_mrkDestination,_mrkOrigin] call A3A_fnc_minefieldAAF};
				["AtaqueAAF",[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_originName,_enemyName],format ["%1 Attack",_enemyName],_mrkOrigin],getMarkerPos _mrkOrigin,"SUCCEEDED"] call A3A_fnc_taskUpdate;
				["AtaqueAAF1",[format ["We are attacking an %2 from the %1. Help the operation if you can",_originName,_destinationName],format ["%1 Attack",_enemyName],_mrkDestination],getMarkerPos _mrkDestination,"FAILED"] call A3A_fnc_taskUpdate;
				};
			};
		};
	};





//_tsk = ["AtaqueAAF",_taskSides,[format ["%2 Is attacking from the %1. Intercept them or we may loose a sector",_originName,_enemyName],"AAF Attack",_mrkOrigin],getMarkerPos _mrkOrigin,"FAILED",10,true,true,"Defend"] call BIS_fnc_setTask;
if (_isSDK) then
	{
	if (!(sides getVariable [_mrkDestination,sideUnknown] == good)) then
		{
		[-10,theBoss] call A3A_fnc_playerScoreAdd;
		}
	else
		{
		{if (isPlayer _x) then {[10,_x] call A3A_fnc_playerScoreAdd}} forEach ([500,0,_destinationPos,good] call A3A_fnc_distanceUnits);
		[5,theBoss] call A3A_fnc_playerScoreAdd;
		};
	};
diag_log "Antistasi: Reached end of winning conditions. Starting despawn";
sleep 30;
_nul = [0,"AtaqueAAF"] spawn A3A_fnc_borrarTask;
_nul = [0,"AtaqueAAF1"] spawn A3A_fnc_borrarTask;

[_mrkOrigin,60] call A3A_fnc_addTimeForIdle;
bigAttackInProgress = false; publicVariable "bigAttackInProgress";
//forcedSpawn = forcedSpawn - _forced; publicVariable "forcedSpawn";
forcedSpawn = forcedSpawn - [_mrkDestination]; publicVariable "forcedSpawn";
[3600] remoteExec ["A3A_fnc_timingCA",2];

{
_veh = _x;
if (!([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)) then {deleteVehicle _x; _pilots = _pilots - [_x]};
} forEach _pilots;
{
_veh = _x;
if (!([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)) then {deleteVehicle _x};
} forEach _vehicles;
{
_veh = _x;
if (!([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)) then {deleteVehicle _x; _totalSoliders = _totalSoliders - [_x]};
} forEach _totalSoliders;

if (count _pilots > 0) then
	{
	{
	[_x] spawn
		{
		private ["_veh"];
		_veh = _this select 0;
		waitUntil {sleep 1; !([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)};
		deleteVehicle _veh;
		};
	} forEach _pilots;
	};

if (count _totalSoliders > 0) then
	{
	{
	[_x] spawn
		{
		private ["_veh"];
		_veh = _this select 0;
		waitUntil {sleep 1; !([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)};
		deleteVehicle _veh;
		};
	} forEach _totalSoliders;
	};


{deleteGroup _x} forEach _groups;
diag_log "Antistasi Waved CA: Despawn completed";
