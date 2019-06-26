
private ["_text","_data","_numCiv","_prestigeOPFOR","_prestigeBLUFOR","_power","_busy","_site","_clickedPosition","_garrison"];
posicionTel = [];

_popFIA = 0;
_popAAF = 0;
_popCSAT = 0;
_pop = 0;
{
_data = server getVariable _x;
_numCiv = _data select 0;
_prestigeOPFOR = _data select 2;
_prestigeBLUFOR = _data select 3;
_popFIA = _popFIA + (_numCiv * (_prestigeBLUFOR / 100));
_popAAF = _popAAF + (_numCiv * (_prestigeOPFOR / 100));
_pop = _pop + _numCiv;
if (_x in destroyedCities) then {_popCSAT = _popCSAT + _numCIV};
} forEach ciudades;
_popFIA = round _popFIA;
_popAAF = round _popAAF;
hint format ["%7\n\nTotal pop: %1\n%6 Support: %2\n%5 Support: %3 \n\nMurdered Pop: %4\n\nClick on the zone",_pop, _popFIA, _popAAF, _popCSAT,nameMalos,nameBuenos,worldName];

if (!visibleMap) then {openMap true};

onMapSingleClick "posicionTel = _pos;";


//waitUntil {sleep 1; (count posicionTel > 0) or (not visiblemap)};
while {visibleMap} do
	{
	sleep 1;
	if (count posicionTel > 0) then
		{
		_clickedPosition = posicionTel;
		_site = [marcadores, _clickedPosition] call BIS_Fnc_nearestPosition;
		_text = "Click on the zone";
		_nameFaction = if (sides getVariable [_site,sideUnknown] == good) then {nameBuenos} else {if (sides getVariable [_site,sideUnknown] == bad) then {nameMalos} else {nameMuyMalos}};
		if (_site == "Synd_HQ") then
			{
			_text = format ["%2 HQ%1",[_site] call A3A_fnc_garrisonInfo,nameBuenos];
			};
		if (_site in ciudades) then
			{
			_data = server getVariable _site;

			_numCiv = _data select 0;
			_prestigeOPFOR = _data select 2;
			_prestigeBLUFOR = _data select 3;
			_power = [_site] call A3A_fnc_powerCheck;
			_text = format ["%1\n\nPop %2\n%6 Support: %3 %5\n%7 Support: %4 %5",[_site,false] call A3A_fnc_fn_location,_numCiv,_prestigeOPFOR,_prestigeBLUFOR,"%",nameMalos,nameBuenos];
			_position = getMarkerPos _site;
			_result = "NONE";
			switch (_power) do
				{
				case good: {_result = format ["%1",nameBuenos]};
				case bad: {_result = format ["%1",nameMalos]};
				case veryBad: {_result = format ["%1",nameMuyMalos]};
				};
			/*_ant1 = [antenas,_position] call BIS_fnc_nearestPosition;
			_ant2 = [antenasMuertas, _position] call BIS_fnc_nearestPosition;
			if (_ant1 distance _position > _ant2 distance _position) then
				{
				_result = "NONE";
				}
			else
				{
				_point = [marcadores,_ant1] call BIS_fnc_NearestPosition;
				if (sides getVariable [_site,sideUnknown] == good) then
					{
					if (sides getVariable [_point,sideUnknown] == good) then {_result = format ["%1",nameBuenos]} else {if (sides getVariable [_point,sideUnknown] == veryBad) then {_result = "NONE"}};
					}
				else
					{
					if (sides getVariable [_point,sideUnknown] == good) then {_result = format ["%1",nameBuenos]} else {if (sides getVariable [_point,sideUnknown] == veryBad) then {_result = "NONE"}};
					};
				};
			*/
			_text = format ["%1\nInfluence: %2",_text,_result];
			if (_site in destroyedCities) then {_text = format ["%1\nDESTROYED",_text]};
			if (sides getVariable [_site,sideUnknown] == good) then {_text = format ["%1\n%2",_text,[_site] call A3A_fnc_garrisonInfo]};
			};
		if (_site in airports) then
			{
			if (not(sides getVariable [_site,sideUnknown] == good)) then
				{
				_text = format ["%1 Airport",_nameFaction];
				_busy = [_site,true] call A3A_fnc_airportCanAttack;
				if (_busy) then {_text = format ["%1\nStatus: Idle",_text]} else {_text = format ["%1\nStatus: Busy",_text]};
				_garrison = count (garrison getVariable _site);
				if (_garrison >= 40) then {_text = format ["%1\nGarrison: Good",_text]} else {if (_garrison >= 20) then {_text = format ["%1\nGarrison: Weakened",_text]} else {_text = format ["%1\nGarrison: Decimated",_text]}};
				}
			else
				{
				_text = format ["%2 Airport%1",[_site] call A3A_fnc_garrisonInfo,_nameFaction];
				};
			};
		if (_site in recursos) then
			{
			if (not(sides getVariable [_site,sideUnknown] == good)) then
				{
				_text = format ["%1 Resources",_nameFaction];
				_garrison = count (garrison getVariable _site);
				if (_garrison >= 30) then {_text = format ["%1\nGarrison: Good",_text]} else {if (_garrison >= 10) then {_text = format ["%1\nGarrison: Weakened",_text]} else {_text = format ["%1\nGarrison: Decimated",_text]}};
				}
			else
				{
				_text = format ["%2 Resources%1",[_site] call A3A_fnc_garrisonInfo,_nameFaction];
				};
			if (_site in destroyedCities) then {_text = format ["%1\nDESTROYED",_text]};
			};
		if (_site in fabricas) then
			{
			if (not(sides getVariable [_site,sideUnknown] == good)) then
				{
				_text = format ["%1 Factory",_nameFaction];
				_garrison = count (garrison getVariable _site);
				if (_garrison >= 16) then {_text = format ["%1\nGarrison: Good",_text]} else {if (_garrison >= 8) then {_text = format ["%1\nGarrison: Weakened",_text]} else {_text = format ["%1\nGarrison: Decimated",_text]}};
				}
			else
				{
				_text = format ["%2 Factory%1",[_site] call A3A_fnc_garrisonInfo,_nameFaction];
				};
			if (_site in destroyedCities) then {_text = format ["%1\nDESTROYED",_text]};
			};
		if (_site in puestos) then
			{
			if (not(sides getVariable [_site,sideUnknown] == good)) then
				{
				_text = format ["%1 Grand Outpost",_nameFaction];
				_busy = [_site,true] call A3A_fnc_airportCanAttack;
				if (_busy) then {_text = format ["%1\nStatus: Idle",_text]} else {_text = format ["%1\nStatus: Busy",_text]};
				_garrison = count (garrison getVariable _site);
				if (_garrison >= 16) then {_text = format ["%1\nGarrison: Good",_text]} else {if (_garrison >= 8) then {_text = format ["%1\nGarrison: Weakened",_text]} else {_text = format ["%1\nGarrison: Decimated",_text]}};
				}
			else
				{
				_text = format ["%2 Grand Outpost%1",[_site] call A3A_fnc_garrisonInfo,_nameFaction];
				};
			};
		if (_site in puertos) then
			{
			if (not(sides getVariable [_site,sideUnknown] == good)) then
				{
				_text = format ["%1 Seaport",_nameFaction];
				_garrison = count (garrison getVariable _site);
				if (_garrison >= 20) then {_text = format ["%1\nGarrison: Good",_text]} else {if (_garrison >= 8) then {_text = format ["%1\nGarrison: Weakened",_text]} else {_text = format ["%1\nGarrison: Decimated",_text]}};
				}
			else
				{
				_text = format ["%2 Seaport%1",[_site] call A3A_fnc_garrisonInfo,_nameFaction];
				};
			};
		if (_site in puestosFIA) then
			{
			if (isOnRoad (getMarkerPos _site)) then
				{
				_text = format ["%2 Roadblock%1",[_site] call A3A_fnc_garrisonInfo,_nameFaction];
				}
			else
				{
				_text = format ["%1 Watchpost",_nameFaction];
				};
			};
		hint format ["%1",_text];
		};
	posicionTel = [];
	};
onMapSingleClick "";








