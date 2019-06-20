private ["_marker","_size","_area"];

_marker = _this select 0;
_size = 0;

_area = markerSize _marker;
_size = _area select 0;
if (_size < _area select 1) then {_size = _area select 1};
_size
