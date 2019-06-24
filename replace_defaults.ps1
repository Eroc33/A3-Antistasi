param (
    [Parameter(Mandatory=$True)][string]$File
)

$Replacements=@{
    "_tipo"="_type";
    "_coste"="_cost";
    "_grupo"="_group";
    "_texto"="_text";
    "_escarretera"="_isRoad";
    "_tipogrupo"="_groupType";
    "_camion"="_truck";
    "_unidades"="_units";
    "_formato"="_format";
    "_marcador"="_marker";
    "_lado"="_side";
    "_salir"="_exit";
    "_tipoVeh"="_vehicleType";
    "_duenyo"="_owner";
    "_vehiculos"="_vehicles";
    "_vehiculo"="_vehicle";
    "_grupos"="_groups";
    "_mrkDestino"="_mrkDestination";
    "_mrkOrigen"="_mrkOrigin";
    "_pilotos"="_pilots";
    "_piloto"="_pilot";
    "_soldadosTotal"="_totalSoliders";
    "_nombredest"="_destinationName";
    "_nombreorig"="_originName";
    "_nombreEny"="_enemyName";
    "_tiempo"="_time";
    "_soldados"="_soldiers";
    "_soldado"="_soldier";
    "_posDestino"="_destinationPos";
    "_posOrigen"="_originPos";
    "_indice"="_index";
    "_puestos"="_points";
    "_puesto"="_point";
    "_cuenta"="_count";
    "_esMar"="_isMarine";
    "_proceder"="_proceed";
    "_esSDK"="_isSDK";
    "_aeropuerto"="_airport";
    "_aeropuertos"="_airports";
    "_ladosTsk"="_taskSides";
    "_ladosTsk1"="_taskSides1";
    "_posOrigenLand"="_landOriginPos";
    "_grupoVeh"="_groupVeh";
    "_posSuelo"="_groundPos";
    "_grupoUav"="_groupUav";
    "_fechafin"="_endDate";
    "_tiempofin"="_endTime";
    "_refuerzos"="_reinforcements";
    "_dificil"="_difficulty";
    "_contacto"="_contact";
    "_esFIA"="_isFIA";
    "_fechafinNum"="_endDateNumeric";
    "_destino"="_destination";
    "_tipoConvoy"="_convoyType";
    "_tipos"="_types";
    "_tipoVehEsc"="_escortVehType";
    "_grupoEsc"="_escortGroup";
    "_tiposConvoy"="_convoyTypes";
    "_grpContacto"="_grpContact";
    "_tipoVehObj"="_vehObjType";
    "_cercano"="_near";
    "_enemigos"="_enemies";
    "_esMarcador"="_isMarker";
    "_amigos"="_friendlies";
    "_sitio"="_site";
    "_marcadores"="_markers";
    "_nombreMiss"="_missionName";
    "_colorbuenos"="_colorGood";
    "_colormuyMalos"="_colorVeryBad";
    "_posicion"="_position";
    "_titulo"="_title";
    "_caja"="_box";
    "_nombre"="_name";
    "_ciudad"="_city";
    "_jugador"="_player";
    "_contenedor"="_container";
    "_posBancos"="_bankPositions";
    "_posAntenas"="_antennaPositions";
    "_antena"="_antenna";
    "_banco"="_bank";
    "_distancia"="_distance";
    "_hayCaja"="_hasBox";
    "_muerto"="_dead";
    "_objetos"="_objects";
    "_arma"="_weapon";
    "_armas"="_weapons";
    "_casco"="_helmet";
    "_objeto"="_object";
    "_necesita"="_required";
    "_cosa"="_thing";
    "_cosas"="_things";
    "_numero"="_number";
    "_tipoMina"="_mineType";
    "_posMina"="_minePos";
    "_mina"="_mine";
    "_datos"="_data";
    "_objetivos"="_objectives";
    "_objetivosFinal"="_objectivesFinal";
    "_objetivoFinal"="_objectiveFinal";
    "_puertoCSAT"="_portCSAT";
    "_puertoNATO"="_portNATO";
    "_tmpObjetivos"="_tmpObjectives";
    "_esCiudad"="_isCity";
    "_estaticas"="_statics";
    "_posSitio"="_sitePos";
    #"_ladoEny"="_enemySide";
    "_aeropCercano"="_nearbyAirports";
    "_cuentasFinal"="_countsFinal";
    "_origen"="_origin";
    "_posiciones"="_positions";
    "_tipoUnit"="_unitType";
    "_tam"="_size";
    "_perro"="_dog";
    "_arrayGrupos"="_groupsArray";
    "_frontera"="_isFrontLine";
    "_bandera"="_flag";
    "_morteros"="_mortars";
    "_tanques"="_tanks";
    "_aire"="_air";
    "_lider"="_leader";
    "_objetivo"="_objective";
    "_tarea"="_task";
    "_numObjetivos"="_numObjectives";
    "_mortero"="_mortar";
    "_transporte"="_transport";
    "_ingeniero"="_engineer";
    "_posicionMRK"="_mrkPosition";
    "_clase"="_class";
    "_sitios"="_sites";
    "_grupoheli"="_heliGroup";
    "_silencio"="_silence";
    "_amigo"="_friend";
    "_modo"="_mode";
    "_edificios"="_buildings";
    "_edificio"="_building";
    "_numSoldados"="_numSoliders";
    "_conquistado"="_conquered";
    "_esControl"="_isControl";
    "_accion"="_action";
    "_cambiar"="_change";
    "_nombrebase"="_baseName";
    "_humo"="_smoke";
    "_tiempolim"="_timeDelay";
    "_fechalim"="_dateDelay";
    "_fechalimnum"="_dateDelayNumeric";
    "_casas"="_houses";
    "_casa"="_house";
    "_poscasa"="_housePos";
    "_postraidor"="_traitorPos";
    "_arrayaeropuertos"="_airportsArray";
    "_grptraidor"="_traitorGroup";
    "_traidor"="_traitor";
    "_minasFIA"="_minesFIA";
    "_grupoPOW"="_groupPOW";
    "_grupo1"="_group1";
    "_municion"="_ammo";
    "_costeHR"="_costHR";
    "_tipoUnidad"="_unitType";
    "_cobertura"="_coverage";
    "_medico"="_medic";
    "_curado"="_cured";
    "_banderas"="_flags";
    "_prestigeMalos"="_badGuysPrestige";
    "_prestigeMuyMalos"="_veryBadGuysPrestige";
    "_hayMuni"="_hasAmmo";
    "_cambiado"="_changed";
    "_cuentaSave"="_saveCounter";
    "_recurso"="_resources";
    "_recAddSDK"="_resAddSDK";
    "_recAddCiudadSDK"="_recAddCitySDK";
    "_hrAddCiudad"="_hrAddCity";
    "_multiplicandorec"="_resourceMultiplyer"
}

foreach ($Find in $Replacements.Keys) {
    $Replace = $Replacements[$Find]
    .\replace.ps1 $File -Find $Find -Replace $Replace
}