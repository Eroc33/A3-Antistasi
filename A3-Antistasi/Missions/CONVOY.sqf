if (!isServer and hasInterface) exitWith {};
private ["_pos","_timeOut","_posbase","_destinationPos","_soldiers","_groups","_vehicles","_POWS","_endTime","_endDate","_endDateNumeric","_veh","_unit","_group","_side","_count","_destinationName","_vehPool","_spawnPoint","_vehicleType"];
_destination = _this select 0;
_base = _this select 1;

_difficulty = if (random 10 < tierWar) then {true} else {false};
_exit = false;
_contact = objNull;
_grpContact = grpNull;
_tsk = "";
_tsk1 = "";
_departureDateNumeric = 0;
_isFIA = false;
_side = if (sides getVariable [_base,sideUnknown] == bad) then {bad} else {veryBad};

if (_side == bad) then
	{
	if ((random 10 >= tierWar) and !(_difficulty)) then
		{
		_isFIA = true;
		};
	};

_posbase = getMarkerPos _base;
_destinationPos = getMarkerPos _destination;

_soldiers = [];
_groups = [];
_vehicles = [];
_POWS = [];
_reinforcements = [];
_escortVehType = "";
_vehObjType = "";
_groupType = "";
_convoyTypes = [];
_posHQ = getMarkerPos respawnGood;

_endTime = 120;
_endDate = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _endTime];
_endDateNumeric = dateToNumber _endDate;

private ["_tsk","_grpPOW","_pos"];

if ((_destination in airports) or (_destination in puestos)) then
	{
	_convoyTypes = ["Municion","Armor"];
	if (_destination in puestos) then {if (((count (garrison getVariable [_destination,0]))/2) >= [_destination] call A3A_fnc_garrisonSize) then {_convoyTypes pushBack "Refuerzos"}};
	}
else
	{
	if (_destination in ciudades) then
		{
		if (sides getVariable [_destination,sideUnknown] == bad) then {_convoyTypes = ["Supplies"]} else {_convoyTypes = ["Supplies"]}
		}
	else
		{
		if ((_destination in recursos) or (_destination in fabricas)) then {_convoyTypes = ["Money"]} else {_convoyTypes = ["Prisoners"]};
		if (((count (garrison getVariable [_destination,0]))/2) >= [_destination] call A3A_fnc_garrisonSize) then {_convoyTypes pushBack "Refuerzos"};
		};
	};

_convoyType = selectRandom _convoyTypes;

_departureTime = if (_difficulty) then {0} else {round random 10};// tiempo para que salga el convoy, deber??amos poner un round random 15
_departureDate = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _departureTime];
_departureDateNumeric = dateToNumber _departureDate;

_destinationName = [_destination] call A3A_fnc_localizar;
_originName = [_base] call A3A_fnc_localizar;
[_base,30] call A3A_fnc_addTimeForIdle;
_text = "";
_taskState = "CREATED";
_taskTitle = "";
_taskIcon = "";
_taskState1 = "CREATED";

switch (_convoyType) do
	{
	case "Municion":
		{
		_text = format ["A convoy from %1 is about to depart at %2:%3. It will provide ammunition to %4. Try to intercept it. Steal or destroy that truck before it reaches it's destination.",_originName,numberToDate [2035,_departureDateNumeric] select 3,numberToDate [2035,_departureDateNumeric] select 4,_destinationName];
		_taskTitle = "Ammo Convoy";
		_taskIcon = "rearm";
		_vehObjType = if (_side == bad) then {vehNATOAmmoTruck} else {vehCSATAmmoTruck};
		};
	case "Armor":
		{
		_text = format ["A convoy from %1 is about to depart at %2:%3. It will reinforce %4 with armored vehicles. Try to intercept it. Steal or destroy that thing before it reaches it's destination.",_originName,numberToDate [2035,_departureDateNumeric] select 3,numberToDate [2035,_departureDateNumeric] select 4,_destinationName];
		_taskTitle = "Armored Convoy";
		_taskIcon = "Destroy";
		_vehObjType = if (_side == bad) then {vehNATOAA} else {vehCSATAA};
		};
	case "Prisoners":
		{
		_text = format ["A group os POW's is being transported from %1 to %4, and it's about to depart at %2:%3. Try to intercept it. Kill or capture the truck driver to make them join you and bring them to HQ. Alive if possible.",_originName,numberToDate [2035,_departureDateNumeric] select 3,numberToDate [2035,_departureDateNumeric] select 4,_destinationName];
		_taskTitle = "Prisoner Convoy";
		_taskIcon = "run";
		_vehObjType = if (_side == bad) then {selectRandom vehNATOTrucks} else {selectRandom vehCSATTrucks};
		};
	case "Refuerzos":
		{
		_text = format ["Reinforcements are being sent from %1 to %4 in a convoy, and it's about to depart at %2:%3. Try to intercept and kill all the troops and vehicle objective.",_originName,numberToDate [2035,_departureDateNumeric] select 3,numberToDate [2035,_departureDateNumeric] select 4,_destinationName];
		_taskTitle = "Reinforcements Convoy";
		_taskIcon = "run";
		_vehObjType = if (_side == bad) then {selectRandom vehNATOTrucks} else {selectRandom vehCSATTrucks};
		};
	case "Money":
		{
		_text = format ["A truck plenty of money is being moved from %1 to %4, and it's about to depart at %2:%3. Steal that truck and bring it to HQ. Those funds will be very welcome.",_originName,numberToDate [2035,_departureDateNumeric] select 3,numberToDate [2035,_departureDateNumeric] select 4,_destinationName];
		_taskTitle = "Money Convoy";
		_taskIcon = "move";
		_vehObjType = "C_Van_01_box_F";
		};
	case "Supplies":
		{
		_text = format ["A truck with medical supplies destination %4 it's about to depart at %2:%3 from %1. Steal that truck bring it to %4 and let people in there know it is %5 who's giving those supplies.",_originName,numberToDate [2035,_departureDateNumeric] select 3,numberToDate [2035,_departureDateNumeric] select 4,_destinationName,nameBuenos];
		_taskTitle = "Supply Convoy";
		_taskIcon = "heal";
		_vehObjType = "C_Van_01_box_F";
		};
	};

[[good,civilian],"CONVOY",[_text,_taskTitle,_destination],_destinationPos,false,0,true,_taskIcon,true] call BIS_fnc_taskCreate;
[[_side],"CONVOY1",[format ["A convoy from %1 to %4, it's about to depart at %2:%3. Protect it from any possible attack.",_originName,numberToDate [2035,_departureDateNumeric] select 3,numberToDate [2035,_departureDateNumeric] select 4,_destinationName],"Protect Convoy",_destination],_destinationPos,false,0,true,"run",true] call BIS_fnc_taskCreate;
missions pushBack ["CONVOY","CREATED"]; publicVariable "missions";
sleep (_departureTime * 60);

_posOrig = [];
_dir = 0;
if (_base in airports) then
	{
	_index = airports find _base;
	_spawnPoint = spawnPoints select _index;
	_posOrig = getMarkerPos _spawnPoint;
	_dir = markerDir _spawnPoint;
	}
else
	{
	_spawnPoint = [getMarkerPos _base] call A3A_fnc_findNearestGoodRoad;
	_posOrig = position _spawnPoint;
	_dir = getDir _spawnPoint;
	};
_group = createGroup _side;
_groups pushBack _group;
_vehicleType = if (_side == bad) then {if (!_isFIA) then {selectRandom vehNATOLightArmed} else {vehPoliceCar}} else {selectRandom vehCSATLightArmed};
_timeOut = 0;
_pos = _posOrig findEmptyPosition [0,100,_vehicleType];
while {_timeOut < 60} do
	{
	if (count _pos > 0) exitWith {};
	_timeOut = _timeOut + 1;
	_pos = _posOrig findEmptyPosition [0,100,_vehicleType];
	sleep 1;
	};
if (count _pos == 0) then {_pos = _posOrig};
_vehicle=[_pos,_dir,_vehicleType, _group] call bis_fnc_spawnvehicle;
_vehLead = _vehicle select 0;
_vehLead allowDamage false;
[_vehLead,"Convoy Lead"] spawn A3A_fnc_inmuneConvoy;
//_vehLead forceFollowRoad true;
_vehCrew = _vehicle select 1;
{[_x] call A3A_fnc_NATOinit;_x allowDamage false} forEach _vehCrew;
//_groupVeh = _vehicle select 2;
_soldiers = _soldiers + _vehCrew;
//_groups pushBack _groupVeh;
_vehicles pushBack _vehLead;
[_vehLead] call A3A_fnc_AIVEHinit;

_vehLead limitSpeed 50;


_count = 1;
if (_difficulty) then {_count =3} else {if ([_destination] call A3A_fnc_isFrontline) then {_count = (round random 2) + 1}};
_vehPool = if (_side == bad) then {if (!_isFIA) then {vehNATOAttack} else {[vehFIAArmedCar,vehFIATruck,vehFIACar]}} else {vehCSATAttack};
if (!_isFIA) then
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
	if (count _vehPool == 0) then {if (_side == bad) then {_vehPool = vehNATOTrucks} else {_vehPool = vehCSATTrucks}};
	};
for "_i" from 1 to _count do
	{
	sleep 2;
	_escortVehType = selectRandom _vehPool;
	if (not([_escortVehType] call A3A_fnc_vehAvailable)) then
		{
		_vehicleType = if (_side == bad) then {selectRandom vehNATOTrucks} else {selectRandom vehCSATTrucks};
		_vehPool = _vehPool - [_vehicleType];
		if (count _vehPool == 0) then {if (_side == bad) then {_vehPool = vehNATOTrucks} else {_vehPool = vehCSATTrucks}};
		};
	_timeOut = 0;
	_pos = _posOrig findEmptyPosition [10,100,_vehicleType];
	while {_timeOut < 60} do
		{
		if (count _pos > 0) exitWith {};
		_timeOut = _timeOut + 1;
		_pos = _posOrig findEmptyPosition [10,100,_vehicleType];
		sleep 1;
		};
	if (count _pos == 0) then {_pos = _posOrig};
	_vehicle=[_pos, _dir,_escortVehType, _group] call bis_fnc_spawnvehicle;
	_veh = _vehicle select 0;
	_veh allowDamage false;
	[_veh,"Convoy Escort"] spawn A3A_fnc_inmuneConvoy;
	_vehCrew = _vehicle select 1;
	{[_x] call A3A_fnc_NATOinit;_x allowDamage false} forEach _vehCrew;
	_soldiers = _soldiers + _vehCrew;
	_vehicles pushBack _veh;
	[_veh] call A3A_fnc_AIVEHinit;
	if (_i == 1) then {_veh setConvoySeparation 60} else {_veh setConvoySeparation 20};
	if (!_isFIA) then
		{
		if (not(_escortVehType in vehTanks)) then
			{
			_groupType = [_escortVehType,_side] call A3A_fnc_cargoSeats;
			_escortGroup = [_posbase,_side, _groupType] call A3A_fnc_spawnGroup;
			{[_x] call A3A_fnc_NATOinit;_x assignAsCargo _veh;_x moveInCargo _veh; _soldiers pushBack _x;[_x] joinSilent _group} forEach units _escortGroup;
			deleteGroup _escortGroup;
			};
		}
	else
		{
		if (not(_escortVehType == vehFIAArmedCar)) then
			{
			_groupType = selectRandom groupsFIASquad;
			if (_escortVehType == vehFIACar) then
				{
				_groupType = selectRandom groupsFIAMid;
				};
			_escortGroup = [_posbase,_side, _groupType] call A3A_fnc_spawnGroup;
			{[_x] call A3A_fnc_NATOinit;_x assignAsCargo _veh;_x moveInCargo _veh; _soldiers pushBack _x;[_x] joinSilent _group} forEach units _escortGroup;
			deleteGroup _escortGroup;
			};
		};
	};

sleep 2;

_timeOut = 0;
_pos = _posOrig findEmptyPosition [10,100,_vehicleType];
while {_timeOut < 60} do
	{
	if (count _pos > 0) exitWith {};
	_timeOut = _timeOut + 1;
	_pos = _posOrig findEmptyPosition [10,100,_vehicleType];
	sleep 1;
	};
if (count _pos == 0) then {_pos = _posOrig};
//_group = createGroup _side;
//_groups pushBack _group;
_vehicle=[_pos, _dir,_vehObjType, _group] call bis_fnc_spawnvehicle;
_vehObj = _vehicle select 0;
_vehObj allowDamage false;
if (_difficulty) then {[_vehObj," Convoy Objective"] spawn A3A_fnc_inmuneConvoy} else {[_vehObj,"Convoy Objective"] spawn A3A_fnc_inmuneConvoy};
_vehCrew = _vehicle select 1;
{[_x] call A3A_fnc_NATOinit; _x allowDamage false} forEach _vehCrew;
//_groupVeh = _vehicle select 2;
_soldiers = _soldiers + _vehCrew;
//_groups pushBack _groupVeh;
_vehicles pushBack _vehObj;
[_vehObj] call A3A_fnc_AIVEHinit;
//_vehObj forceFollowRoad true;
_vehObj setConvoySeparation 50;

if (_convoyType == "Armor") then {_vehObj lock 3};// else {_vehObj forceFollowRoad true};
if (_convoyType == "Prisoners") then
	{
	_grpPOW = createGroup good;
	_groups pushBack _grpPOW;
	for "_i" from 1 to (1+ round (random 11)) do
		{
		_unit = _grpPOW createUnit [SDKUnarmed, _posbase, [], 0, "NONE"];
		[_unit,true] remoteExec ["setCaptive",0,_unit];
		_unit setCaptive true;
		_unit disableAI "MOVE";
		_unit setBehaviour "CARELESS";
		_unit allowFleeing 0;
		_unit assignAsCargo _vehObj;
		_unit moveInCargo [_vehObj, _i + 3];
		removeAllWeapons _unit;
		removeAllAssignedItems _unit;
		[_unit,"refugiado"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_unit];
		_POWS pushBack _unit;
		[_unit] call A3A_fnc_reDress;
		};
	};
if (_convoyType == "Refuerzos") then
	{
	_groupType = [_vehObjType,_side] call A3A_fnc_cargoSeats;
	_escortGroup = [_posbase,_side,_groupType] call A3A_fnc_spawnGroup;
	{[_x] call A3A_fnc_NATOinit;_x assignAsCargo _veh;_x moveInCargo _veh; _soldiers pushBack _x;[_x] joinSilent _group;_reinforcements pushBack _x} forEach units _escortGroup;
	deleteGroup _escortGroup;
	};
if ((_convoyType == "Money") or (_convoyType == "Supplies")) then
	{
	reportedVehs pushBack _vehObj;
	publicVariable "reportedVehs";
	_vehObj addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and ((_this select 4=="") or (side (_this select 3) != good)) and (!isPlayer driver (_this select 0))) then {0} else {(_this select 2)}}];
	};

sleep 2;
_escortVehType = selectRandom _vehPool;
if (not([_escortVehType] call A3A_fnc_vehAvailable)) then
	{
	_vehicleType = if (_side == bad) then {selectRandom vehNATOTrucks} else {selectRandom vehCSATTrucks};
	_vehPool = _vehPool - [_vehicleType];
	if (count _vehPool == 0) then {if (_side == bad) then {_vehPool = vehNATOTrucks} else {_vehPool = vehCSATTrucks}};
	};
_timeOut = 0;
_pos = _posOrig findEmptyPosition [10,100,_vehicleType];
while {_timeOut < 60} do
	{
	if (count _pos > 0) exitWith {};
	_timeOut = _timeOut + 1;
	_pos = _posOrig findEmptyPosition [10,100,_vehicleType];
	sleep 1;
	};
if (count _pos == 0) then {_pos = _posOrig};
//_group = createGroup _side;
//_groups pushBack _group;
_vehicle=[_pos,_dir,_escortVehType, _group] call bis_fnc_spawnvehicle;
_veh = _vehicle select 0;
_veh allowDamage false;
[_veh,"Convoy Escort"] spawn A3A_fnc_inmuneConvoy;
_vehCrew = _vehicle select 1;
{[_x] call A3A_fnc_NATOinit; _x allowDamage false} forEach _vehCrew;
_soldiers = _soldiers + _vehCrew;
_vehicles pushBack _veh;
[_veh] call A3A_fnc_AIVEHinit;
//_veh forceFollowRoad true;
_veh setConvoySeparation 20;
//_veh limitSpeed 50;
if (!_isFIA) then
	{
	if (not(_escortVehType in vehTanks)) then
		{
		_groupType = [_escortVehType,_side] call A3A_fnc_cargoSeats;
		_escortGroup = [_posbase,_side, _groupType] call A3A_fnc_spawnGroup;
		{[_x] call A3A_fnc_NATOinit;_x assignAsCargo _veh;_x moveInCargo _veh; _soldiers pushBack _x;[_x] joinSilent _group} forEach units _escortGroup;
		deleteGroup _escortGroup;
		};
	}
else
	{
	if (not(_escortVehType == vehFIAArmedCar)) then
		{
		_groupType = selectRandom groupsFIASquad;
		if (_escortVehType == vehFIACar) then
			{
			_groupType = selectRandom groupsFIAMid;
			};
		_escortGroup = [_posbase,_side,_groupType] call A3A_fnc_spawnGroup;
		{[_x] call A3A_fnc_NATOinit;_x assignAsCargo _veh;_x moveInCargo _veh; _soldiers pushBack _x;[_x] joinSilent _group} forEach units _escortGroup;
		deleteGroup _escortGroup;
		};
	};

[_vehicles,_soldiers] spawn
	{
	sleep 30;
	{_x allowDamage true} forEach (_this select 0);
	{_x allowDamage true; if (vehicle _x == _x) then {deleteVehicle _x}} forEach (_this select 1);
	};
//{_x disableAI "AUTOCOMBAT"} forEach _soldiers;
_wp0 = _group addWaypoint [(position _vehLead),0];
//_wp0 = (waypoints _group) select 0;
_wp0 setWaypointType "MOVE";
_wp0 setWaypointFormation "COLUMN";
_wp0 setWaypointBehaviour "SAFE";
[_base,_destinationPos,_group] call WPCreate;
_wp0 = _group addWaypoint [_destinationPos, count waypoints _group];
_wp0 setWaypointType "MOVE";

_bonus = if (_difficulty) then {2} else {1};

if (_convoyType == "Municion") then
	{
	waitUntil {sleep 1; (dateToNumber date > _endDateNumeric) or (_vehObj distance _destinationPos < 300) or (not alive _vehObj) or ((driver _vehObj getVariable ["spawner",false]) and (side group (driver _vehObj) == good))};
	if ((_vehObj distance _destinationPos < 100) or (dateToNumber date >_endDateNumeric)) then
		{
		_taskState = "FAILED";
		_taskState1 = "SUCCEEDED";
		[-1200*_bonus] remoteExec ["A3A_fnc_timingCA",2];
		[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		clearMagazineCargoGlobal _vehObj;
		clearWeaponCargoGlobal _vehObj;
		clearItemCargoGlobal _vehObj;
		clearBackpackCargoGlobal _vehObj;
		}
	else
		{
		_taskState = "SUCCEEDED";
		_taskState1 = "FAILED";
		[0,300*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
		[1800*_bonus] remoteExec ["A3A_fnc_timingCA",2];
		{if (isPlayer _x) then {[10*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach ([500,0,_vehObj,good] call A3A_fnc_distanceUnits);
		[5*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		[getPosASL _vehObj,_side,"",false] spawn A3A_fnc_patrolCA;
		if (_side == bad) then {[3,0] remoteExec ["A3A_fnc_prestige",2]} else {[0,3] remoteExec ["A3A_fnc_prestige",2]};
		if (!alive _vehObj) then
			{
			_killZones = killZones getVariable [_base,[]];
			_killZones = _killZones + [_destination,_destination];
			killZones setVariable [_base,_killZones,true];
			};
		};
	};

if (_convoyType == "Armor") then
	{
	waitUntil {sleep 1; (dateToNumber date > _endDateNumeric) or (_vehObj distance _destinationPos < 300) or (not alive _vehObj) or ((driver _vehObj getVariable ["spawner",false]) and (side group (driver _vehObj) == good))};
	if ((_vehObj distance _destinationPos < 100) or (dateToNumber date > _endDateNumeric)) then
		{
		_taskState = "FAILED";
		_taskState1 = "SUCCEEDED";
		server setVariable [_destination,dateToNumber date,true];
		[-1200*_bonus] remoteExec ["A3A_fnc_timingCA",2];
		[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		}
	else
		{
		_taskState = "SUCCEEDED";
		_taskState1 = "FAILED";
		[5,0] remoteExec ["A3A_fnc_prestige",2];
		[0,5*_bonus,_destinationPos] remoteExec ["A3A_fnc_citySupportChange",2];
		[1800*_bonus] remoteExec ["A3A_fnc_timingCA",2];
		{if (isPlayer _x) then {[10*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach ([500,0,_vehObj,good] call A3A_fnc_distanceUnits);
		[5*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		[getPosASL _vehObj,_side,"",false] spawn A3A_fnc_patrolCA;
		if (_side == bad) then {[3,0] remoteExec ["A3A_fnc_prestige",2]} else {[0,3] remoteExec ["A3A_fnc_prestige",2]};
		if (!alive _vehObj) then
			{
			_killZones = killZones getVariable [_base,[]];
			_killZones = _killZones + [_destination,_destination];
			killZones setVariable [_base,_killZones,true];
			};
		};
	};

if (_convoyType == "Prisoners") then
	{
	waitUntil {sleep 1; (dateToNumber date > _endDateNumeric) or (_vehObj distance _destinationPos < 300) or (not alive driver _vehObj) or ((driver _vehObj getVariable ["spawner",false]) and (side group (driver _vehObj == good))) or ({alive _x} count _POWs == 0)};
	if ((_vehObj distance _destinationPos < 100) or ({alive _x} count _POWs == 0) or (dateToNumber date > _endDateNumeric)) then
		{
		_taskState = "FAILED";
		_taskState1 = "SUCCEEDED";
		{[_x,false] remoteExec ["setCaptive",0,_x]; _x setCaptive false} forEach _POWs;
		//_count = 2 * (count _POWs);
		//[_count,0] remoteExec ["A3A_fnc_prestige",2];
		[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		};
	if ((not alive driver _vehObj) or ((driver _vehObj getVariable ["spawner",false]) and (side group (driver _vehObj) == good))) then
		{
		[getPosASL _vehObj,_side,"",false] spawn A3A_fnc_patrolCA;
		{[_x,false] remoteExec ["setCaptive",0,_x]; _x setCaptive false; _x enableAI "MOVE"; [_x] orderGetin false} forEach _POWs;
		waitUntil {sleep 2; ({alive _x} count _POWs == 0) or ({(alive _x) and (_x distance _posHQ < 50)} count _POWs > 0) or (dateToNumber date > _endDateNumeric)};
		if (({alive _x} count _POWs == 0) or (dateToNumber date > _endDateNumeric)) then
			{
			_taskState = "FAILED";
			_taskState1 = "FAILED";
			_count = 2 * (count _POWs);
			//[0,- _count, _destinationPos] remoteExec ["A3A_fnc_citySupportChange",2];
			[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
			_killZones = killZones getVariable [_base,[]];
			_killZones = _killZones + [_destination,_destination];
			killZones setVariable [_base,_killZones,true];
			}
		else
			{
			_taskState = "SUCCEEDED";
			_taskState1 = "FAILED";
			_count = {(alive _x) and (_x distance _posHQ < 150)} count _POWs;
			_hr = _count;
			_resourcesFIA = 300 * _count;
			[_hr,_resourcesFIA*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
			[0,10*_bonus,_posbase] remoteExec ["A3A_fnc_citySupportChange",2];
			if (_side == bad) then {[3,0] remoteExec ["A3A_fnc_prestige",2]} else {[-2*_count,3] remoteExec ["A3A_fnc_prestige",2]};
			{[_x] join _grppow; [_x] orderGetin false} forEach _POWs;
			{[_count,_x] call A3A_fnc_playerScoreAdd} forEach (allPlayers - (entities "HeadlessClient_F"));
			[(round (_count/2))*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
			};
		};
	};

if (_convoyType == "Refuerzos") then
	{
	waitUntil {sleep 1; (dateToNumber date > _endDateNumeric) or (_vehObj distance _destinationPos < 300) or ({(!alive _x) or (captive _x)} count _reinforcements == count _reinforcements)};
	if ({(!alive _x) or (captive _x)} count _reinforcements == count _reinforcements) then
		{
		_taskState = "SUCCEEDED";
		_taskState1 = "FAILED";
		[0,10*_bonus,_posbase] remoteExec ["A3A_fnc_citySupportChange",2];
		if (_side == bad) then {[3,0] remoteExec ["A3A_fnc_prestige",2]} else {[0,3] remoteExec ["A3A_fnc_prestige",2]};
		{if (_x distance _vehObj < 500) then {[10*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
		[5*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		_killZones = killZones getVariable [_base,[]];
		_killZones = _killZones + [_destination,_destination];
		killZones setVariable [_base,_killZones,true];
		}
	else
		{
		_taskState = "FAILED";
		_count = {alive _x} count _reinforcements;
		if (_count > 8) then {_taskState1 = "SUCCEEDED"} else {_taskState = "FAILED"};
		[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		if (sides getVariable [_destination,sideUnknown] != good) then
			{
			_types = [];
			{_types pushBack (typeOf _x)} forEach (_reinforcements select {alive _x});
			[_soldiers,_side,_destination,0] remoteExec ["A3A_fnc_garrisonUpdate",2];
			};
		if (_side == bad) then {[(-1*(0.25*_count)),0] remoteExec ["A3A_fnc_prestige",2]} else {[0,(-1*(0.25*_count))] remoteExec ["A3A_fnc_prestige",2]};
		};
	};

if (_convoyType == "Money") then
	{
	waitUntil {sleep 1; (dateToNumber date > _endDateNumeric) or (_vehObj distance _destinationPos < 300) or (not alive _vehObj) or ((driver _vehObj getVariable ["spawner",false]) and (side group (driver _vehObj) == good))};
	if ((dateToNumber date > _endDateNumeric) or (_vehObj distance _destinationPos < 100) or (not alive _vehObj)) then
		{
		_taskState = "FAILED";
		if ((dateToNumber date > _endDateNumeric) or (_vehObj distance _destinationPos < 100)) then
			{
			[-1200*_bonus] remoteExec ["A3A_fnc_timingCA",2];
			[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
			_taskState1 = "SUCCEEDED";
			}
		else
			{
			[getPosASL _vehObj,_side,"",false] spawn A3A_fnc_patrolCA;
			[1200*_bonus] remoteExec ["A3A_fnc_timingCA",2];
			_taskState1 = "FAILED";
			_killZones = killZones getVariable [_base,[]];
			_killZones = _killZones + [_destination,_destination];
			killZones setVariable [_base,_killZones,true];
			};
		};
	if ((driver _vehObj getVariable ["spawner",false]) and (side group (driver _vehObj) == good)) then
		{
		[getPosASL _vehObj,_side,"",false] spawn A3A_fnc_patrolCA;
		waitUntil {sleep 2; (_vehObj distance _posHQ < 50) or (not alive _vehObj) or (dateToNumber date > _endDateNumeric)};
		if ((not alive _vehObj) or (dateToNumber date > _endDateNumeric)) then
			{
			_taskState = "FAILED";
			_taskState1 = "FAILED";
			[1200*_bonus] remoteExec ["A3A_fnc_timingCA",2];
			};
		if (_vehObj distance _posHQ < 50) then
			{
			_taskState = "SUCCEEDED";
			_taskState1 = "FAILED";
			[10*_bonus,-20*_bonus,_destinationPos] remoteExec ["A3A_fnc_citySupportChange",2];
			[3,0] remoteExec ["A3A_fnc_prestige",2];
			[0,5000*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
			[-120*_bonus] remoteExec ["A3A_fnc_timingCA",2];
			{if (_x distance _vehObj < 500) then {[10*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
			[5*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
			waitUntil {sleep 1; speed _vehObj < 1};
			[_vehObj] call A3A_fnc_vaciar;
			deleteVehicle _vehObj;
			};
		};
	reportedVehs = reportedVehs - [_vehObj];
	publicVariable "reportedVehs";
	};

if (_convoyType == "Supplies") then
	{
	waitUntil {sleep 1; (dateToNumber date > _endDateNumeric) or (_vehObj distance _destinationPos < 300) or (not alive _vehObj) or ((driver _vehObj getVariable ["spawner",false]) and (side group (driver _vehObj) == good))};
	if (not alive _vehObj) then
		{
		[getPosASL _vehObj,_side,"",false] spawn A3A_fnc_patrolCA;
		_taskState = "FAILED";
		_taskState1 = "FAILED";
		[3,0] remoteExec ["A3A_fnc_prestige",2];
		[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		_killZones = killZones getVariable [_base,[]];
		_killZones = _killZones + [_destination,_destination];
		killZones setVariable [_base,_killZones,true];
		};
	if ((dateToNumber date > _endDateNumeric) or (_vehObj distance _destinationPos < 300) or ((driver _vehObj getVariable ["spawner",false]) and (side group (driver _vehObj) == good))) then
		{
		if ((driver _vehObj getVariable ["spawner",false]) and (side group (driver _vehObj) == good)) then
			{
			[getPosASL _vehObj,_side,"",false] spawn A3A_fnc_patrolCA;
			waitUntil {sleep 1; (_vehObj distance _destinationPos < 100) or (not alive _vehObj) or (dateToNumber date > _endDateNumeric)};
			if (_vehObj distance _destinationPos < 100) then
				{
				_taskState = "SUCCEEDED";
				_taskState1 = "FAILED";
				[0,15*_bonus,_destination] remoteExec ["A3A_fnc_citySupportChange",2];
				{if (_x distance _vehObj < 500) then {[10*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
				[5*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
				}
			else
				{
				_taskState = "FAILED";
				_taskState1 = "FAILED";
				[5*_bonus,-10*_bonus,_destination] remoteExec ["A3A_fnc_citySupportChange",2];
				[3,0] remoteExec ["A3A_fnc_prestige",2];
				[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
				};
			}
		else
			{
			_taskState = "FAILED";
			_taskState1 = "SUCCEEDED";
			[-3,0] remoteExec ["A3A_fnc_prestige",2];
			[15*_bonus,0,_destination] remoteExec ["A3A_fnc_citySupportChange",2];
			[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
			};
		};
	reportedVehs = reportedVehs - [_vehObj];
	publicVariable "reportedVehs";
	};

["CONVOY",[_text,_taskTitle,_destination],_destinationPos,_taskState] call A3A_fnc_taskUpdate;
["CONVOY1",[format ["A convoy from %1 to %4, it's about to depart at %2:%3. Protect it from any possible attack.",_originName,numberToDate [2035,_departureDateNumeric] select 3,numberToDate [2035,_departureDateNumeric] select 4,_destinationName],"Protect Convoy",_destination],_destinationPos,_taskState1] call A3A_fnc_taskUpdate;
_wp0 = _group addWaypoint [_posbase, 0];
_wp0 setWaypointType "MOVE";
_wp0 setWaypointBehaviour "SAFE";
_wp0 setWaypointSpeed "LIMITED";
_wp0 setWaypointFormation "COLUMN";

if (_convoyType == "Prisoners") then
	{
	{
	deleteVehicle _x;
	} forEach _POWs;
	};

_nul = [600,"CONVOY"] spawn A3A_fnc_borrarTask;
_nul = [0,"CONVOY1"] spawn A3A_fnc_borrarTask;
{
if (!([distanceSPWN,1,_x,good] call A3A_fnc_distanceUnits)) then {deleteVehicle _x}
} forEach _vehicles;
{
if (!([distanceSPWN,1,_x,good] call A3A_fnc_distanceUnits)) then {deleteVehicle _x; _soldiers = _soldiers - [_x]}
} forEach _soldiers;

if (count _soldiers > 0) then
	{
	{
	waitUntil {sleep 1; (!([distanceSPWN,1,_x,good] call A3A_fnc_distanceUnits))};
	deleteVehicle _x;
	} forEach _soldiers;
	};
{deleteGroup _x} forEach _groups;




