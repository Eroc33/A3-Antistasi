private ["_pool","_veh","_vehicleType"];

_veh = cursorTarget;

if (isNull _veh) exitWith {hint "You are not looking at a vehicle"};

if (!alive _veh) exitWith {hint "You cannot unlock destroyed"};

if (_veh isKindOf "Man") exitWith {hint "Are you kidding?"};
if (not(_veh isKindOf "AllVehicles")) exitWith {hint "The vehicle you are looking at cannot be used"};
_owner = _veh getVariable "duenyo";

if (isNil "_owner") exitWith {hint "The vehicle you are looking at is already unlocked"};

if (_owner != getPlayerUID player) exitWith {hint "You cannot unlock vehicles which you do not own"};

_veh setVariable ["duenyo",nil,true];

hint "Vehicle Unlocked";
