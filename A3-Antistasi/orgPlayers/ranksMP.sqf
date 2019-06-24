_player = _this select 0;
_player = _player getVariable ["owner",_player];
//if ((!isServer) and (player != _player)) exitWith {};
_rank = _this select 1;
_player setRank _rank;
[] spawn A3A_fnc_statistics;
