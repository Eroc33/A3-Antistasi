//if ([0.5] call A3A_fnc_fogCheck) exitWith {};
private ["_objectives","_markers","_base","_objetivo","_count","_airport","_data","_prestigeOPFOR","_scoreLand","_scoreAir","_analizado","_garrison","_size","_statics","_exit"];

_objectives = [];
_markers = [];
_cuentaFacil = 0;
_natoIsFull = false;
_csatIsFull = false;
_airports = airports select {([_x,false] call A3A_fnc_airportCanAttack) and (sides getVariable [_x,sideUnknown] != good)};
_objectives = marcadores - controles - puestosFIA - ["Synd_HQ","NATO_carrier","CSAT_carrier"] - destroyedCities;
if (gameMode != 1) then {_objectives = _objectives select {sides getVariable [_x,sideUnknown] == good}};
//_objetivosSDK = _objectives select {sides getVariable [_x,sideUnknown] == good};
if ((tierWar < 2) and (gameMode <= 2)) then
	{
	_airports = _airports select {(sides getVariable [_x,sideUnknown] == bad)};
	//_objectives = _objetivosSDK;
	_objectives = _objectives select {sides getVariable [_x,sideUnknown] == good};
	}
else
	{
	if (gameMode != 4) then {if ({sides getVariable [_x,sideUnknown] == bad} count _airports == 0) then {_airports pushBack "NATO_carrier"}};
	if (gameMode != 3) then {if ({sides getVariable [_x,sideUnknown] == veryBad} count _airports == 0) then {_airports pushBack "CSAT_carrier"}};
	if (([vehNATOPlane] call A3A_fnc_vehAvailable) and ([vehNATOMRLS] call A3A_fnc_vehAvailable) and ([vehNATOTank] call A3A_fnc_vehAvailable)) then {_natoIsFull = true};
	if (([vehCSATPlane] call A3A_fnc_vehAvailable) and ([vehCSATMRLS] call A3A_fnc_vehAvailable) and ([vehCSATTank] call A3A_fnc_vehAvailable)) then {_csatIsFull = true};
	};
if (gameMode != 4) then
	{
	if (tierWar < 3) then {_objectives = _objectives - ciudades};
	}
else
	{
	if (tierWar < 5) then {_objectives = _objectives - ciudades};
	};
//lets keep the nearest targets for each AI airbase in the target list, so we ensure even when they are surrounded of friendly zones, they remain as target
_nearestObjectives = [];
{
_side = sides getVariable [_x,sideUnknown];
_tmpTargets = _objectives select {sides getVariable [_x,sideUnknown] != _side};
if !(_tmpTargets isEqualTo []) then
	{
	_nearestTarget = [_tmpTargets,getMarkerPos _x] call BIS_fnc_nearestPosition;
	_nearestObjectives pushBack _nearestTarget;
	};
} forEach _airports;
//the following discards targets which are surrounded by friendly zones, excluding airbases and the nearest targets
_objetivosProv = _objectives - airports - _nearestObjectives;
{
_objectivePos = getMarkerPos _x;
_objectiveSide = sides getVariable [_x,sideUnknown];
if (((marcadores - controles - ciudades - puestosFIA) select {sides getVariable [_x,sideUnknown] != _objectiveSide}) findIf {getMarkerPos _x distance2D _objectivePos < 2000} == -1) then {_objectives = _objectives - [_x]};
} forEach _objetivosProv;

if (_objectives isEqualTo []) exitWith {};
_objectivesFinal = [];
_basesFinal = [];
_countsFinal = [];
_objectiveFinal = [];
_easy = [];
_easyArr = [];
_portCSAT = if ({(sides getVariable [_x,sideUnknown] == veryBad)} count puertos >0) then {true} else {false};
_portNATO = if ({(sides getVariable [_x,sideUnknown] == bad)} count puertos >0) then {true} else {false};
_waves = 1;

{
_base = _x;
_posBase = getMarkerPos _base;
_killZones = killZones getVariable [_base,[]];
_tmpObjectives = [];
_baseNATO = true;
if (sides getVariable [_base,sideUnknown] == bad) then
	{
	_tmpObjectives = _objectives select {sides getVariable [_x,sideUnknown] != bad};
	_tmpObjectives = _tmpObjectives - (ciudades select {([_x] call A3A_fnc_powerCheck) == good});
	}
else
	{
	_baseNATO = false;
	_tmpObjectives = _objectives select {sides getVariable [_x,sideUnknown] != veryBad};
	_tmpObjectives = _tmpObjectives - (ciudades select {(((server getVariable _x) select 2) + ((server getVariable _x) select 3) < 90) and ([_x] call A3A_fnc_powerCheck != bad)});
	};

_tmpObjectives = _tmpObjectives select {getMarkerPos _x distance2D _posBase < distanceForAirAttack};
if !(_tmpObjectives isEqualTo []) then
	{
	_near = [_tmpObjectives,_base] call BIS_fnc_nearestPosition;
	{
	_isCity = if (_x in ciudades) then {true} else {false};
	_proceed = true;
	_sitePos = getMarkerPos _x;
	_isSDK = false;
	_isTheSameIsland = [_x,_base] call A3A_fnc_isTheSameIsland;
	if ([_x,true] call A3A_fnc_fogCheck >= 0.3) then
		{
		if (sides getVariable [_x,sideUnknown] == good) then
			{
			_isSDK = true;
			/*
			_valor = if (_baseNATO) then {prestigeNATO} else {prestigeCSAT};
			if (random 100 > _valor) then
				{
				_proceed = false
				}
			*/
			};
		if (!_isTheSameIsland and (not(_x in airports))) then
			{
			if (!_isSDK) then {_proceed = false};
			};
		}
	else
		{
		_proceed = false;
		};
	if (_proceed) then
		{
		if (!_isCity) then
			{
			if !(_x in _killZones) then
				{
				if !(_x in _easyArr) then
					{
					_site = _x;
					if (((!(_site in airports)) or (_isSDK)) and !(_base in ["NATO_carrier","CSAT_carrier"])) then
						{
						_enemySide = if (_baseNATO) then {veryBad} else {bad};
						if ({(sides getVariable [_x,sideUnknown] == _enemySide) and (getMarkerPos _x distance _sitePos < distanceSPWN)} count airports == 0) then
							{
							_garrison = garrison getVariable [_site,[]];
							_statics = staticsToSave select {_x distance _sitePos < distanceSPWN};
							_points = puestosFIA select {getMarkerPos _x distance _sitePos < distanceSPWN};
							_count = ((count _garrison) + (count _points) + (2*(count _statics)));
							if (_count <= 8) then
								{
								if (!foundIFA or (_sitePos distance _posBase < distanceForLandAttack)) then
									{
									_proceed = false;
									_easy pushBack [_site,_base];
									_easyArr pushBackUnique _site;
									};
								};
							};
						};
					};
				};
			};
		};
	if (_proceed) then
		{
		_times = 1;
		if (_baseNATO) then
			{
			if ({sides getVariable [_x,sideUnknown] == bad} count airports <= 1) then {_times = 2};
			if (!_isCity) then
				{
				if ((_x in puestos) or (_x in puertos)) then
					{
					if (!_isSDK) then
						{
						if (({[_x] call A3A_fnc_vehAvailable} count vehNATOAttack > 0) or ({[_x] call A3A_fnc_vehAvailable} count vehNATOAttackHelis > 0)) then {_times = 2*_times} else {_times = 0};
						}
					else
						{
						_times = 2*_times;
						};
					}
				else
					{
					if (_x in airports) then
						{
						if (!_isSDK) then
							{
							if (([vehNATOPlane] call A3A_fnc_vehAvailable) or (!([vehCSATAA] call A3A_fnc_vehAvailable))) then {_times = 5*_times} else {_times = 0};
							}
						else
							{
							if (!_isTheSameIsland) then {_times = 5*_times} else {_times = 2*_times};
							};
						}
					else
						{
						if ((!_isSDK) and _natoIsFull) then {_times = 0};
						};
					};
				};
			if (_times > 0) then
				{
				_nearbyAirports = [airports,_sitePos] call bis_fnc_nearestPosition;
				if ((sides getVariable [_nearbyAirports,sideUnknown] == veryBad) and (_x != _nearbyAirports)) then {_times = 0};
				};
			}
		else
			{
			_times = 2;
			if (!_isCity) then
				{
				if ((_x in puestos) or (_x in puertos)) then
					{
					if (!_isSDK) then
						{
						if (({[_x] call A3A_fnc_vehAvailable} count vehCSATAttack > 0) or ({[_x] call A3A_fnc_vehAvailable} count vehCSATAttackHelis > 0)) then {_times = 2*_times} else {_times = 0};
						}
					else
						{
						_times = 2*_times;
						};
					}
				else
					{
					if (_x in airports) then
						{
						if (!_isSDK) then
							{
							if (([vehCSATPlane] call A3A_fnc_vehAvailable) or (!([vehNATOAA] call A3A_fnc_vehAvailable))) then {_times = 5*_times} else {_times = 0};
							}
						else
							{
							if (!_isTheSameIsland) then {_times = 5*_times} else {_times = 2*_times};
							};
						}
					else
						{
						if ((!_isSDK) and _csatIsFull) then {_times = 0};
						};
					}
				};
			if (_times > 0) then
				{
				_nearbyAirports = [airports,_sitePos] call bis_fnc_nearestPosition;
				if ((sides getVariable [_nearbyAirports,sideUnknown] == bad) and (_x != _nearbyAirports)) then {_times = 0};
				};
			};
		if (_times > 0) then
			{
			if ((!_isSDK) and (!_isCity)) then
				{
				//_times = _times + (floor((garrison getVariable [_x,0])/8))
				_numGarr = [_x] call A3A_fnc_garrisonSize;
				if ((_numGarr/2) < count (garrison getVariable [_x,[]])) then {if ((_numGarr/3) < count (garrison getVariable [_x,[]])) then {_times = _times + 6} else {_times = _times +2}};
				};
			if (_isTheSameIsland) then
				{
				if (_sitePos distance _posBase < distanceForLandAttack) then
					{
					if  (!_isCity) then
						{
						_times = _times * 4
						};
					};
				};
			if (!_isCity) then
				{
				_isMarine = false;
				if ((_baseNATO and _portNATO) or (!_baseNATO and _portCSAT)) then
					{
					for "_i" from 0 to 3 do
						{
						_pos = _sitePos getPos [1000,(_i*90)];
						if (surfaceIsWater _pos) exitWith {_isMarine = true};
						};
					};
				if (_isMarine) then {_times = _times * 2};
				};
			if (_x == _near) then {_times = _times * 5};
			if (_x in _killZones) then
				{
				_site = _x;
				_times = _times / (({_x == _site} count _killZones) + 1);
				};
			_times = round (_times);
			_index = _objectivesFinal find _x;
			if (_index == -1) then
				{
				_objectivesFinal pushBack _x;
				_basesFinal pushBack _base;
				_countsFinal pushBack _times;
				}
			else
				{
				if ((_times > (_countsFinal select _index)) or ((_times == (_countsFinal select _index)) and (random 1 < 0.5))) then
					{
					_objectivesFinal deleteAt _index;
					_basesFinal deleteAt _index;
					_countsFinal deleteAt _index;
					_objectivesFinal pushBack _x;
					_basesFinal pushBack _base;
					_countsFinal pushBack _times;
					};
				};
			};
		};
	if (count _easy == 4) exitWith {};
	} forEach _tmpObjectives;
	};
if (count _easy == 4) exitWith {};
} forEach _airports;

if (count _easy == 4) exitWith
	{
	{[[_x select 0,_x select 1,"",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2];sleep 30} forEach _easy;
	};
if (foundIFA and (sunOrMoon < 1)) exitWith {};
if ((count _objectivesFinal > 0) and (count _easy < 3)) then
	{
	_arrayFinal = [];
	/*{
	for "_i" from 1 to _x do
		{
		_arrayFinal pushBack [(_objectivesFinal select _forEachIndex),(_basesFinal select _forEachIndex)];
		};
	} forEach _countsFinal;*/
	for "_i" from 0 to (count _objectivesFinal) - 1 do
		{
		_arrayFinal pushBack [_objectivesFinal select _i,_basesFinal select _i];
		};
	//_objectiveFinal = selectRandom _arrayFinal;
	_objectiveFinal = _arrayFinal selectRandomWeighted _countsFinal;
	_destination = _objectiveFinal select 0;
	_origin = _objectiveFinal select 1;
	///aqu?? decidimos las oleadas
	if (_waves == 1) then
		{
		if (sides getVariable [_destination,sideUnknown] == good) then
			{
			_waves = (round (random tierWar));
			if (_waves == 0) then {_waves = 1};
			}
		else
			{
			if (sides getVariable [_origin,sideUnknown] == veryBad) then
				{
				if (_destination in airports) then
					{
					_waves = 2 + round (random tierWar);
					}
				else
					{
					if (!(_destination in ciudades)) then
						{
						_waves = 1 + round (random (tierWar)/2);
						};
					};
				}
			else
				{
				if (!(_destination in ciudades)) then
					{
					_waves = 1 + round (random ((tierWar - 3)/2));
					};
				};
			};
		};
	if (not(_destination in ciudades)) then
		{
		///[[_destination,_origin,_waves],"A3A_fnc_wavedCA"] call A3A_fnc_scheduler;
		[_destination,_origin,_waves] spawn A3A_fnc_wavedCA;
		}
	else
		{
		//if (sides getVariable [_origin,sideUnknown] == bad) then {[[_destination,_origin,_waves],"A3A_fnc_wavedCA"] call A3A_fnc_scheduler} else {[[_destination,_origin],"A3A_fnc_CSATpunish"] call A3A_fnc_scheduler};
		if (sides getVariable [_origin,sideUnknown] == bad) then {[_destination,_origin,_waves] spawn A3A_fnc_wavedCA} else {[_destination,_origin] spawn A3A_fnc_CSATpunish};
		};
	};

if (_waves == 1) then
	{
	{[[_x select 0,_x select 1,"",false],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2]} forEach _easy;
	};
