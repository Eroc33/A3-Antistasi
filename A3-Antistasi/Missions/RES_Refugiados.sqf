if (!isServer and hasInterface) exitWith{};
private ["_marker","_difficulty","_exit","_contact","_grpContact","_tsk","_posHQ","_ciudades","_city","_size","_position","_house","_housePos","_destinationName","_timeDelay","_dateDelay","_dateDelayNumeric","_pos","_count"];

_marker = _this select 0;

_difficulty = if (random 10 < tierWar) then {true} else {false};
_exit = false;
_contact = objNull;
_grpContact = grpNull;
_tsk = "";
_position = getMarkerPos _marker;

_POWs = [];

_size = [_marker] call A3A_fnc_sizeMarker;
//_houses = nearestObjects [_position, ["house"], _size];
_houses = (nearestObjects [_position, ["house"], _size]) select {!((typeOf _x) in UPSMON_Bld_remove)};
_housePos = [];
_house = _houses select 0;
while {count _housePos < 3} do
	{
	_house = selectRandom _houses;
	_housePos = _house buildingPos -1;
	if (count _housePos < 3) then {_houses = _houses - [_house]};
	};


_destinationName = [_marker] call A3A_fnc_localizar;
_timeDelay = if (_difficulty) then {30} else {60};
if (foundIFA) then {_timeDelay = _timeDelay * 2};
_dateDelay = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeDelay];
_dateDelayNumeric = dateToNumber _dateDelay;
_side = if (sides getVariable [_marker,sideUnknown] == bad) then {bad} else {veryBad};
_text = if (_side == bad) then {format ["A group of smugglers have been arrested in %1 and they are about to be sent to prison. Go there and free them in order to make them join our cause. Do this before %2:%3",_destinationName,numberToDate [2035,_dateDelayNumeric] select 3,numberToDate [2035,_dateDelayNumeric] select 4]} else {format ["A group of %3 supportes are hidden in %1 awaiting for evacuation. We have to find them before %2 does it. If not, there will be a certain death for them. Bring them back to HQ",_destinationName,nameMuyMalos,nameBuenos]};
_posTsk = if (_side == bad) then {(position _house) getPos [random 100, random 360]} else {position _house};

[[good,civilian],"RES",[_text,"Refugees Evac",_destinationName],_posTsk,false,0,true,"run",true] call BIS_fnc_taskCreate;
missions pushBack ["RES","CREATED"]; publicVariable "missions";
_groupPOW = createGroup good;
for "_i" from 1 to (((count _housePos) - 1) min 15) do
	{
	_unit = _groupPOW createUnit [SDKUnarmed, _housePos select _i, [], 0, "NONE"];
	_unit allowdamage false;
	_unit disableAI "MOVE";
	_unit disableAI "AUTOTARGET";
	_unit disableAI "TARGET";
	_unit setBehaviour "CARELESS";
	_unit allowFleeing 0;
	_unit setSkill 0;
	_POWs pushBack _unit;
	[_unit,"refugiado"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_unit];
	if (_side == bad) then {[_unit,true] remoteExec ["setCaptive",0,_unit]; _unit setCaptive true};
	[_unit] call A3A_fnc_reDress;
	sleep 0.5;
	};

sleep 5;

{_x allowDamage true} forEach _POWs;

sleep 30;
_mrk = "";
_group = grpNull;
_veh = objNull;
_group1 = grpNull;
if (_side == veryBad) then
	{
	_nul = [_house] spawn
		{
		private ["_house"];
		_house = _this select 0;
		if (_difficulty) then {sleep 300} else {sleep 300 + (random 1800)};
		if (["RES"] call BIS_fnc_taskExists) then
			{
			_airports = airports select {(sides getVariable [_x,sideUnknown] == veryBad) and ([_x,true] call A3A_fnc_airportCanAttack)};
			if (count _airports > 0) then
				{
				_airport = [_airports, position casa] call BIS_fnc_nearestPosition;
				[[getPosASL _house,_airport,"",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2];
				};
			};
		};
	}
else
	{
	_posVeh = [];
	_dirVeh = 0;
	_roads = [];
	_radius = 20;
	while {count _roads == 0} do
		{
		_roads = (getPos _house) nearRoads _radius;
		_radius = _radius + 10;
		};
	_road = _roads select 0;
	_posroad = getPos _road;
	_roadcon = roadsConnectedto _road; if (count _roadCon == 0) then {diag_log format ["Antistasi Error: Esta carretera no tiene conexi??n: %1",position _road]};
	if (count _roadCon > 0) then
		{
		_posrel = getPos (_roadcon select 0);
		_dirveh = [_posroad,_posrel] call BIS_fnc_DirTo;
		}
	else
		{
		_dirVeh = getDir _road;
		};
	_posVeh = [_posroad, 3, _dirveh + 90] call BIS_Fnc_relPos;
	_veh = vehPoliceCar createVehicle _posVeh;
	_veh allowDamage false;
	_veh setDir _dirVeh;
	sleep 15;
	_veh allowDamage true;
	_nul = [_veh] call A3A_fnc_AIVEHinit;
	_mrk = createMarkerLocal [format ["%1patrolarea", floor random 100], getPos _house];
	_mrk setMarkerShapeLocal "RECTANGLE";
	_mrk setMarkerSizeLocal [50,50];
	_mrk setMarkerTypeLocal "hd_warning";
	_mrk setMarkerColorLocal "ColorRed";
	_mrk setMarkerBrushLocal "DiagGrid";
	_mrk setMarkerAlphaLocal 0;
	if ((random 100 < prestigeNATO) or (_difficulty)) then
		{
		_group = [getPos _house,bad, NATOSquad] call A3A_fnc_spawnGroup;
		sleep 1;
		}
	else
		{
		_group = createGroup bad;
		_group = [getPos _house,bad,[policeOfficer,policeGrunt,policeGrunt,policeGrunt,policeGrunt,policeGrunt,policeGrunt,policeGrunt]] call A3A_fnc_spawnGroup;
		};
	if (random 10 < 2.5) then
		{
		_dog = _group createUnit ["Fin_random_F",_position,[],0,"FORM"];
		[_dog] spawn A3A_fnc_guardDog;
		};
	_nul = [leader _group, _mrk, "SAFE","SPAWNED", "NOVEH2","RANDOM", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";
	{[_x,""] call A3A_fnc_NATOinit} forEach units _group;
	_group1 = [_house buildingExit 0, bad, groupsNATOGen] call A3A_fnc_spawnGroup;
	};

_bonus = if (_difficulty) then {2} else {1};

if (_side == bad) then
	{
	waitUntil {sleep 1; ({alive _x} count _POWs == 0) or ({(alive _x) and (_x distance getMarkerPos respawnGood < 50)} count _POWs > 0) or (dateToNumber date > _dateDelayNumeric)};
	if ({(alive _x) and (_x distance getMarkerPos respawnGood < 50)} count _POWs > 0) then
		{
		sleep 5;
		["RES",[_text,"Refugees Evac",_destinationName],_posTsk,"SUCCEEDED","run"] call A3A_fnc_taskUpdate;
		_count = {(alive _x) and (_x distance getMarkerPos respawnGood < 150)} count _POWs;
		_hr = _count;
		_resourcesFIA = 100 * _count;
		[_hr,_resourcesFIA*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
		[3,0] remoteExec ["A3A_fnc_prestige",2];
		{if (_x distance getMarkerPos respawnGood < 500) then {[_count*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
		[round (_count*_bonus/2),theBoss] call A3A_fnc_playerScoreAdd;
		{[_x] join _groupPOW; [_x] orderGetin false} forEach _POWs;
		}
	else
		{
		["RES",[_text,"Refugees Evac",_destinationName],_posTsk,"FAILED","run"] call A3A_fnc_taskUpdate;
		[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		};
	}
else
	{
	waitUntil {sleep 1; ({alive _x} count _POWs == 0) or ({(alive _x) and (_x distance getMarkerPos respawnGood < 50)} count _POWs > 0)};
	if ({alive _x} count _POWs == 0) then
		{
		["RES",[_text,"Refugees Evac",_destinationName],_posTsk,"FAILED","run"] call A3A_fnc_taskUpdate;
		[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		}
	else
		{
		["RES",[_text,"Refugees Evac",_destinationName],_posTsk,"SUCCEEDED","run"] call A3A_fnc_taskUpdate;
		_count = {(alive _x) and (_x distance getMarkerPos respawnGood < 150)} count _POWs;
		_hr = _count;
		_resourcesFIA = 100 * _count;
		[_hr,_resourcesFIA*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
		{if (_x distance getMarkerPos respawnGood < 500) then {[_count*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
		[round (_count*_bonus/2),theBoss] call A3A_fnc_playerScoreAdd;
		{[_x] join _groupPOW; [_x] orderGetin false} forEach _POWs;
		};
	};

sleep 60;
_items = [];
_ammo = [];
_weapons = [];
{
_unit = _x;
if (_unit distance getMarkerPos respawnGood < 150) then
	{
	{if (not(([_x] call BIS_fnc_baseWeapon) in unlockedWeapons)) then {_weapons pushBack ([_x] call BIS_fnc_baseWeapon)}} forEach weapons _unit;
	{if (not(_x in unlockedMagazines)) then {_ammo pushBack _x}} forEach magazines _unit;
	_items = _items + (items _unit) + (primaryWeaponItems _unit) + (assignedItems _unit) + (secondaryWeaponItems _unit);
	};
deleteVehicle _unit;
} forEach _POWs;
deleteGroup _groupPOW;
{caja addWeaponCargoGlobal [_x,1]} forEach _weapons;
{caja addMagazineCargoGlobal [_x,1]} forEach _ammo;
{caja addItemCargoGlobal [_x,1]} forEach _items;

if (_side == bad) then
	{
	deleteMarkerLocal _mrk;
	if (!isNull _veh) then {if (!([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits)) then {deleteVehicle _veh}};
	{
	waitUntil {sleep 1; !([distanceSPWN,1,_x,good] call A3A_fnc_distanceUnits)};
	deleteVehicle _x;
	} forEach units _group;
	deleteGroup _group;
	if (!isNull _group1) then
		{
		{
		waitUntil {sleep 1; !([distanceSPWN,1,_x,good] call A3A_fnc_distanceUnits)};
		deleteVehicle _x;
		} forEach units _group1;
		deleteGroup _group1;
		};
	};
//sleep (540 + random 1200);

//_nul = [_tsk,true] call BIS_fnc_deleteTask;
//deleteMarker _mrkfin;

_nul = [1200,"RES"] spawn A3A_fnc_borrarTask;


