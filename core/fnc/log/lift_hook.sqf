
private ["_chopper","_array","_cargo_array","_cargo","_bbr","_rope_length"];

_chopper = vehicle player;
_array = [vehicle player] call btc_fnc_log_get_liftable;
_cargo_array = nearestObjects [_chopper, _array, 30];
_cargo_array = _cargo_array - [_chopper];
if (count _cargo_array > 0 && ((_cargo_array select 0) isKindOf "ACE_friesGantry") OR (typeof (_cargo_array select 0) isEqualTo "ACE_friesAnchorBar")) then {_cargo_array deleteAt 0;};
if (count _cargo_array > 0) then {_cargo = _cargo_array select 0;} else {_cargo = objNull;};
if (isNull _cargo) exitWith {};

if (!Alive _cargo) exitWith {_cargo spawn btc_fnc_log_lift_hook_fake;};

private ["_rope","_max_cargo","_mass"];

{ropeDestroy _x;} foreach ropes _chopper;

_bbr = getArray (configfile >> "CfgVehicles" >> typeof _cargo >> "slingLoadCargoMemoryPoints");
if (_bbr isEqualTo [] OR !(vehicle player canSlingLoad _cargo)) then {

	_bbr = boundingBoxReal _cargo;
	if (abs((_bbr select 0) select 0) < 5) then {
		_rope_length = 10;
	} else {
		_rope_length = 10 + abs((_bbr select 0) select 0);
	};

	ropeCreate [vehicle player, "slingload0", _cargo, [((_bbr select 0) select 0), ((_bbr select 1) select 1), 0], _rope_length];
	ropeCreate [vehicle player, "slingload0", _cargo, [((_bbr select 0) select 0), ((_bbr select 0) select 1), 0], _rope_length];
	ropeCreate [vehicle player, "slingload0", _cargo, [((_bbr select 1) select 0), ((_bbr select 0) select 1), 0], _rope_length];
	ropeCreate [vehicle player, "slingload0", _cargo, [((_bbr select 1) select 0), ((_bbr select 1) select 1), 0], _rope_length];
} else {
	{
		ropeCreate [vehicle player, "slingload0", _cargo, _x, 11];
	} forEach _bbr;
};

if (btc_debug) then {hint str(_bbr);};

_max_cargo  = getNumber (configFile >> "cfgVehicles" >> typeof _chopper >> "slingLoadMaxCargoMass");
_mass = getMass _cargo;

if !(local _cargo) then {
	[[_cargo, player],{(_this select 0) setOwner owner (_this select 1);}] remoteExec ["call", 2];
	waitUntil {local _cargo};
};

if ((_mass + 400) > _max_cargo) then {
	private "_new_mass";
	_cargo setVariable ["mass",_mass];
	_new_mass = (_max_cargo - 1000);
	if (_new_mass < 0) then {_new_mass = 50;};
	_cargo setMass _new_mass;
	//if (local _cargo) then {_cargo setMass _new_mass;} else {[[_cargo,_new_mass],"btc_fnc_log_set_mass",_cargo] spawn BIS_fnc_MP;};
};

(vehicle player) setVariable ["cargo",_cargo];

btc_lifted = true;

waitUntil {sleep 5; (!Alive player || !Alive _cargo || !btc_lifted || vehicle player == player)};

//if (local _cargo) then {_cargo setMass _mass;} else {[[_cargo,_mass],"btc_fnc_log_set_mass",_cargo] spawn BIS_fnc_MP;};
_cargo setMass _mass;