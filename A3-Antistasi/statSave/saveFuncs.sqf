fn_SaveStat =
{
	_varName = _this select 0;
	_varValue = _this select 1;
	if (!isNil "_varValue") then
		{
		if (worldName == "Tanoa") then
			{
			profileNameSpace setVariable [_varName + serverID + "WotP",_varValue]
			}
		else
			{
			if (side group petros == independent) then {profileNameSpace setVariable [_varName + serverID + "Antistasi" + worldName,_varValue]} else {profileNameSpace setVariable [_varName + serverID + "AntistasiB" + worldName,_varValue]};
			};
		if (isDedicated) then {saveProfileNamespace};
		};
};

fn_LoadStat =
{
	private ["_varName","_varvalue"];
	_varName = _this select 0;
	if (worldName == "Tanoa") then
		{
		_varValue = profileNameSpace getVariable (_varName + serverID + "WotP")
		}
	else
		{
		if (side group petros == independent) then {_varValue = profileNameSpace getVariable (_varName + serverID + "Antistasi" + worldName)} else {_varValue = profileNameSpace getVariable (_varName + serverID + "AntistasiB" + worldName)};
		};
	if(isNil "_varValue") exitWith {diag_log format ["Antistasi: Error en Persistent Load. La variable %1 no existe",_varname]};
	[_varName,_varValue] call fn_SetStat;
};

//===========================================================================
//ADD VARIABLES TO THIS ARRAY THAT NEED SPECIAL SCRIPTING TO LOAD
/*specialVarLoads =
[
	"weaponsPlayer",
	"magazinesPlayer",
	"backpackPlayer",
	"mrkNATO",
	"mrkSDK",
	"prestigeNATO","prestigeCSAT", "hr","planesAAFcurrent","helisAAFcurrent","APCAAFcurrent","tanksAAFcurrent","armas","items","mochis","municion","fecha", "WitemsPlayer","prestigeOPFOR","prestigeBLUFOR","resourcesAAF","resourcesFIA","skillFIA"];
*/
specialVarLoads =
["puestosFIA","minas","estaticas","cuentaCA","antenas","mrkNATO","mrkSDK","prestigeNATO","prestigeCSAT","posHQ", "hr","armas","items","mochis","municion","fecha", "prestigeOPFOR","prestigeBLUFOR","resourcesFIA","skillFIA","distanceSPWN","civPerc","maxUnits","destroyedCities","garrison","tasks","scorePlayer","rankPlayer","smallCAmrk","dinero","miembros","vehInGarage","destroyedBuildings","personalGarage","idlebases","idleassets","chopForest","weather","killZones","jna_dataList","controlesSDK","loadoutPlayer","mrkCSAT","nextTick","bombRuns","dificultad","gameMode"];
//THIS FUNCTIONS HANDLES HOW STATS ARE LOADED
fn_SetStat =
{
	_varName = _this select 0;
	_varValue = _this select 1;
	if(isNil '_varValue') exitWith {};
	if(_varName in specialVarLoads) then
	{
		if(_varName == 'cuentaCA') then {cuentaCA = _varValue; publicVariable "cuentaCA"};
		if(_varName == 'dificultad') then
			{
			if !(isMultiplayer) then
				{
				skillMult = _varValue;
				if (skillMult == 0.5) then {minWeaps = 15};
				if (skillMult == 2) then {minWeaps = 40};
				};
			};
		if(_varName == 'gameMode') then
			{
			if !(isMultiplayer) then
				{
				gameMode = _varValue;
				if (gameMode != 1) then
					{
					bad setFriend [veryBad,1];
				    veryBad setFriend [bad,1];
				    if (gameMode == 3) then {"CSAT_carrier" setMarkerAlpha 0};
				    if (gameMode == 4) then {"NATO_carrier" setMarkerAlpha 0};
					};
				};
			};
		if(_varName == 'bombRuns') then {bombRuns = _varValue; publicVariable "bombRuns"};
		if(_varName == 'nextTick') then {nextTick = time + _varValue};
		if(_varName == 'miembros') then {miembros = +_varValue; publicVariable "miembros"};
		if(_varName == 'smallCAmrk') then {smallCAmrk = +_varValue};
		if(_varName == 'mrkNATO') then {{sides setVariable [_x,bad,true]} forEach _varValue;};
		if(_varName == 'mrkCSAT') then {{sides setVariable [_x,veryBad,true]} forEach _varValue;};
		if(_varName == 'mrkSDK') then {{sides setVariable [_x,good,true]} forEach _varValue;};
		if(_varName == 'controlesSDK') then
			{
			{
			sides setVariable [_x,good,true]
			} forEach _varValue;
			};
		if(_varName == 'chopForest') then {chopForest = _varValue; publicVariable "chopForest"};
		if(_varName == 'dinero') then {player setVariable ["dinero",_varValue,true];};
		if(_varName == 'loadoutPlayer') then
			{
			_pepe = + _varValue;
			if (isMultiplayer) then
				{
				removeAllItemsWithMagazines player;
				{player removeWeaponGlobal _x} forEach weapons player;
				removeBackpackGlobal player;
				removeVest player;
				if ((not("ItemGPS" in unlockedItems)) and ("ItemGPS" in (assignedItems player))) then {player unlinkItem "ItemGPS"};
				if ((!foundTFAR) and (!foundACRE) and ("ItemRadio" in (assignedItems player)) and (not("ItemRadio" in unlockedItems))) then {player unlinkItem "ItemRadio"};
				["loadoutPlayer", getUnitLoadout player] call fn_SaveStat;
				};
			player setUnitLoadout _pepe;
			};
		if(_varName == 'scorePlayer') then {player setVariable ["score",_varValue,true];};
		if(_varName == 'rankPlayer') then {player setRank _varValue; player setVariable ["rango",_varValue,true]};
		if(_varName == 'personalGarage') then {personalGarage = +_varValue};
		if(_varName == 'jna_dataList') then {jna_dataList = +_varValue};
		if(_varName == 'prestigeNATO') then {prestigeNATO = _varValue; publicVariable "prestigeNATO"};
		if(_varName == 'prestigeCSAT') then {prestigeCSAT = _varValue; publicVariable "prestigeCSAT"};
		if(_varName == 'hr') then {server setVariable ["HR",_varValue,true]};
		if(_varName == 'fecha') then {setDate _varValue};
		if(_varName == 'weather') then
			{
			0 setFog (_varValue select 0);
			0 setRain (_varValue select 1);
			forceWeatherChange
			};
		if(_varName == 'resourcesFIA') then {server setVariable ["resourcesFIA",_varValue,true]};
		if(_varName == 'destroyedCities') then {destroyedCities = +_varValue; publicVariable "destroyedCities"};
		if(_varName == 'skillFIA') then
			{
			skillFIA = _varValue; publicVariable "skillFIA";
			{
			_cost = server getVariable _x;
			for "_i" from 1 to _varValue do
				{
				_cost = round (_cost + (_cost * (_i/280)));
				};
			server setVariable [_x,_cost,true];
			} forEach soldiersSDK;
			};
		if(_varName == 'distanceSPWN') then {distanceSPWN = _varValue; distanceSPWN1 = distanceSPWN * 1.3; distanceSPWN2 = distanceSPWN /2; publicVariable "distanceSPWN";publicVariable "distanceSPWN1";publicVariable "distanceSPWN2"};
		if(_varName == 'civPerc') then {civPerc = _varValue; if (civPerc < 1) then {civPerc = 35}; publicVariable "civPerc"};
		if(_varName == 'maxUnits') then {maxUnits=_varValue; publicVariable "maxUnits"};
		if(_varName == 'vehInGarage') then {vehInGarage= +_varValue; publicVariable "vehInGarage"};
		if(_varName == 'destroyedBuildings') then
			{
			destroyedBuildings= +_varValue;
			//publicVariable "destroyedBuildings";
			{
			//(nearestBuilding _x) setDamage [1,false];
			[nearestBuilding _x,[1,false]] remoteExec ["setDamage"];
			} forEach destroyedBuildings;
			};
		if(_varName == 'minas') then
			{
			for "_i" from 0 to (count _varvalue) - 1 do
				{
				_mineType = _varvalue select _i select 0;
				switch _mineType do
					{
					case "APERSMine_Range_Ammo": {_mineType = "APERSMine"};
					case "ATMine_Range_Ammo": {_mineType = "ATMine"};
					case "APERSBoundingMine_Range_Ammo": {_mineType = "APERSBoundingMine"};
					case "SLAMDirectionalMine_Wire_Ammo": {_mineType = "SLAMDirectionalMine"};
					case "APERSTripMine_Wire_Ammo": {_mineType = "APERSTripMine"};
					case "ClaymoreDirectionalMine_Remote_Ammo": {_mineType = "Claymore_F"};
					};
				_minePos = _varvalue select _i select 1;
				_mine = createMine [_mineType, _minePos, [], 0];
				_detectada = _varvalue select _i select 2;
				{_x revealMine _mine} forEach _detectada;
				if (count (_varvalue select _i) > 3) then//borrar esto en febrero
					{
					_dirMina = _varvalue select _i select 3;
					_mine setDir _dirMina;
					};
				};
			};
		if(_varName == 'garrison') then
			{
			//_markers = marcadores - puestosFIA - controles - ciudades;
			{garrison setVariable [_x select 0,_x select 1,true]} forEach _varvalue;
			};
		if(_varName == 'puestosFIA') then
			{
			if (count (_varValue select 0) == 2) then
				{
				{
				_position = _x select 0;
				_garrison = _x select 1;
				_mrk = createMarker [format ["FIApost%1", random 1000], _position];
				_mrk setMarkerShape "ICON";
				_mrk setMarkerType "loc_bunker";
				_mrk setMarkerColor colorGood;
				if (isOnRoad _position) then {_mrk setMarkerText format ["%1 Roadblock",nameBuenos]} else {_mrk setMarkerText format ["%1 Watchpost",nameBuenos]};
				spawner setVariable [_mrk,2,true];
				if (count _garrison > 0) then {garrison setVariable [_mrk,_garrison,true]};
				puestosFIA pushBack _mrk;
				sides setVariable [_mrk,good,true];
				} forEach _varvalue;
				};
			};

		if(_varName == 'antenas') then
			{
			antenasmuertas = +_varvalue;
			for "_i" from 0 to (count _varvalue - 1) do
			    {
			    _posAnt = _varvalue select _i;
			    _mrk = [mrkAntenas, _posAnt] call BIS_fnc_nearestPosition;
			    _antenna = [antenas,_mrk] call BIS_fnc_nearestPosition;
			    {if ([antenas,_x] call BIS_fnc_nearestPosition == _antenna) then {[_x,false] spawn A3A_fnc_apagon}} forEach ciudades;
			    antenas = antenas - [_antenna];
			    _antenna removeAllEventHandlers "Killed";
			    _antenna setDamage [1,false];
			    deleteMarker _mrk;
			    };
			antenasmuertas = _varvalue;
			publicVariable "antenas";
			publicVariable "antenasMuertas";
			};
		if(_varname == 'prestigeOPFOR') then
			{
			for "_i" from 0 to (count ciudades) - 1 do
				{
				_city = ciudades select _i;
				_data = server getVariable _city;
				_numCiv = _data select 0;
				_numVeh = _data select 1;
				_prestigeOPFOR = _varvalue select _i;
				_prestigeBLUFOR = _data select 3;
				_data = [_numCiv,_numVeh,_prestigeOPFOR,_prestigeBLUFOR];
				server setVariable [_city,_data,true];
				};
			};
		if(_varname == 'prestigeBLUFOR') then
			{
			for "_i" from 0 to (count ciudades) - 1 do
				{
				_city = ciudades select _i;
				_data = server getVariable _city;
				_numCiv = _data select 0;
				_numVeh = _data select 1;
				_prestigeOPFOR = _data select 2;
				_prestigeBLUFOR = _varvalue select _i;
				_data = [_numCiv,_numVeh,_prestigeOPFOR,_prestigeBLUFOR];
				server setVariable [_city,_data,true];
				};
			};
		if(_varname == 'idlebases') then
			{
			{
			server setVariable [(_x select 0),(_x select 1),true];
			} forEach _varValue;
			};
		if(_varname == 'idleassets') then
			{
			{
			timer setVariable [(_x select 0),(_x select 1),true];
			} forEach _varValue;
			};
		if(_varname == 'killZones') then
			{
			{
			killZones setVariable [(_x select 0),(_x select 1),true];
			} forEach _varValue;
			};
		if(_varName == 'posHQ') then
			{
			_posHQ = if (count _varValue >3) then {_varValue select 0} else {_varValue};
			{if (getMarkerPos _x distance _posHQ < 1000) then
				{
				sides setVariable [_x,good,true];
				};
			} forEach controles;
			respawnGood setMarkerPos _posHQ;
			petros setPos _posHQ;
			"Synd_HQ" setMarkerPos _posHQ;
			if (chopForest) then
				{
				if (!isMultiplayer) then {{ _x hideObject true } foreach (nearestTerrainObjects [position petros,["tree","bush"],70])} else {{ _x hideObjectGlobal true } foreach (nearestTerrainObjects [position petros,["tree","bush"],70])};
				};
			if (count _varValue == 3) then
				{
				[] spawn A3A_fnc_buildHQ;
				}
			else
				{
				fuego setPos (_varValue select 1);
				caja setDir ((_varValue select 2) select 0);
				caja setPos ((_varValue select 2) select 1);
				mapa setDir ((_varValue select 3) select 0);
				mapa setPos ((_varValue select 3) select 1);
				bandera setPos (_varValue select 4);
				cajaVeh setDir ((_varValue select 5) select 0);
				cajaVeh setPos ((_varValue select 5) select 1);
				};
			{_x setPos _posHQ} forEach (playableUnits select {side _x == good});
			};
		if(_varname == 'estaticas') then
			{
			for "_i" from 0 to (count _varvalue) - 1 do
				{
				_vehicleType = _varvalue select _i select 0;
				_posVeh = _varvalue select _i select 1;
				_dirVeh = _varvalue select _i select 2;
				_veh = createVehicle [_vehicleType,[0,0,1000],[],0,"NONE"];
				_veh setPos _posVeh;
				_veh setDir _dirVeh;
				_veh setVectorUp surfaceNormal (getPos _veh);
				if ((_veh isKindOf "StaticWeapon") or (_veh isKindOf "Building")) then
					{
					staticsToSave pushBack _veh;
					};
				[_veh] call A3A_fnc_AIVEHinit;
				};
			publicVariable "staticsToSave";
			};
		if(_varname == 'tasks') then
			{
			{
			if (_x == "AtaqueAAF") then
				{
				[] call A3A_fnc_ataqueAAF;
				}
			else
				{
				if (_x == "DEF_HQ") then
					{
					[] spawn A3A_fnc_ataqueHQ;
					}
				else
					{
					[_x,true] call A3A_fnc_missionRequest;
					};
				};
			} forEach _varvalue;
			};
	}
	else
	{
		call compile format ["%1 = %2",_varName,_varValue];
	};
};

//==================================================================================================================================================================================================
saveFuncsLoaded = true;
