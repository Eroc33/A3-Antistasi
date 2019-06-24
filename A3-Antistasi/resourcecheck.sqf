if (!isServer) exitWith{};

if (isMultiplayer) then {waitUntil {!isNil "switchCom"}};

private ["_text"];
scriptName "resourcecheck";
_saveCounter = 3600;

while {true} do
	{
	//sleep 600;//600
	nextTick = time + 600;
	waitUntil {sleep 15; time >= nextTick};
	if (isMultiplayer) then {waitUntil {sleep 10; isPlayer theBoss}};
	_suppBoost = 1+ ({sides getVariable [_x,sideUnknown] == good} count puertos);
	_resAddSDK = 25;//0
	_hrAddBLUFOR = 0;//0
	_popFIA = 0;
	_popAAF = 0;
	_popCSAT = 0;
	_popTotal = 0;
	_bonusFIA = 1 + (0.25*({(sides getVariable [_x,sideUnknown] == good) and !(_x in destroyedCities)} count fabricas));
	{
	_city = _x;
	_recAddCitySDK = 0;
	_hrAddCity = 0;
	_data = server getVariable _city;
	_numCiv = _data select 0;
	_numVeh = _data select 1;
	//_roads = _data select 2;
	_prestigeNATO = _data select 2;
	_prestigeSDK = _data select 3;
	_power = [_city] call A3A_fnc_powerCheck;
	_popTotal = _popTotal + _numCiv;
	_popFIA = _popFIA + (_numCiv * (_prestigeSDK / 100));
	_popAAF = _popAAF + (_numCiv * (_prestigeNATO / 100));
	_resourceMultiplyer = if (_power != good) then {0.5} else {1};
	//if (not _power) then {_resourceMultiplyer = 0.5};

	if (_city in destroyedCities) then
		{
		_recAddCitySDK = 0;
		_hrAddCity = 0;
		_popCSAT = _popCSAT + _numCIV;
		}
	else
		{
		_recAddCitySDK = ((_numciv * _resourceMultiplyer*(_prestigeSDK / 100))/3);
		_hrAddCity = (_numciv * (_prestigeSDK / 10000));///20000 originalmente
		switch (_power) do
			{
			case good: {[-1,_suppBoost,_city] spawn A3A_fnc_citySupportChange};
			case bad: {[1,-1,_city] spawn A3A_fnc_citySupportChange};
			case veryBad: {[-1,-1,_city] spawn A3A_fnc_citySupportChange};
			};
		if (sides getVariable [_city,sideUnknown] == bad) then
			{
			_recAddCitySDK = (_recAddCitySDK/2);
			_hrAddCity = (_hrAddCity/2);
			};
		};
	_resAddSDK = _resAddSDK + _recAddCitySDK;
	_hrAddBLUFOR = _hrAddBLUFOR + _hrAddCity;
	// revuelta civil!!
	if ((_prestigeNATO < _prestigeSDK) and (sides getVariable [_city,sideUnknown] == bad)) then
		{
		["TaskSucceeded", ["", format ["%1 joined %2",[_city, false] call A3A_fnc_fn_location,nameBuenos]]] remoteExec ["BIS_fnc_showNotification",good];
		sides setVariable [_city,good,true];
		_nul = [5,0] remoteExec ["A3A_fnc_prestige",2];
		_mrkD = format ["Dum%1",_city];
		_mrkD setMarkerColor colorGood;
		garrison setVariable [_city,[],true];
		sleep 5;
		{_nul = [_city,_x] spawn A3A_fnc_deleteControles} forEach controles;
		if ((!(["CONVOY"] call BIS_fnc_taskExists)) and (!bigAttackInProgress)) then
			{
			_base = [_city] call A3A_fnc_findBasesForConvoy;
			if (_base != "") then
				{
				[[_city,_base],"CONVOY"] call A3A_fnc_scheduler;
				};
			};
		[] call A3A_fnc_tierCheck;
		};
	if ((_prestigeNATO > _prestigeSDK) and (sides getVariable [_city,sideUnknown] == good)) then
		{
		["TaskFailed", ["", format ["%1 joined %2",[_city, false] call A3A_fnc_fn_location,nameMalos]]] remoteExec ["BIS_fnc_showNotification",good];
		sides setVariable [_city,bad,true];
		_nul = [-5,0] remoteExec ["A3A_fnc_prestige",2];
		_mrkD = format ["Dum%1",_city];
		_mrkD setMarkerColor colorBad;
		garrison setVariable [_city,[],true];
		sleep 5;
		[] call A3A_fnc_tierCheck;
		};
	} forEach ciudades;
	if (_popCSAT > (_popTotal / 3)) then {["destroyedCities",false,true] remoteExec ["BIS_fnc_endMission"]};
	if ((_popFIA > _popAAF) and ({sides getVariable [_x,sideUnknown] == good} count airports == count airports)) then {["end1",true,true,true,true] remoteExec ["BIS_fnc_endMission",0]};
	/*
	{
	_fabrica = _x;
	if (sides getVariable [_fabrica,sideUnknown] == good) then
		{
		if (not(_fabrica in destroyedCities)) then {_bonusFIA = _bonusFIA + 0.25};
		};
	} forEach fabricas;
	*/
	{
	_resources = _x;
	if (sides getVariable [_resources,sideUnknown] == good) then
		{
		if (not(_resources in destroyedCities)) then {_resAddSDK = _resAddSDK + (300 * _bonusFIA)};
		};
	} forEach recursos;
	_hrAddBLUFOR = (round _hrAddBLUFOR);
	_resAddSDK = (round _resAddSDK);

	_text = format ["<t size='0.6' color='#C1C0BB'>Taxes Income.<br/> <t size='0.5' color='#C1C0BB'><br/>Manpower: +%1<br/>Money: +%2 ???",_hrAddBLUFOR,_resAddSDK];
	[] call A3A_fnc_FIAradio;
	//_updated = false;
	_updated = [] call A3A_fnc_arsenalManage;
	if (_updated != "") then {_text = format ["%1<br/>Arsenal Updated<br/><br/>%2",_text,_updated]};
	[petros,"taxRep",_text] remoteExec ["A3A_fnc_commsMP",[good,civilian]];
	_hrAddBLUFOR = _hrAddBLUFOR + (server getVariable "hr");
	_resAddSDK = _resAddSDK + (server getVariable "resourcesFIA");
	server setVariable ["hr",_hrAddBLUFOR,true];
	server setVariable ["resourcesFIA",_resAddSDK,true];
	bombRuns = bombRuns + (({sides getVariable [_x,sideUnknown] == good} count airports) * 0.25);
	[petros,"taxRep",_text] remoteExec ["A3A_fnc_commsMP",[good,civilian]];
	[] call A3A_fnc_economicsAI;
	if (isMultiplayer) then
		{
		[] spawn A3A_fnc_assigntheBoss;
		difficultyCoef = floor ((({side group _x == good} count playableUnits) - ({side group _x != good} count playableUnits)) / 5);
		publicVariable "difficultyCoef";
		};
	if ((!bigAttackInProgress) and (random 100 < 50)) then {[] call A3A_fnc_missionRequestAUTO};
	[[],"A3A_fnc_reinforcementsAI"] call A3A_fnc_scheduler;
	{
	_veh = _x;
	if ((_veh isKindOf "StaticWeapon") and ({isPlayer _x} count crew _veh == 0) and (alive _veh)) then
		{
		_veh setDamage 0;
		[_veh,1] remoteExec ["setVehicleAmmoDef",_veh];
		};
	} forEach vehicles;
	cuentaCA = cuentaCA - 600;
	if (cuentaCA < 0) then {cuentaCA = 0};
	publicVariable "cuentaCA";
	if ((cuentaCA == 0)/* and (diag_fps > minimoFPS)*/) then
		{
		[1200] remoteExec ["A3A_fnc_timingCA",2];
		if (!bigAttackInProgress) then
			{
			_script = [] spawn A3A_fnc_ataqueAAF;
			waitUntil {sleep 5; scriptDone _script};
			};
		};
	sleep 3;
	if ((count antenasMuertas > 0) and (not(["REP"] call BIS_fnc_taskExists))) then
		{
		_posibles = [];
		{
		_marker = [marcadores, _x] call BIS_fnc_nearestPosition;
		if ((sides getVariable [_marker,sideUnknown] == bad) and (spawner getVariable _marker == 2)) exitWith
			{
			_posibles pushBack [_marker,_x];
			};
		} forEach antenasMuertas;
		if (count _posibles > 0) then
			{
			_posible = selectRandom _posibles;
			[[_posible select 0,_posible select 1],"REP_Antena"] call A3A_fnc_scheduler;
			};
		}
	else
		{
		_changed = false;
		{
		_chance = 5;
		if ((_x in recursos) and (sides getVariable [_x,sideUnknown] == veryBad)) then {_chace = 20};
		if (random 100 < _chance) then
			{
			_changed = true;
			destroyedCities = destroyedCities - [_x];
			_name = [_x] call A3A_fnc_localizar;
			["TaskSucceeded", ["", format ["%1 Rebuilt",_name]]] remoteExec ["BIS_fnc_showNotification",[good,civilian]];
			sleep 2;
			};
		} forEach (destroyedCities - ciudades) select {sides getVariable [_x,sideUnknown] != good};
		if (_changed) then {publicVariable "destroyedCities"};
		};
	if (isDedicated) then
		{
		{
		if (side _x == civilian) then
			{
			_var = _x getVariable "statusAct";
			if (isNil "_var") then
				{
				if (local _x) then
					{
					if ((typeOf _x) in arrayCivs) then
						{
						if (vehicle _x == _x) then
							{
							if (primaryWeapon _x == "") then
								{
								_group = group _x;
								deleteVehicle _x;
								if ({alive _x} count units _group == 0) then {deleteGroup _group};
								};
							};
						};
					};
				};
			};
		} forEach allUnits;
		if (autoSave) then
			{
			_saveCounter = _saveCounter - 600;
			if (_saveCounter <= 0) then
				{
				_saveCounter = 3600;
				_nul = [] execVM "statSave\saveLoop.sqf";
				};
			};
		};

	sleep 4;
	};
