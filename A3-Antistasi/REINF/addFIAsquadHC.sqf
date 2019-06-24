
if (player != theBoss) exitWith {hint "Only our Commander has access to this function"};
//if (!allowPlayerRecruit) exitWith {hint "Server is very loaded. \nWait one minute or change FPS settings in order to fulfill this request"};
if (markerAlpha respawnGood == 0) exitWith {hint "You cant recruit a new squad while you are moving your HQ"};
if (!([player] call A3A_fnc_hasRadio)) exitWith {if !(foundIFA) then {hint "You need a radio in your inventory to be able to give orders to other squads"} else {hint "You need a Radio Man in your group to be able to give orders to other squads"}};
_chequeo = false;
{
	if (((side _x == veryBad) or (side _x == bad)) and (_x distance petros < 500) and ([_x] call A3A_fnc_canFight) and !(isPlayer _x)) exitWith {_chequeo = true};
} forEach allUnits;

if (_chequeo) exitWith {Hint "You cannot Recruit Squads with enemies near your HQ"};

private ["_groupType","_isInf","_vehicleType","_cost","_costHR","_exit","_format","_pos","_hr","_resourcesFIA","_group","_roads","_road","_group","_truck","_vehicle","_mortar","_mortarCrew"];


_groupType = _this select 0;
_exit = false;
if (_groupType isEqualType "") then
	{
	if (_groupType == "not_supported") then {_exit = true; hint "The group or vehicle type you request is not supported in your modset"};
	if (foundIFA and ((_groupType == SDKMortar) or (_groupType == SDKMGStatic)) and !debug) then {_exit = true; hint "The group or vehicle type you request is not supported in your modset"};
	};

if (activeGREF) then
	{
	if (_groupType isEqualType objNull) then
		{
		if (_groupType == staticATbuenos) then {hint "AT trucks are disabled in RHS - GREF"; _exit = true};
		};
	};
if (_exit) exitWith {};
garageVeh = objNull;
_isInf = false;
_vehicleType = "";
_cost = 0;
_costHR = 0;
_format = [];
_squadId = "Squd-";

_hr = server getVariable "hr";
_resourcesFIA = server getVariable "resourcesFIA";

private ["_group","_roads","_truck","_withBackpack"];
_withBackpack = "";
if (_groupType isEqualType []) then
	{
	{
	_unitType = if (random 20 <= skillFIA) then {_x select 1} else {_x select 0};
	_format pushBack _unitType;
	_cost = _cost + (server getVariable _unitType); _costHR = _costHR +1
	} forEach _groupType;
	if (count _this > 1) then
		{
		_withBackpack = _this select 1;
		if (_withBackpack == "MG") then {_cost = _cost + ([SDKMGStatic] call A3A_fnc_vehiclePrice)};
		if (_withBackpack == "Mortar") then {_cost = _cost + ([SDKMortar] call A3A_fnc_vehiclePrice)};
		};
	_isInf = true;
	}
else
	{
	_cost = _cost + (2*(server getVariable staticCrewBuenos)) + ([_groupType] call A3A_fnc_vehiclePrice);
	_costHR = 2;
	//if (_groupType == SDKMortar) then {_cost = _cost + ([vehSDKBike] call A3A_fnc_vehiclePrice)} else {_cost = _cost + ([vehSDKTruck] call A3A_fnc_vehiclePrice)};
	if ((_groupType == SDKMortar) or (_groupType == SDKMGStatic)) then
		{
		_isInf = true;
		_format = [staticCrewBuenos,staticCrewBuenos];
		}
	else
		{
		_cost = _cost + ([vehSDKTruck] call A3A_fnc_vehiclePrice)
		};
	};
if ((_withBackpack != "") and foundIFA) exitWith {hint "Your current modset does not support packing / unpacking static weapons"; garageVeh = nil};

if (_hr < _costHR) then {_exit = true;hint format ["You do not have enough HR for this request (%1 required)",_costHR]};

if (_resourcesFIA < _cost) then {_exit = true;hint format ["You do not have enough money for this request (%1 ??? required)",_cost]};

if (_exit) exitWith {garageVeh = nil};

_nul = [- _costHR, - _cost] remoteExec ["A3A_fnc_resourcesFIA",2];

_pos = getMarkerPos respawnGood;

_road = [_pos] call A3A_fnc_findNearestGoodRoad;
_bypassAI = false;
if (_isInf) then
	{
	_pos = [(getMarkerPos respawnGood), 30, random 360] call BIS_Fnc_relPos;
	if (_groupType isEqualType []) then
		{
		_group = [_pos, good, _format,true] call A3A_fnc_spawnGroup;
		//if (_groupType isEqualTo groupsSDKSquad) then {_squadId = "Squd-"};
		if (_groupType isEqualTo groupsSDKmid) then {_squadId = "Tm-"};
		if (_groupType isEqualTo groupsSDKAT) then {_squadId = "AT-"};
		if (_groupType isEqualTo groupsSDKSniper) then {_squadId = "Snpr-"};
		if (_groupType isEqualTo groupsSDKSentry) then {_squadId = "Stry-"};
		if (_withBackpack == "MG") then
			{
			((units _group) select ((count (units _group)) - 2)) addBackpackGlobal soporteStaticSDKB2;
			((units _group) select ((count (units _group)) - 1)) addBackpackGlobal MGStaticSDKB;
			_squadId = "SqMG-";
			}
		else
			{
			if (_withBackpack == "Mortar") then
				{
				((units _group) select ((count (units _group)) - 2)) addBackpackGlobal soporteStaticSDKB3;
				((units _group) select ((count (units _group)) - 1)) addBackpackGlobal MortStaticSDKB;
				_squadId = "SqMort-";
				};
			};
		}
	else
		{
		_group = [_pos, good, _format,true] call A3A_fnc_spawnGroup;
		_group setVariable ["staticAutoT",false,true];
		if (_groupType == SDKMortar) then {_squadId = "Mort-"};
		if (_groupType == SDKMGStatic) then {_squadId = "MG-"};
		[_group,_groupType] spawn A3A_fnc_MortyAI;
		_bypassAI = true;
		};
	_squadId = format ["%1%2",_squadId,{side (leader _x) == good} count allGroups];
	_group setGroupId [_squadId];
	}
else
	{
	_pos = position _road findEmptyPosition [1,30,vehSDKTruck];
	_vehicle = if (_groupType == staticAABuenos) then
		{
		if (activeGREF) then {[_pos, 0,"rhsgref_ins_g_ural_Zu23", good] call bis_fnc_spawnvehicle} else {[_pos, 0,vehSDKTruck, good] call bis_fnc_spawnvehicle};
		}
	else
		{
		[_pos, 0,_groupType, good] call bis_fnc_spawnvehicle
		};
	_truck = _vehicle select 0;
	_group = _vehicle select 2;
	//_mortar attachTo [_truck,[0,-1.5,0.2]];
	//_mortar setDir (getDir _truck + 180);

	if ((!activeGREF) and (_groupType == staticAABuenos)) then
		{
		_pos = _pos findEmptyPosition [1,30,SDKMortar];
		_mortarCrew = _group createUnit [staticCrewBuenos, _pos, [],0, "NONE"];
		_mortar = _groupType createVehicle _pos;
		_nul = [_mortar] call A3A_fnc_AIVEHinit;
		_mortar attachTo [_truck,[0,-1.5,0.2]];
		_mortar setDir (getDir _truck + 180);
		_mortarCrew moveInGunner _mortar;
		};
	if (_groupType == vehSDKAT) then {_group setGroupId [format ["M.AT-%1",{side (leader _x) == good} count allGroups]]};
	if (_groupType == staticAABuenos) then {_group setGroupId [format ["M.AA-%1",{side (leader _x) == good} count allGroups]]};

	driver _truck action ["engineOn", vehicle driver _truck];
	_nul = [_truck] call A3A_fnc_AIVEHinit;
	_bypassAI = true;
	};

{[_x] call A3A_fnc_FIAinit} forEach units _group;
//leader _group setBehaviour "SAFE";
theBoss hcSetGroup [_group];
petros directSay "SentGenReinforcementsArrived";
hint format ["Group %1 at your command.\n\nGroups are managed from the High Command bar (Default: CTRL+SPACE)\n\nIf the group gets stuck, use the AI Control feature to make them start moving. Mounted Static teams tend to get stuck (solving this is WiP)\n\nTo assign a vehicle for this group, look at some vehicle, and use Vehicle Squad Mngmt option in Y menu", groupID _group];

if (!_isInf) exitWith {garageVeh = nil};
if !(_bypassAI) then {_group spawn A3A_fnc_attackDrillAI};

if (count _format == 2) then
	{
	_vehicleType = vehSDKBike;
	}
else
	{
	if (count _format > 4) then
		{
		_vehicleType = vehSDKTruck;
		}
	else
		{
		_vehicleType = vehSDKLightUnarmed;
		};
	};

_cost = [_vehicleType] call A3A_fnc_vehiclePrice;
private ["_display","_childControl"];
if (_cost > server getVariable "resourcesFIA") exitWith {garageVeh = nil};

_nul = createDialog "veh_query";

sleep 1;
disableSerialization;

_display = findDisplay 100;

if (str (_display) != "no display") then
	{
	_ChildControl = _display displayCtrl 104;
	_ChildControl  ctrlSetTooltip format ["Buy a vehicle for this squad for %1 ???",_cost];
	_ChildControl = _display displayCtrl 105;
	_ChildControl  ctrlSetTooltip "Barefoot Infantry";
	};

waitUntil {(!dialog) or (!isNil "vehQuery")};
garageVeh = nil;
if ((!dialog) and (isNil "vehQuery")) exitWith {};

//if (!vehQuery) exitWith {vehQuery = nil};

vehQuery = nil;
//_resourcesFIA = server getVariable "resourcesFIA";
//if (_resourcesFIA < _cost) exitWith {hint format ["You do not have enough money for this vehicle: %1 ??? required",_cost]};
_pos = position _road findEmptyPosition [1,30,"B_G_Van_01_transport_F"];
_mortar = _vehicleType createVehicle _pos;
_nul = [_mortar] call A3A_fnc_AIVEHinit;
_group addVehicle _mortar;
_mortar setVariable ["owner",_group,true];
_nul = [0, - _cost] remoteExec ["A3A_fnc_resourcesFIA",2];
leader _group assignAsDriver _mortar;
{[_x] orderGetIn true; [_x] allowGetIn true} forEach units _group;
hint "Vehicle Purchased";
petros directSay "SentGenBaseUnlockVehicle";
