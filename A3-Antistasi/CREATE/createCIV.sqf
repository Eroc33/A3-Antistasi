if (!isServer and hasInterface) exitWith{};

private ["_marker","_data","_numCiv","_numVeh","_roads","_prestigeOPFOR","_presitgeBLUFOR","_civs","_groups","_vehicles","_civsPatrol","_patrolGroups","_vehPatrol","_civType","_vehicleType","_dirVeh","_count","_group","_size","_road","_civType","_vehicleType","_dirVeh","_position","_area","_civ","_veh","_roadcon","_pos","_p1","_p2","_mrkMar","_patrolCities","_patrolCount","_waves","_groupP","_wp","_wp1"];

_marker = _this select 0;

if (_marker in destroyedCities) exitWith {};

_data = server getVariable _marker;

_numCiv = _data select 0;
_numVeh = _data select 1;
//_roads = _data select 2;
_roads = roads getVariable _marker;//
//_prestigeOPFOR = _data select 3;
//_prestigeBLUFOR = _data select 4;

_prestigeOPFOR = _data select 2;
_prestigeBLUFOR = _data select 3;

_civs = [];
_groups = [];
_vehicles = [];
_civsPatrol = [];
_patrolGroups = [];
_vehPatrol = [];
_size = [_marker] call A3A_fnc_sizeMarker;

_civType = "";
_vehicleType = "";
_dirVeh = 0;

_position = getMarkerPos (_marker);

_area = [_marker] call A3A_fnc_sizeMarker;

_roads = _roads call BIS_fnc_arrayShuffle;

_numVeh = round (_numVeh * (civPerc/200) * civTraffic);
if (_numVeh < 1) then {_numVeh = 1};
_numCiv = round (_numCiv * (civPerc/250));
if ((daytime < 8) or (daytime > 21)) then {_numCiv = round (_numCiv/4); _numVeh = round (_numVeh * 1.5)};
if (_numCiv < 1) then {_numCiv = 1};

_count = 0;
_max = count _roads;

while {(spawner getVariable _marker != 2) and (_count < _numVeh) and (_count < _max)} do
	{
	_p1 = _roads select _count;
	_road = roadAt _p1;
	if (!isNull _road) then
		{
		if ((count (nearestObjects [_p1, ["Car", "Truck"], 5]) == 0) and !([50,1,_road,good] call A3A_fnc_distanceUnits)) then
			{
			_roadcon = roadsConnectedto (_road);
			_p2 = getPos (_roadcon select 0);
			_dirveh = [_p1,_p2] call BIS_fnc_DirTo;
			_pos = [_p1, 3, _dirveh + 90] call BIS_Fnc_relPos;
			_vehicleType = selectRandom arrayCivVeh;
			/*
			_mrk = createmarker [format ["%1", count vehicles], _p1];
		    _mrk setMarkerSize [5, 5];
		    _mrk setMarkerShape "RECTANGLE";
		    _mrk setMarkerBrush "SOLID";
		    _mrk setMarkerColor colorGood;
		    //_mrk setMarkerText _name;
		    */
			_veh = _vehicleType createVehicle _pos;
			_veh setDir _dirveh;
			_vehicles pushBack _veh;
			_nul = [_veh] spawn A3A_fnc_civVEHinit;
			};
		};
	sleep 0.5;
	_count = _count + 1;
	};

_mrkMar = if !(foundIFA) then {seaSpawn select {getMarkerPos _x inArea _marker}} else {[]};
if (count _mrkMar > 0) then
	{
	for "_i" from 0 to (round (random 3)) do
		{
		if (spawner getVariable _marker != 2) then
			{
			_vehicleType = selectRandom civBoats;
			_pos = (getMarkerPos (_mrkMar select 0)) findEmptyPosition [0,20,_vehicleType];
			_veh = _vehicleType createVehicle _pos;
			_veh setDir (random 360);
			_vehicles pushBack _veh;
			[_veh] spawn A3A_fnc_civVEHinit;
			sleep 0.5;
			};
		};
	};

if ((random 100 < ((prestigeNATO) + (prestigeCSAT))) and (spawner getVariable _marker != 2)) then
	{
	_pos = [];
	while {true} do
		{
		_pos = [_position, round (random _area), random 360] call BIS_Fnc_relPos;
		if (!surfaceIsWater _pos) exitWith {};
		};
	_group = createGroup civilian;
	_groups pushBack _group;
	_civ = _group createUnit ["C_journalist_F", _pos, [],0, "NONE"];
	_nul = [_civ] spawn A3A_fnc_CIVinit;
	_civs pushBack _civ;
	_nul = [_civ, _marker, "SAFE", "SPAWNED","NOFOLLOW", "NOVEH2","NOSHARE","DoRelax"] execVM "scripts\UPSMON.sqf";
	};


if ([_marker,false] call A3A_fnc_fogCheck > 0.2) then
	{
	_patrolCities = [_marker] call A3A_fnc_citiesToCivPatrol;

	_patrolCount = 0;

	_waves = round (_numCiv / 60);
	if (_waves < 1) then {_waves = 1};

	for "_i" from 1 to _waves do
		{
		while {(spawner getVariable _marker != 2) and (_patrolCount < (count _patrolCities - 1) and (_count < _max))} do
			{
			//_p1 = getPos (_roads select _count);
			_p1 = _roads select _count;
			//_road = (_p1 nearRoads 5) select 0;
			_road = roadAt _p1;
			if (!isNull _road) then
			//if (!isNil "_road") then
				{
				if (count (nearestObjects [_p1, ["Car", "Truck"], 5]) == 0) then
					{
					_groupP = createGroup civilian;
					_patrolGroups = _patrolGroups + [_groupP];
					_roadcon = roadsConnectedto _road;
					//_p1 = getPos (_roads select _count);
					_p2 = getPos (_roadcon select 0);
					_dirveh = [_p1,_p2] call BIS_fnc_DirTo;
					_vehicleType = arrayCivVeh call BIS_Fnc_selectRandom;
					_veh = _vehicleType createVehicle _p1;
					_veh setDir _dirveh;
					_veh addEventHandler ["HandleDamage",{if (((_this select 1) find "wheel" != -1) and (_this select 4=="") and (!isPlayer driver (_this select 0))) then {0;} else {(_this select 2);};}];
					_veh addEventHandler ["HandleDamage",
						{
						_veh = _this select 0;
						if (side(_this select 3) == good) then
							{
							_driver = driver _veh;
							if (side _driver == civilian) then {_driver leaveVehicle _veh};
							};
						}
						];
					//_veh forceFollowRoad true;
					_vehPatrol = _vehPatrol + [_veh];
					_civType = selectRandom arrayCivs;
					_civ = _groupP createUnit [_civType, _p1, [],0, "NONE"];
					_nul = [_civ] spawn A3A_fnc_CIVinit;
					_civsPatrol = _civsPatrol + [_civ];
					_civ moveInDriver _veh;
					_groupP addVehicle _veh;
					_groupP setBehaviour "CARELESS";
					_destinationPos = selectRandom (roads getVariable (_patrolCities select _patrolCount));
					_wp = _groupP addWaypoint [_destinationPos,0];
					_wp setWaypointType "MOVE";
					_wp setWaypointSpeed "FULL";
					_wp setWaypointTimeout [30, 45, 60];
					_wp = _groupP addWaypoint [_position,1];
					_wp setWaypointType "MOVE";
					_wp setWaypointTimeout [30, 45, 60];
					_wp1 = _groupP addWaypoint [_position,2];
					_wp1 setWaypointType "CYCLE";
					_wp1 synchronizeWaypoint [_wp];
					};
				};
			_patrolCount = _patrolCount + 1;
			sleep 5;
			};
		};
	};

waitUntil {sleep 1;(spawner getVariable _marker == 2)};

{deleteVehicle _x} forEach _civs;
{deleteGroup _x} forEach _groups;
{
if (!([distanceSPWN-_size,1,_x,good] call A3A_fnc_distanceUnits)) then
	{
	if (_x in reportedVehs) then {reportedVehs = reportedVehs - [_x]; publicVariable "reportedVehs"};
	deleteVehicle _x;
	}
} forEach _vehicles;
{
waitUntil {sleep 1; !([distanceSPWN,1,_x,good] call A3A_fnc_distanceUnits)};
deleteVehicle _x} forEach _civsPatrol;
{
if (!([distanceSPWN,1,_x,good] call A3A_fnc_distanceUnits)) then
	{
	if (_x in reportedVehs) then {reportedVehs = reportedVehs - [_x]; publicVariable "reportedVehs"};
	deleteVehicle _x
	}
else
	{
	[_x] spawn A3A_fnc_civVEHinit
	};
} forEach _vehPatrol;
{deleteGroup _x} forEach _patrolGroups;
