private _group = _this;

private _leader = leader _group;

private _side = side _group;
private _enemySides = _side call BIS_fnc_enemySides;
private _objectives = (_leader nearTargets  500) select {((_x select 2) in _enemySides) and ([_x select 4] call A3A_fnc_canFight)};
_objectives = [_objectives,[_leader],{_input0 distance (_x select 0)},"ASCEND"] call BIS_fnc_sortBy;
_group setVariable ["objetivos",_objectives];
_objectives
