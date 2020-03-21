params["_ship"];

// Submarine and teleport handles spawn
if(isServer) then {
	// Spawn and place sub
	_sub = "Submarine_01_F" createVehicle [0,0,0];
	_sub enableSimulation false;
	_ship setVariable ["GSRI_FREMM_submarine", _sub, true];
	_sub setPosASL [(getPosASL _ship select 0) + 100, (getPosASL _ship select 1) + 100, (getPosASL _ship select 2)-10];
	_sub setDir getDir _ship;

	// Add map marker
	_mk = createMarker ["marker_submarine", _sub];
	_mk setMarkerType "flag_France";
	_mk setMarkerText "S-625 Devigny";

	// Create handle for TP to sub
	_toSub = "Land_Battery_F" createVehicle [0,0,0];
	_toSub enableSimulation false;
	_toSub attachTo [_ship,[-2.21198,13.976,7.537]];
	_ship setVariable ["GSRI_FREMM_submarine_toSub", _toSub, true];

	// Handle for TP to ship
	_toShip = "Land_Battery_F" createVehicle [0,0,0];
	_toShip enableSimulation false;
	_toShip attachTo [_ship getVariable "GSRI_FREMM_submarine", [0.0788574,-4.32037,3.1]];
	_ship setVariable ["GSRI_FREMM_submarine_toShip", _toShip, true];
};

// Adding position selection eventHandler
addMissionEventHandler ["MapSingleClick", GSRI_fnc_subSelectPos];

// Adding "abort selection" eventHandler
addMissionEventHandler ["Map", {
	params ["_opened", "_forced"];
	// Detect if map is closed but do not check if the event is linked to this module
	if!(_opened) then {
		player setVariable ["GSRI_FREMM_submarine_token", false];
		if!(player getVariable ["GSRI_FREMM_submarine_hadMap",true]) then { player unlinkItem "ItemMap"; player setVariable ["GSRI_FREMM_submarine_hadMap", nil] };
	};
}];

// Clientside jobs
if!(isDedicated) then {
	// Create handle for sub movement
	_com = "Land_Battery_F" createVehicleLocal [0,0,0];
	_com enableSimulation false;
	_com attachTo [_ship, [-2.94995,-34.0001,20.6]];

	// Add actions with map selection
	_statement = {
		if!("ItemMap" in assignedItems player) then { player setVariable ["GSRI_FREMM_submarine_hadMap", false]; player linkItem "ItemMap" };
		// Open the map
		openMap true;

		// Set the "submarine token" for the eventHandler to fire correctly
		player setVariable ["GSRI_FREMM_submarine_token", true];

		// Help notification
		["SubmarineInfo"] call BIS_fnc_showNotification;
	};
	_action = ["submarineSelectPosition","Choisir une destination pour le sous-marin","",_statement,{true}] call ace_interact_menu_fnc_createAction;
	[_com, 0, [], _action] call ace_interact_menu_fnc_addActionToObject;

	// Add teleport action
	{
		// Select the handle opposite to the one the player is interacting with
		_targetName = ["toSub", "toShip"] select (_x == "toSub");
		_statement = {
			params["_target", "_player", "_params"];
			_params params["_ship","_targetName"];
			_player setPosASL getPosASL (_ship getVariable (format["GSRI_FREMM_submarine_%1", _targetName]));
		};
		_action = [format["action_%1",_x], "Aller ailleurs", "",_statement,{true},{},[_ship, _targetName]] call ace_interact_menu_fnc_createAction;
		[(_ship getVariable format ["GSRI_FREMM_submarine_%1",_x]), 0, [], _action] call ace_interact_menu_fnc_addActionToObject;
	} forEach ["toSub", "toShip"];
};