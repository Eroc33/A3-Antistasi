if (!isServer and hasInterface) exitWith{};

private ["_marker","_vehicles","_groups","_soldiers","_civs","_position","_pos","_groupType","_tipociv","_mrkSize","_mrk","_ang","_count","_group","_veh","_civ","_isFrontLine","_flag","_dog","_garrison","_side","_cfg","_isFIA","_roads","_dist","_road","_roadscon","_roadcon","_dirveh","_bunker","_vehicleType","_unitType","_unit","_groupType","_stance"];

_marker = _this select 0;

_position = getMarkerPos _marker;

_mrkSize = [_marker] call A3A_fnc_sizeMarker;

_civs = [];
_soldiers = [];
_groups = [];
_vehicles = [];

_isFrontLine = [_marker] call A3A_fnc_isFrontline;

_side = veryBad;

_isFIA = false;
if (sides getVariable [_marker,sideUnknown] == bad) then
	{
	_side = bad;
	if ((random 10 <= (tierWar + difficultyCoef)) and !(_isFrontLine)) then
		{
		_isFIA = true;
		};
	};
_roads = _position nearRoads _mrkSize;
_dist = 0;
_road = objNull;
{if ((position _x) distance _position > _dist) then {_road = _x;_dist = position _x distance _position}} forEach _roads;
_roadscon = roadsConnectedto _road;
_roadcon = objNull;
{if ((position _x) distance _position > _dist) then {_roadcon = _x}} forEach _roadscon;
_dirveh = [_roadcon, _road] call BIS_fnc_DirTo;

if ((spawner getVariable _marker != 2) and _isFrontLine) then
	{
	if (count _roads != 0) then
		{
		if (!_isFIA) then
			{
			_group = createGroup _side;
			_groups pushBack _group;
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
			_nul = [leader _group, _mrk, "SAFE","SPAWNED", "RANDOM","NOVEH2"] execVM "scripts\UPSMON.sqf";
			_groups pushBack _group;
			{[_x,_marker] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _group;
			};
		_count = _count +1;
		};
	};

_vehicleType = if (_side == bad) then {NATOFlag} else {CSATFlag};
_flag = createVehicle [_vehicleType, _position, [],0, "CAN_COLLIDE"];
_flag allowDamage false;
[_flag,"take"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_flag];
_vehicles pushBack _flag;

if (not(_marker in destroyedCities)) then
	{
	if ((daytime > 8) and (daytime < 18)) then
		{
		_group = createGroup civilian;
		_groups pushBack _group;
		for "_i" from 1 to 4 do
			{
			if (spawner getVariable _marker != 2) then
				{
				_civ = _group createUnit ["C_man_w_worker_F", _position, [],0, "NONE"];
				_nul = [_civ] spawn A3A_fnc_CIVinit;
				_civs pushBack _civ;
				_civ setVariable ["marcador",_marker,true];
				sleep 0.5;
				_civ addEventHandler ["Killed",
					{
					if (({alive _x} count units group (_this select 0)) == 0) then
						{
						_marker = (_this select 0) getVariable "marcador";
						_name = [_marker] call A3A_fnc_localizar;
						destroyedCities pushBackUnique _marker;
						publicVariable "destroyedCities";
						["TaskFailed", ["", format ["%1 Destroyed",_name]]] remoteExec ["BIS_fnc_showNotification",[good,civilian]];
						};
					}];
				};
			};
		//_nul = [_marker,_civs] spawn destroyCheck;
		_nul = [leader _group, _marker, "SAFE", "SPAWNED","NOFOLLOW", "NOSHARE","DORELAX","NOVEH2"] execVM "scripts\UPSMON.sqf";
		};
	};

_pos = _position findEmptyPosition [5,_mrkSize,"I_Truck_02_covered_F"];//donde pone 5 antes pon??a 10
if (count _pos > 0) then
	{
	_vehicleType = if (_side == bad) then
		{
		if (!_isFIA) then {vehNATOTrucks} else {[vehFIATruck]};
		}
	else
		{
		vehCSATTrucks
		};
	_veh = createVehicle [selectRandom _vehicleType, _pos, [], 0, "NONE"];
	_veh setDir random 360;
	_vehicles pushBack _veh;
	_nul = [_veh] call A3A_fnc_AIVEHinit;
	sleep 1;
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
{
if (alive _x) then
	{
	deleteVehicle _x
	};
} forEach _soldiers;
//if (!isNull _periodista) then {deleteVehicle _periodista};
{deleteGroup _x} forEach _groups;
{deleteVehicle _x} forEach _civs;
{if (!([distanceSPWN-_mrkSize,1,_x,good] call A3A_fnc_distanceUnits)) then {deleteVehicle _x}} forEach _vehicles;
