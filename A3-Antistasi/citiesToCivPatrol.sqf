_marker = _this select 0;
_markerPos = getMarkerPos _marker;

_arrayCities = (ciudades select {getMarkerPos _x distance _markerPos < 3000}) - [_marker];
/*
for "_i" from 0 to (count ciudades - 1) do
	{
	if ((getMarkerPos (ciudades select _i)) distance _posMarcador < 3000) then {_arrayCities set [count _arrayCities,ciudades select _i]};
	};

_arrayCities = _arrayCities - [_marker];
*/
_arrayCities
