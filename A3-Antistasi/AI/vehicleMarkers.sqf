private ["_veh","_text","_mrkfin","_pos","_side","_type","_newPos","_road","_friends"];

_veh = _this select 0;
_text = _this select 1;
_convoy = false;
if ((_text == "Convoy Objective") or (_text == "Mission Vehicle") or (_text == "Supply Box")) then {_convoy = true};
_side = side (group (driver _veh));
_type = "_unknown";
_format = "";
_color = colorBad;
if (_veh isKindOf "Truck") then {_type = "_motor_inf"}
	else
		{
		if (_veh isKindOf "Wheeled_APC_F") then {_type = "_mech_inf"}
		else
			{
			if (_veh isKindOf "Tank") then {_type = "_armor"}
			else
				{
				if (_veh isKindOf "Plane_Base_F") then {_type = "_plane"}
				else
					{
					if (_veh isKindOf "UAV_02_base_F") then {_type = "_uav"}
					else
						{
						if (_veh isKindOf "Helicopter") then {_type = "_air"}
						else
							{
							if (_veh isKindOf "Boat_F") then {_type = "_naval"}
							};
						};
					};
				};
			};
		};

if ((_side == good) or (_side == sideUnknown)) then
	{
	_enemigo = false;
	_format = "n";
	_color = colorGood;
	}
else
	{
	if (_side == bad) then
		{
		_format = "b";
		}
	else
		{
		if (_side == veryBad) then
			{
			_format = "o";
			_color = colorVeryBad;
			};
		};
	};

_type = format ["%1%2",_format,_type];

if ((side group (driver _veh) != good) and (side driver _veh != sideUnknown)) then {["TaskSucceeded", ["", format ["%1 Spotted",_text]]] spawn BIS_fnc_showNotification};

_mrkfin = createMarkerLocal [format ["%2%1", random 100,_text], position _veh];
_mrkfin setMarkerShapeLocal "ICON";
_mrkfin setMarkerTypeLocal _type;
_mrkfin setMarkerColorLocal _color;
_mrkfin setMarkerTextLocal _text;

while {(alive _veh) and !(isNull _veh) and (revelar or _convoy or (_veh getVariable ["revelado",false]))} do
	{
	_pos = getPos _veh;
	_mrkfin setMarkerPosLocal _pos;
	sleep 60;
	};
deleteMarkerLocal _mrkfin;
//if (alive _veh) then {_veh setVariable ["revelado",false,true]};