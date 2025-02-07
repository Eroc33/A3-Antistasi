//el sitio de la caja es el 21
if (!isServer and hasInterface) exitWith {};
private ["_bank","_marker","_difficulty","_salir","_contact","_grpContact","_tsk","_posHQ","_ciudades","_city","_size","_position","_housePos","_destinationName","_timeDelay","_dateDelay","_dateDelayNumeric","_posBase","_pos","_truck","_count","_mrkfin","_mrk","_soldiers"];
_bank = _this select 0;
_marker = [ciudades,_bank] call BIS_fnc_nearestPosition;

_difficulty = if (random 10 < tierWar) then {true} else {false};
_salir = false;
_contact = objNull;
_grpContact = grpNull;
_tsk = "";
_position = getPosASL _bank;

_posbase = getMarkerPos respawnGood;

_timeDelay = if (_difficulty) then {60} else {120};
if (foundIFA) then {_timeDelay = _timeDelay * 2};
_dateDelay = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeDelay];
_dateDelayNumeric = dateToNumber _dateDelay;

_city = [ciudades, _position] call BIS_fnc_nearestPosition;
_mrkfin = createMarker [format ["LOG%1", random 100], _position];
_destinationName = [_city] call A3A_fnc_localizar;
_mrkfin setMarkerShape "ICON";
//_mrkfin setMarkerType "hd_destroy";
//_mrkfin setMarkerColor "ColorBlue";
//_mrkfin setMarkerText "Bank";

_pos = (getMarkerPos respawnGood) findEmptyPosition [1,50,"C_Van_01_box_F"];

_truck = "C_Van_01_box_F" createVehicle _pos;
{_x reveal _truck} forEach (allPlayers - (entities "HeadlessClient_F"));
[_truck] call A3A_fnc_AIVEHinit;
_truck setVariable ["destino",_destinationName,true];
_truck addEventHandler ["GetIn",
	{
	if (_this select 1 == "driver") then
		{
		_text = format ["Bring this truck to %1 Bank and park it in the main entrance",(_this select 0) getVariable "destino"];
		_text remoteExecCall ["hint",_this select 2];
		};
	}];

[_truck,"Mission Vehicle"] spawn A3A_fnc_inmuneConvoy;

[[good,civilian],"LOG",[format ["We know Gendarmes are guarding a big amount of money in the bank of %1. Take this truck and go there before %2:%3, hold the truck close to tha bank's main entrance for 2 minutes and the money will be transferred to the truck. Bring it back to HQ and the money will be ours.",_destinationName,numberToDate [2035,_dateDelayNumeric] select 3,numberToDate [2035,_dateDelayNumeric] select 4],"Bank Robbery",_mrkfin],_position,false,0,true,"Interact",true] call BIS_fnc_taskCreate;
missions pushBack ["LOG","CREATED"]; publicVariable "missions";
_mrk = createMarkerLocal [format ["%1patrolarea", floor random 100], _position];
_mrk setMarkerShapeLocal "RECTANGLE";
_mrk setMarkerSizeLocal [30,30];
_mrk setMarkerTypeLocal "hd_warning";
_mrk setMarkerColorLocal "ColorRed";
_mrk setMarkerBrushLocal "DiagGrid";
_mrk setMarkerAlphaLocal 0;

_groups = [];
_soldiers = [];
for "_i" from 1 to 4 do
	{
	_group = if (_difficulty) then {[_position,bad, groupsNATOSentry] call A3A_fnc_spawnGroup} else {[_position,bad, groupsNATOGen] call A3A_fnc_spawnGroup};
	sleep 1;
	_nul = [leader _group, _mrk, "SAFE","SPAWNED", "NOVEH2", "FORTIFY"] execVM "scripts\UPSMON.sqf";
	{[_x,""] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _group;
	_groups pushBack _group;
	};

_position = _bank buildingPos 1;

waitUntil {sleep 1; (dateToNumber date > _dateDelayNumeric) or (!alive _truck) or (_truck distance _position < 7)};
_bonus = if (_difficulty) then {2} else {1};
if ((dateToNumber date > _dateDelayNumeric) or (!alive _truck)) then
	{
	["LOG",[format ["We know Gendarmes is guarding a big amount of money in the bank of %1. Take this truck and go there before %2:%3, hold the truck close to tha bank's main entrance for 2 minutes and the money will be transferred to the truck. Bring it back to HQ and the money will be ours.",_destinationName,numberToDate [2035,_dateDelayNumeric] select 3,numberToDate [2035,_dateDelayNumeric] select 4],"Bank Robbery",_mrkfin],_position,"FAILED","Interact"] call A3A_fnc_taskUpdate;
	[-1800*_bonus] remoteExec ["A3A_fnc_timingCA",2];
	[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
	}
else
	{
	_count = 120*_bonus;//120
	[[_position,bad,"",true],"A3A_fnc_patrolCA"] remoteExec ["A3A_fnc_scheduler",2];
	[10*_bonus,-20*_bonus,_marker] remoteExec ["A3A_fnc_citySupportChange",2];
	["TaskFailed", ["", format ["Bank of %1 being assaulted",_destinationName]]] remoteExec ["BIS_fnc_showNotification",bad];
	{_friend = _x;
	if (_friend distance _truck < 300) then
		{
		if ((captive _friend) and (isPlayer _friend)) then {[_friend,false] remoteExec ["setCaptive",0,_friend]; _friend setCaptive false};
		{if (side _x == bad) then {_x reveal [_friend,4]};
		} forEach allUnits;
		};
	} forEach ([distanceSPWN,0,_position,good] call A3A_fnc_distanceUnits);
	_exit = false;
	while {(_count > 0) or (_truck distance _position < 7) and (alive _truck) and (dateToNumber date < _dateDelayNumeric)} do
		{
		while {(_count > 0) and (_truck distance _position < 7) and (alive _truck)} do
			{
			_format = format ["%1", _count];
			{if (isPlayer _x) then {[petros,"countdown",_format] remoteExec ["A3A_fnc_commsMP",_x]}} forEach ([80,0,_truck,good] call A3A_fnc_distanceUnits);
			sleep 1;
			_count = _count - 1;
			};
		if (_count > 0) then
			{
			_count = 120*_bonus;//120
			if (_truck distance _position > 6) then {{[petros,"hint","Don't get the truck far from the bank or count will restart"] remoteExec ["A3A_fnc_commsMP",_x]} forEach ([200,0,_truck,good] call A3A_fnc_distanceUnits)};
			waitUntil {sleep 1; (!alive _truck) or (_truck distance _position < 7) or (dateToNumber date < _dateDelayNumeric)};
			}
		else
			{
			if (alive _truck) then
				{
				{if (isPlayer _x) then {[petros,"hint","Drive the Truck back to base to finish this mission"] remoteExec ["A3A_fnc_commsMP",_x]}} forEach ([80,0,_truck,good] call A3A_fnc_distanceUnits);
				_exit = true;
				};
			//waitUntil {sleep 1; (!alive _truck) or (_truck distance _position > 7) or (dateToNumber date < _dateDelayNumeric)};
			};
		if (_exit) exitWith {};
		};
	};


waitUntil {sleep 1; (dateToNumber date > _dateDelayNumeric) or (!alive _truck) or (_truck distance _posbase < 50)};
if ((_truck distance _posbase < 50) and (dateToNumber date < _dateDelayNumeric)) then
	{
	["LOG",[format ["We know Gendarmes is guarding a big amount of money in the bank of %1. Take this truck and go there before %2:%3, hold the truck close to tha bank's main entrance for 2 minutes and the money will be transferred to the truck. Bring it back to HQ and the money will be ours.",_destinationName,numberToDate [2035,_dateDelayNumeric] select 3,numberToDate [2035,_dateDelayNumeric] select 4],"Bank Robbery",_mrkfin],_position,"SUCCEEDED","Interact"] call A3A_fnc_taskUpdate;
	[0,5000*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
	[10*_bonus,0] remoteExec ["A3A_fnc_prestige",2];
	[1800*_bonus] remoteExec ["A3A_fnc_timingCA",2];
	{if (_x distance _truck < 500) then {[10*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
	[5*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
	waitUntil {sleep 1; speed _truck == 0};

	[_truck] call A3A_fnc_vaciar;
	};
if (!alive _truck) then
	{
	["LOG",[format ["We know Gendarmes is guarding a big amount of money in the bank of %1. Take this truck and go there before %2:%3, hold the truck close to tha bank's main entrance for 2 minutes and the money will be transferred to the truck. Bring it back to HQ and the money will be ours.",_destinationName,numberToDate [2035,_dateDelayNumeric] select 3,numberToDate [2035,_dateDelayNumeric] select 4],"Bank Robbery",_mrkfin],_position,"FAILED","Interact"] call A3A_fnc_taskUpdate;
	[1800*_bonus] remoteExec ["A3A_fnc_timingCA",2];
	[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
	};


deleteVehicle _truck;

_nul = [1200,"LOG"] spawn A3A_fnc_borrarTask;

waitUntil {sleep 1; !([distanceSPWN,1,_position,good] call A3A_fnc_distanceUnits)};

{_group = _x;
{deleteVehicle _x} forEach units _group;
deleteGroup _x;
} forEach _groups;

//sleep (600 + random 1200);
//_nul = [_tsk,true] call BIS_fnc_deleteTask;
deleteMarker _mrk;
deleteMarker _mrkfin;


