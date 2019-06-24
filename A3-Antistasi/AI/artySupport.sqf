if (count hcSelected player == 0) exitWith {hint "You must select an artillery group"};

private ["_groups","_artyArray","_artyRoundsArr","_hasAmmo","_ready","_haveArtillery","_alive","_soldier","_veh","_ammoType","_artilleryType","_clickedPosition","_artyArrayDef1","_artyRoundsArr1","_piece","_isInRange","_clickedPosition2","_rounds","_roundsMax","_marker","_size","_forced","_text","_mrkfin","_mrkfin2","_time","_eta","_count","_pos","_ang"];

_groups = hcSelected player;
_units = [];
{_group = _x;
{_units pushBack _x} forEach units _group;
} forEach _groups;
tipoMuni = nil;
_artyArray = [];
_artyRoundsArr = [];

_hasAmmo = 0;
_ready = false;
_haveArtillery = false;
_alive = false;

{
_soldier = _x;
_veh = vehicle _soldier;
if ((_veh != _soldier) and (not(_veh in _artyArray))) then
	{
	if (( "Artillery" in (getArray (configfile >> "CfgVehicles" >> typeOf _veh >> "availableForSupportTypes")))) then
		{
		_haveArtillery = true;
		if ((canFire _veh) and (alive _veh) and (isNil "tipoMuni")) then
			{
			_alive = true;
			_nul = createDialog "mortar_type";
			waitUntil {!dialog or !(isNil "tipoMuni")};
			if !(isNil "tipoMuni") then
				{
				_ammoType = tipoMuni;
				//tipoMuni = nil;
			//	};
			//if (! isNil "_ammoType") then
				//{
				{
				if (_x select 0 == _ammoType) then
					{
					_hasAmmo = _hasAmmo + 1;
					};
				} forEach magazinesAmmo _veh;
				};
			if (_hasAmmo > 0) then
				{
				if (unitReady _veh) then
					{
					_ready = true;
					_artyArray pushBack _veh;
					_artyRoundsArr pushBack (((magazinesAmmo _veh) select 0)select 1);
					};
				};
			};
		};
	};
} forEach _units;

if (!_haveArtillery) exitWith {hint "You must select an artillery group or it is a Mobile Mortar and it's moving"};
if (!_alive) exitWith {hint "All elements in this Batery cannot fire or are disabled"};
if ((_hasAmmo < 2) and (!_ready)) exitWith {hint "The Battery has no ammo to fire. Reload it on HQ"};
if (!_ready) exitWith {hint "Selected Battery is busy right now"};
if (_ammoType == "not_supported") exitWith {hint "Your current modset doesent support this strike type"};
if (isNil "_ammoType") exitWith {};

hcShowBar false;
hcShowBar true;

if (_ammoType != "2Rnd_155mm_Mo_LG") then
	{
	closedialog 0;
	_nul = createDialog "strike_type";
	}
else
	{
	tipoArty = "NORMAL";
	};

waitUntil {!dialog or (!isNil "tipoArty")};

if (isNil "tipoArty") exitWith {};

_artilleryType = tipoArty;
tipoArty = nil;


posicionTel = [];

hint "Select the position on map where to perform the Artillery strike";

if (!visibleMap) then {openMap true};
onMapSingleClick "posicionTel = _pos;";

waitUntil {sleep 1; (count posicionTel > 0) or (!visibleMap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

_clickedPosition = posicionTel;

_artyArrayDef1 = [];
_artyRoundsArr1 = [];

for "_i" from 0 to (count _artyArray) - 1 do
	{
	_piece = _artyArray select _i;
	_isInRange = _clickedPosition inRangeOfArtillery [[_piece], ((getArtilleryAmmo [_piece]) select 0)];
	if (_isInRange) then
		{
		_artyArrayDef1 pushBack _piece;
		_artyRoundsArr1 pushBack (_artyRoundsArr select _i);
		};
	};

if (count _artyArrayDef1 == 0) exitWith {hint "The position you marked is out of bounds for that Battery"};

_mrkfin = createMarkerLocal [format ["Arty%1", random 100], _clickedPosition];
_mrkfin setMarkerShapeLocal "ICON";
_mrkfin setMarkerTypeLocal "hd_destroy";
_mrkfin setMarkerColorLocal "ColorRed";

if (_artilleryType == "BARRAGE") then
	{
	_mrkfin setMarkerTextLocal "Atry Barrage Begin";
	posicionTel = [];

	hint "Select the position to finish the barrage";

	if (!visibleMap) then {openMap true};
	onMapSingleClick "posicionTel = _pos;";

	waitUntil {sleep 1; (count posicionTel > 0) or (!visibleMap)};
	onMapSingleClick "";

	_clickedPosition2 = posicionTel;
	};

if ((_artilleryType == "BARRAGE") and (isNil "_clickedPosition2")) exitWith {deleteMarkerLocal _mrkfin};

if (_artilleryType != "BARRAGE") then
	{
	if (_ammoType != "2Rnd_155mm_Mo_LG") then
		{
		closedialog 0;
		_nul = createDialog "rounds_number";
		}
	else
		{
		rondas = 1;
		};
	waitUntil {!dialog or (!isNil "rondas")};
	};

if ((isNil "rondas") and (_artilleryType != "BARRAGE")) exitWith {deleteMarkerLocal _mrkfin};

if (_artilleryType != "BARRAGE") then
	{
	_mrkfin setMarkerTextLocal "Arty Strike";
	_rounds = rondas;
	_roundsMax = _rounds;
	rondas = nil;
	}
else
	{
	_rounds = round (_clickedPosition distance _clickedPosition2) / 10;
	_roundsMax = _rounds;
	};

_marker = [marcadores,_clickedPosition] call BIS_fnc_nearestPosition;
_size = [_marker] call A3A_fnc_sizeMarker;
_forced = false;

if ((not(_marker in forcedSpawn)) and (_clickedPosition distance (getMarkerPos _marker) < _size) and ((spawner getVariable _marker != 0))) then
	{
	_forced = true;
	forcedSpawn pushBack _marker;
	publicVariable "forcedSpawn";
	};

_text = format ["Requesting fire support on Grid %1. %2 Rounds", mapGridPosition _clickedPosition, round _rounds];
[theBoss,"sideChat",_text] remoteExec ["A3A_fnc_commsMP",[good,civilian]];

if (_artilleryType == "BARRAGE") then
	{
	_mrkfin2 = createMarkerLocal [format ["Arty%1", random 100], _clickedPosition2];
	_mrkfin2 setMarkerShapeLocal "ICON";
	_mrkfin2 setMarkerTypeLocal "hd_destroy";
	_mrkfin2 setMarkerColorLocal "ColorRed";
	_mrkfin2 setMarkerTextLocal "Arty Barrage End";
	_ang = [_clickedPosition,_clickedPosition2] call BIS_fnc_dirTo;
	sleep 5;
	_eta = (_artyArrayDef1 select 0) getArtilleryETA [_clickedPosition, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)];
	_time = time + _eta;
	_text = format ["Acknowledged. Fire mission is inbound. ETA %1 secs for the first impact",round _eta];
	[petros,"sideChat",_text]remoteExec ["A3A_fnc_commsMP",[good,civilian]];
	[_time] spawn
		{
		private ["_time"];
		_time = _this select 0;
		waitUntil {sleep 1; time > _time};
		[petros,"sideChat","Splash. Out"] remoteExec ["A3A_fnc_commsMP",[good,civilian]];
		};
	};

_pos = [_clickedPosition,random 10,random 360] call BIS_fnc_relPos;

for "_i" from 0 to (count _artyArrayDef1) - 1 do
	{
	if (_rounds > 0) then
		{
		_piece = _artyArrayDef1 select _i;
		_count = _artyRoundsArr1 select _i;
		//hint format ["Rondas que faltan: %1, rondas que tiene %2",_rounds,_count];
		if (_count >= _rounds) then
			{
			if (_artilleryType != "BARRAGE") then
				{
				_piece commandArtilleryFire [_pos,_ammoType,_rounds];
				}
			else
				{
				for "_r" from 1 to _rounds do
					{
					_piece commandArtilleryFire [_pos,_ammoType,1];
					sleep 2;
					_pos = [_pos,10,_ang + 5 - (random 10)] call BIS_fnc_relPos;
					};
				};
			_rounds = 0;
			}
		else
			{
			if (_artilleryType != "BARRAGE") then
				{
				_piece commandArtilleryFire [[_pos,random 10,random 360] call BIS_fnc_relPos,_ammoType,_count];
				}
			else
				{
				for "_r" from 1 to _count do
					{
					_piece commandArtilleryFire [_pos,_ammoType,1];
					sleep 2;
					_pos = [_pos,10,_ang + 5 - (random 10)] call BIS_fnc_relPos;
					};
				};
			_rounds = _rounds - _count;
			};
		};
	};

if (_artilleryType != "BARRAGE") then
	{
	sleep 5;
	_eta = (_artyArrayDef1 select 0) getArtilleryETA [_clickedPosition, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)];
	_time = time + _eta - 5;
	if (isNil "_time") exitWith {diag_log format ["Antistasi: Error en artySupport.sqf. Params: %1,%2,%3,%4",_artyArrayDef1 select 0,_clickedPosition,((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0),(_artyArrayDef1 select 0) getArtilleryETA [_clickedPosition, ((getArtilleryAmmo [(_artyArrayDef1 select 0)]) select 0)]]};
	_text = format ["Acknowledged. Fire mission is inbound. %2 Rounds fired. ETA %1 secs",round _eta,_roundsMax - _rounds];
	[petros,"sideChat",_text] remoteExec ["A3A_fnc_commsMP",[good,civilian]];
	};

if (_artilleryType != "BARRAGE") then
	{
	waitUntil {sleep 1; time > _time};
	[petros,"sideChat","Splash. Out"] remoteExec ["A3A_fnc_commsMP",[good,civilian]];
	};
sleep 10;
deleteMarkerLocal _mrkfin;
if (_artilleryType == "BARRAGE") then {deleteMarkerLocal _mrkfin2};

if (_forced) then
	{
	sleep 20;
	if (_marker in forcedSpawn) then
		{
		forcedSpawn = forcedSpawn - [_marker];
		publicVariable "forcedSpawn";
		};
	};
