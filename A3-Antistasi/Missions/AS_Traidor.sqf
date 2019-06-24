if (!isServer and hasInterface) exitWith{};

_marker = _this select 0;

_difficulty = if (random 10 < tierWar) then {true} else {false};
_exit = false;
_contact = objNull;
_grpContact = grpNull;
_tsk = "";
_tsk1 = "";

_position = getMarkerPos _marker;

_timeDelay = if (_difficulty) then {30} else {60};
if (foundIFA) then {_timeDelay = _timeDelay * 2};
_dateDelay = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeDelay];
_dateDelayNumeric = dateToNumber _dateDelay;

_size = [_marker] call A3A_fnc_sizeMarker;
_houses = (nearestObjects [_position, ["house"], _size]) select {!((typeOf _x) in UPSMON_Bld_remove)};
_housePos = [];
_house = _houses select 0;
while {count _housePos < 3} do
	{
	_house = _houses call BIS_Fnc_selectRandom;
	_housePos = _house buildingPos -1;
	if (count _housePos < 3) then {_houses = _houses - [_house]};
	};

_max = (count _housePos) - 1;
_rnd = floor random _max;
_traitorPos = _housePos select _rnd;
_posSol1 = _housePos select (_rnd + 1);
_posSol2 = (_house buildingExit 0);

_destinationName = [_marker] call A3A_fnc_localizar;

_traitorGroup = createGroup bad;

_airportsArray = airports select {sides getVariable [_x,sideUnknown] == bad};
_base = [_airportsArray, _position] call BIS_Fnc_nearestPosition;
_posBase = getMarkerPos _base;

_traitor = _traitorGroup createUnit [NATOOfficer2, _traitorPos, [], 0, "NONE"];
_traitor allowDamage false;
_traitor setPos _traitorPos;
_sol1 = _traitorGroup createUnit [NATOBodyG, _posSol1, [], 0, "NONE"];
_sol2 = _traitorGroup createUnit [NATOBodyG, _posSol2, [], 0, "NONE"];
_traitorGroup selectLeader _traitor;

_posTsk = (position _house) getPos [random 100, random 360];

[[good,civilian],"AS",[format ["A traitor has scheduled a meeting with %4 in %1. Kill him before he provides enough intel to give us trouble. Do this before %2:%3. We don't where exactly this meeting will happen. You will recognise the building by the nearby Offroad and %4 presence.",_destinationName,numberToDate [2035,_dateDelayNumeric] select 3,numberToDate [2035,_dateDelayNumeric] select 4,nameMalos],"Kill the Traitor",_marker],_posTsk,false,0,true,"Kill",true] call BIS_fnc_taskCreate;
[[bad],"AS1",[format ["We arranged a meeting in %1 with a %4 contact who may have vital information about their Headquarters position. Protect him until %2:%3.",_destinationName,numberToDate [2035,_dateDelayNumeric] select 3,numberToDate [2035,_dateDelayNumeric] select 4,nameBuenos],"Protect Contact",_marker],getPos _house,false,0,true,"Defend",true] call BIS_fnc_taskCreate;
missions pushBack ["AS","CREATED"]; publicVariable "missions";
{_nul = [_x,""] call A3A_fnc_NATOinit; _x allowFleeing 0} forEach units _traitorGroup;
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
_veh = vehSDKLightUnarmed createVehicle _posVeh;
_veh allowDamage false;
_veh setDir _dirVeh;
sleep 15;
_veh allowDamage true;
_traitor allowDamage true;
_nul = [_veh] call A3A_fnc_AIVEHinit;
{_x disableAI "MOVE"; _x setUnitPos "UP"} forEach units _traitorGroup;

_mrk = createMarkerLocal [format ["%1patrolarea", floor random 100], getPos _house];
_mrk setMarkerShapeLocal "RECTANGLE";
_mrk setMarkerSizeLocal [50,50];
_mrk setMarkerTypeLocal "hd_warning";
_mrk setMarkerColorLocal "ColorRed";
_mrk setMarkerBrushLocal "DiagGrid";
_mrk setMarkerAlphaLocal 0;

_groupType = if (random 10 < tierWar) then {NATOSquad} else {[policeOfficer,policeGrunt,policeGrunt,policeGrunt,policeGrunt,policeGrunt,policeGrunt,policeGrunt]};
_group = [_position,bad, NATOSquad] call A3A_fnc_spawnGroup;
sleep 1;
if (random 10 < 2.5) then
	{
	_dog = _group createUnit ["Fin_random_F",_position,[],0,"FORM"];
	[_dog] spawn A3A_fnc_guardDog;
	};
_nul = [leader _group, _mrk, "SAFE","SPAWNED", "NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf";
{[_x,""] call A3A_fnc_NATOinit} forEach units _group;

waitUntil {sleep 1; (dateToNumber date > _dateDelayNumeric) or (not alive _traitor) or ({_traitor knowsAbout _x > 1.4} count ([500,0,_traitor,good] call A3A_fnc_distanceUnits) > 0)};

if ({_traitor knowsAbout _x > 1.4} count ([500,0,_traitor,good] call A3A_fnc_distanceUnits) > 0) then
	{
	{_x enableAI "MOVE"} forEach units _traitorGroup;
	_traitor assignAsDriver _veh;
	[_traitor] orderGetin true;
	_wp0 = _traitorGroup addWaypoint [_posVeh, 0];
	_wp0 setWaypointType "GETIN";
	_wp1 = _traitorGroup addWaypoint [_posBase,1];
	_wp1 setWaypointType "MOVE";
	_wp1 setWaypointBehaviour "CARELESS";
	_wp1 setWaypointSpeed "FULL";
	};

waitUntil  {sleep 1; (dateToNumber date > _dateDelayNumeric) or (not alive _traitor) or (_traitor distance _posBase < 20)};

if (not alive _traitor) then
	{
	["AS",[format ["A traitor has scheduled a meeting with %4 in %1. Kill him before he provides enough intel to give us trouble. Do this before %2:%3. We don't where exactly this meeting will happen. You will recognise the building by the nearby Offroad and %4 presence.",_destinationName,numberToDate [2035,_dateDelayNumeric] select 3,numberToDate [2035,_dateDelayNumeric] select 4,nameMalos],"Kill the Traitor",_marker],_traitor,"SUCCEEDED"] call A3A_fnc_taskUpdate;
	["AS1",[format ["We arranged a meeting in %1 with a %4 contact who may have vital information about their Headquarters position. Protect him until %2:%3.",_destinationName,numberToDate [2035,_dateDelayNumeric] select 3,numberToDate [2035,_dateDelayNumeric] select 4,nameBuenos],"Protect Contact",_marker],getPos _house,"FAILED"] call A3A_fnc_taskUpdate;
	if (_difficulty) then
		{
		[4,0] remoteExec ["A3A_fnc_prestige",2];
		[0,600] remoteExec ["A3A_fnc_resourcesFIA",2];
		{
		if (!isPlayer _x) then
			{
			_skill = skill _x;
			_skill = _skill + 0.1;
			_x setSkill _skill;
			}
		else
			{
			[20,_x] call A3A_fnc_playerScoreAdd;
			};
		} forEach ([_size,0,_position,good] call A3A_fnc_distanceUnits);
		[10,theBoss] call A3A_fnc_playerScoreAdd;
		}
	else
		{
		[2,0] remoteExec ["A3A_fnc_prestige",2];
		[0,300] remoteExec ["A3A_fnc_resourcesFIA",2];
		{
		if (!isPlayer _x) then
			{
			_skill = skill _x;
			_skill = _skill + 0.1;
			_x setSkill _skill;
			}
		else
			{
			[10,_x] call A3A_fnc_playerScoreAdd;
			};
		} forEach ([_size,0,_position,good] call A3A_fnc_distanceUnits);
		[5,theBoss] call A3A_fnc_playerScoreAdd;
		};
	}
else
	{
	["AS",[format ["A traitor has scheduled a meeting with %4 in %1. Kill him before he provides enough intel to give us trouble. Do this before %2:%3. We don't where exactly this meeting will happen. You will recognise the building by the nearby Offroad and %4 presence.",_destinationName,numberToDate [2035,_dateDelayNumeric] select 3,numberToDate [2035,_dateDelayNumeric] select 4,nameMalos],"Kill the Traitor",_marker],_traitor,"FAILED"] call A3A_fnc_taskUpdate;
	["AS1",[format ["We arranged a meeting in %1 with a %4 contact who may have vital information about their Headquarters position. Protect him until %2:%3.",_destinationName,numberToDate [2035,_dateDelayNumeric] select 3,numberToDate [2035,_dateDelayNumeric] select 4,nameBuenos],"Protect Contact",_marker],getPos _house,"SUCCEEDED"] call A3A_fnc_taskUpdate;
	if (_difficulty) then {[-10,theBoss] call A3A_fnc_playerScoreAdd} else {[-10,theBoss] call A3A_fnc_playerScoreAdd};
	if (dateToNumber date > _dateDelayNumeric) then
		{
		_hrT = server getVariable "hr";
		_resourcesFIAT = server getVariable "resourcesFIA";
		[-1*(round(_hrT/3)),-1*(round(_resourcesFIAT/3))] remoteExec ["A3A_fnc_resourcesFIA",2];
		}
	else
		{
		if (isPlayer theBoss) then
			{
			if (!(["DEF_HQ"] call BIS_fnc_taskExists)) then
				{
				[[bad],"A3A_fnc_ataqueHQ"] remoteExec ["A3A_fnc_scheduler",2];
				};
			}
		else
			{
			_minesFIA = allmines - (detectedMines bad) - (detectedMines veryBad);
			if (count _minesFIA > 0) then
				{
				{if (random 100 < 30) then {bad revealMine _x;}} forEach _minesFIA;
				};
			};
		};
	};

_nul = [1200,"AS"] spawn A3A_fnc_borrarTask;
_nul = [10,"AS1"] spawn A3A_fnc_borrarTask;
if (!([distanceSPWN,1,_veh,good] call A3A_fnc_distanceUnits)) then {deleteVehicle _veh};

{
waitUntil {sleep 1; !([distanceSPWN,1,_x,good] call A3A_fnc_distanceUnits)};
deleteVehicle _x
} forEach units _traitorGroup;
deleteGroup _traitorGroup;

{
waitUntil {sleep 1; !([distanceSPWN,1,_x,good] call A3A_fnc_distanceUnits)};
deleteVehicle _x
} forEach units _group;
deleteGroup _group;
