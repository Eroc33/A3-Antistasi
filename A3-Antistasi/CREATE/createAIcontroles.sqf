if (!isServer and hasInterface) exitWith{};

private ["_pos","_roadscon","_veh","_roads","_conquered","_dirVeh","_marker","_position","_vehicles","_soldiers","_size","_bunker","_groupE","_unit","_groupType","_group","_timeDelay","_dateDelay","_dateDelayNumeric","_base","_dog","_side","_cfg","_isFIA","_exit","_isControl","_size","_vehicleType","_unitType","_markers","_isFrontLine","_uav","_groupUav","_allUnits","_closest","_winner","_timeDelay","_dateDelay","_fechalimNum","_mrkSize","_base","_mine","_loser","_side"];

_marker = _this select 0;
_position = getMarkerPos _marker;
_side = sides getVariable [_marker,sideUnknown];

if ((_side == good) or (_side == sideUnknown)) exitWith {};
if ({if ((sides getVariable [_x,sideUnknown] != _side) and (_position inArea _x)) exitWith {1}} count marcadores >1) exitWith {};
_vehicles = [];
_soldiers = [];
_pilots = [];
_conquered = false;
_group = grpNull;
_isFIA = false;
_exit = false;

_isControl = if (isOnRoad _position) then {true} else {false};

if (_isControl) then
	{
	if (gameMode != 4) then
		{
		if (_side == bad) then
			{
			if ((random 10 > (tierWar + difficultyCoef)) and (!([_marker] call A3A_fnc_isFrontline))) then
				{
				_isFIA = true;
				}
			};
		}
	else
		{
		if (_side == veryBad) then
			{
			if ((random 10 > (tierWar + difficultyCoef)) and (!([_marker] call A3A_fnc_isFrontline))) then
				{
				_isFIA = true;
				}
			};
		};

	_size = 20;
	while {true} do
		{
		_roads = _position nearRoads _size;
		if (count _roads > 1) exitWith {};
		_size = _size + 5;
		};

	_roadscon = roadsConnectedto (_roads select 0);

	_dirveh = [_roads select 0, _roadscon select 0] call BIS_fnc_DirTo;
	if ((isNull (_roads select 0)) or (isNull (_roadscon select 0))) then {diag_log format ["Antistasi Roadblock error report: %1 position is bad",_marker]};

	if (!_isFIA) then
		{
		_groupE = grpNull;
		if !(foundIFA) then
			{
			_pos = [getPos (_roads select 0), 7, _dirveh + 270] call BIS_Fnc_relPos;
			_bunker = "Land_BagBunker_01_Small_green_F" createVehicle _pos;
			_vehicles pushBack _bunker;
			_bunker setDir _dirveh;
			_pos = getPosATL _bunker;
			_vehicleType = if (_side == bad) then {NATOMG} else {CSATMG};
			_veh = _vehicleType createVehicle _position;
			_vehicles pushBack _veh;
			_veh setPosATL _pos;
			_veh setDir _dirVeh;

			_groupE = createGroup _side;
			_unitType = if (_side == bad) then {staticCrewMalos} else {staticCrewMuyMalos};
			_unit = _groupE createUnit [_unitType, _position, [], 0, "NONE"];
			_unit moveInGunner _veh;
			_soldiers pushBack _unit;
			sleep 1;
			_pos = [getPos (_roads select 0), 7, _dirveh + 90] call BIS_Fnc_relPos;
			_bunker = "Land_BagBunker_01_Small_green_F" createVehicle _pos;
			_vehicles pushBack _bunker;
			_bunker setDir _dirveh + 180;
			_pos = getPosATL _bunker;
			_pos = [getPos _bunker, 6, getDir _bunker] call BIS_fnc_relPos;
			_vehicleType = if (_side == bad) then {NATOFlag} else {CSATFlag};
			_veh = createVehicle [_vehicleType, _pos, [],0, "CAN_COLLIDE"];
			_vehicles pushBack _veh;
			_veh = _vehicleType createVehicle _position;
			_vehicles pushBack _veh;
			_veh setPosATL _pos;
			_veh setDir _dirVeh;
			sleep 1;
			_unit = _groupE createUnit [_unitType, _position, [], 0, "NONE"];
			_unit moveInGunner _veh;
			_soldiers pushBack _unit;
			sleep 1;
			{_nul = [_x] call A3A_fnc_AIVEHinit} forEach _vehicles;
			};
		_groupType = if (_side == bad) then {selectRandom groupsNATOmid} else {selectRandom groupsCSATmid};
		_group = if !(foundIFA) then {[_position,_side, _groupType,false,true] call A3A_fnc_spawnGroup} else {[_position,_side, _groupType] call A3A_fnc_spawnGroup};
		if !(isNull _group) then
			{
			if !(foundIFA) then
				{
				{[_x] join _group} forEach units _groupE;
				deleteGroup _groupE;
				};
			if (random 10 < 2.5) then
				{
				_dog = _group createUnit ["Fin_random_F",_position,[],0,"FORM"];
				[_dog,_group] spawn A3A_fnc_guardDog;
				};
			_nul = [leader _group, _marker, "SAFE","SPAWNED","NOVEH2","NOFOLLOW"] execVM "scripts\UPSMON.sqf";
			{[_x,""] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _group;
			};
		}
	else
		{
		_vehicleType = if !(foundIFA) then {vehFIAArmedCar} else {vehFIACar};
		_veh = _vehicleType createVehicle getPos (_roads select 0);
		_veh setDir _dirveh + 90;
		_nul = [_veh] call A3A_fnc_AIVEHinit;
		_vehicles pushBack _veh;
		sleep 1;
		_groupType = selectRandom groupsFIAMid;
		_group = if !(foundIFA) then {[_position, _side, _groupType,false,true] call A3A_fnc_spawnGroup} else {[_position, _side, _groupType] call A3A_fnc_spawnGroup};
		if !(isNull _group) then
			{
			_unit = _group createUnit [FIARifleman, _position, [], 0, "NONE"];
			_unit moveInGunner _veh;
			{_soldiers pushBack _x; [_x,""] call A3A_fnc_NATOinit} forEach units _group;
			};
		};
	}
else
	{
	_markers = marcadores select {(getMarkerPos _x distance _position < distanceSPWN) and (sides getVariable [_x,sideUnknown] == good)};
	_markers = _markers - ["Synd_HQ"] - puestosFIA;
	_isFrontLine = if (count _markers > 0) then {true} else {false};
	if (_isFrontLine) then
		{
		_cfg = CSATSpecOp;
		if (sides getVariable [_marker,sideUnknown] == bad) then
			{
			_cfg = NATOSpecOp;
			_side = bad;
			};
		_mrkSize = [_marker] call A3A_fnc_sizeMarker;
		if ({if (_x inArea _marker) exitWith {1}} count allMines == 0) then
			{
			for "_i" from 1 to 60 do
				{
				_mine = createMine ["APERSMine",_position,[],_mrkSize];
				if (_side == bad) then {bad revealMine _mine} else {veryBad revealMine _mine};
				};
			};
		_group = [_position,_side, _cfg] call A3A_fnc_spawnGroup;
		_nul = [leader _group, _marker, "SAFE","SPAWNED","RANDOM","NOVEH2","NOFOLLOW"] execVM "scripts\UPSMON.sqf";
		if !(foundIFA) then
			{
			sleep 1;
			{_soldiers pushBack _x} forEach units _group;
			_vehicleType = if (_side == bad) then {vehNATOUAVSmall} else {vehCSATUAVSmall};
			_uav = createVehicle [_vehicleType, _position, [], 0, "FLY"];
			createVehicleCrew _uav;
			_vehicles pushBack _uav;
			_groupUav = group (crew _uav select 1);
			{[_x] joinSilent _group; _pilots pushBack _x} forEach units _groupUav;
			deleteGroup _groupUav;
			};
		{[_x,""] call A3A_fnc_NATOinit} forEach units _group;
		}
	else
		{
		_exit = true;
		};
	};
if (_exit) exitWith {};
_spawnStatus = 0;
while {(spawner getVariable _marker != 2) and ({[_x,_marker] call A3A_fnc_canConquer} count _soldiers > 0)} do
	{
	if ((spawner getVariable _marker == 1) and (_spawnStatus != spawner getVariable _marker)) then
		{
		_spawnStatus = 1;
		if (isMultiplayer) then
			{
			{if (vehicle _x == _x) then {[_x,false] remoteExec ["enableSimulationGlobal",2]}} forEach _soldiers
			}
		else
			{
			{if (vehicle _x == _x) then {_x enableSimulationGlobal false}} forEach _soldiers
			};
		}
	else
		{
		if ((spawner getVariable _marker == 0) and (_spawnStatus != spawner getVariable _marker)) then
			{
			_spawnStatus = 0;
			if (isMultiplayer) then
				{
				{if (vehicle _x == _x) then {[_x,true] remoteExec ["enableSimulationGlobal",2]}} forEach _soldiers
				}
			else
				{
				{if (vehicle _x == _x) then {_x enableSimulationGlobal true}} forEach _soldiers
				};
			};
		};
	sleep 3;
	};

waitUntil {sleep 1;((spawner getVariable _marker == 2))  or ({[_x,_marker] call A3A_fnc_canConquer} count _soldiers == 0)};

_conquered = false;
_winner = bad;
if (spawner getVariable _marker != 2) then
	{
	_conquered = true;
	_allUnits = allUnits select {(side _x != civilian) and (side _x != _side) and (alive _x) and (!captive _x)};
	_closest = [_allUnits,_position] call BIS_fnc_nearestPosition;
	_winner = side _closest;
	_loser = bad;
	if (_isControl) then
		{
		["TaskSucceeded", ["", "Roadblock Destroyed"]] remoteExec ["BIS_fnc_showNotification",_winner];
		["TaskFailed", ["", "Roadblock Lost"]] remoteExec ["BIS_fnc_showNotification",_side];
		};
	if (sides getVariable [_marker,sideUnknown] == bad) then
		{
		if (_winner == veryBad) then
			{
			_nul = [-5,0,_position] remoteExec ["A3A_fnc_citySupportChange",2];
			sides setVariable [_marker,veryBad,true];
			}
		else
			{
			sides setVariable [_marker,good,true];
			};
		}
	else
		{
		_loser = veryBad;
		if (_winner == bad) then
			{
			sides setVariable [_marker,bad,true];
			_nul = [5,0,_position] remoteExec ["A3A_fnc_citySupportChange",2];
			}
		else
			{
			sides setVariable [_marker,good,true];
			_nul = [0,5,_position] remoteExec ["A3A_fnc_citySupportChange",2];
			};
		};
	if (_winner == good) then {[[_position,_side,"",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2]};
	};

waitUntil {sleep 1;(spawner getVariable _marker == 2)};

{_veh = _x;
if (not(_veh in staticsToSave)) then
	{
	if ((!([distanceSPWN,1,_x,good] call A3A_fnc_distanceUnits))) then {deleteVehicle _x}
	};
} forEach _vehicles;
{
if (alive _x) then
	{
	if (_x != vehicle _x) then {deleteVehicle (vehicle _x)};
	deleteVehicle _x
	}
} forEach (_soldiers + _pilots);
deleteGroup _group;

if (_conquered) then
	{
	_index = controles find _marker;
	if (_index > defaultControlIndex) then
		{
		_timeDelay = 120;//120
		_dateDelay = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeDelay];
		_dateDelayNumeric = dateToNumber _dateDelay;
		waitUntil {sleep 60;(dateToNumber date > _dateDelayNumeric)};
		_base = [(marcadores - controles),_position] call BIS_fnc_nearestPosition;
		if (sides getVariable [_base,sideUnknown] == bad) then
			{
			sides setVariable [_marker,bad,true];
			}
		else
			{
			if (sides getVariable [_base,sideUnknown] == veryBad) then
				{
				sides setVariable [_marker,veryBad,true];
				};
			};
		}
	else
		{
		/*
		if ((!_isControl) and (_winner == good)) then
			{
			_mrkSize = [_marker] call A3A_fnc_sizeMarker;
			for "_i" from 1 to 60 do
				{
				_mine = createMine ["APERSMine",_position,[],_mrkSize];
				if (_loser == bad) then {bad revealMine _mine} else {veryBad revealMine _mine};
				};
			};
		*/
		};
	};

