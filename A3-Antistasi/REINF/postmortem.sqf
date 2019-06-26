_dead = _this select 0;
sleep cleantime;
deleteVehicle _dead;
_group = group _dead;
if (!isNull _group) then
	{
	if ({alive _x} count units _group == 0) then {deleteGroup _group};
	}
else
	{
	if (_dead in staticsToSave) then {staticsToSave = staticsToSave - [_dead]; publicVariable "staticsToSave";};
	};
