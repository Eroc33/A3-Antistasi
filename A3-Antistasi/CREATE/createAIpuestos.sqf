if (!isServer and hasInterface) exitWith{};
private ["_marker","_vehicles","_groups","_soldiers","_position","_pos","_mrkSize","_isFrontLine","_side","_cfg","_isFIA","_garrison","_antenna","_size","_buildings","_mrk","_count","_groupType","_group","_unitType","_vehicleType","_veh","_unit","_flag","_box","_roads","_mrkMar","_vehicle","_vehCrew","_groupVeh","_dist","_road","_roadCon","_dirVeh","_bunker","_dir","_posF"];
_marker = _this select 0;

_vehicles = [];
_groups = [];
_soldiers = [];

_position = getMarkerPos (_marker);
_pos = [];


_mrkSize = [_marker] call A3A_fnc_sizeMarker;

_isFrontLine = [_marker] call A3A_fnc_isFrontline;
_side = veryBad;
_isFIA = false;
if (sides getVariable [_marker,sideUnknown] == bad) then
	{
	_side = bad;
	if ((random 10 >= (tierWar + difficultyCoef)) and !(_isFrontLine) and !(_marker in forcedSpawn)) then
		{
		_isFIA = true;
		};
	};

_antenna = objNull;

if (_side == bad) then
	{
	if (_marker in puestos) then
		{
		_buildings = nearestObjects [_position,["Land_TTowerBig_1_F","Land_TTowerBig_2_F","Land_Communication_F"], _mrkSize];
		if (count _buildings > 0) then
			{
			_antenna = _buildings select 0;
			};
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
	while {(spawner getVariable _marker !=2) and (_count < 4)} do
		{
		_groupsArray = if (_side == bad) then
			{
			if (!_isFIA) then {groupsNATOsmall} else {groupsFIASmall};
			}
		else
			{
			groupsCSATsmall
			};
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
			[leader _group, _mrk, "SAFE","SPAWNED", "RANDOM","NOVEH2"] execVM "scripts\UPSMON.sqf";
			_groups pushBack _group;
			{[_x,_marker] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _group;
			};
		_count = _count +1;
		};
	};

if ((_isFrontLine) and (spawner getVariable _marker!=2) and (_marker in puestos)) then
	{
	_group = createGroup _side;
	_unitType = if (_side==bad) then {staticCrewmalos} else {staticCrewMuyMalos};
	_vehicleType = if (_side == bad) then {NATOMortar} else {CSATMortar};
	_pos = [_position] call A3A_fnc_mortarPos;
	_veh = _vehicleType createVehicle _pos;
	_nul=[_veh] execVM "scripts\UPSMON\MON_artillery_add.sqf";
	_unit = _group createUnit [_unitType, _position, [], 0, "NONE"];
	[_unit,_marker] call A3A_fnc_NATOinit;
	_unit moveInGunner _veh;
	_soldiers pushBack _unit;
	_vehicles pushBack _veh;
	sleep 1;
	};

_ret = [_marker,_mrkSize,_side,_isFrontLine] call A3A_fnc_milBuildings;
_groups pushBack (_ret select 0);
_vehicles append (_ret select 1);
_soldiers append (_ret select 2);

_vehicleType = if (_side == bad) then {NATOFlag} else {CSATFlag};
_flag = createVehicle [_vehicleType, _position, [],0, "CAN_COLLIDE"];
_flag allowDamage false;
[_flag,"take"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_flag];
_vehicles pushBack _flag;

_box = objNull;
if (_side == bad) then
	{
	_box = NATOAmmoBox createVehicle _position;
	_nul = [_box] call A3A_fnc_NATOcrate;
	}
else
	{
	_box = CSATAmmoBox createVehicle _position;
	_nul = [_box] call A3A_fnc_CSATcrate;
	};
_vehicles pushBack _box;
_box call jn_fnc_logistics_addAction;
{_nul = [_x] call A3A_fnc_AIVEHinit;} forEach _vehicles;
_roads = _position nearRoads _mrkSize;

if ((_marker in puertos) and (spawner getVariable _marker!=2) and !foundIFA) then
	{
	_vehicleType = if (_side == bad) then {vehNATOBoat} else {vehCSATBoat};
	if ([_vehicleType] call A3A_fnc_vehAvailable) then
		{
		_mrkMar = seaSpawn select {getMarkerPos _x inArea _marker};
		_pos = (getMarkerPos (_mrkMar select 0)) findEmptyPosition [0,20,_vehicleType];
		_vehicle=[_pos, 0,_vehicleType, _side] call bis_fnc_spawnvehicle;
		_veh = _vehicle select 0;
		[_veh] call A3A_fnc_AIVEHinit;
		_vehCrew = _vehicle select 1;
		{[_x,_marker] call A3A_fnc_NATOinit} forEach _vehCrew;
		_groupVeh = _vehicle select 2;
		_soldiers = _soldiers + _vehCrew;
		_groups pushBack _groupVeh;
		_vehicles pushBack _veh;
		sleep 1;
		};
	{_box addItemCargoGlobal [_x,2]} forEach swoopShutUp;
	}
else
	{
	if (_isFrontLine) then
		{
		if (spawner getVariable _marker!=2) then
			{
			if (count _roads != 0) then
				{
				_dist = 0;
				_road = objNull;
				{if ((position _x) distance _position > _dist) then {_road = _x;_dist = position _x distance _position}} forEach _roads;
				_roadscon = roadsConnectedto _road;
				_roadcon = objNull;
				{if ((position _x) distance _position > _dist) then {_roadcon = _x}} forEach _roadscon;
				_dirveh = [_roadcon, _road] call BIS_fnc_DirTo;
				if (!_isFIA) then
					{
					_group = createGroup _side;
					_groups pushBack _group;
					_pos = [getPos _road, 7, _dirveh + 270] call BIS_Fnc_relPos;
					_bunker = "Land_BagBunker_01_Small_green_F" createVehicle _pos;
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
					}
				else
					{
					_groupType = selectRandom groupsFIAMid;
					_group = [_position, _side, _groupType,false,true] call A3A_fnc_spawnGroup;
					if !(isNull _group) then
						{
						_veh = vehFIAArmedCar createVehicle getPos _road;
						_veh setDir _dirveh + 90;
						_nul = [_veh] call A3A_fnc_AIVEHinit;
						_vehicles pushBack _veh;
						sleep 1;
						_unit = _group createUnit [FIARifleman, _position, [], 0, "NONE"];
						_unit moveInGunner _veh;
						{_soldiers pushBack _x; [_x,_marker] call A3A_fnc_NATOinit} forEach units _group;
						};
					};
				};
			};
		};
	};

if (count _roads != 0) then
	{
	_pos = _position findEmptyPosition [5,_mrkSize,"I_Truck_02_covered_F"];//donde pone 5 antes pon??a 10
	if (count _pos > 0) then
		{
		_vehicleType = if (_side == bad) then {if (!_isFIA) then {vehNATOTrucks} else {[vehFIATruck]}} else {vehCSATTrucks};
		_veh = createVehicle [selectRandom _vehicleType, _pos, [], 0, "NONE"];
		_veh setDir random 360;
		_vehicles pushBack _veh;
		_nul = [_veh] call A3A_fnc_AIVEHinit;
		sleep 1;
		};
	};

_count = 0;

if ((!isNull _antenna) and (spawner getVariable _marker!=2)) then
	{
	if ((typeOf _antenna == "Land_TTowerBig_1_F") or (typeOf _antenna == "Land_TTowerBig_2_F")) then
		{
		_group = createGroup _side;
		_pos = getPosATL _antenna;
		_dir = getDir _antenna;
		_posF = _pos getPos [2,_dir];
		_posF set [2,23.1];
		if (typeOf _antenna == "Land_TTowerBig_2_F") then
			{
			_posF = _pos getPos [1,_dir];
			_posF set [2,24.3];
			};
		_unitType = if (_side == bad) then {if (!_isFIA) then {NATOMarksman} else {FIAMarksman}} else {CSATMarksman};
		_unit = _group createUnit [_unitType, _position, [], _dir, "NONE"];
		_unit setPosATL _posF;
		_unit forceSpeed 0;
		//_unit disableAI "MOVE";
		//_unit disableAI "AUTOTARGET";
		_unit setUnitPos "UP";
		[_unit,_marker] call A3A_fnc_NATOinit;
		_soldiers pushBack _unit;
		_groups pushBack _group;
		};
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


if (_marker in puertos) then
	{
	_box addItemCargo ["V_RebreatherIA",round random 5];
	_box addItemCargo ["G_I_Diving",round random 5];
	};

waitUntil {sleep 1; (spawner getVariable _marker == 2)};

deleteMarker _mrk;
//{if ((!alive _x) and (not(_x in destroyedBuildings))) then {destroyedBuildings = destroyedBuildings + [position _x]; publicVariableServer "destroyedBuildings"}} forEach _buildings;
{
if (alive _x) then
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
