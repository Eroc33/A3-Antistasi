private ["_type","_cost","_group","_unit","_tam","_roads","_road","_pos","_truck","_text","_mrk","_hr","_exists","_clickedPosition","_isRoad","_groupType","_resourcesFIA","_hrFIA"];

if (["PuestosFIA"] call BIS_fnc_taskExists) exitWith {hint "We can only deploy / delete one Observation Post or Roadblock at a time."};
if (!([player] call A3A_fnc_hasRadio)) exitWith {if !(foundIFA) then {hint "You need a radio in your inventory to be able to give orders to other squads"} else {hint "You need a Radio Man in your group to be able to give orders to other squads"}};

_type = _this select 0;

if (!visibleMap) then {openMap true};
posicionTel = [];
if (_type != "delete") then {hint "Click on the position you wish to build the Observation Post or Roadblock. \n Remember: to build Roadblocks you must click exactly on a road map section"} else {hint "Click on the Observation Post or Roadblock to delete."};

onMapSingleClick "posicionTel = _pos;";

waitUntil {sleep 1; (count posicionTel > 0) or (not visiblemap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

_clickedPosition = posicionTel;
_pos = [];

if ((_type == "delete") and (count puestosFIA < 1)) exitWith {hint "No Posts or Roadblocks deployed to delete"};
if ((_type == "delete") and ({(alive _x) and (!captive _x) and ((side _x == bad) or (side _x == veryBad)) and (_x distance _clickedPosition < 500)} count allUnits > 0)) exitWith {hint "You cannot delete a Post while enemies are near it"};

_cost = 0;
_hr = 0;

if (_type != "delete") then
	{
	_isRoad = isOnRoad _clickedPosition;

	_groupType = groupsSDKSniper;

	if (_isRoad) then
		{
		_groupType = groupsSDKAT;
		_cost = _cost + ([vehSDKLightArmed] call A3A_fnc_vehiclePrice) + (server getVariable staticCrewBuenos);
		_hr = _hr + 1;
		};

	//_format = (configfile >> "CfgGroups" >> "good" >> "Guerilla" >> "Infantry" >> _groupType);
	//_units = [_format] call groupComposition;
	{_cost = _cost + (server getVariable (_x select 0)); _hr = _hr +1} forEach _groupType;
	}
else
	{
	_mrk = [puestosFIA,_clickedPosition] call BIS_fnc_nearestPosition;
	_pos = getMarkerPos _mrk;
	if (_clickedPosition distance _pos >10) exitWith {hint "No post nearby"};
	};
//if ((_type == "delete") and (_clickedPosition distance _pos >10)) exitWith {hint "No post nearby"};

_resourcesFIA = server getVariable "resourcesFIA";
_hrFIA = server getVariable "hr";

if (((_resourcesFIA < _cost) or (_hrFIA < _hr)) and (_type!= "delete")) exitWith {hint format ["You lack of resources to build this Outpost or Roadblock \n %1 HR and %2 ? needed",_hr,_cost]};

if (_type != "delete") then
	{
	[-_hr,-_cost] remoteExec ["A3A_fnc_resourcesFIA",2];
	};

 [[_type,_clickedPosition],"A3A_fnc_crearPuestosFIA"] call BIS_fnc_MP
