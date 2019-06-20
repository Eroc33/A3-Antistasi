if (!isServer and hasInterface) exitWith {};

private ["_marker","_isMarker","_exit","_radio","_base","_airport","_destinationPos","_soldiers","_vehicles","_groups","_roads","_originPos","_tam","_vehicleType","_vehicle","_veh","_vehCrew","_groupVeh","_landPos","_groupType","_group","_soldier","_threatEval","_pos","_timeOut","_side","_count","_isMarker","_inWaves","_typeOfAttack","_near","_airports","_site","_enemies","_plane","_friendlies","_type","_isSDK","_weapons","_destinationName","_vehPool","_super","_spawnPoint","_pos1","_pos2"];

_marker = _this select 0;//[position player,bad,"Normal",false] spawn A3A_Fnc_patrolCA
_airport = _this select 1;
_typeOfAttack = _this select 2;
_super = if (!isMultiplayer) then {false} else {_this select 3};
_inWaves = false;
_side = bad;
_originPos = [];
_destinationPos = [];
if ([_marker,false] call A3A_fnc_fogCheck < 0.3) exitWith {diag_log format ["Antistasi PatrolCA: Attack on %1 exit because of heavy fog",_marker]};
if (_airport isEqualType "") then
	{
	_inWaves = true;
	if (sides getVariable [_airport,sideUnknown] == veryBad) then {_side = veryBad};
	_originPos = getMarkerPos _airport;
	}
else
	{
	_side = _airport;
	};

//if ((!_inWaves) and (diag_fps < minimoFPS)) exitWith {diag_log format ["Antistasi PatrolCA: CA cancelled because of FPS %1",""]};

_isMarker = false;
_exit = false;
if (_marker isEqualType "") then
	{
	_isMarker = true;
	_destinationPos = getMarkerPos _marker;
	if (!_inWaves) then {if (_marker in smallCAmrk) then {_exit = true}};
	}
else
	{
	_destinationPos = _marker;
	_near = [smallCApos,_marker] call BIS_fnc_nearestPosition;
	if (_near distance _marker < (distanceSPWN2)) then
		{
		_exit = true;
		}
	else
		{
		if (count smallCAmrk > 0) then
			{
			_near = [smallCAmrk,_marker] call BIS_fnc_nearestPosition;
			if (getMarkerPos _near distance _marker < (distanceSPWN2)) then {_exit = true};
			};
		};
	};

if (_exit) exitWith {diag_log format ["Antistasi PatrolCA: CA cancelled because of other CA in vincity of %1",_marker]};

_enemies = allUnits select {_x distance _destinationPos < distanceSPWN2 and (side (group _x) != _side) and (side (group _x) != civilian) and (alive _x)};

if ((!_isMarker) and (_typeOfAttack != "Air") and (!_super) and ({sides getVariable [_x,sideUnknown] == _side} count airports > 0)) then
	{
	_plane = if (_side == bad) then {vehNATOPlane} else {vehCSATPlane};
	if ([_plane] call A3A_fnc_vehAvailable) then
		{
		_friendlies = if (_side == bad) then {allUnits select {(_x distance _destinationPos < 200) and (alive _x) and ((side (group _x) == _side) or (side (group _x) == civilian))}} else {allUnits select {(_x distance _destinationPos < 100) and ([_x] call A3A_fnc_canFight) and (side (group _x) == _side)}};
		if (count _friendlies == 0) then
			{
			_type = "NAPALM";
			{
			if (vehicle _x isKindOf "Tank") then
				{
				_type = "HE"
				}
			else
				{
				if (vehicle _x != _x) then
					{
					if !(vehicle _x isKindOf "StaticWeapon") then {_type = "CLUSTER"};
					};
				};
			if (_type == "HE") exitWith {};
			} forEach _enemies;
			_exit = true;
			if (!_isMarker) then {smallCApos pushBack _destinationPos};
			[_destinationPos,_side,_type] spawn A3A_fnc_airstrike;
			diag_log format ["Antistasi PatrolCA: Airstrike of type %1 sent to %2",_type,_marker];
			if (!_isMarker) then
				{
				sleep 120;
				smallCApos = smallCApos - [_destinationPos];
				};
			diag_log format ["Antistasi PatrolCA: CA resolved on airstrike %1",_marker]
			};
		};
	};
if (_exit) exitWith {};
_threatEvalLand = 0;
if (!_inWaves) then
	{
	_threatEvalLand = [_destinationPos,_side] call A3A_fnc_landThreatEval;
	_airports = airports select {(sides getVariable [_x,sideUnknown] == _side) and ([_x,true] call A3A_fnc_airportCanAttack) and (getMarkerPos _x distance2D _destinationPos < distanceForAirAttack)};
	if (foundIFA and (_threatEvalLand <= 15)) then {_airports = _airports select {(getMarkerPos _x distance2D _destinationPos < distanceForLandAttack)}};
	_points = if (_threatEvalLand <= 15) then {puestos select {(sides getVariable [_x,sideUnknown] == _side) and ([_destinationPos,getMarkerPos _x] call A3A_fnc_isTheSameIsland) and (getMarkerPos _x distance _destinationPos < distanceForLandAttack)  and ([_x,true] call A3A_fnc_airportCanAttack)}} else {[]};
	_airports = _airports + _points;
	if (_isMarker) then
		{
		if (_marker in blackListDest) then
			{
			_airports = _airports - puestos;
			};
		_airports = _airports - [_marker];
		_airports = _airports select {({_x == _marker} count (killZones getVariable [_x,[]])) < 3};
		}
	else
		{
		if (!_super) then
			{
			_site = [(recursos + fabricas + airports + puestos + puertos),_destinationPos] call BIS_fnc_nearestPosition;
			_airports = _airports select {({_x == _site} count (killZones getVariable [_x,[]])) < 3};
			};
		};
	if (_airports isEqualTo []) then
		{
		_exit = true;
		}
	else
		{
		_airport = [_airports,_destinationPos] call BIS_fnc_nearestPosition;
		_originPos = getMarkerPos _airport;
		};
	};

if (_exit) exitWith {diag_log format ["Antistasi PatrolCA: CA cancelled because no available base (distance, not spawned, busy, killzone) to attack %1",_marker]};


_allUnits = {(local _x) and (alive _x)} count allUnits;
_allUnitsSide = 0;
_maxUnitsSide = maxUnits;

if (gameMode <3) then
	{
	_allUnitsSide = {(local _x) and (alive _x) and (side group _x == _side)} count allUnits;
	_maxUnitsSide = round (maxUnits * 0.7);
	};
if ((_allUnits + 4 > maxUnits) or (_allUnitsSide + 4 > _maxUnitsSide)) then {_exit = true};

if (_exit) exitWith {diag_log format ["Antistasi PatrolCA: CA cancelled because of reaching the maximum of units on attacking %1",_marker]};

_base = if ((_originPos distance _destinationPos < distanceForLandAttack) and ([_destinationPos,_originPos] call A3A_fnc_isTheSameIsland) and (_threatEvalLand <= 15)) then {_airport} else {""};

if (_typeOfAttack == "") then
	{
	_typeOfAttack = "Normal";
	{
	_exit = false;
	if (vehicle _x != _x) then
		{
		_veh = vehicle _x;
		if (_veh isKindOf "Plane") exitWith {_exit = true; _typeOfAttack = "Air"};
		if (_veh isKindOf "Helicopter") then
			{
			_weapons = getArray (configfile >> "CfgVehicles" >> (typeOf _veh) >> "weapons");
			if (_weapons isEqualType []) then
				{
				if (count _weapons > 1) then {_exit = true; _typeOfAttack = "Air"};
				};
			}
		else
			{
			if (_veh isKindOf "Tank") then {_typeOfAttack = "Tank"};
			};
		};
	if (_exit) exitWith {};
	} forEach _enemies;
	};

_isSDK = false;
if (_isMarker) then
	{
	smallCAmrk pushBackUnique _marker; publicVariable "smallCAmrk";
	if (sides getVariable [_marker,sideUnknown] == good) then
		{
		_isSDK = true;
		_destinationName = [_marker] call A3A_fnc_localizar;
		if (!_inWaves) then {["IntelAdded", ["", format ["QRF sent to %1",_destinationName]]] remoteExec ["BIS_fnc_showNotification",_side]};
		};
	}
else
	{
	smallCApos pushBack _destinationPos;
	};

//if (debug) then {hint format ["Nos contraatacan desde %1 o desde el aeropuerto %2 hacia %3", _base, _airport,_marker]; sleep 5};
diag_log format ["Antistasi PatrolCA: CA performed from %1 to %2.Is waved:%3.Is super:%4",_airport,_marker,_inWaves,_super];
//_config = if (_side == bad) then {cfgNATOInf} else {cfgCSATInf};

_soldiers = [];
_vehicles = [];
_groups = [];
_roads = [];

if (_base != "") then
	{
	_airport = "";
	if (_base in puestos) then {[_base,60] call A3A_fnc_addTimeForIdle} else {[_base,30] call A3A_fnc_addTimeForIdle};
	_index = airports find _base;
	_spawnPoint = objNull;
	_pos = [];
	_dir = 0;
	if (_index > -1) then
		{
		_spawnPoint = spawnPoints select _index;
		_pos = getMarkerPos _spawnPoint;
		_dir = markerDir _spawnPoint;
		}
	else
		{
		_spawnPoint = [_originPos] call A3A_fnc_findNearestGoodRoad;
		_pos = position _spawnPoint;
		_dir = getDir _spawnPoint;
		};

	_vehPool = if (_side == bad) then {vehNATOAttack select {[_x] call A3A_fnc_vehAvailable}} else {vehCSATAttack select {[_x] call A3A_fnc_vehAvailable}};
	_road = [_destinationPos] call A3A_fnc_findNearestGoodRoad;
	if ((position _road) distance _destinationPos > 150) then {_vehPool = _vehPool - vehTanks};
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
	_count = if (!_super) then {if (_isMarker) then {2} else {1}} else {round ((tierWar + difficultyCoef) / 2) + 1};
	_landPosBlacklist = [];
	for "_i" from 1 to _count do
		{
		if (_vehPool isEqualTo []) then {if (_side == bad) then {_vehPool = vehNATOTrucks} else {_vehPool = vehCSATTrucks}};
		_vehicleType = if (_i == 1) then
						{
						if (_typeOfAttack == "Normal") then
							{
							selectRandom _vehPool
							}
						else
							{
							if (_typeOfAttack == "Air") then
								{
								if (_side == bad) then
									{
									if ([vehNATOAA] call A3A_fnc_vehAvailable) then {vehNATOAA} else {selectRandom _vehPool}
									}
								else
									{
									if ([vehCSATAA] call A3A_fnc_vehAvailable) then {vehCSATAA} else {selectRandom _vehPool}
									};
								}
							else
								{
								if (_side == bad) then
									{
									if ([vehNATOTank] call A3A_fnc_vehAvailable) then {vehNATOTank} else {selectRandom _vehPool}
									}
								else
									{
									if ([vehCSATTank] call A3A_fnc_vehAvailable) then {vehCSATTank} else {selectRandom _vehPool}
									};
								};
							};
						}
					else
						{
						if ((_isMarker) and !((_vehPool - vehTanks) isEqualTo [])) then {selectRandom (_vehPool - vehTanks)} else {selectRandom _vehPool};
						};
		//_road = _roads select 0;
		_timeOut = 0;
		_pos = _pos findEmptyPosition [0,100,_vehicleType];
		while {_timeOut < 60} do
			{
			if (count _pos > 0) exitWith {};
			_timeOut = _timeOut + 1;
			_pos = _pos findEmptyPosition [0,100,_vehicleType];
			sleep 1;
			};
		if (count _pos == 0) then {_pos = if (_index == -1) then {getMarkerPos _spawnPoint} else {position _spawnPoint}};
		_vehicle=[_pos, _dir,_vehicleType, _side] call bis_fnc_spawnvehicle;

		_veh = _vehicle select 0;
		_vehCrew = _vehicle select 1;
		{[_x] call A3A_fnc_NATOinit} forEach _vehCrew;
		[_veh] call A3A_fnc_AIVEHinit;
		_groupVeh = _vehicle select 2;
		_soldiers = _soldiers + _vehCrew;
		_groups pushBack _groupVeh;
		_vehicles pushBack _veh;
		_landPos = [_destinationPos,_pos,false,_landPosBlacklist] call A3A_fnc_findSafeRoadToUnload;
		if ((not(_vehicleType in vehTanks)) and (not(_vehicleType in vehAA))) then
			{
			_landPosBlacklist pushBack _landPos;
			_groupType = if (_typeOfAttack == "Normal") then
				{
				[_vehicleType,_side] call A3A_fnc_cargoSeats;
				}
			else
				{
				if (_typeOfAttack == "Air") then
					{
					if (_side == bad) then {groupsNATOAA} else {groupsCSATAA}
					}
				else
					{
					if (_side == bad) then {groupsNATOAT} else {groupsCSATAT}
					};
				};
			_group = [_originPos,_side,_groupType] call A3A_fnc_spawnGroup;
			{
			_x assignAsCargo _veh;
			_x moveInCargo _veh;
			if (vehicle _x == _veh) then
				{
				_soldiers pushBack _x;
				[_x] call A3A_fnc_NATOinit;
				_x setVariable ["origen",_base];
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
				//_groups pushBack _group;
				[_base,_landPos,_groupVeh] call WPCreate;
				_Vwp0 = (wayPoints _groupVeh) select 0;
				_Vwp0 setWaypointBehaviour "SAFE";
				_Vwp0 = _groupVeh addWaypoint [_landPos,count (wayPoints _groupVeh)];
				_Vwp0 setWaypointType "TR UNLOAD";
				//_Vwp0 setWaypointStatements ["true", "(group this) spawn A3A_fnc_attackDrillAI"];
				//_Vwp0 setWaypointStatements ["true", "[vehicle this] call A3A_fnc_smokeCoverAuto"];
				_Vwp1 = _groupVeh addWaypoint [_destinationPos, count (wayPoints _groupVeh)];
				_Vwp1 setWaypointType "SAD";
				_Vwp1 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
				_Vwp1 setWaypointBehaviour "COMBAT";
				[_veh,"APC"] spawn A3A_fnc_inmuneConvoy;
				_veh allowCrewInImmobile true;
				}
			else
				{
				(units _group) joinSilent _groupVeh;
				deleteGroup _group;
				_groupVeh spawn A3A_fnc_attackDrillAI;
				if (count units _groupVeh > 1) then {_groupVeh selectLeader (units _groupVeh select 1)};
				[_base,_landPos,_groupVeh] call WPCreate;
				_Vwp0 = (wayPoints _groupVeh) select 0;
				_Vwp0 setWaypointBehaviour "SAFE";
				/*
				_Vwp0 = (wayPoints _groupVeh) select ((count wayPoints _groupVeh) - 1);
				_Vwp0 setWaypointType "GETOUT";
				*/
				_Vwp0 = _groupVeh addWaypoint [_landPos, count (wayPoints _groupVeh)];
				_Vwp0 setWaypointType "GETOUT";
				//_Vwp0 setWaypointStatements ["true", "(group this) spawn A3A_fnc_attackDrillAI"];
				_Vwp1 = _groupVeh addWaypoint [_destinationPos, count (wayPoints _groupVeh)];
				_Vwp1 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
				if (_isMarker) then
					{

					if ((count (garrison getVariable _marker)) < 4) then
						{
						_Vwp1 setWaypointType "MOVE";
						_Vwp1 setWaypointBehaviour "AWARE";
						}
					else
						{
						_Vwp1 setWaypointType "SAD";
						_Vwp1 setWaypointBehaviour "COMBAT";
						};
					}
				else
					{
					_Vwp1 setWaypointType "SAD";
					_Vwp1 setWaypointBehaviour "COMBAT";
					};
				[_veh,"Inf Truck."] spawn A3A_fnc_inmuneConvoy;
				};
			}
		else
			{
			{_x disableAI "MINEDETECTION"} forEach (units _groupVeh);
			[_base,_destinationPos,_groupVeh] call WPCreate;
			_Vwp0 = (wayPoints _groupVeh) select 0;
			_Vwp0 setWaypointBehaviour "SAFE";
			_Vwp0 = _groupVeh addWaypoint [_destinationPos, count (waypoints _groupVeh)];
			[_veh,"Tank"] spawn A3A_fnc_inmuneConvoy;
			_Vwp0 setWaypointType "SAD";
			_Vwp0 setWaypointBehaviour "AWARE";
			_Vwp0 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
			_veh allowCrewInImmobile true;
			};
		_vehPool = _vehPool select {[_x] call A3A_fnc_vehAvailable}
		};
	diag_log format ["Antistasi PatrolCA: Land CA performed on %1, Type is %2, Vehicle count: %3, Soldier count: %4",_marker,_typeOfAttack,count _vehicles,count _soldiers];
	}
else
	{
	[_airport,20] call A3A_fnc_addTimeForIdle;
	_vehPool = [];
	_count = if (!_super) then {if (_isMarker) then {2} else {1}} else {round ((tierWar + difficultyCoef) / 2) + 1};
	_vehicleType = "";
	_vehPool = if (_side == bad) then {(vehNATOAir - [vehNATOPlane]) select {[_x] call A3A_fnc_vehAvailable}} else {(vehCSATAir - [vehCSATPlane]) select {[_x] call A3A_fnc_vehAvailable}};
	if (_isSDK) then
		{
		_rnd = random 100;
		if (_side == bad) then
			{
			if (_rnd > prestigeNATO) then
				{
				_vehPool = _vehPool - vehNATOAttackHelis;
				};
			}
		else
			{
			if (_rnd > prestigeCSAT) then
				{
				_vehPool = _vehPool - vehCSATAttackHelis;
				};
			};
		};
	if (_vehPool isEqualTo []) then {if (_side == bad) then {_vehPool = [vehNATOPatrolHeli]} else {_vehPool = [vehCSATPatrolHeli]}};
	for "_i" from 1 to _count do
		{
		_vehicleType = if (_i == 1) then
				{
				if (_typeOfAttack == "Normal") then
					{
					if (_count == 1) then
						{
						if (count (_vehPool - vehTransportAir) == 0) then {selectRandom _vehPool} else {selectRandom (_vehPool - vehTransportAir)};
						}
					else
						{
						//if (count (_vehPool - vehTransportAir) == 0) then {selectRandom _vehPool} else {selectRandom (_vehPool - vehTransportAir)};
						selectRandom (_vehPool select {_x in vehTransportAir});
						};
					}
				else
					{
					if (_typeOfAttack == "Air") then
						{
						if (_side == bad) then {if ([vehNATOPlaneAA] call A3A_fnc_vehAvailable) then {vehNATOPlaneAA} else {selectRandom _vehPool}} else {if ([vehCSATPlaneAA] call A3A_fnc_vehAvailable) then {vehCSATPlaneAA} else {selectRandom _vehPool}};
						}
					else
						{
						if (_side == bad) then {if ([vehNATOPlane] call A3A_fnc_vehAvailable) then {vehNATOPlane} else {selectRandom _vehPool}} else {if ([vehCSATPlane] call A3A_fnc_vehAvailable) then {vehCSATPlane} else {selectRandom _vehPool}};
						};
					};
				}
			else
				{
				if (_isMarker) then {selectRandom (_vehPool select {_x in vehTransportAir})} else {selectRandom _vehPool};
				};

		_pos = _originPos;
		_ang = 0;
		_size = [_airport] call A3A_fnc_sizeMarker;
		_buildings = nearestObjects [_originPos, ["Land_LandMark_F","Land_runway_edgelight"], _size / 2];
		if (count _buildings > 1) then
			{
			_pos1 = getPos (_buildings select 0);
			_pos2 = getPos (_buildings select 1);
			_ang = [_pos1, _pos2] call BIS_fnc_DirTo;
			_pos = [_pos1, 5,_ang] call BIS_fnc_relPos;
			};
		if (count _pos == 0) then {_pos = _originPos};
		_vehicle=[_pos, _ang + 90,_vehicleType, _side] call bis_fnc_spawnvehicle;
		_veh = _vehicle select 0;
		if (foundIFA) then {_veh setVelocityModelSpace [((velocityModelSpace _veh) select 0) + 0,((velocityModelSpace _veh) select 1) + 150,((velocityModelSpace _veh) select 2) + 50]};
		_vehCrew = _vehicle select 1;
		_groupVeh = _vehicle select 2;
		_soldiers append _vehCrew;
		_groups pushBack _groupVeh;
		_vehicles pushBack _veh;
		{[_x] call A3A_fnc_NATOinit} forEach units _groupVeh;
		[_veh] call A3A_fnc_AIVEHinit;
		if (not (_vehicleType in vehTransportAir)) then
			{
			_Hwp0 = _groupVeh addWaypoint [_destinationPos, 0];
			_Hwp0 setWaypointBehaviour "AWARE";
			_Hwp0 setWaypointType "SAD";
			//[_veh,"Air Attack"] spawn A3A_fnc_inmuneConvoy;
			}
		else
			{
			_groupType = if (_typeOfAttack == "Normal") then
				{
				[_vehicleType,_side] call A3A_fnc_cargoSeats;
				}
			else
				{
				if (_typeOfAttack == "Air") then
					{
					if (_side == bad) then {groupsNATOAA} else {groupsCSATAA}
					}
				else
					{
					if (_side == bad) then {groupsNATOAT} else {groupsCSATAT}
					};
				};
			_group = [_originPos,_side,_groupType] call A3A_fnc_spawnGroup;
			//{_x assignAsCargo _veh;_x moveInCargo _veh; [_x] call A3A_fnc_NATOinit;_soldiers pushBack _x;_x setVariable ["origen",_airport]} forEach units _group;
			{
			_x assignAsCargo _veh;
			_x moveInCargo _veh;
			if (vehicle _x == _veh) then
				{
				_soldiers pushBack _x;
				[_x] call A3A_fnc_NATOinit;
				_x setVariable ["origen",_airport];
				}
			else
				{
				deleteVehicle _x;
				};
			} forEach units _group;
			_groups pushBack _group;
			_landpos = [];
			_proceed = true;
			if (_isMarker) then
				{
				if ((_marker in airports)  or !(_veh isKindOf "Helicopter")) then
					{
					_proceed = false;
					[_veh,_group,_marker,_airport] spawn A3A_fnc_airdrop;
					}
				else
					{
					if (_isSDK) then
						{
						if (((count(garrison getVariable [_marker,[]])) < 10) and (_vehicleType in vehFastRope)) then
							{
							_proceed = false;
							//_group setVariable ["mrkAttack",_marker];
							[_veh,_group,_destinationPos,_originPos,_groupVeh] spawn A3A_fnc_fastrope;
							};
						};
					};
				}
			else
				{
				if !(_veh isKindOf "Helicopter") then
					{
					_proceed = false;
					[_veh,_group,_destinationPos,_airport] spawn A3A_fnc_airdrop;
					};
				};
			if (_proceed) then
				{
				_landPos = [_destinationPos, 300, 550, 10, 0, 0.20, 0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
				if !(_landPos isEqualTo [0,0,0]) then
					{
					_landPos set [2, 0];
					_pad = createVehicle ["Land_HelipadEmpty_F", _landpos, [], 0, "NONE"];
					_vehicles pushBack _pad;
					_wp0 = _groupVeh addWaypoint [_landpos, 0];
					_wp0 setWaypointType "TR UNLOAD";
					_wp0 setWaypointStatements ["true", "(vehicle this) land 'GET OUT';[vehicle this] call A3A_fnc_smokeCoverAuto"];
					_wp0 setWaypointBehaviour "CARELESS";
					_wp3 = _group addWaypoint [_landpos, 0];
					_wp3 setWaypointType "GETOUT";
					_wp3 setWaypointStatements ["true", "(group this) spawn A3A_fnc_attackDrillAI"];
					_wp0 synchronizeWaypoint [_wp3];
					_wp4 = _group addWaypoint [_destinationPos, 1];
					_wp4 setWaypointType "MOVE";
					_wp4 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
					_wp2 = _groupVeh addWaypoint [_originPos, 1];
					_wp2 setWaypointType "MOVE";
					_wp2 setWaypointStatements ["true", "deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList"];
					[_groupVeh,1] setWaypointBehaviour "AWARE";
					}
				else
					{
					if (_vehicleType in vehFastRope) then
						{
						[_veh,_group,_destinationPos,_originPos,_groupVeh] spawn A3A_fnc_fastrope;
						}
					else
						{
						[_veh,_group,_marker,_airport] spawn A3A_fnc_airdrop;
						};
					};
				};
			};
		sleep 30;
		_vehPool = _vehPool select {[_x] call A3A_fnc_vehAvailable};
		};
	diag_log format ["Antistasi PatrolCA: Air CA performed on %1, Type is %2, Vehicle count: %3, Soldier count: %4",_marker,_typeOfAttack,count _vehicles,count _soldiers];
	};

if (_isMarker) then
	{
	_time = time + 3600;
	_size = [_marker] call A3A_fnc_sizeMarker;
	if (_side == bad) then
		{
		waitUntil {sleep 5; (({!([_x] call A3A_fnc_canFight)} count _soldiers) >= 3*({([_x] call A3A_fnc_canFight)} count _soldiers)) or (time > _time) or (sides getVariable [_marker,sideUnknown] == bad) or (({[_x,_marker] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _side) and (side _x != civilian) and ([_x,_marker] call A3A_fnc_canConquer)} count allUnits))};
		if  ((({[_x,_marker] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _side) and (side _x != civilian) and ([_x,_marker] call A3A_fnc_canConquer)} count allUnits)) and (not(sides getVariable [_marker,sideUnknown] == bad))) then
			{
			[bad,_marker] remoteExec ["A3A_fnc_markerChange",2];
			diag_log format ["Antistasi Debug patrolCA: Attack from %1 or %2 to retake %3 succesful. Retaken.",_airport,_base,_marker];
			};
		sleep 10;
		if (!(sides getVariable [_marker,sideUnknown] == bad)) then
			{
			{_x doMove _originPos} forEach _soldiers;
			if (sides getVariable [_airport,sideUnknown] == bad) then
				{
				_killZones = killZones getVariable [_airport,[]];
				_killZones = _killZones + [_marker,_marker];
				killZones setVariable [_airport,_killZones,true];
				};
			diag_log format ["Antistasi Debug patrolCA: Attack from %1 or %2 to retake %3 failed",_airport,_base,_marker];
			}
		}
	else
		{
		waitUntil {sleep 5; (({!([_x] call A3A_fnc_canFight)} count _soldiers) >= 3*({([_x] call A3A_fnc_canFight)} count _soldiers))or (time > _time) or (sides getVariable [_marker,sideUnknown] == veryBad) or (({[_x,_marker] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _side) and (side _x != civilian) and ([_x,_marker] call A3A_fnc_canConquer)} count allUnits))};
		if  ((({[_x,_marker] call A3A_fnc_canConquer} count _soldiers) > 3*({(side _x != _side) and (side _x != civilian) and ([_x,_marker] call A3A_fnc_canConquer)} count allUnits)) and (not(sides getVariable [_marker,sideUnknown] == veryBad))) then
			{
			[veryBad,_marker] remoteExec ["A3A_fnc_markerChange",2];
			diag_log format ["Antistasi Debug patrolCA: Attack from %1 or %2 to retake %3 succesful. Retaken.",_airport,_base,_marker];
			};
		sleep 10;
		if (!(sides getVariable [_marker,sideUnknown] == veryBad)) then
			{
			{_x doMove _originPos} forEach _soldiers;
			if (sides getVariable [_airport,sideUnknown] == veryBad) then
				{
				_killZones = killZones getVariable [_airport,[]];
				_killZones = _killZones + [_marker,_marker];
				killZones setVariable [_airport,_killZones,true];
				};
			diag_log format ["Antistasi Debug patrolCA: Attack from %1 or %2 to retake %3 failed",_airport,_base,_marker];
			}
		};
	}
else
	{
	_ladoENY = if (_side == bad) then {veryBad} else {bad};
	if (_typeOfAttack != "Air") then {waitUntil {sleep 1; (!([distanceSPWN1,1,_destinationPos,good] call A3A_fnc_distanceUnits) and !([distanceSPWN1,1,_destinationPos,_ladoENY] call A3A_fnc_distanceUnits)) or (({!([_x] call A3A_fnc_canFight)} count _soldiers) >= 3*({([_x] call A3A_fnc_canFight)} count _soldiers))}} else {waitUntil {sleep 1; (({!([_x] call A3A_fnc_canFight)} count _soldiers) >= 3*({([_x] call A3A_fnc_canFight)} count _soldiers))}};
	if (({!([_x] call A3A_fnc_canFight)} count _soldiers) >= 3*({([_x] call A3A_fnc_canFight)} count _soldiers)) then
		{
		_markers = recursos + fabricas + airports + puestos + puertos select {getMarkerPos _x distance _destinationPos < distanceSPWN};
		_site = if (_base != "") then {_base} else {_airport};
		_killZones = killZones getVariable [_site,[]];
		_killZones append _markers;
		killZones setVariable [_site,_killZones,true];
		diag_log format ["Antistasi Debug patrolCA: Attack from %1 or %2 to %3 failed",_airport,_base,_marker];
		};
	diag_log format ["Antistasi Debug patrolCA: Attack from %1 or %2 to %3 despawned",_airport,_base,_marker];
	};
diag_log format ["Antistasi PatrolCA: CA on %1 finished",_marker];

//if (_marker in forcedSpawn) then {forcedSpawn = forcedSpawn - [_marker]; publicVariable "forcedSpawn"};

{
_veh = _x;
if (!([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)) then {deleteVehicle _x};
} forEach _vehicles;
{
_veh = _x;
if (!([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)) then {deleteVehicle _x; _soldiers = _soldiers - [_x]};
} forEach _soldiers;

if (count _soldiers > 0) then
	{
	{
	[_x] spawn
		{
		private ["_veh"];
		_veh = _this select 0;
		waitUntil {sleep 1; !([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)};
		deleteVehicle _veh;
		};
	} forEach _soldiers;
	};

{deleteGroup _x} forEach _groups;

sleep ((300 - ((tierWar + difficultyCoef) * 5)) max 0);
if (_isMarker) then {smallCAmrk = smallCAmrk - [_marker]; publicVariable "smallCAmrk"} else {smallCApos = smallCApos - [_destinationPos]};
