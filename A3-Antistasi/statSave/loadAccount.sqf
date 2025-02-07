_byPassServer = if (isMultiplayer) then {if (count _this >0) then {_this select 0} else {false}} else {false};
if !(isMultiplayer) then
	{
	waitUntil {/*(!isNil "serverInitDone") and */(!isNil "initVar")};
	["loadoutPlayer"] call fn_LoadStat;
	diag_log "Antistasi: SP Personal player stats loaded";
	[] spawn A3A_fnc_statistics;
	}
else
	{
	if (!isDedicated) then
		{
		if (side player == good) then
			{
			waitUntil {/*(!isNil "serverInitDone") and */(!isNil "initVar")};
			["loadoutPlayer"] call fn_LoadStat;
			//player setPos getMarkerPos respawnGood;
			if ([player] call A3A_fnc_isMember) then
				{
				["scorePlayer"] call fn_LoadStat;
				["rankPlayer"] call fn_LoadStat;
				};
			["dinero"] call fn_LoadStat;
			["personalGarage"] call fn_LoadStat;
			diag_log "Antistasi: MP Personal player stats loaded";
			[] spawn A3A_fnc_statistics;
			};
		};
	};

if (isServer and !_byPassServer) then
	{
	diag_log "Antistasi: Starting Persistent Load";
	petros allowdamage false;

	["puestosFIA"] call fn_LoadStat; publicVariable "puestosFIA";
	["mrkSDK"] call fn_LoadStat; /*if (isMultiplayer) then {sleep 5}*/;
	["mrkCSAT"] call fn_LoadStat;
	["dificultad"] call fn_LoadStat;
	["gameMode"] call fn_LoadStat;
	["destroyedCities"] call fn_LoadStat;
	["minas"] call fn_LoadStat;
	["cuentaCA"] call fn_LoadStat;
	["antenas"] call fn_LoadStat;
	["prestigeNATO"] call fn_LoadStat;
	["prestigeCSAT"] call fn_LoadStat;
	["hr"] call fn_LoadStat;
	["fecha"] call fn_LoadStat;
	["weather"] call fn_LoadStat;
	["prestigeOPFOR"] call fn_LoadStat;
	["prestigeBLUFOR"] call fn_LoadStat;
	["resourcesFIA"] call fn_LoadStat;
	["garrison"] call fn_LoadStat;
	["skillFIA"] call fn_LoadStat;
	["distanceSPWN"] call fn_LoadStat;
	["civPerc"] call fn_LoadStat;
	["maxUnits"] call fn_LoadStat;
	["miembros"] call fn_LoadStat;
	["vehInGarage"] call fn_LoadStat;
	["destroyedBuildings"] call fn_LoadStat;
	["idlebases"] call fn_LoadStat;
	["idleassets"] call fn_LoadStat;
	["killZones"] call fn_LoadStat;
	["controlesSDK"] call fn_LoadStat;
	["bombRuns"] call fn_LoadStat;
	waitUntil {!isNil "arsenalInit"};
	["jna_dataList"] call fn_LoadStat;
	//===========================================================================
	#include "\A3\Ui_f\hpp\defineResinclDesign.inc"

	unlockedWeapons = [];
	unlockedBackpacks = [];
	unlockedMagazines = [];
	unlockedOptics = [];
	unlockedItems = [];
	unlockedRifles = [];
	unlockedMG = [];
	unlockedGL = [];
	unlockedSN = [];
	unlockedAA = [];
	unlockedAT = [];

	{unlockedWeapons pushBack (_x select 0)} forEach (((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_HANDGUN) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOTHROW) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOPUT) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_SECONDARYWEAPON)) select {_x select 1 == -1}); publicVariable "unlockedWeapons";
	{unlockedBackpacks pushBack (_x select 0)} forEach ((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_BACKPACK) select {_x select 1 == -1}); publicVariable "unlockedBackpacks";
	{unlockedMagazines pushBack (_x select 0)} forEach (((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOMAG) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL)) select {_x select 1 == -1}); publicVariable "unlockedMagazines";
	{unlockedOptics pushBack (_x select 0)} forEach ((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMOPTIC) select {_x select 1 == -1});
	unlockedOptics = [unlockedOptics,[],{getNumber (configfile >> "CfgWeapons" >> _x >> "ItemInfo" >> "mass")},"DESCEND"] call BIS_fnc_sortBy;
	publicVariable "unlockedOptics";
	{unlockedItems pushBack (_x select 0)} forEach ((((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_HEADGEAR) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_VEST) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_GOGGLES) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_MAP) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_GPS) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_RADIO) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_COMPASS) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_WATCH) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMACC) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMMUZZLE) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMBIPOD) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_BINOCULARS) + (jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_NVGS)) select {_x select 1 == -1}));
	unlockedItems = unlockedItems + unlockedOptics; publicVariable "unlockedItems";


	//unlockedRifles = unlockedweapons -  hguns -  mlaunchers - rlaunchers - ["Binocular","Laserdesignator","Rangefinder"] - srifles - mguns; publicVariable "unlockedRifles";
	//unlockedRifles = unlockedweapons select {_x in arifles}; publicVariable "unlockedRifles";

	{
	_weapon = _x;
	if (_weapon in arifles) then
		{
		unlockedRifles pushBack _weapon;
		if (count (getArray (configfile >> "CfgWeapons" >> _weapon >> "muzzles")) == 2) then
			{
			unlockedGL pushBack _weapon;
			};
		}
	else
		{
		if (_weapon in mguns) then
			{
			unlockedMG pushBack _weapon;
			}
		else
			{
			if (_weapon in srifles) then
				{
				unlockedSN pushBack _weapon;
				}
			else
				{
				if (_weapon in ((rlaunchers + mlaunchers) select {(getNumber (configfile >> "CfgWeapons" >> _x >> "lockAcquire") == 0)})) then
					{
					unlockedAT pushBack _weapon;
					}
				else
					{
					if (_weapon in (mlaunchers select {(getNumber (configfile >> "CfgWeapons" >> _x >> "lockAcquire") == 1)})) then {unlockedAA pushBack _weapon};
					};
				};
			};
		};
	} forEach unlockedWeapons;
	if (foundIFA) then {unlockedRifles = unlockedRifles - ["LIB_M2_Flamethrower","LIB_PTRD"]};

	publicVariable "unlockedRifles";
	publicVariable "unlockedMG";
	publicVariable "unlockedSN";
	publicVariable "unlockedGL";
	publicVariable "unlockedAT";
	publicVariable "unlockedAA";
	if ("NVGoggles" in unlockedItems) then {haveNV = true; publicVariable "haveNV"};
	if (!haveRadio) then {if ("ItemRadio" in unlockedItems) then {haveRadio = true; publicVariable "haveRadio"}};

	{
	if (sides getVariable [_x,sideUnknown] != good) then
		{
		_position = getMarkerPos _x;
		_near = [(marcadores - controles - puestosFIA),_position] call BIS_fnc_nearestPosition;
		_side = sides getVariable [_near,sideUnknown];
		sides setVariable [_x,_side,true];
		};
	} forEach controles;


	{
	if (sides getVariable [_x,sideUnknown] == sideUnknown) then
		{
		sides setVariable [_x,bad,true];
		};
	} forEach marcadores;

	{[_x] call A3A_fnc_mrkUpdate} forEach (marcadores - controles);
	if (count puestosFIA > 0) then {marcadores = marcadores + puestosFIA; publicVariable "marcadores"};

	{if (_x in destroyedCities) then {[_x] call A3A_fnc_destroyCity}} forEach ciudades;

	["chopForest"] call fn_LoadStat;
	["destroyedBuildings"] call fn_LoadStat;
	/*
	{
	_buildings = nearestObjects [_x, listMilBld, 25, true];
	(_buildings select 1) setDamage 1;
	} forEach destroyedBuildings;
	*/
	["posHQ"] call fn_LoadStat;
	["nextTick"] call fn_LoadStat;
	["estaticas"] call fn_LoadStat;//tiene que ser el ??ltimo para que el sleep del borrado del contenido no haga que despawneen


	if (!isMultiPlayer) then {player setPos getMarkerPos respawnGood} else {{_x setPos getMarkerPos respawnGood} forEach (playableUnits select {side _x == good})};
	_sites = marcadores select {sides getVariable [_x,sideUnknown] == good};
	tierWar = 1 + (floor (((5*({(_x in puestos) or (_x in recursos) or (_x in ciudades)} count _sites)) + (10*({_x in puertos} count _sites)) + (20*({_x in airports} count _sites)))/10));
	if (tierWar > 10) then {tierWar = 10};
	publicVariable "tierWar";

	clearMagazineCargoGlobal caja;
	clearWeaponCargoGlobal caja;
	clearItemCargoGlobal caja;
	clearBackpackCargoGlobal caja;

	[] remoteExec ["A3A_fnc_statistics",[good,civilian]];
	diag_log "Antistasi: Server sided Persistent Load done";

	["tasks"] call fn_LoadStat;
	if !(isMultiplayer) then
		{
		{
		_pos = getMarkerPos _x;
		_dmrk = createMarker [format ["Dum%1",_x], _pos];
		_dmrk setMarkerShape "ICON";
		[_x] call A3A_fnc_mrkUpdate;
		if (sides getVariable [_x,sideUnknown] != good) then
			{
			_nul = [_x] call A3A_fnc_crearControles;
			};
		} forEach airports;

		{
		_pos = getMarkerPos _x;
		_dmrk = createMarker [format ["Dum%1",_x], _pos];
		_dmrk setMarkerShape "ICON";
		_dmrk setMarkerType "loc_rock";
		_dmrk setMarkerText "Resources";
		[_x] call A3A_fnc_mrkUpdate;
		if (sides getVariable [_x,sideUnknown] != good) then
			{
			_nul = [_x] call A3A_fnc_crearControles;
			};
		} forEach recursos;

		{
		_pos = getMarkerPos _x;
		_dmrk = createMarker [format ["Dum%1",_x], _pos];
		_dmrk setMarkerShape "ICON";
		_dmrk setMarkerType "u_installation";
		_dmrk setMarkerText "Factory";
		[_x] call A3A_fnc_mrkUpdate;
		if (sides getVariable [_x,sideUnknown] != good) then
			{
			_nul = [_x] call A3A_fnc_crearControles;
			};
		} forEach fabricas;

		{
		_pos = getMarkerPos _x;
		_dmrk = createMarker [format ["Dum%1",_x], _pos];
		_dmrk setMarkerShape "ICON";
		_dmrk setMarkerType "loc_bunker";
		[_x] call A3A_fnc_mrkUpdate;
		if (sides getVariable [_x,sideUnknown] != good) then
			{
			_nul = [_x] call A3A_fnc_crearControles;
			};
		} forEach puestos;

		{
		_pos = getMarkerPos _x;
		_dmrk = createMarker [format ["Dum%1",_x], _pos];
		_dmrk setMarkerShape "ICON";
		_dmrk setMarkerType "b_naval";
		_dmrk setMarkerText "Sea Port";
		[_x] call A3A_fnc_mrkUpdate;
		if (sides getVariable [_x,sideUnknown] != good) then
			{
			_nul = [_x] call A3A_fnc_crearControles;
			};
		} forEach puertos;
		sides setVariable ["NATO_carrier",bad,true];
		sides setVariable ["CSAT_carrier",veryBad,true];
		};
	statsLoaded = 0; publicVariable "statsLoaded";
	placementDone = true; publicVariable "placementDone";
	petros allowdamage true;
	};
