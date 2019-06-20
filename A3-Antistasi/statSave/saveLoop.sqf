if (savingClient) exitWith {hint "Your personal stats are being saved"};
if (!isDedicated) then
	{
	if (side player == good) then
		{
		savingClient = true;
		["loadoutPlayer", getUnitLoadout player] call fn_SaveStat;
		//["gogglesPlayer", goggles player] call fn_SaveStat;
		//["vestPlayer", vest player] call fn_SaveStat;
		//["outfit", uniform player] call fn_SaveStat;
		//["hat", headGear player] call fn_SaveStat;
		if (isMultiplayer) then
			{
			["scorePlayer", player getVariable "score"] call fn_SaveStat;
			["rankPlayer",rank player] call fn_SaveStat;
			_personalGarage = [];
			_personalGarage = _personalGarage + personalGarage;
			["personalGarage",_personalGarage] call fn_SaveStat;
			_resFunds = player getVariable "dinero";
			{
			_friend = _x;
			if ((!isPlayer _friend) and (alive _friend)) then
				{
				_resFunds = _resFunds + (server getVariable (typeOf _friend));
				if (vehicle _friend != _friend) then
					{
					_veh = vehicle _friend;
					_vehicleType = typeOf _veh;
					if (not(_veh in staticsToSave)) then
						{
						if ((_veh isKindOf "StaticWeapon") or (driver _veh == _friend)) then
							{
							_resFunds = _resFunds + ([_vehicleType] call A3A_fnc_vehiclePrice);
							if (count attachedObjects _veh != 0) then {{_resFunds = _resFunds + ([typeOf _x] call A3A_fnc_vehiclePrice)} forEach attachedObjects _veh};
							};
						};
					};
				};
			} forEach units group player;
			["dinero",_resFunds] call fn_SaveStat;
			};
		savingClient = false;
		};
	};

 if (!isServer) exitWith {};
 if (savingServer) exitWith {"Server data save is still in progress" remoteExecCall ["hint",theBoss]};
 savingServer = true;
 private ["_garrison"];
	["cuentaCA", cuentaCA] call fn_SaveStat;
	["gameMode", gameMode] call fn_SaveStat;
	["dificultad", skillMult] call fn_SaveStat;
	["bombRuns", bombRuns] call fn_SaveStat;
	["smallCAmrk", smallCAmrk] call fn_SaveStat;
	["miembros", miembros] call fn_SaveStat;
	["antenas", antenasmuertas] call fn_SaveStat;
	//["mrkNATO", (marcadores - controles) select {sides getVariable [_x,sideUnknown] == bad}] call fn_SaveStat;
	["mrkSDK", (marcadores - controles - puestosFIA) select {sides getVariable [_x,sideUnknown] == good}] call fn_SaveStat;
	["mrkCSAT", (marcadores - controles) select {sides getVariable [_x,sideUnknown] == veryBad}] call fn_SaveStat;
	["posHQ", [getMarkerPos respawnGood,getPos fuego,[getDir caja,getPos caja],[getDir mapa,getPos mapa],getPos bandera,[getDir cajaVeh,getPos cajaVeh]]] call fn_Savestat;
	["prestigeNATO", prestigeNATO] call fn_SaveStat;
	["prestigeCSAT", prestigeCSAT] call fn_SaveStat;
	["fecha", date] call fn_SaveStat;
	["skillFIA", skillFIA] call fn_SaveStat;
	["destroyedCities", destroyedCities] call fn_SaveStat;
	["distanceSPWN", distanceSPWN] call fn_SaveStat;
	["civPerc", civPerc] call fn_SaveStat;
	["chopForest", chopForest] call fn_SaveStat;
	["maxUnits", maxUnits] call fn_SaveStat;
	["nextTick", nextTick - time] call fn_SaveStat;
	/*
	["unlockedWeapons", unlockedWeapons] call fn_SaveStat;
	["unlockedItems", unlockedItems] call fn_SaveStat;
	["unlockedMagazines", unlockedMagazines] call fn_SaveStat;
	["unlockedBackpacks", unlockedBackpacks] call fn_SaveStat;
	*/
	["weather",[fogParams,rain]] call fn_SaveStat;
	["destroyedBuildings",destroyedBuildings] call fn_SaveStat;
	//["firstLoad",false] call fn_SaveStat;
private ["_hrFunds","_resFunds","_veh","_vehicleType","_weapons","_municion","_items","_bags","_contenedores","_arrayStatics","_posVeh","_dierVeh","_prestigeOPFOR","_prestigeBLUFOR","_city","_data","_markers","_garrison","_arrayMrkMF","_arrayFIAposts","_postPositions","_mineType","_minePos","_detected","_types","_exists","_friend"];

_hrFunds = (server getVariable "hr") + ({(alive _x) and (not isPlayer _x) and (_x getVariable ["spawner",false]) and ((group _x in (hcAllGroups theBoss) or (isPlayer (leader _x))) and (side group _x == good))} count allUnits);
_resFunds = server getVariable "resourcesFIA";
/*
_weapons = [];
_municion = [];
_items = [];
_bags = [];*/
_vehInGarage = [];
_vehInGarage = _vehInGarage + vehInGarage;
{
_friend = _x;
if ((_friend getVariable ["spawner",false]) and (side group _friend == good))then
	{
	if ((alive _friend) and (!isPlayer _friend)) then
		{
		if (((isPlayer leader _friend) and (!isMultiplayer)) or (group _friend in (hcAllGroups theBoss)) and (not((group _friend) getVariable ["esNATO",false]))) then
			{
			_resFunds = _resFunds + (server getVariable [(typeOf _friend),0]);
			_bag = backpack _friend;
			if (_bag != "") then
				{
				switch (_bag) do
					{
					case MortStaticSDKB: {_resFunds = _resFunds + ([SDKMortar] call A3A_fnc_vehiclePrice)};
					case AAStaticSDKB: {_resFunds = _resFunds + ([staticAABuenos] call A3A_fnc_vehiclePrice)};
					case MGStaticSDKB: {_resFunds = _resFunds + ([SDKMGStatic] call A3A_fnc_vehiclePrice)};
					case ATStaticSDKB: {_resFunds = _resFunds + ([staticATBuenos] call A3A_fnc_vehiclePrice)};
					};
				};
			if (vehicle _friend != _friend) then
				{
				_veh = vehicle _friend;
				_vehicleType = typeOf _veh;
				if (not(_veh in staticsToSave)) then
					{
					if ((_veh isKindOf "StaticWeapon") or (driver _veh == _friend)) then
						{
						if ((group _friend in (hcAllGroups theBoss)) or (!isMultiplayer)) then
							{
							_resFunds = _resFunds + ([_vehicleType] call A3A_fnc_vehiclePrice);
							if (count attachedObjects _veh != 0) then {{_resFunds = _resFunds + ([typeOf _x] call A3A_fnc_vehiclePrice)} forEach attachedObjects _veh};
							};
						};
					};
				};
			};
		};
	};
} forEach allUnits;


["resourcesFIA", _resFunds] call fn_SaveStat;
["hr", _hrFunds] call fn_SaveStat;
["vehInGarage", _vehInGarage] call fn_SaveStat;

_arrayStatics = [];
{
_veh = _x;
_vehicleType = typeOf _veh;
if ((_veh distance getMarkerPos respawnGood < 50) and !(_veh in staticsToSave) and !(_vehicleType in ["ACE_SandbagObject","Land_PaperBox_01_open_boxes_F","Land_PaperBox_01_open_empty_F"])) then
	{
	if (((not (_veh isKindOf "StaticWeapon")) and (not (_veh isKindOf "ReammoBox")) and (not (_veh isKindOf "FlagCarrier")) and (not(_veh isKindOf "Building"))) and (not (_vehicleType == "C_Van_01_box_F")) and (count attachedObjects _veh == 0) and (alive _veh) and ({(alive _x) and (!isPlayer _x)} count crew _veh == 0) and (not(_vehicleType == "WeaponHolderSimulated"))) then
		{
		_posVeh = getPos _veh;
		_dirVeh = getDir _veh;
		_arrayStatics pushBack [_vehicleType,_posVeh,_dirVeh];
		};
	};
} forEach vehicles - [caja,bandera,fuego,cajaveh,mapa];

_sites = marcadores select {sides getVariable [_x,sideUnknown] == good};
{
_position = position _x;
if ((alive _x) and !(surfaceIsWater _position) and !(isNull _x)) then
	{
	_arrayStatics pushBack [typeOf _x,getPos _x,getDir _x];
	/*
	_near = [_sites,_position] call BIS_fnc_nearestPosition;
	if (_position inArea _near) then
		{
		_arrayStatics pushBack [typeOf _x,getPos _x,getDir _x]
		};
	*/
	};
} forEach staticsToSave;

["estaticas", _arrayStatics] call fn_SaveStat;
[] call A3A_fnc_arsenalManage;

_jna_dataList = [];
_jna_dataList = _jna_dataList + jna_dataList;
["jna_dataList", _jna_dataList] call fn_SaveStat;

_prestigeOPFOR = [];
_prestigeBLUFOR = [];

{
_city = _x;
_data = server getVariable _city;
_prestigeOPFOR = _prestigeOPFOR + [_data select 2];
_prestigeBLUFOR = _prestigeBLUFOR + [_data select 3];
} forEach ciudades;

["prestigeOPFOR", _prestigeOPFOR] call fn_SaveStat;
["prestigeBLUFOR", _prestigeBLUFOR] call fn_SaveStat;

_markers = marcadores - puestosFIA - controles;
_garrison = [];
{
_garrison pushBack [_x,garrison getVariable [_x,[]]];
} forEach _markers;

["garrison",_garrison] call fn_SaveStat;
/*
_arrayMrkMF = [];

{
_posMineF = getMarkerPos _x;
_arrayMrkMF = _arrayMrkMF + [_posMineF];
} forEach minefieldMrk;

["mineFieldMrk", _arrayMrkMF] call fn_SaveStat;
*/
_minesArray = [];
{
_mineType = typeOf _x;
_minePos = getPos _x;
_dirMina = getDir _x;
_detected = [];
if (_x mineDetectedBy good) then
	{
	_detected pushBack good
	};
if (_x mineDetectedBy bad) then
	{
	_detected pushBack bad
	};
if (_x mineDetectedBy veryBad) then
	{
	_detected pushBack veryBad
	};
_minesArray = _minesArray + [[_mineType,_minePos,_detected,_dirMina]];
} forEach allMines;

["minas", _minesArray] call fn_SaveStat;

_arrayFIAposts = [];

{
_postPositions = getMarkerPos _x;
_arrayFIAposts pushBack [_postPositions,garrison getVariable [_x,[]]];
} forEach puestosFIA;

["puestosFIA", _arrayFIAposts] call fn_SaveStat;

if (!isDedicated) then
	{
	_types = [];
	{
	if ([_x] call BIS_fnc_taskExists) then
		{
		_state = [_x] call BIS_fnc_taskState;
		if (_state == "CREATED") then
			{
			_types pushBackUnique _x;
			};
		};
	} forEach ["AS","CON","DES","LOG","RES","CONVOY","DEF_HQ","AtaqueAAF"];

	["tasks",_types] call fn_SaveStat;
	};

_data = [];
{
_data pushBack [_x,server getVariable _x];
} forEach airports + puestos;

["idlebases",_data] call fn_SaveStat;

_data = [];
{
_data pushBack [_x,timer getVariable _x];
} forEach (vehAttack + vehNATOAttackHelis + vehPlanes + vehCSATAttackHelis);

["idleassets",_data] call fn_SaveStat;

_data = [];
{
_data pushBack [_x,killZones getVariable [_x,[]]];
} forEach airports + puestos;

["killZones",_data] call fn_SaveStat;

_controls = controles select {(sides getVariable [_x,sideUnknown] == good) and (controles find _x < defaultControlIndex)};
["controlesSDK",_controls] call fn_SaveStat;

savingServer = false;
[[petros,"hint",format ["Savegame Done.\n\nYou won't lose your stats in the event of a game update.\n\nRemember: if you want to preserve any vehicle, it must be near the HQ Flag with no AI inside.\nIf AI are inside, you will save the funds you spent on it.\n\nAI will be refunded\n\nStolen and purchased Static Weapons need to be ASSEMBLED in order to be saved. You can save disassembled Static Weapons in the ammo box.\n\nMounted Statics (Mortar/AA/AT squads) won't get saved, but you will be able to recover the cost.\n\nSame for assigned vehicles more than 50m away from HQ.\n\n%1 fund count:\nHR: %2\nMoney: %3 ???",nameBuenos,_hrFunds,_resFunds]],"A3A_fnc_commsMP"] call BIS_fnc_MP;
diag_log "Antistasi: Persistent Save Done";
