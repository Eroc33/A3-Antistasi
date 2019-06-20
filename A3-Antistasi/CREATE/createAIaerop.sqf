if (!isServer and hasInterface) exitWith{};

private ["_pos","_marker","_vehicles","_groups","_soldiers","_position","_busy","_buildings","_pos1","_pos2","_group","_count","_vehicleType","_veh","_unit","_arrayVehAAF","_nVeh","_isFrontLine","_mrkSize","_ang","_mrk","_groupType","_flag","_dog","_unitType","_garrison","_side","_cfg","_max","_vehicle","_vehCrew","_groupVeh","_roads","_dist","_road","_roadscon","_roadcon","_dirveh","_bunker","_groupType","_positions","_posMG","_posMort","_posTank"];
_marker = _this select 0;

_vehicles = [];
_groups = [];
_soldiers = [];

_position = getMarkerPos (_marker);
_pos = [];

_mrkSize = [_marker] call A3A_fnc_sizeMarker;
//_garrison = garrison getVariable _marker;

_isFrontLine = [_marker] call A3A_fnc_isFrontline;
_busy = if (dateToNumber date > server getVariable _marker) then {false} else {true};
_nVeh = round (_mrkSize/60);

_side = sides getVariable [_marker,sideUnknown];

_positions = roads getVariable [_marker,[]];
_posMG = _positions select {(_x select 2) == "MG"};
_posMort = _positions select {(_x select 2) == "Mort"};
_posTank = _positions select {(_x select 2) == "Tank"};
_posAA = _positions select {(_x select 2) == "AA"};
_posAT = _positions select {(_x select 2) == "AT"};

if (spawner getVariable _marker != 2) then
	{
	_vehicleType = if (_side == bad) then {vehNATOAA} else {vehCSATAA};
	if ([_vehicleType] call A3A_fnc_vehAvailable) then
		{
		_max = if (_side == bad) then {1} else {2};
		for "_i" from 1 to _max do
			{
			_pos = [_position, 50, _mrkSize, 10, 0, 0.3, 0] call BIS_Fnc_findSafePos;
			//_pos = _position findEmptyPosition [_mrkSize - 200,_mrkSize+50,_vehicleType];
			_vehicle=[_pos, random 360,_vehicleType, _side] call bis_fnc_spawnvehicle;
			_veh = _vehicle select 0;
			_vehCrew = _vehicle select 1;
			{[_x,_marker] call A3A_fnc_NATOinit} forEach _vehCrew;
			[_veh] call A3A_fnc_AIVEHinit;
			_groupVeh = _vehicle select 2;
			_soldiers = _soldiers + _vehCrew;
			_groups pushBack _groupVeh;
			_vehicles pushBack _veh;
			sleep 1;
			};
		};
	};

if ((spawner getVariable _marker != 2) and _isFrontLine) then
	{
	_roads = _position nearRoads _mrkSize;
	if (count _roads != 0) then
		{
		_group = createGroup _side;
		_groups pushBack _group;
		_dist = 0;
		_road = objNull;
		{if ((position _x) distance _position > _dist) then {_road = _x;_dist = position _x distance _position}} forEach _roads;
		_roadscon = roadsConnectedto _road;
		_roadcon = objNull;
		{if ((position _x) distance _position > _dist) then {_roadcon = _x}} forEach _roadscon;
		_dirveh = [_roadcon, _road] call BIS_fnc_DirTo;
		_pos = [getPos _road, 7, _dirveh + 270] call BIS_Fnc_relPos;
		_bunker = "Land_BagBunker_01_small_green_F" createVehicle _pos;
		_vehicles pushBack _bunker;
		_bunker setDir _dirveh;
		_pos = getPosATL _bunker;
		_vehicleType = if (_side==bad) then {staticATmalos} else {staticATmuyMalos};
		_veh = _vehicleType createVehicle _position;
		_vehicles pushBack _veh;
		_veh setPos _pos;
		_veh setDir _dirVeh + 180;
		_unitType = if (_side==bad) then {staticCrewmalos} else {staticCrewMuyMalos};
		_unit = _group createUnit [_unitType, _position, [], 0, "NONE"];
		[_unit,_marker] call A3A_fnc_NATOinit;
		[_veh] call A3A_fnc_AIVEHinit;
		_unit moveInGunner _veh;
		_soldiers pushBack _unit;
		};
	};
_mrk = createMarkerLocal [format ["%1patrolarea", random 100], _position];
_mrk setMarkerShapeLocal "RECTANGLE";
_mrk setMarkerSizeLocal [(distanceSPWN/2),(distanceSPWN/2)];
_mrk setMarkerTypeLocal "hd_warning";
_mrk setMarkerColorLocal "ColorRed";
_mrk setMarkerBrushLocal "DiagGrid";
_ang = markerDir _marker;
_mrk setMarkerDirLocal _ang;
if (!debug) then {_mrk setMarkerAlphaLocal 0};
_garrison = garrison getVariable [_marker,[]];
_garrison = _garrison call A3A_fnc_garrisonReorg;
_size = count _garrison;
private _patrol = true;
if (_size < ([_marker] call A3A_fnc_garrisonSize)) then
	{
	_patrol = false;
	}
else
	{
	if ({if ((getMarkerPos _x inArea _mrk) and (sides getVariable [_x,sideUnknown] != _side)) exitWIth {1}} count marcadores > 0) then {_patrol = false};
	};
if (_patrol) then
	{
	_count = 0;
	while {(spawner getVariable _marker != 2) and (_count < 4)} do
		{
		_groupsArray = if (_side == bad) then {groupsNATOsmall} else {groupsCSATsmall};
		if ([_marker,false] call A3A_fnc_fogCheck < 0.3) then {_groupsArray = _groupsArray - sniperGroups};
		_groupType = selectRandom _groupsArray;
		_group = [_position,_side, _groupType,false,true] call A3A_fnc_spawnGroup;
		if !(isNull _group) then
			{
			sleep 1;
			if ((random 10 < 2.5) and (not(_groupType in sniperGroups))) then
				{
				_dog = _group createUnit ["Fin_random_F",_position,[],0,"FORM"];
				[_dog] spawn A3A_fnc_guardDog;
				sleep 1;
				};
			_nul = [leader _group, _mrk, "SAFE","SPAWNED", "RANDOM", "NOVEH2"] execVM "scripts\UPSMON.sqf";
			_groups pushBack _group;
			{[_x,_marker] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _group;
			};
		_count = _count +1;
		};
	};
_count = 0;

_group = createGroup _side;
_groups pushBack _group;
_unitType = if (_side==bad) then {staticCrewmalos} else {staticCrewMuyMalos};
_vehicleType = if (_side == bad) then {NATOMortar} else {CSATMortar};
{
if (spawner getVariable _marker != 2) then
	{
	_veh = _vehicleType createVehicle [0,0,1000];
	_veh setDir (_x select 1);
	_veh setPosATL (_x select 0);
	_nul=[_veh] execVM "scripts\UPSMON\MON_artillery_add.sqf";
	_unit = _group createUnit [_unitType, _position, [], 0, "NONE"];
	[_unit,_marker] call A3A_fnc_NATOinit;
	_unit moveInGunner _veh;
	_soldiers pushBack _unit;
	_vehicles pushBack _veh;
	_nul = [_veh] call A3A_fnc_AIVEHinit;
	sleep 1;
	};
} forEach _posMort;
_vehicleType = if (_side == bad) then {NATOMG} else {CSATMG};
{
if (spawner getVariable _marker != 2) then
	{
	_proceed = true;
	if ((_x select 0) select 2 > 0.5) then
		{
		_bld = nearestBuilding (_x select 0);
		if !(alive _bld) then {_proceed = false};
		};
	if (_proceed) then
		{
		_veh = _vehicleType createVehicle [0,0,1000];
		_veh setDir (_x select 1);
		_veh setPosATL (_x select 0);
		_unit = _group createUnit [_unitType, _position, [], 0, "NONE"];
		[_unit,_marker] call A3A_fnc_NATOinit;
		_unit moveInGunner _veh;
		_soldiers pushBack _unit;
		_vehicles pushBack _veh;
		_nul = [_veh] call A3A_fnc_AIVEHinit;
		sleep 1;
		};
	};
} forEach _posMG;
_vehicleType = if (_side == bad) then {staticAAMalos} else {staticAAmuyMalos};
{
if (spawner getVariable _marker != 2) then
	{
	if !([_vehicleType] call A3A_fnc_vehAvailable) exitWith {};
	_proceed = true;
	if ((_x select 0) select 2 > 0.5) then
		{
		_bld = nearestBuilding (_x select 0);
		if !(alive _bld) then {_proceed = false};
		};
	if (_proceed) then
		{
		_veh = _vehicleType createVehicle [0,0,1000];
		_veh setDir (_x select 1);
		_veh setPosATL (_x select 0);
		_unit = _group createUnit [_unitType, _position, [], 0, "NONE"];
		[_unit,_marker] call A3A_fnc_NATOinit;
		_unit moveInGunner _veh;
		_soldiers pushBack _unit;
		_vehicles pushBack _veh;
		_nul = [_veh] call A3A_fnc_AIVEHinit;
		sleep 1;
		};
	};
} forEach _posAA;
_vehicleType = if (_side == bad) then {staticATMalos} else {staticATmuyMalos};
{
if (spawner getVariable _marker != 2) then
	{
	if !([_vehicleType] call A3A_fnc_vehAvailable) exitWith {};
	_proceed = true;
	if ((_x select 0) select 2 > 0.5) then
		{
		_bld = nearestBuilding (_x select 0);
		if !(alive _bld) then {_proceed = false};
		};
	if (_proceed) then
		{
		_veh = _vehicleType createVehicle [0,0,1000];
		_veh setDir (_x select 1);
		_veh setPosATL (_x select 0);
		_unit = _group createUnit [_unitType, _position, [], 0, "NONE"];
		[_unit,_marker] call A3A_fnc_NATOinit;
		_unit moveInGunner _veh;
		_soldiers pushBack _unit;
		_vehicles pushBack _veh;
		_nul = [_veh] call A3A_fnc_AIVEHinit;
		sleep 1;
		};
	};
} forEach _posAT;

_ret = [_marker,_mrkSize,_side,_isFrontLine] call A3A_fnc_milBuildings;
_groups pushBack (_ret select 0);
_vehicles append (_ret select 1);
_soldiers append (_ret select 2);

if (!_busy) then
	{
	_buildings = nearestObjects [_position, ["Land_LandMark_F","Land_runway_edgelight"], _mrkSize / 2];
	if (count _buildings > 1) then
		{
		_pos1 = getPos (_buildings select 0);
		_pos2 = getPos (_buildings select 1);
		_ang = [_pos1, _pos2] call BIS_fnc_DirTo;

		_pos = [_pos1, 5,_ang] call BIS_fnc_relPos;
		_group = createGroup _side;
		_groups pushBack _group;
		_count = 0;
		while {(spawner getVariable _marker != 2) and (_count < 5)} do
			{
			_vehicleType = if (_side == bad) then {selectRandom (vehNATOAir select {[_x] call A3A_fnc_vehAvailable})} else {selectRandom (vehCSATAir select {[_x] call A3A_fnc_vehAvailable})};
			_veh = createVehicle [_vehicleType, _pos, [],3, "NONE"];
			_veh setDir (_ang + 90);
			sleep 1;
			_vehicles pushBack _veh;
			_nul = [_veh] call A3A_fnc_AIVEHinit;
			_pos = [_pos, 50,_ang] call BIS_fnc_relPos;
			/*
			_unitType = if (_side==bad) then {NATOpilot} else {CSATpilot};
			_unit = _group createUnit [_unitType, _position, [], 0, "NONE"];
			[_unit,_marker] call A3A_fnc_NATOinit;
			_soldiers pushBack _unit;
			*/
			_count = _count + 1;
			};
		_nul = [leader _group, _marker, "SAFE","SPAWNED","NOFOLLOW","NOVEH"] execVM "scripts\UPSMON.sqf";
		};
	};

_vehicleType = if (_side == bad) then {NATOFlag} else {CSATFlag};
_flag = createVehicle [_vehicleType, _position, [],0, "CAN_COLLIDE"];
_flag allowDamage false;
[_flag,"take"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_flag];
_vehicles pushBack _flag;
if (_side == bad) then
	{
	_veh = NATOAmmoBox createVehicle _position;
	_nul = [_veh] call A3A_fnc_NATOcrate;
	_vehicles pushBack _veh;
	_veh call jn_fnc_logistics_addAction;
	}
else
	{
	_veh = CSATAmmoBox createVehicle _position;
	_nul = [_veh] call A3A_fnc_CSATcrate;
	_vehicles pushBack _veh;
	_veh call jn_fnc_logistics_addAction;
	};

if (!_busy) then
	{
	{
	_arrayVehAAF = if (_side == bad) then {vehNATOAttack select {[_x] call A3A_fnc_vehAvailable}} else {vehCSATAttack select {[_x] call A3A_fnc_vehAvailable}};
	if ((spawner getVariable _marker != 2) and (count _arrayVehAAF > 0)) then
		{
		_veh = createVehicle [selectRandom _arrayVehAAF, (_x select 0), [], 0, "NONE"];
		_veh setDir (_x select 1);
		_vehicles pushBack _veh;
		_nul = [_veh] call A3A_fnc_AIVEHinit;
		_nVeh = _nVeh -1;
		sleep 1;
		};
	} forEach _posTank;
	};
_arrayVehAAF = if (_side == bad) then {vehNATONormal} else {vehCSATNormal};

_count = 0;
while {(spawner getVariable _marker != 2) and (_count < _nVeh)} do
	{
	_vehicleType = selectRandom _arrayVehAAF;
	_pos = [_position, 10, _mrkSize/2, 10, 0, 0.3, 0] call BIS_Fnc_findSafePos;
	_veh = createVehicle [_vehicleType, _pos, [], 0, "NONE"];
	_veh setDir random 360;
	_vehicles pushBack _veh;
	_nul = [_veh] call A3A_fnc_AIVEHinit;
	sleep 1;
	_count = _count + 1;
	};

_array = [];
_subArray = [];
_count = 0;
_size = _size -1;
while {_count <= _size} do
	{
	_array pushBack (_garrison select [_count,7]);
	_count = _count + 8;
	};
for "_i" from 0 to (count _array - 1) do
	{
	_group = if (_i == 0) then {[_position,_side, (_array select _i),true,false] call A3A_fnc_spawnGroup} else {[_position,_side, (_array select _i),false,true] call A3A_fnc_spawnGroup};
	_groups pushBack _group;
	{[_x,_marker] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _group;
	if (_i == 0) then {_nul = [leader _group, _marker, "SAFE", "RANDOMUP","SPAWNED", "NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf"} else {_nul = [leader _group, _marker, "SAFE","SPAWNED", "RANDOM","NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf"};
	};

waitUntil {sleep 1; (spawner getVariable _marker == 2)};

deleteMarker _mrk;
{if (alive _x) then
	{
	deleteVehicle _x
	};
} forEach _soldiers;
//if (!isNull _periodista) then {deleteVehicle _periodista};
{deleteGroup _x} forEach _groups;
{
if (!(_x in staticsToSave)) then
	{
	if ((!([distanceSPWN-_mrkSize,1,_x,good] call A3A_fnc_distanceUnits))) then {deleteVehicle _x}
	};
} forEach _vehicles;


