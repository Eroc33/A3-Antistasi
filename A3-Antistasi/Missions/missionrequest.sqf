if (!isServer) exitWith {};

private ["_type","_posbase","posibleSites","_sites","_exists","_site","_pos","_city"];

_type = _this select 0;

_posbase = getMarkerPos respawnGood;
posibleSites = [];
_sites = [];
_exists = false;

_silence = false;
if (count _this > 1) then {_silence = true};

if ([_type] call BIS_fnc_taskExists) exitWith {if (!_silence) then {[petros,"globalChat","I already gave you a mission of this type"] remoteExec ["A3A_fnc_commsMP",theBoss]}};

if (_type == "AS") then
	{
	_sites = airports + ciudades + (controles select {!(isOnRoad getMarkerPos _x)});
	_sites = _sites select {sides getVariable [_x,sideUnknown] != good};
	if ((count _sites > 0) and ({sides getVariable [_x,sideUnknown] == bad} count airports > 0)) then
		{
		//posibleSites = _sites select {((getMarkerPos _x distance _posbase < distanciaMiss) and (not(spawner getVariable _x)))};
		for "_i" from 0 to ((count _sites) - 1) do
			{
			_site = _sites select _i;
			_pos = getMarkerPos _site;
			if (_pos distance _posbase < distanciaMiss) then
				{
				if (_site in controles) then
					{
					_markers = marcadores select {(getMarkerPos _x distance _pos < distanceSPWN) and (sides getVariable [_x,sideUnknown] == good)};
					_markers = _markers - ["Synd_HQ"];
					_isFrontLine = if (count _markers > 0) then {true} else {false};
					if (_isFrontLine) then
						{
						posibleSites pushBack _site;
						};
					}
				else
					{
					if (spawner getVariable _site == 2) then {posibleSites pushBack _site};
					};
				};
			};
		};
	if (count posibleSites == 0) then
		{
		if (!_silence) then
			{
			[petros,"globalChat","I have no assasination missions for you. Move our HQ closer to the enemy or finish some other assasination missions in order to have better intel"] remoteExec ["A3A_fnc_commsMP",theBoss];
			[petros,"hint","Assasination Missions require cities, Patrolled Jungles or Airports closer than 4Km from your HQ."] remoteExec ["A3A_fnc_commsMP",theBoss];
			};
		}
	else
		{
		_site = selectRandom posibleSites;
		if (_site in airports) then {[[_site],"AS_Oficial"] remoteExec ["A3A_fnc_scheduler",2]} else {if (_site in ciudades) then {[[_site],"AS_Traidor"] remoteExec ["A3A_fnc_scheduler",2]} else {[[_site],"AS_SpecOP"] remoteExec ["A3A_fnc_scheduler",2]}};
		};
	};
if (_type == "CON") then
	{
	_sites = (controles select {(isOnRoad (getMarkerPos _x))})+ puestos + recursos;
	_sites = _sites select {sides getVariable [_x,sideUnknown] != good};
	if (count _sites > 0) then
		{
		posibleSites = _sites select {(getMarkerPos _x distance _posbase < distanciaMiss)};
		};
	if (count posibleSites == 0) then
		{
		if (!_silence) then
			{
			[petros,"globalChat","I have no Conquest missions for you. Move our HQ closer to the enemy or finish some other conquest missions in order to have better intel."] remoteExec ["A3A_fnc_commsMP",theBoss];
			[petros,"hint","Conquest Missions require roadblocks or outposts closer than 4Km from your HQ."] remoteExec ["A3A_fnc_commsMP",theBoss];
			};
		}
	else
		{
		_site = selectRandom posibleSites;
		[[_site],"CON_Puestos"] remoteExec ["A3A_fnc_scheduler",2];
		};
	};
if (_type == "DES") then
	{
	_sites = airports select {sides getVariable [_x,sideUnknown] != good};
	_sites = _sites + antenas;
	if (count _sites > 0) then
		{
		for "_i" from 0 to ((count _sites) - 1) do
			{
			_site = _sites select _i;
			if (_site in marcadores) then {_pos = getMarkerPos _site} else {_pos = getPos _site};
			if (_pos distance _posbase < distanciaMiss) then
				{
				if (_site in marcadores) then
					{
					if (spawner getVariable _site == 2) then {posibleSites pushBack _site};
					}
				else
					{
					_near = [marcadores, getPos _site] call BIS_fnc_nearestPosition;
					if (sides getVariable [_near,sideUnknown] == bad) then {posibleSites pushBack _site};
					};
				};
			};
		};
	if (count posibleSites == 0) then
		{
		if (!_silence) then
			{
			[petros,"globalChat","I have no destroy missions for you. Move our HQ closer to the enemy or finish some other destroy missions in order to have better intel"] remoteExec ["A3A_fnc_commsMP",theBoss];
			[petros,"hint","Destroy Missions require Airbases or Radio Towers closer than 4Km from your HQ."] remoteExec ["A3A_fnc_commsMP",theBoss];
			};
		}
	else
		{
		_site = posibleSites call BIS_fnc_selectRandom;
		if (_site in airports) then {if (random 10 < 8) then {[[_site],"DES_Vehicle"] remoteExec ["A3A_fnc_scheduler",2]} else {[[_site],"DES_Heli"] remoteExec ["A3A_fnc_scheduler",2]}};
		if (_site in antenas) then {[[_site],"DES_antena"] remoteExec ["A3A_fnc_scheduler",2]}
		};
	};
if (_type == "LOG") then
	{
	_sites = puestos + ciudades - destroyedCities;
	_sites = _sites select {sides getVariable [_x,sideUnknown] != good};
	if (random 100 < 20) then {_sites = _sites + bancos};
	if (count _sites > 0) then
		{
		for "_i" from 0 to ((count _sites) - 1) do
			{
			_site = _sites select _i;
			if (_site in marcadores) then
				{
				_pos = getMarkerPos _site;
				}
			else
				{
				_pos = getPos _site;
				};
			if (_pos distance _posbase < distanciaMiss) then
				{
				if (_site in ciudades) then
					{
					_data = server getVariable _site;
					_prestigeOPFOR = _data select 2;
					_prestigeBLUFOR = _data select 3;
					if (_prestigeOPFOR + _prestigeBLUFOR < 90) then
						{
						posibleSites pushBack _site;
						};
					}
				else
					{
					if ([_pos,_posbase] call A3A_fnc_isTheSameIsland) then {posibleSites pushBack _site};
					};
				};
			if (_site in bancos) then
				{
				_city = [ciudades, _pos] call BIS_fnc_nearestPosition;
				if (sides getVariable [_city,sideUnknown] == good) then {posibleSites = posibleSites - [_site]};
				};
			};
		};
	if (count posibleSites == 0) then
		{
		if (!_silence) then
			{
			[petros,"globalChat","I have no logistics missions for you. Move our HQ closer to the enemy or finish some other logistics missions in order to have better intel"] remoteExec ["A3A_fnc_commsMP",theBoss];
			[petros,"hint","Logistics Missions require Outposts, Cities or Banks closer than 4Km from your HQ."] remoteExec ["A3A_fnc_commsMP",theBoss];
			};
		}
	else
		{
		_site = posibleSites call BIS_fnc_selectRandom;
		if (_site in ciudades) then {[[_site],"LOG_Suministros"] remoteExec ["A3A_fnc_scheduler",2]};
		if (_site in puestos) then {[[_site],"LOG_Ammo"] remoteExec ["A3A_fnc_scheduler",2]};
		if (_site in bancos) then {[[_site],"LOG_Bank"] remoteExec ["A3A_fnc_scheduler",2]};
		};
	};
if (_type == "RES") then
	{
	_sites = airports + puestos + ciudades;
	_sites = _sites select {sides getVariable [_x,sideUnknown] != good};
	if (count _sites > 0) then
		{
		for "_i" from 0 to ((count _sites) - 1) do
			{
			_site = _sites select _i;
			_pos = getMarkerPos _site;
			if (_site in ciudades) then {if (_pos distance _posbase < distanciaMiss) then {posibleSites pushBack _site}} else {if ((_pos distance _posbase < distanciaMiss) and (spawner getVariable _site == 2)) then {posibleSites = posibleSites + [_site]}};
			};
		};
	if (count posibleSites == 0) then
		{
		if (!_silence) then
			{
			[petros,"globalChat","I have no rescue missions for you. Move our HQ closer to the enemy or finish some other rescue missions in order to have better intel"] remoteExec ["A3A_fnc_commsMP",theBoss];
			[petros,"hint","Rescue Missions require Cities or Airports closer than 4Km from your HQ."] remoteExec ["A3A_fnc_commsMP",theBoss];
			};
		}
	else
		{
		_site = posibleSites call BIS_fnc_selectRandom;
		if (_site in ciudades) then {[[_site],"RES_Refugiados"] remoteExec ["A3A_fnc_scheduler",2]} else {[[_site],"RES_Prisioneros"] remoteExec ["A3A_fnc_scheduler",2]};
		};
	};
if (_type == "CONVOY") then
	{
	if (!bigAttackInProgress) then
		{
		_sites = (airports + recursos + fabricas + puertos + puestos - blackListDest) + (ciudades select {count (garrison getVariable [_x,[]]) < 10});
		_sites = _sites select {(sides getVariable [_x,sideUnknown] != good) and !(_x in blackListDest)};
		if (count _sites > 0) then
			{
			for "_i" from 0 to ((count _sites) - 1) do
				{
				_site = _sites select _i;
				_pos = getMarkerPos _site;
				_base = [_site] call A3A_fnc_findBasesForConvoy;
				if ((_pos distance _posbase < (distanciaMiss*2)) and (_base !="")) then
					{
					if ((_site in ciudades) and (sides getVariable [_site,sideUnknown] == good)) then
						{
						if (sides getVariable [_base,sideUnknown] == bad) then
							{
							_data = server getVariable _site;
							_prestigeOPFOR = _data select 2;
							_prestigeBLUFOR = _data select 3;
							if (_prestigeOPFOR + _prestigeBLUFOR < 90) then
								{
								posibleSites pushBack _site;
								};
							}
						}
					else
						{
						if (((sides getVariable [_site,sideUnknown] == bad) and (sides getVariable [_base,sideUnknown] == bad)) or ((sides getVariable [_site,sideUnknown] == veryBad) and (sides getVariable [_base,sideUnknown] == veryBad))) then {posibleSites pushBack _site};
						};
					};
				};
			};
		if (count posibleSites == 0) then
			{
			if (!_silence) then
				{
				[petros,"globalChat","I have no Convoy missions for you. Move our HQ closer to the enemy or finish some other missions in order to have better intel"] remoteExec ["A3A_fnc_commsMP",theBoss];
				[petros,"hint","Convoy Missions require Airports or Cities closer than 5Km from your HQ, and they must have an idle friendly base in their surroundings."] remoteExec ["A3A_fnc_commsMP",theBoss];
				};
			}
		else
			{
			_site = posibleSites call BIS_fnc_selectRandom;
			_base = [_site] call A3A_fnc_findBasesForConvoy;
			[[_site,_base],"CONVOY"] remoteExec ["A3A_fnc_scheduler",2];
			};
		}
	else
		{
		[petros,"globalChat","There is a big battle around, I don't think the enemy will send any convoy"] remoteExec ["A3A_fnc_commsMP",theBoss];
		[petros,"hint","Convoy Missions require a calmed status around the island, and now it is not the proper time."] remoteExec ["A3A_fnc_commsMP",theBoss];
		};
	};

if ((count posibleSites > 0) and (!_silence)) then {[petros,"globalChat","I have a mission for you"] remoteExec ["A3A_fnc_commsMP",theBoss]};
