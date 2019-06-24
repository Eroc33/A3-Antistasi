if (!isServer and hasInterface) exitWith{};

private ["_poscrash","_marker","_position","_mrkfin","_vehicleType","_efecto","_heli","_vehicles","_soldiers","_groups","_unit","_roads","_road","_vehicle","_veh","_groupType","_tsk","_smoke","_emitterArray","_count"];

_marker = _this select 0;

_difficulty = if (random 10 < tierWar) then {true} else {false};
_exit = false;
_contact = objNull;
_grpContact = grpNull;
_tsk = "";
_tsk1 = "";
_position = getMarkerPos _marker;
_side = if (sides getVariable [_marker,sideUnknown] == bad) then {bad} else {veryBad};
_posHQ = getMarkerPos respawnGood;

_timeDelay = 120;
_dateDelay = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeDelay];
_dateDelayNumeric = dateToNumber _dateDelay;
_ang = random 360;
_count = 0;
_dist = if (_difficulty) then {2000} else {3000};
while {true} do
	{
	_poscrashOrig = _position getPos [_dist,_ang];
	if ((!surfaceIsWater _poscrashOrig) and (_poscrashOrig distance _posHQ < 4000)) exitWith {};
	_ang = _ang + 1;
	_count = _count + 1;
	if (_count > 360) then
		{
		_count = 0;
		_dist = _dist - 500;
		};
	};

_vehicleType = selectRandom (vehPlanes + vehAttackHelis + vehTransportAir);

_posCrashMrk = [_poscrash,random 500,random 360] call BIS_fnc_relPos;
_posCrash = _posCrashOrig findEmptyPosition [0,100,_vehicleType];
if (count _posCrash == 0) then
	{
	if (!isMultiplayer) then {{ _x hideObject true } foreach (nearestTerrainObjects [_posCrashOrig,["tree","bush"],50])} else {{[_x,true] remoteExec ["hideObjectGlobal",2]} foreach (nearestTerrainObjects [_posCrashOrig,["tree","bush"],50])};
	_posCrash = _posCrashOrig;
	};
_mrkfin = createMarker [format ["DES%1", random 100], _posCrashMrk];
_mrkfin setMarkerShape "ICON";
//_mrkfin setMarkerType "hd_destroy";
//_mrkfin setMarkerColor "ColorRed";
//_mrkfin setMarkerText "Destroy Downed Chopper";

_baseName = [_marker] call A3A_fnc_localizar;
/*
if (!_difficulty) then
	{
	[[good,civilian],"DES",[format ["We have downed air vehicle. It is a good chance to destroy it before it is recovered. Do it before a recovery team from the %1 reaches the place. MOVE QUICKLY",_baseName],"Destroy Air",_mrkfin],_posCrashMrk,false,0,true,"Destroy",true] call BIS_fnc_taskCreate
	}
else
	{
	["DES",[format ["We have downed air vehicle. It is a good chance to destroy it before it is recovered. Do it before a recovery team from the %1 reaches the place. MOVE QUICKLY",_baseName],"Destroy Air",_mrkfin],_posCrashMrk,"CREATED","Destroy"] call A3A_fnc_taskUpdate;
	};*/
//missions pushBack _tsk; publicVariable "missions";
[[good,civilian],"DES",[format ["We have downed air vehicle. It is a good chance to destroy it before it is recovered. Do it before a recovery team from the %1 reaches the place. MOVE QUICKLY",_baseName],"Destroy Air",_mrkfin],_posCrashMrk,false,0,true,"Destroy",true] call BIS_fnc_taskCreate;
[[good,civilian],"DES1",[format ["The rebels managed to shot down a helicopter. A recovery team departing from the %1 is inbound to recover it. Cover them while they perform the whole operation",_baseName],"Helicopter Down",_mrkfin],_posCrash,false,0,true,"Defend",true] call BIS_fnc_taskCreate;
missions pushBack ["DES","CREATED"]; publicVariable "missions";
_vehicles = [];
_soldiers = [];
_groups = [];

_efecto = createVehicle ["CraterLong", _poscrash, [], 0, "CAN_COLLIDE"];
_heli = createVehicle [_vehicleType, _poscrash, [], 0, "CAN_COLLIDE"];
_heli attachTo [_efecto,[0,0,1.5]];
_smoke = "test_EmptyObjectForSmoke" createVehicle _poscrash; _smoke attachTo[_heli,[0,1.5,-1]];
_heli setDamage 0.9;
_heli lock 2;
_vehicles = _vehicles + [_heli,_efecto];

_size = 100;

while {true} do
	{
	_roads = _position nearRoads _size;
	if (count _roads > 0) exitWith {};
	_size = _size + 50;
	};

_road = _roads select 0;
_vehicleType = if (_side == bad) then {selectRandom vehNATOLightUnarmed} else {selectRandom vehCSATLightUnarmed};
_vehicle=[position _road, 0,_vehicleType, _side] call bis_fnc_spawnvehicle;
_veh = _vehicle select 0;
[_veh] call A3A_fnc_AIVEHinit;
//[_veh,"Escort"] spawn A3A_fnc_inmuneConvoy;
_vehCrew = _vehicle select 1;
{[_x] call A3A_fnc_NATOinit} forEach _vehCrew;
_groupVeh = _vehicle select 2;
_soldiers = _soldiers + _vehCrew;
_groups pushBack _groupVeh;
_vehicles pushBack _veh;

sleep 1;
_groupType = if (_side == bad) then {groupsNATOSentry} else {groupsCSATSentry};
_group = [_position, _side, _groupType] call A3A_fnc_spawnGroup;

{_x assignAsCargo _veh; _x moveInCargo _veh; _soldiers pushBack _x; [_x] join _groupVeh; [_x] call A3A_fnc_NATOinit} forEach units _group;
deleteGroup _group;
//[_veh] spawn smokeCover;

_Vwp0 = _groupVeh addWaypoint [_poscrash, 0];
_Vwp0 setWaypointType "TR UNLOAD";
_Vwp0 setWaypointBehaviour "SAFE";
_Gwp0 = _group addWaypoint [_poscrash, 0];
_Gwp0 setWaypointType "GETOUT";
_Vwp0 synchronizeWaypoint [_Gwp0];

sleep 15;
_vehicleType = if (_side == bad) then {vehNATOTrucks select 0} else {vehCSATTrucks select 0};
_vehicleT=[position _road, 0,_vehicleType, _side] call bis_fnc_spawnvehicle;
_vehT = _vehicleT select 0;
[_vehT] call A3A_fnc_AIVEHinit;
//[_vehT,"Recover Truck"] spawn A3A_fnc_inmuneConvoy;
_vehCrewT = _vehicle select 1;
{[_x] call A3A_fnc_NATOinit} forEach _vehCrewT;
_grupoVehT = _vehicleT select 2;
_soldiers = _soldiers + _vehCrewT;
_groups pushBack _grupoVehT;
_vehicles pushBack _vehT;

_Vwp0 = _grupoVehT addWaypoint [_poscrash, 0];
_Vwp0 setWaypointType "MOVE";
_Vwp0 setWaypointBehaviour "SAFE";
waitUntil {sleep 1; (not alive _heli) or (_vehT distance _heli < 50) or (dateToNumber date > _dateDelayNumeric)};

if (_vehT distance _heli < 50) then
	{
	_vehT doMove position _heli;
	sleep 60;
	if (alive _heli) then
		{
		_heli attachTo [_vehT,[0,-3,2]];
		_emitterArray = _smoke getVariable "effects";
		{deleteVehicle _x} forEach _emitterArray;
		deleteVehicle _smoke;
		};

	_Vwp0 = _grupoVehT addWaypoint [_position, 1];
	_Vwp0 setWaypointType "MOVE";
	_Vwp0 setWaypointBehaviour "SAFE";

	_Vwp0 = _groupVeh addWaypoint [_poscrash, 0];
	_Vwp0 setWaypointType "LOAD";
	_Vwp0 setWaypointBehaviour "SAFE";
	_Gwp0 = _group addWaypoint [_poscrash, 0];
	_Gwp0 setWaypointType "GETIN";
	_Vwp0 synchronizeWaypoint [_Gwp0];

	_Vwp0 = _groupVeh addWaypoint [_position, 2];
	_Vwp0 setWaypointType "MOVE";
	_Vwp0 setWaypointBehaviour "SAFE";

	};

waitUntil {sleep 1; (not alive _heli) or (_vehT distance _position < 100) or (dateToNumber date > _dateDelayNumeric)};

_bonus = if (_difficulty) then {2} else {1};

if (not alive _heli) then
	{
	["DES",[format ["We have downed air vehicle. It is a good chance to destroy it before it is recovered. Do it before a recovery team from the %1 reaches the place. MOVE QUICKLY",_baseName],"Destroy Air",_mrkfin],_posCrashMrk,"SUCCEEDED","Destroy"] call A3A_fnc_taskUpdate;
	[0,300*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
	if (typeOf _heli in vehCSATAir) then {[0,3] remoteExec ["A3A_fnc_prestige",2]} else {[3,0] remoteExec ["A3A_fnc_prestige",2]};
	//[-3,3,_position] remoteExec ["A3A_fnc_citySupportChange",2];
	[1800*_bonus] remoteExec ["A3A_fnc_timingCA",2];
	{if (_x distance _heli < 500) then {[10*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
	[5*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
	["DES1",[format ["The rebels managed to shot down a helicopter. A recovery team departing from the %1 is inbound to recover it. Cover them while they perform the whole operation",_baseName],"Helicopter Down",_mrkfin],_posCrash,"FAILED","Defend"] call A3A_fnc_taskUpdate;
	}
else
	{
	["DES",[format ["We have downed air vehicle. It is a good chance to destroy it before it is recovered. Do it before a recovery team from the %1 reaches the place. MOVE QUICKLY",_baseName],"Destroy Air",_mrkfin],_posCrashMrk,"FAILED","Destroy"] call A3A_fnc_taskUpdate;
	["DES1",[format ["The rebels managed to shot down a helicopter. A recovery team departing from the %1 is inbound to recover it. Cover them while they perform the whole operation",_baseName],"Helicopter Down",_mrkfin],_posCrash,"SUCCEEDED","Defend"] call A3A_fnc_taskUpdate;
	//[3,0,_position] remoteExec ["A3A_fnc_citySupportChange",2];
	[-600*_bonus] remoteExec ["A3A_fnc_timingCA",2];
	[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
	};

if (!isNull _smoke) then
	{
	_emitterArray = _smoke getVariable "effects";
	{deleteVehicle _x} forEach _emitterArray;
	deleteVehicle _smoke;
	};

_nul = [1200,"DES"] spawn A3A_fnc_borrarTask;
_nul = [0,"DES1"] spawn A3A_fnc_borrarTask;
deleteMarker _mrkfin;
{
waitUntil {sleep 1;(!([distanceSPWN,1,_x,good] call A3A_fnc_distanceUnits))};
deleteVehicle _x} forEach _vehicles;
{deleteVehicle _x} forEach _soldiers;
{deleteGroup _x} forEach _groups;

//sleep (600 + random 1200);

//_nul = [_tsk,true] call BIS_fnc_deleteTask;




