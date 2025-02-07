private ["_vehInGarage","_check"];

pool = !(_this select 0);
if (pool and (not([player] call A3A_fnc_isMember))) exitWith {hint "You cannot access the Garage as you are guest in this server"};
if (player != player getVariable "owner") exitWith {hint "You cannot access the Garage while you are controlling AI"};

if ([player,300] call A3A_fnc_enemyNearCheck) exitWith {Hint "You cannot manage the Garage with enemies nearby"};
vehInGarageShow = [];
_haveAir = false;
_airports = airports select {(sides getVariable [_x,sideUnknown] == good) and (player inArea _x)};
if (count _airports > 0) then {_haveAir = true};
{
if ((_x in vehPlanes)) then
	{
	if (_haveAir) then {vehInGarageShow pushBack _x};
	}
else
	{
	vehInGarageShow pushBack _x;
	};
} forEach (if (pool) then {vehInGarage} else {personalGarage});
if (count vehInGarageShow == 0) exitWith {hintC "The Garage is empty or the vehicles you have are not suitable to recover in the place you are.\n\nAir vehicles need to be recovered near Airport flags."};
_near = [marcadores select {sides getVariable [_x,sideUnknown] == good},player] call BIS_fnc_nearestPosition;
if !(player inArea _near) exitWith {hint "You need to be close to one of your garrisons to be able to retrieve a vehicle from your garage"};
cuentaGarage = 0;
_type = vehInGarageShow select cuentaGarage;
garageVeh = _type createVehicleLocal [0,0,1000];
garageVeh allowDamage false;
garageVeh enableSimulationGlobal false;
comprado = 0;
[format ["<t size='0.7'>%1<br/><br/><t size='0.6'>Garage Keys.<t size='0.5'><br/>Arrow Up-Down to Navigate<br/>Arrow Left-Right to rotate<br/>SPACE to Select<br/>ENTER to Exit",getText (configFile >> "CfgVehicles" >> typeOf garageVeh >> "displayName")],0,0,5,0,0,4] spawn bis_fnc_dynamicText;
hint "Hover your mouse to the desired position. If it's safe and suitable, you will see the vehicle";
garageKeys = (findDisplay 46) displayAddEventHandler ["KeyDown",
		{
		_handled = false;
		_exit = false;
		_change = false;
		_bought = false;
		if (_this select 1 == 57) then
			{
			_exit = true;
			_bought = true;
			};
		if (_this select 1 == 28) then
			{
			_exit = true;
			deleteVehicle garageVeh;
			};
		if (_this select 1 == 200) then
			{
			if (cuentaGarage + 1 > (count vehInGarageShow) - 1) then {cuentaGarage = 0} else {cuentaGarage = cuentaGarage + 1};
			_change = true;
			_handled = true;
			//["",0,0,0.34,0,0,4] spawn bis_fnc_dynamicText;
			};
		if (_this select 1 == 208) then
			{
			if (cuentaGarage - 1 < 0) then {cuentaGarage = (count vehInGarageShow) - 1} else {cuentaGarage = cuentaGarage - 1};
			_change = true;
			_handled = true;
			//["",0,0,0.34,0,0,4] spawn bis_fnc_dynamicText;
			};
		if (_this select 1 == 205) then
			{
			garageVeh setDir (getDir garageVeh + 1);
			_handled = true;
			};
		if (_this select 1 == 203) then
			{
			garageVeh setDir (getDir garageVeh - 1);
			_handled = true;
			};
		if (_change) then
			{
			deleteVehicle garageVeh;
			_type = vehInGarageShow select cuentaGarage;
			if (isNil "_type") then {_exit = true};
			if (typeName _type != typeName "") then {_exit = true};
			if (!_exit) then
				{
				garageVeh = _type createVehicleLocal [0,0,1000];
				garageVeh allowDamage false;
				garageVeh enableSimulationGlobal false;
				[format ["<t size='0.7'>%1<br/><br/><t size='0.6'>Garage Keys.<t size='0.5'><br/>Arrow Up-Down to Navigate<br/>Arrow Left-Right to rotate<br/>SPACE to Select<br/>ENTER to Exit",getText (configFile >> "CfgVehicles" >> typeOf garageVeh >> "displayName")],0,0,5,0,0,4] spawn bis_fnc_dynamicText;
				};
			};
		if (_exit) then
			{
			if (!_bought) then
				{
				["",0,0,5,0,0,4] spawn bis_fnc_dynamicText;
				comprado = 1;
				}
			else
				{
				if (garageVeh distance [0,0,1000] <= 1500) then
					{
					["<t size='0.6'>The current position is not suitable for the vehicle. Try another",0,0,3,0,0,4] spawn bis_fnc_dynamicText;
					}
				else
					{
					comprado = 2;
					["<t size='0.6'>Vehicle retrieved from Garage",0,0,3,0,0,4] spawn bis_fnc_dynamicText;
					};
				};
			};
		_handled;
		}];
posicionSel = [0,0,0];
onEachFrame
 {
 if !(isNull garageVeh) then
  {
  _ins = lineIntersectsSurfaces [
    AGLToASL positionCameraToWorld [0,0,0],
    AGLToASL positionCameraToWorld [0,0,1000],
    player,garageVeh
   ];
   if (_ins isEqualTo []) exitWith {};
   _pos = (_ins select 0 select 0);
   if (_pos distance posicionSel < 0.1) exitWith {};
   posicionSel = _pos;
   _ship = false;
   if (garageVeh isKindOf "Ship") then {_pos set [2,0]; _ship = true};
   if (count (_pos findEmptyPosition [0, 0, typeOf garageVeh])== 0) exitWith {garageVeh setPosASL [0,0,0]};
   if (_pos distance2d player > 100)exitWith {garageVeh setPosASL [0,0,0]};
   _water = surfaceIsWater _pos;
   if (_ship and {!_water}) exitWith {garageVeh setPosASL [0,0,0]};
   if (!_ship and {_water}) exitWith {garageVeh setPosASL [0,0,0]};
   garageVeh setPosASL _pos;
   garageVeh setVectorUp (_ins select 0 select 1);
   };
 };
waitUntil {(comprado > 0) or !(player inArea _near)};
onEachFrame {};
(findDisplay 46) displayRemoveEventHandler ["KeyDown", garageKeys];
posicionSel = nil;
_pos = getPosASL garageVeh;
_dir = getDir garageVeh;
_type = typeOf garageVeh;
deleteVehicle garageVeh;
if !(player inArea _near) then {hint "You need to be close to one of your garrisons to be able to retrieve a vehicle from your garage";["",0,0,5,0,0,4] spawn bis_fnc_dynamicText; comprado = nil; garageVeh = nil; cuentaGarage = nil};
if ([player,300] call A3A_fnc_enemyNearCheck) then
	{
	hint "You cannot manage the Garage with enemies nearby";
	comprado = 0;
	};
if (comprado != 2) exitWith {comprado = nil; garageVeh = nil; cuentaGarage = nil};
comprado = nil;
//if (player distance2D _pos > 100) exitWith {hint "You have to select a closer position from you"};
waitUntil {isNull garageVeh};
garageVeh = nil;
_garageVeh = createVehicle [_type, [0,0,1000], [], 0, "NONE"];
_garageVeh setDir _dir;
_garageVeh setPosASL _pos;
[_garageVeh] call A3A_fnc_AIVEHinit;
if (_garageVeh isKindOf "Car") then {_garageVeh setPlateNumber format ["%1",name player]};
//_pool = false;
//if (vehInGarageShow isEqualTo vehInGarage) then {_pool = true};
_newArr = [];
_found = false;
if (pool) then
	{
	{
	if ((_x != (vehInGarageShow select cuentaGarage)) or (_found)) then {_newArr pushBack _x} else {_found = true};
	} forEach vehInGarage;
	vehInGarage = _newArr;
	publicVariable "vehInGarage";
	}
else
	{
	{
	if ((_x != (vehInGarageShow select cuentaGarage)) or (_found)) then {_newArr pushBack _x} else {_found = true};
	} forEach personalGarage;
	personalGarage = _newArr;
	["personalGarage",_newArr] call fn_SaveStat;
	_garageVeh setVariable ["duenyo",getPlayerUID player,true];
	};
cuentaGarage = nil;
if (_garageVeh isKindOf "StaticWeapon") then {staticsToSave pushBack _garageVeh; publicVariable "staticsToSave"};
clearMagazineCargoGlobal _garageVeh;
clearWeaponCargoGlobal _garageVeh;
clearItemCargoGlobal _garageVeh;
clearBackpackCargoGlobal _garageVeh;
_garageVeh allowDamage true;
_garageVeh enableSimulationGlobal true;
