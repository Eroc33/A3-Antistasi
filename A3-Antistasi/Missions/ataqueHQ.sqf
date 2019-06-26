if (!isServer and hasInterface) exitWith{};

_position = getMarkerPos respawnGood;

_pilots = [];
_vehicles = [];
_groups = [];
_soldiers = [];

if ({(_x distance _position < 500) and (typeOf _x == staticAABuenos)} count staticsToSave > 4) exitWith {};

_airports = airports select {(sides getVariable [_x,sideUnknown] != good) and (spawner getVariable _x == 2)};
if (count _airports == 0) exitWith {};
_airport = [_airports,_position] call BIS_fnc_nearestPosition;
_originPos = getMarkerPos _airport;
_side = if (sides getVariable [_airport,sideUnknown] == bad) then {bad} else {veryBad};
_tsk1 = "";
_tsk = "";
[[good,civilian],"DEF_HQ",[format ["Enemy knows our HQ coordinates. They have sent a SpecOp Squad in order to kill %1. Intercept them and kill them. Or you may move our HQ 1Km away so they will loose track",name petros],format ["Defend %1",name petros],respawnGood],_position,true,10,true,"Defend",true] call BIS_fnc_taskCreate;
[[_side],"DEF_HQ1",[format ["We know %2 HQ coordinates. We have sent a SpecOp Squad in order to kill his leader %1. Help the SpecOp team",name petros, nameBuenos],format ["Kill %1",name petros],respawnGood],_position,true,10,true,"Attack",true] call BIS_fnc_taskCreate;
missions pushBack ["DEF_HQ","CREATED"]; publicVariable "missions";
_vehicleTypes = if (_side == bad) then {vehNATOAttackHelis} else {vehCSATAttackHelis};
_vehicleTypes = _vehicleTypes select {[_x] call A3A_fnc_vehAvailable};

if (count _vehicleTypes > 0) then
	{
	_vehicleType = selectRandom _vehicleTypes;
	//_pos = [_position, distanceSPWN * 3, random 360] call BIS_Fnc_relPos;
	_vehicle=[_originPos, 0, _vehicleType, _side] call bis_fnc_spawnvehicle;
	_heli = _vehicle select 0;
	_heliCrew = _vehicle select 1;
	_heliGroup = _vehicle select 2;
	_pilots = _pilots + _heliCrew;
	_groups pushBack _heliGroup;
	_vehicles pushBack _heli;
	{[_x] call A3A_fnc_NATOinit} forEach _heliCrew;
	[_heli] call A3A_fnc_AIVEHinit;
	_wp1 = _heliGroup addWaypoint [_position, 0];
	_wp1 setWaypointType "SAD";
	//[_heli,"Air Attack"] spawn A3A_fnc_inmuneConvoy;
	sleep 30;
	};
_vehicleTypes = if (_side == bad) then {vehNATOTransportHelis} else {vehCSATTransportHelis};
_groupType = if (_side == bad) then {NATOSpecOp} else {CSATSpecOp};

for "_i" from 0 to (round random 2) do
	{
	_vehicleType = selectRandom _vehicleTypes;
	//_pos = [_position, distanceSPWN * 3, random 360] call BIS_Fnc_relPos;
	_vehicle=[_originPos, 0, _vehicleType, _side] call bis_fnc_spawnvehicle;
	_heli = _vehicle select 0;
	_heliCrew = _vehicle select 1;
	_heliGroup = _vehicle select 2;
	_pilots = _pilots + _heliCrew;
	_groups pushBack _heliGroup;
	_vehicles pushBack _heli;

	{_x setBehaviour "CARELESS";} forEach units _heliGroup;
	_group = [_originPos, _side, _groupType] call A3A_fnc_spawnGroup;
	{_x assignAsCargo _heli; _x moveInCargo _heli; _soldiers pushBack _x; [_x] call A3A_fnc_NATOinit} forEach units _group;
	_groups pushBack _group;
	//[_heli,"Air Transport"] spawn A3A_fnc_inmuneConvoy;
	[_heli,_group,_position,_originPos,_heliGroup] spawn A3A_fnc_fastrope;
	sleep 10;
	};

waitUntil {sleep 1;({[_x] call A3A_fnc_canFight} count _soldiers < {!([_x] call A3A_fnc_canFight)} count _soldiers) or (_position distance getMarkerPos respawnGood > 999) or (!alive petros)};

if (!alive petros) then
	{
	["DEF_HQ",[format ["Enemy knows our HQ coordinates. They have sent a SpecOp Squad in order to kill %1. Intercept them and kill them. Or you may move our HQ 1Km away so they will loose track",name petros],format ["Defend %1",name petros],respawnGood],_position,"FAILED"] call A3A_fnc_taskUpdate;
	["DEF_HQ1",[format ["We know %2 HQ coordinates. We have sent a SpecOp Squad in order to kill his leader %1. Help the SpecOp team",name petros,nameBuenos],format ["Kill %1",name petros],respawnGood],_position,"SUCCEEDED"] call A3A_fnc_taskUpdate;
	}
else
	{
	if (_position distance getMarkerPos respawnGood > 999) then
		{
		["DEF_HQ",[format ["Enemy knows our HQ coordinates. They have sent a SpecOp Squad in order to kill Maru. Intercept them and kill them. Or you may move our HQ 1Km away so they will loose track",name petros],format ["Defend %1",name petros],respawnGood],_position,"SUCCEEDED"] call A3A_fnc_taskUpdate;
		["DEF_HQ1",[_side],[format ["We know %2 HQ coordinates. We have sent a SpecOp Squad in order to kill his leader %1. Help the SpecOp team",name petros,nameBuenos],format ["Kill %1",name petros],respawnGood],_position,"FAILED"] call A3A_fnc_taskUpdate;
		}
	else
		{
		["DEF_HQ",[format ["Enemy knows our HQ coordinates. They have sent a SpecOp Squad in order to kill %1. Intercept them and kill them. Or you may move our HQ 1Km away so they will loose track",name petros],format ["Defend %1",name petros],respawnGood],_position,"SUCCEEDED"] call A3A_fnc_taskUpdate;
		["DEF_HQ1",[format ["We know %2 HQ coordinates. We have sent a SpecOp Squad in order to kill his leader %1. Help the SpecOp team",name petros,nameBuenos],format ["Kill %1",name petros],respawnGood],_position,"FAILED"] call A3A_fnc_taskUpdate;
		[0,3] remoteExec ["A3A_fnc_prestige",2];
		[0,300] remoteExec ["A3A_fnc_resourcesFIA",2];
		//[-5,5,_position] remoteExec ["A3A_fnc_citySupportChange",2];
		{if (isPlayer _x) then {[10,_x] call A3A_fnc_playerScoreAdd}} forEach ([500,0,_position,good] call A3A_fnc_distanceUnits);
		};
	};

_nul = [1200,"DEF_HQ"] spawn A3A_fnc_borrarTask;
sleep 60;
_nul = [0,"DEF_HQ1"] spawn A3A_fnc_borrarTask;

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
