if (!isServer) exitWith {};

private ["_winner","_marker","_looser","_position","_other","_flag","_flags","_dist","_text","_sides"];

_winner = _this select 0;
_marker = _this select 1;
if ((_winner == good) and (_marker in airports) and (tierWar < 3)) exitWith {};
if ((_winner == good) and (sides getVariable [_marker,sideUnknown] == good)) exitWith {};
if ((_winner == bad) and (sides getVariable [_marker,sideUnknown] == bad)) exitWith {};
if ((_winner == veryBad) and (sides getVariable [_marker,sideUnknown] == veryBad)) exitWith {};
if (_marker in markersChanging) exitWith {};
markersChanging pushBackUnique _marker;
_position = getMarkerPos _marker;
_looser = sides getVariable [_marker,sideUnknown];
_sides = [good,bad,veryBad];
_other = "";
_text = "";
_badGuysPrestige = 0;
_veryBadGuysPrestige = 0;
_flag = objNull;
_size = [_marker] call A3A_fnc_sizeMarker;

if ((!(_marker in ciudades)) and (spawner getVariable _marker != 2)) then
	{
	_flags = nearestObjects [_position, ["FlagCarrier"], _size];
	_flag = _flags select 0;
	};
if (isNil "_flag") then {_flag = objNull};
//[_flag,"remove"] remoteExec ["A3A_fnc_flagaction",0,_flag];

if (_looser == good) then
	{
	_text = format ["%1 ",nameBuenos];
	[] call A3A_fnc_tierCheck;
	}
else
	{
	if (_looser == bad) then
		{
		_text = format ["%1 ",nameMalos];
		}
	else
		{
		_text = format ["%1 ",nameMuyMalos];
		};
	};
garrison setVariable [_marker,[],true];
sides setVariable [_marker,_winner,true];
if (_winner == good) then
	{
	_super = if (_marker in airports) then {true} else {false};
	[[_marker,_looser,"",_super],"A3A_fnc_patrolCA"] call A3A_fnc_scheduler;
	//sleep 15;
	[[_marker],"A3A_fnc_autoGarrison"] call A3A_fnc_scheduler;
	}
else
	{
	_soldiers = [];
	{_soldiers pushBack (typeOf _x)} forEach (allUnits select {(_x distance _position < (_size*3)) and (_x getVariable ["spawner",false]) and (side group _x == _winner) and (vehicle _x == _x) and (alive _x)});
	[_soldiers,_winner,_marker,0] remoteExec ["A3A_fnc_garrisonUpdate",2];
	};

_nul = [_marker] call A3A_fnc_mrkUpdate;
_sides = _sides - [_winner,_looser];
_other = _sides select 0;
if (_marker in airports) then
	{
	if (_winner == good) then
		{
		[0,10,_position] remoteExec ["A3A_fnc_citySupportChange",2];
		if (_looser == bad) then
			{
			_badGuysPrestige = 20;
			_veryBadGuysPrestige = 10;
			}
		else
			{
			_badGuysPrestige = 10;
			_veryBadGuysPrestige = 20;
			};
		}
	else
		{
		server setVariable [_marker,dateToNumber date,true];
		[_marker,60] call A3A_fnc_addTimeForIdle;
		if (_winner == bad) then
			{
			[10,0,_position] remoteExec ["A3A_fnc_citySupportChange",2]
			}
		else
			{
			[-10,-10,_position] remoteExec ["A3A_fnc_citySupportChange",2]
			};
		if (_looser == good) then
			{
			_badGuysPrestige = -10;
			_veryBadGuysPrestige = -10;
			};
		};
	["TaskSucceeded", ["", "Airbase Taken"]] remoteExec ["BIS_fnc_showNotification",_winner];
	["TaskFailed", ["", "Airbase Lost"]] remoteExec ["BIS_fnc_showNotification",_looser];
	["TaskUpdated",["",format ["%1 lost an Airbase",_text]]] remoteExec ["BIS_fnc_showNotification",_other];
	killZones setVariable [_marker,[],true];
	};
if (_marker in puestos) then
	{
	if !(_winner == good) then
		{
		server setVariable [_marker,dateToNumber date,true];
		if (_looser == good) then
			{
			if (_winner == bad) then {_badGuysPrestige = -5} else {_veryBadGuysPrestige = -5};
			};
		}
	else
		{
		if (_looser == bad) then {_badGuysPrestige = 5;_veryBadGuysPrestige = 2} else {_badGuysPrestige = 2;_veryBadGuysPrestige = 5};
		};
	["TaskSucceeded", ["", "Outpost Taken"]] remoteExec ["BIS_fnc_showNotification",_winner];
	["TaskFailed", ["", "Outpost Lost"]] remoteExec ["BIS_fnc_showNotification",_looser];
	["TaskUpdated",["",format ["%1 lost an Outpost",_text]]] remoteExec ["BIS_fnc_showNotification",_other];
	killZones setVariable [_marker,[],true];
	};
if (_marker in puertos) then
	{
	if !(_winner == good) then
		{
		if (_looser == good) then
			{
			if (_winner == bad) then {_badGuysPrestige = -5} else {_veryBadGuysPrestige = -5};
			};
		}
	else
		{
		if (_looser == bad) then {_badGuysPrestige = 5;_veryBadGuysPrestige = 2} else {_badGuysPrestige = 2;_veryBadGuysPrestige = 5};
		};
	["TaskSucceeded", ["", "Seaport Taken"]] remoteExec ["BIS_fnc_showNotification",_winner];
	["TaskFailed", ["", "Seaport Lost"]] remoteExec ["BIS_fnc_showNotification",_looser];
	["TaskUpdated",["",format ["%1 lost a Seaport",_text]]] remoteExec ["BIS_fnc_showNotification",_other];
	};
if (_marker in fabricas) then
	{
	["TaskSucceeded", ["", "Factory Taken"]] remoteExec ["BIS_fnc_showNotification",_winner];
	["TaskFailed", ["", "Factory Lost"]] remoteExec ["BIS_fnc_showNotification",_looser];
	["TaskUpdated",["",format ["%1 lost a Factory",_text]]] remoteExec ["BIS_fnc_showNotification",_other];
	};
if (_marker in recursos) then
	{
	["TaskSucceeded", ["", "Resource Taken"]] remoteExec ["BIS_fnc_showNotification",_winner];
	["TaskFailed", ["", "Resource Lost"]] remoteExec ["BIS_fnc_showNotification",_looser];
	["TaskUpdated",["",format ["%1 lost a Resource",_text]]] remoteExec ["BIS_fnc_showNotification",_other];
	};

{_nul = [_marker,_x] spawn A3A_fnc_deleteControles} forEach controles;
if (_winner == good) then
	{
	[] call A3A_fnc_tierCheck;
	if (!isNull _flag) then
		{
		//[_flag,"remove"] remoteExec ["A3A_fnc_flagaction",0,_flag];
		[_flag,"SDKFlag"] remoteExec ["A3A_fnc_flagaction",0,_flag];
		[_flag,SDKFlagTexture] remoteExec ["setFlagTexture",_flag];
		sleep 2;
		//[_flag,"unit"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_flag];
		//[_flag,"vehicle"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_flag];
		//[_flag,"garage"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_flag];
		if (_marker in puertos) then {[_flag,"seaport"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_flag]};
		};
	[_badGuysPrestige,_veryBadGuysPrestige] spawn A3A_fnc_prestige;
	waitUntil {sleep 1; ((spawner getVariable _marker == 2)) or ({((side group _x) in [_looser,_other]) and (_x getVariable ["spawner",false]) and ([_x,_marker] call A3A_fnc_canConquer)} count allUnits > 3*({(side _x == good) and ([_x,_marker] call A3A_fnc_canConquer)} count allUnits))};
	if (spawner getVariable _marker != 2) then
		{
		sleep 10;
		[_marker,good] remoteExec ["A3A_fnc_zoneCheck",2];
		};
	}
else
	{
	if (!isNull _flag) then
		{
		if (_looser == good) then
			{
			[_flag,"remove"] remoteExec ["A3A_fnc_flagaction",0,_flag];
			sleep 2;
			[_flag,"take"] remoteExec ["A3A_fnc_flagaction",[good,civilian],_flag];
			};
		if (_winner == bad) then
			{
			[_flag,NATOFlagTexture] remoteExec ["setFlagTexture",_flag];
			}
		else
			{
			[_flag,CSATFlagTexture] remoteExec ["setFlagTexture",_flag];
			};
		};
	if (_looser == good) then
		{
		[_badGuysPrestige,_veryBadGuysPrestige] spawn A3A_fnc_prestige;
		if ((random 10 < ((tierWar + difficultyCoef)/4)) and !(["DEF_HQ"] call BIS_fnc_taskExists) and (isPlayer theBoss)) then {[[],"A3A_fnc_ataqueHQ"] remoteExec ["A3A_fnc_scheduler",2]};
		};
	};
if ((_winner != good) and (_looser != good)) then
	{
	if (_marker in puestos) then
		{
		_nearBy = (puertos + recursos + fabricas) select {((getMarkerPos _x) distance _position < distanceSPWN) and (sides getVariable [_x,sideUnknown] != good)};
		if (_looser == bad) then  {_nearBy = _nearBy select {sides getVariable [_x,sideUnknown] == bad}} else {_nearBy = _nearBy select {sides getVariable [_x,sideUnknown] == veryBad}};
		{[_winner,_x] spawn A3A_fnc_markerChange; sleep 5} forEach _nearBy;
		}
	else
		{
		if (_marker in airports) then
			{
			_nearBy = (puertos + puestos) select {((getMarkerPos _x) distance _position < distanceSPWN) and (sides getVariable [_x,sideUnknown] != good)};
			_nearBy append ((fabricas + recursos) select {(sides getVariable [_x,sideUnknown] != good) and (sides getVariable [_x,sideUnknown] != _winner) and ([airports,_x] call BIS_fnc_nearestPosition == _marker)});
			if (_looser == bad) then  {_nearBy = _nearBy select {sides getVariable [_x,sideUnknown] == bad}} else {_nearBy = _nearBy select {sides getVariable [_x,sideUnknown] == veryBad}};
			{[_winner,_x] spawn A3A_fnc_markerChange; sleep 5} forEach _nearBy;
			};
		};
	};
markersChanging = markersChanging - [_marker];
