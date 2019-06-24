private ["_unit","_medic","_timeOut","_cured","_isPlayer","_smoked","_enemy","_coverage","_dummyGrp","_dummy"];
_unit = _this select 0;///no usar canfight porque algunas tienen setcaptive true y te va a liar todo
if !(isNull (_unit getVariable ["ayudado",objNull])) exitWith {};
_medic = _this select 1;
if (isPlayer _medic) exitWith {};
if (_medic getVariable ["ayudando",false]) exitWith {};
_unit setVariable ["ayudado",_medic];
_medic setVariable ["ayudando",true];
_medic setVariable ["maniobrando",true];
_cured = false;
_isPlayer = if ({isPlayer _x} count units group _unit >0) then {true} else {false};
_smoked = false;

if (_medic != _unit) then
	{
	if !(_unit getVariable ["INCAPACITATED",false]) then
		{
		if (_isPlayer) then {_unit groupChat format ["Comrades, this is %1. I'm hurt",name _unit]};
		playSound3D [(selectRandom injuredSounds),_unit,false, getPosASL _unit, 1, 1, 50];
		};
	if (_isPlayer) then
		{
		[_medic,_unit] spawn
			{
			sleep 2;
			private ["_medic","_unit"];
			_medic = _this select 0;
			_unit = _this select 1;
			_medic groupChat format ["Wait a minute comrade %1, I will patch you up",name _unit]
			};
		};
	if (hasInterface) then {if (player == _unit) then {hint format ["%1 is on the way to help you",name _medic]}};
	_enemy = _medic findNearestEnemy _unit;
	_smoked = [_medic,_unit,_enemy] call A3A_fnc_cubrirConHumo;
	_medic stop false;
	_medic forceSpeed -1;
	_timeOut = time + 60;
	sleep 5;
	_medic doMove getPosATL _unit;
	while {true} do
		{
		if (!([_medic] call A3A_fnc_canFight) or (!alive _unit) or (_medic distance _unit <= 3) or (_timeOut < time) or (_unit != vehicle _unit) or (_medic != vehicle _medic) or (_medic != _unit getVariable ["ayudado",objNull]) or !(isNull attachedTo _unit) or (_medic getVariable ["cancelRevive",false])) exitWith {};
		sleep 1;
		};
	if ((isPlayer _unit) and !(isMultiplayer))  then
		{
		if (([_medic] call A3A_fnc_canFight) and (_medic distance _unit > 3) and (_medic == _unit getVariable ["ayudado",objNull]) and !(_unit getVariable ["llevado",false]) and (allUnits findIf {((side _x == bad) or (side _x == veryBad)) and (_x distance2D _unit < 50)} == -1)) then {_medic setPos position _unit};
		};
	if ((_unit distance _medic <= 3) and (alive _unit) and ([_medic] call A3A_fnc_canFight) and (_medic == vehicle _medic) and (_medic == _unit getVariable ["ayudado",objNull]) and (isNull attachedTo _unit) and !(_medic getVariable ["cancelRevive",false])) then
		{
		if ((_unit getVariable ["INCAPACITATED",false]) and (!isNull _enemy) and (_timeOut >= time) and (_medic != _unit)) then
			{
			_coverage = [_unit,_enemy] call A3A_fnc_cobertura;
			{if (([_x] call A3A_fnc_canFight) and (_x distance _medic < 50) and !(_x getVariable ["ayudando",false]) and (!isPlayer _x)) then {[_x,_enemy] call A3A_fnc_fuegoSupresor}} forEach units (group _medic);
			if (count _coverage == 3) then
				{
				//if (_isPlayer) then {_unit setVariable ["llevado",true,true]};
				_medic setUnitPos "MIDDLE";
				_medic playAction "grabDrag";
				sleep 0.1;
				_timeOut = time + 5;
				waitUntil {sleep 0.3; ((animationState _medic) == "AmovPercMstpSlowWrflDnon_AcinPknlMwlkSlowWrflDb_2") or ((animationState _medic) == "AmovPercMstpSnonWnonDnon_AcinPknlMwlkSnonWnonDb_2") or !([_medic] call A3A_fnc_canFight) or (_timeOut < time)};
				if ([_medic] call A3A_fnc_canFight) then
					{
					[_unit,"AinjPpneMrunSnonWnonDb"] remoteExec ["switchMove"];
					_medic disableAI "ANIM";
					//_medic playMoveNow "AcinPknlMstpSrasWrflDnon";
					_medic stop false;
					_dummyGrp = createGroup civilian;
					_dummy = _dummyGrp createUnit ["C_man_polo_1_F", [0,0,20], [], 0, "FORM"];
					_dummy setUnitPos "MIDDLE";
					_dummy forceWalk true;
					_dummy setSkill 0;
					if (isMultiplayer) then {[_dummy,true] remoteExec ["hideObjectGlobal",2]} else {_dummy hideObject true};
					_dummy allowdammage false;
					_dummy setBehaviour "CARELESS";
					_dummy disableAI "FSM";
					_dummy disableAI "SUPPRESSION";
				    _dummy forceSpeed 0.2;
				    _dummy setPosATL (getPosATL _medic);
					_medic attachTo [_dummy, [0, -0.2, 0]];
					_medic setDir 180;
					//_unit attachTo [_dummy, [0, 1.1, 0.092]];
					_unit attachTo [_dummy, [0,-1.1, 0.092]];
					_unit setDir 0;
					_dummy doMove _coverage;
					[_medic] spawn {sleep 4.5; (_this select 0) playMove "AcinPknlMwlkSrasWrflDb"};
					_timeOut = time + 30;
					while {true} do
						{
						sleep 0.2;
						if (!([_medic] call A3A_fnc_canFight) or (!alive _unit) or (_medic distance _coverage <= 2) or (_timeOut < time) or (_medic != vehicle _medic) or (_medic getVariable ["cancelRevive",false])) exitWith {};
						if (_unit distance _dummy > 3) then
							{
							detach _unit;
							_unit setPos (position _dummy);
							_unit attachTo [_dummy, [0,-1.1, 0.092]];
							_unit setDir 0;
							};
						if (_medic distance _dummy > 3) then
							{
							detach _medic;
							_medic setPos (position _dummy);
							_medic attachTo [_dummy, [0, -0.2, 0]];
							_medic setDir 180;
							};
						};
					detach _unit;
					detach _medic;
					detach _dummy;
					deleteVehicle _dummy;
					deleteGroup _dummyGrp;
					_medic enableAI "ANIM";
					};
				if ((alive _unit) and ([_medic] call A3A_fnc_canFight) and (_medic == vehicle _medic) and !(_medic getVariable ["cancelRevive",false])) then
					{
					_medic playMove "amovpknlmstpsraswrfldnon";
					_medic stop true;
					_unit stop true;
					sleep 3;
					_cured = [_unit,_medic] call A3A_fnc_actionRevive;
					_unit playMoveNow "";
					if (_cured) then
						{
						if (_medic != _unit) then {if (_isPlayer) then {_medic groupChat format ["You are ready %1",name _unit]}};
						};
					sleep 5;
					_medic stop false;
					_unit stop false;
					_unit dofollow leader group _unit;
					_medic doFollow leader group _unit;
					}
				else
					{
					//if ([_medic] call A3A_fnc_canFight) then {_medic switchMove ""};
					[_medic,""] remoteExec ["switchMove"];
					if ((alive _unit) and (_unit getVariable ["INCAPACITATED",false])) then
						{
						_unit playMoveNow "";
						_unit setUnconscious false;
						_timeOut = time + 3;
						waitUntil {sleep 0.3; (lifeState _unit != "INCAPACITATED") or (_timeOut < time)};
						_unit setUnconscious true;
						};
					};
				//if (_isPlayer) then {_unit setVariable ["llevado",false,true]};
				}
			else
				{
				_medic stop true;
				//if (!_smoked) then {[_medic,_unit] call A3A_fnc_cubrirConHumo};
				_unit stop true;
				_cured = [_unit,_medic] call A3A_fnc_actionRevive;
				if (_cured) then
					{
					if (_medic != _unit) then {if (_isPlayer) then {_medic groupChat format ["You are ready %1",name _unit]}};
					sleep 10;
					};
				_medic stop false;
				_unit stop false;
				_unit dofollow leader group _unit;
				_medic doFollow leader group _unit;
				};
			if ((animationState _medic == "amovpknlmstpsraswrfldnon") or (animationState _medic == "AmovPercMstpSlowWrflDnon_AcinPknlMwlkSlowWrflDb_2") or (animationState _medic == "AmovPercMstpSnonWnonDnon_AcinPknlMwlkSnonWnonDb_2")) then {_medic switchMove ""};
			}
		else
			{
			_medic stop true;
			//if (!_smoked) then {[_medic,_unit] call A3A_fnc_cubrirConHumo};
			_unit stop true;
			if (_unit getVariable ["INCAPACITATED",false]) then {_cured = [_unit,_medic] call A3A_fnc_actionRevive} else {_medic action ["HealSoldier",_unit]; _cured = true};
			if (_cured) then
				{
				if (_medic != _unit) then {if (_isPlayer) then {_medic groupChat format ["You are ready %1",name _unit]}};
				sleep 10;
				};
			_medic stop false;
			_unit stop false;
			_unit dofollow leader group _unit;
			_medic doFollow leader group _unit;
			};
		};
	if (_medic == _unit getVariable ["ayudado",objNull]) then {_unit setVariable ["ayudado",objNull]};
	_medic setUnitPos "AUTO";
	if (_medic getVariable ["cancelRevive",false]) then
		{
		_medic stop false;
		_medic doFollow leader group _unit;
		sleep 15;
		};
	}
else
	{
	[_medic,_medic] call A3A_fnc_cubrirConHumo;
	if ([_medic] call A3A_fnc_canFight) then
		{
		_medic action ["HealSoldierSelf",_medic];
		sleep 10;
		};
	_unit setVariable ["ayudado",objNull];
	_cured = true;
	};
if (_medic getVariable ["cancelRevive",false]) then
	{
	_medic setVariable ["cancelRevive",false];
	sleep 15;
	};
_medic setVariable ["ayudando",false];
_medic setVariable ["maniobrando",false];
_cured
