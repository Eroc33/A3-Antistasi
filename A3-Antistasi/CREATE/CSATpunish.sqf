if (!isServer and hasInterface) exitWith {};
private ["_originPos","_groupType","_originName","_markTsk","_wp1","_soldiers","_landpos","_pad","_vehicles","_wp0","_wp3","_wp4","_wp2","_group","_groups","_vehicleType","_vehicle","_heli","_heliCrew","_heliGroup","_pilots","_rnd","_resourcesAAF","_nVeh","_roads","_Vwp1","_tanks","_road","_veh","_vehCrew","_groupVeh","_Vwp0","_size","_Hwp0","_grupo1","_uav","_groupUav","_uwp0","_tsk","_soldier","_pilot","_mrkDestination","_destinationPos","_prestigeCSAT","_base","_airport","_destinationName","_time","_solMax","_nul","_pos","_timeOut"];
_mrkDestination = _this select 0;
_mrkOrigin = _this select 1;
bigAttackInProgress = true;
publicVariable "bigAttackInProgress";
_destinationPos = getMarkerPos _mrkDestination;
_originPos = getMarkerPos _mrkOrigin;
_groups = [];
_soldiers = [];
_pilots = [];
_vehicles = [];
_civiles = [];

_destinationName = [_mrkDestination] call A3A_fnc_localizar;
[[good,civilian,bad],"AtaqueAAF",[format ["%2 is making a punishment expedition to %1. They will kill everybody there. Defend the city at all costs",_destinationName,nameMuyMalos],format ["%1 Punishment",nameMuyMalos],_mrkDestination],getMarkerPos _mrkDestination,false,0,true,"Defend",true] call BIS_fnc_taskCreate;

_nul = [_mrkOrigin,_mrkDestination,veryBad] spawn A3A_fnc_artilleria;
_side = if (sides getVariable [_mrkDestination,sideUnknown] == bad) then {bad} else {good};
_time = time + 3600;

for "_i" from 1 to 3 do
	{
	_vehicleType = if (_i != 3) then {selectRandom (vehCSATAir select {[_x] call A3A_fnc_vehAvailable})} else {selectRandom (vehCSATTransportHelis select {[_x] call A3A_fnc_vehAvailable})};
	_timeOut = 0;
	_pos = _originPos findEmptyPosition [0,100,_vehicleType];
	while {_timeOut < 60} do
		{
		if (count _pos > 0) exitWith {};
		_timeOut = _timeOut + 1;
		_pos = _originPos findEmptyPosition [0,100,_vehicleType];
		sleep 1;
		};
	if (count _pos == 0) then {_pos = _originPos};
	_vehicle=[_pos, 0, _vehicleType, veryBad] call bis_fnc_spawnvehicle;
	_heli = _vehicle select 0;
	_heliCrew = _vehicle select 1;
	{[_x] call A3A_fnc_NATOinit} forEach _heliCrew;
	[_heli] call A3A_fnc_AIVEHinit;
	_heliGroup = _vehicle select 2;
	_pilots = _pilots + _heliCrew;
	_groups pushBack _heliGroup;
	_vehicles pushBack _heli;
	//_heli lock 3;
	if (not(_vehicleType in vehCSATTransportHelis)) then
		{
		{[_x] call A3A_fnc_NATOinit} forEach _heliCrew;
		_wp1 = _heliGroup addWaypoint [_destinationPos, 0];
		_wp1 setWaypointType "SAD";
		//[_heli,"Air Attack"] spawn A3A_fnc_inmuneConvoy;
		}
	else
		{
		{_x setBehaviour "CARELESS";} forEach units _heliGroup;
		_groupType = [_vehicleType,veryBad] call A3A_fnc_cargoSeats;
		_group = [_originPos, veryBad, _groupType] call A3A_fnc_spawnGroup;
		{_x assignAsCargo _heli;_x moveInCargo _heli; _soldiers pushBack _x; [_x] call A3A_fnc_NATOinit; _x setVariable ["origen",_mrkOrigin]} forEach units _group;
		_groups pushBack _group;
		//[_heli,"CSAT Air Transport"] spawn A3A_fnc_inmuneConvoy;

		if (not(_vehicleType in vehFastRope)) then
			{

			_landPos = _destinationPos getPos [(random 500) + 300, random 360];

			_landPos = [_landPos, 200, 350, 10, 0, 0.20, 0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if !(_landPos isEqualTo [0,0,0]) then
				{
				_landPos set [2, 0];
				_pad = createVehicle ["Land_HelipadEmpty_F", _landpos, [], 0, "NONE"];
				_vehicles pushBack _pad;
				_wp0 = _heliGroup addWaypoint [_landpos, 0];
				_wp0 setWaypointType "TR UNLOAD";
				_wp0 setWaypointStatements ["true", "(vehicle this) land 'GET OUT'"];
				[_heliGroup,0] setWaypointBehaviour "CARELESS";
				_wp3 = _group addWaypoint [_landpos, 0];
				_wp3 setWaypointType "GETOUT";
				_wp0 synchronizeWaypoint [_wp3];
				_wp4 = _group addWaypoint [_destinationPos, 1];
				_wp4 setWaypointType "SAD";
				_wp4 setWaypointStatements ["true","{if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
				_wp2 = _heliGroup addWaypoint [_originPos, 1];
				_wp2 setWaypointType "MOVE";
				_wp2 setWaypointStatements ["true", "deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList"];
				[_heliGroup,1] setWaypointBehaviour "AWARE";
				}
			else
				{
				[_heli,_group,_mrkDestination,_mrkOrigin] spawn A3A_fnc_airdrop;
				};
			}
		else
			{
			{_x disableAI "TARGET"; _x disableAI "AUTOTARGET"} foreach units _heliGroup;
			[_heli,_group,_destinationPos,_originPos,_heliGroup] spawn A3A_fnc_fastrope;
			};
		};
	sleep 20;
	};

_data = server getVariable _mrkDestination;

_numCiv = _data select 0;
_numCiv = round (_numCiv /10);

if (sides getVariable [_mrkDestination,sideUnknown] == bad) then {[[_destinationPos,bad,"",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2]};

if (_numCiv < 8) then {_numCiv = 8};

_size = [_mrkDestination] call A3A_fnc_sizeMarker;
//_grupoCivil = if (_side == good) then {createGroup good} else {createGroup bad};
_grupoCivil = createGroup good;
_groups pushBack _grupoCivil;
//[veryBad,[civilian,0]] remoteExec ["setFriend",2];
_unitType = if (_side == good) then {SDKUnarmed} else {NATOUnarmed};
for "_i" from 0 to _numCiv do
	{
	while {true} do
		{
		_pos = _destinationPos getPos [random _size,random 360];
		if (!surfaceIsWater _pos) exitWith {};
		};
	_unitType = selectRandom arrayCivs;
	_civ = _grupoCivil createUnit [_unitType,_pos, [],0,"NONE"];
	_civ forceAddUniform (selectRandom civUniforms);
	_rnd = random 100;
	if (_rnd < 90) then
		{
		if (_rnd < 25) then {[_civ, "hgun_PDW2000_F", 5, 0] call BIS_fnc_addWeapon;} else {[_civ, "hgun_Pistol_heavy_02_F", 5, 0] call BIS_fnc_addWeapon;};
		};
	_civiles pushBack _civ;
	[_civ] call A3A_fnc_civInit;
	sleep 0.5;
	};

_nul = [leader _grupoCivil, _mrkDestination, "AWARE","SPAWNED","NOVEH2"] execVM "scripts\UPSMON.sqf";

_civilMax = {alive _x} count _civiles;
_solMax = count _soldiers;

for "_i" from 0 to round random 2 do
	{
	if ([vehCSATPlane] call A3A_fnc_vehAvailable) then
		{
		_nul = [_mrkDestination,veryBad,"NAPALM"] spawn A3A_fnc_airstrike;
		sleep 30;
		};
	};

waitUntil {sleep 5; (({not (captive _x)} count _soldiers) < ({captive _x} count _soldiers)) or ({alive _x} count _soldiers < round (_solMax / 3)) or (({(_x distance _destinationPos < _size*2) and (not(vehicle _x isKindOf "Air")) and (alive _x) and (!captive _x)} count _soldiers) > 4*({(alive _x) and (_x distance _destinationPos < _size*2)} count _civiles)) or (time > _time)};

if ((({not (captive _x)} count _soldiers) < ({captive _x} count _soldiers)) or ({alive _x} count _soldiers < round (_solMax / 3)) or (time > _time)) then
	{
	{_x doMove [0,0,0]} forEach _soldiers;
	//["AtaqueAAF", "SUCCEEDED",true] spawn BIS_fnc_taskSetState;
	["AtaqueAAF",[format ["%2 is making a punishment expedition to %1. They will kill everybody there. Defend the city at all costs",_destinationName,nameMuyMalos],format ["%1 Punishment",nameMuyMalos],_mrkDestination],getMarkerPos _mrkDestination,"SUCCEEDED"] call A3A_fnc_taskUpdate;
	if ({(side _x == good) and (_x distance _destinationPos < _size * 2)} count allUnits >= {(side _x == bad) and (_x distance _destinationPos < _size * 2)} count allUnits) then
		{
		if (sides getVariable [_mrkDestination,sideUnknown] == bad) then {[-15,15,_destinationPos] remoteExec ["A3A_fnc_citySupportChange",2]} else {[-5,15,_destinationPos] remoteExec ["A3A_fnc_citySupportChange",2]};
		[-5,0] remoteExec ["A3A_fnc_prestige",2];
		{[-10,10,_x] remoteExec ["A3A_fnc_citySupportChange",2]} forEach ciudades;
		{if (isPlayer _x) then {[10,_x] call A3A_fnc_playerScoreAdd}} forEach ([500,0,_destinationPos,good] call A3A_fnc_distanceUnits);
		[10,theBoss] call A3A_fnc_playerScoreAdd;
		}
	else
		{
		if (sides getVariable [_mrkDestination,sideUnknown] == bad) then {[15,-5,_destinationPos] remoteExec ["A3A_fnc_citySupportChange",2]} else {[15,-15,_destinationPos] remoteExec ["A3A_fnc_citySupportChange",2]};
		{[10,-10,_x] remoteExec ["A3A_fnc_citySupportChange",2]} forEach ciudades;
		};
	}
else
	{
	["AtaqueAAF",[format ["%2 is making a punishment expedition to %1. They will kill everybody there. Defend the city at all costs",_destinationName,nameMuyMalos],format ["%1 Punishment",nameMuyMalos],_mrkDestination],getMarkerPos _mrkDestination,"FAILED"] call A3A_fnc_taskUpdate;
	//["AtaqueAAF", "FAILED",true] spawn BIS_fnc_taskSetState;
	[-20,-20,_destinationPos] remoteExec ["A3A_fnc_citySupportChange",2];
	{[-10,-10,_x] remoteExec ["A3A_fnc_citySupportChange",2]} forEach ciudades;
	destroyedCities = destroyedCities + [_mrkDestination];
	publicVariable "destroyedCities";
	for "_i" from 1 to 60 do
		{
		_mine = createMine ["APERSMine",_destinationPos,[],_size];
		veryBad revealMine _mine;
		};
	[_mrkDestination] call A3A_fnc_destroyCity;
	};

sleep 15;
//[veryBad,[civilian,1]] remoteExec ["setFriend",2];
_nul = [0,"AtaqueAAF"] spawn A3A_fnc_borrarTask;
[7200] remoteExec ["A3A_fnc_timingCA",2];
{
_veh = _x;
if (!([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)) then {deleteVehicle _x};
} forEach _vehicles;
{
_veh = _x;
if (!([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)) then {deleteVehicle _x; _soldiers = _soldiers - [_x]};
} forEach _soldiers;
{
_veh = _x;
if (!([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)) then {deleteVehicle _x; _pilots = _pilots - [_x]};
} forEach _pilots;

bigAttackInProgress = false;
publicVariable "bigAttackInProgress";

if (count _soldiers > 0) then
	{
	{
	_veh = _x;
	waitUntil {sleep 1; !([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)};
	deleteVehicle _veh;
	} forEach _soldiers;
	};

if (count _pilots > 0) then
	{
	{
	_veh = _x;
	waitUntil {sleep 1; !([distanceSPWN,1,_x,good] call A3A_fnc_distanceUnits) and (({_x distance _veh <= distanceSPWN} count (allPlayers - (entities "HeadlessClient_F"))) == 0)};
	deleteVehicle _veh;
	} forEach _pilots;
	};
{deleteGroup _x} forEach _groups;

waitUntil {sleep 1; (spawner getVariable _mrkDestination == 2)};

{deleteVehicle _x} forEach _civiles;
deleteGroup _grupoCivil;
