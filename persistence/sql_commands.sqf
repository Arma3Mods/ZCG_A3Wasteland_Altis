//MySQL queries for persistence
//Author: Panaetius
//Date: 15.03.2014

if(!isServer) exitWith {};

sqlite_savePlayer = {
	private ["_array", "_uid", "_varValue", "_res", "_query"];
	_array = _this;	
	_uid = _array select 0;
	
	_varValue = _array select 1;
	
	//delete stuff
	_query = format ["START TRANSACTION;Delete FROM player WHERE Id=''%1'';Delete FROM item WHERE PlayerId=''%1'';", _uid];
	// save values
	_query = _query + format ["INSERT INTO player (Id,Health,Side,AccountName, Money, Vest, Uniform, Backpack, Goggles, HeadGear,Position, Direction, PrimaryWeapon, SecondaryWeapon, HandgunWeapon,Hunger,Thirst) VALUES (''%1'', %2, ''%3'', ''%4'', %5, ''%6'', ''%7'', ''%8'', ''%9'', ''%10'', ''%11'', %12, ''%13'', ''%14'', ''%15'',%16,%17);", 
		_uid, 
		_varValue select 0, 
		_varValue select 1, 
		_varValue select 2,
		_varValue select 3,
		_varValue select 4,
		_varValue select 5,
		_varValue select 6,
		_varValue select 7,
		_varValue select 8,
		_varValue select 9,
		_varValue select 10,
		_varValue select 11,
		_varValue select 12,
		_varValue select 13,
		_varValue select 15,
		_varValue select 16
		];
	
	_query = _query + "INSERT INTO item (PlayerId, Type, Name) Values ";
	
	{
		_query = _query + format ["('%1', '%2', ''%3''),", _uid, _x select 0, _x select 1];
	}forEach (_varValue select 14);
		
	_query = [_query, ([_query] call KRON_StrLen) - 1] call KRON_StrLeft;
	
	_query = _query + ";COMMIT;";
	
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', '%1']", _query, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
} call mf_compile;

sqlite_readPlayer = {
	private ["_array", "_uid", "_data", "_player", "_query", "_items"];
	_uid = _this;
	
	_query = format ["SELECT * FROM player WHERE Id=''%1'' LIMIT 1", _uid];
	_player = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', '%1']", _query, A3W_DatabaseName];
	
	_query = format ["SELECT * FROM item WHERE PlayerId=''%1''", _uid];
	_items = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', '%1']", _query, A3W_DatabaseName];
		
	_data = ((call compile _player) select 0) select 0;
	_data set [count _data, (call compile _items) select 0];
	
	_data
} call mf_compile;

sqlite_deletePlayer = {
	private "_res";
	_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', 'Delete FROM player WHERE Id=''%1'';Delete FROM Item WHERE PlayerId=''%1'';']", _this, A3W_DatabaseName];
	
	true
} call mf_compile;

sqlite_exists = {
	private ["_player", "_query"];
	_query = format ["SELECT Id FROM player WHERE Id=''%1'' LIMIT 1", _this];
	_player = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', '%1']", _query, A3W_DatabaseName];
	
	if (count ((call compile _player) select 0) > 0 ) then 
	{
		true
	} else {
		false
	};
} call mf_compile;

sqlite_deleteBaseObjects = {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%1', 'DELETE FROM objects;']", A3W_DatabaseName];
} call mf_compile;

sqlite_saveBaseObjects = {
	private ["_query", "_res"];
	_query = _this;
	_query = [_query, ([_query] call KRON_StrLen) - 1] call KRON_StrLeft;
	_query = "START TRANSACTION;" + _query + ";COMMIT;";
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommandAsync ['%2', '%1']", _query, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
} call mf_compile;

sqlite_commitBaseObject = {
	private ["_res"];
	
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%1', 'START TRANSACTION;DELETE FROM Objects WHERE IsSaved=1;COMMIT;START TRANSACTION;UPDATE Objects SET IsSaved=1 WHERE IsSaved=0;COMMIT;START TRANSACTION;DELETE FROM objects WHERE Id IN (SELECT * FROM (SELECT DISTINCT o1.Id FROM objects o1 INNER JOIN objects o2 ON o2.Id < o1.Id AND o2.Position = o1.Position AND o2.Name = o1.Name AND o2.issaved = 1 AND o1.IsSaved = 1) as a);COMMIT;']", A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
} call mf_compile;

sqlite_deleteUncommitedObjects = {
	private ["_res"];
	
	_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%1', 'DELETE FROM objects WHERE IsSaved=0 OR GenerationCount > 9;']", A3W_DatabaseName];
} call mf_compile;

sqlite_countObjects = {
	_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%1', 'SELECT Count(*) FROM Objects']", A3W_DatabaseName];
	_res = parseNumber ((((call compile _res) select 0) select 0) select 0);
	_res
} call mf_compile;

sqlite_loadBaseObjects = {
	private "_res";
	
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%3', 'SELECT * FROM Objects ORDER BY Id ASC LIMIT %1,%2']", _this select 0, _this select 1, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
	_res = ((call compile _res) select 0);
	_res
} call mf_compile;

sqlite_saveBasePart = {
	private ["_query", "_res"];
	_query = _this;
	_query = format ["START TRANSACTION;DELETE FROM objects WHERE IsVehicle=0 AND Name=''%1'' AND Position=''%2'';INSERT INTO Objects (SequenceNumber, Name, Position, Direction, SupplyLeft, Weapons, Magazines, Items, IsVehicle, IsSaved, GenerationCount) VALUES (%3);COMMIT;", _this select 0, _this select 1, _this select 2];
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommandAsync ['%2', '%1']", _query, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
} call mf_compile;

sqlite_unsaveBasePart = {
	private ["_query", "_res"];
	_query = _this;
	_query = format ["START TRANSACTION;DELETE FROM objects WHERE IsVehicle=0 AND Name=''%1'' AND Position=''%2'';COMMIT;", _this select 0, _this select 1];
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommandAsync ['%2', '%1']", _query, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
} call mf_compile;

sqlite_getVehicleSaveQuery = {
	_classname = typeOf _this;
			
	_pos = getPosASL _this;
	_dir = [vectorDir _this] + [vectorUp _this];

	_supplyleft = 0;

	// Save weapons & ammo
	_weapons = getWeaponCargo _this;
	_magazines = getMagazineCargo _this;
	_items = getItemCargo _this;
	
	_isVehicle = 1;
	
	_saveQuery = format ["(%1, ''%2'', ''%3'', ''%4'', %5, ''%6'', ''%7'', ''%8'', %9, 0, %10),", _PersistentDB_ObjCount, _classname, _pos, _dir, _supplyleft, _weapons, _magazines, _items, _isvehicle, _this getVariable ["generationCount", 0]];
	
	_saveQuery
} call mf_compile;

sqlite_createWarchest = {
	private ["_query", "_res", "_warchestData"];
	_warchestData = _this;
	_query = format ["INSERT INTO Warchest (Money, Side, Direction, Position) VALUES (%1, ''%2'', ''%3'', ''%4'');SELECT LAST_INSERT_ID();", _warchestData select 0, _warchestData select 1, _warchestData select 2, _warchestData select 3];
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommandAsync ['%2', '%1']", _query, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
	
	_res = (((call compile _res) select 0) select 0) select 0;
	
	(_warchestData select 4) setVariable ["Id", _res, true];
} call mf_compile;

sqlite_saveWarchest = {
	private ["_query", "_res", "_warchestData"];
	_warchestData = _this;
	_query = format ["UPDATE Warchest SET Money=%2, GenerationCount=0 WHERE Id=%1", _warchestData select 0, _warchestData select 1];
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommandAsync ['%2', '%1']", _query, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
} call mf_compile;

sqlite_deleteWarchest = {
	private ["_query", "_res"];
	_query = format ["DELETE FROM Warchest WHERE Id=%1", _this];
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommandAsync ['%2', '%1']", _query, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
} call mf_compile;

sqlite_countWarchests = {
	_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%1', 'SELECT Count(*) FROM Warchest']", A3W_DatabaseName];
	_res = parseNumber ((((call compile _res) select 0) select 0) select 0);
	_res
} call mf_compile;

sqlite_loadWarchests = {
	private "_res";
	
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%3', 'UPDATE Warchest SET GenerationCount = GenerationCount + 1;DELETE FROM warchest WHERE GenerationCount > 21;SELECT * FROM Warchest WHERE GenerationCount < 22 ORDER BY Id ASC LIMIT %1,%2']", _this select 0, _this select 1, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
	_res = ((call compile _res) select 0);
	_res
} call mf_compile;

sqlite_getTrigger = {
	_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', 'SELECT `Condition` FROM triggers WHERE Name=''%1''']", _this, A3W_DatabaseName];
	_res = parseNumber ((((call compile _res) select 0) select 0) select 0);
	_res
} call mf_compile;

sqlite_setTrigger = {
	_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', 'UPDATE  triggers SET `Condition` = 0 WHERE Name=''%1''']", _this, A3W_DatabaseName];
} call mf_compile;

sqlite_saveBeacon = {
	private ["_query", "_res", "_beacon", "_groupOnly"];
	_beacon = _this;
	_groupOnly = 0;
	
	if(_beacon getVariable ["groupOnly",false]) then
	{
		_groupOnly = 1;
	};	
	
	_haloJump = 0;
	
	if(_beacon getVariable ["haloJump",false]) then
	{
		_haloJump = 1;
	};
	
	_query = format ["INSERT INTO beacon (Side, Direction, Position, OwnerName, OwnerId, GroupOnly, GenerationCount, HaloJump) VALUES (''%1'', ''%2'', ''%3'', ''%4'', %5, %6, 0, %7);SELECT LAST_INSERT_ID();", 
		_beacon getVariable ["side", resistance],
		[vectorDir _beacon] + [vectorUp _beacon],
		getPosATL _beacon,
		_beacon getVariable ["ownerName",""],
		_beacon getVariable ["ownerUID",0],
		_groupOnly,
		_haloJump];
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommandAsync ['%2', '%1']", _query, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
	
	_res = (((call compile _res) select 0) select 0) select 0;
	
	_beacon setVariable ["Id", _res, true];
} call mf_compile;

sqlite_updateBeacon = {
	private ["_query", "_res", "_beacon", "_groupOnly"];
	_beacon = _this;
	
	_groupOnly = 0;
	
	if(_beacon getVariable ["groupOnly",false]) then
	{
		_groupOnly = 1;
	};
	
	_haloJump = 0;
	
	if(_beacon getVariable ["haloJump",false]) then
	{
		_haloJump = 1;
	};
	
	_query = format ["UPDATE beacon SET GroupOnly=%2, GenerationCount=%3, HaloJump=%4 WHERE Id=%1", _beacon getVariable ["Id", -1], _groupOnly, _beacon getVariable ["GenerationCount", 0], _haloJump];
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommandAsync ['%2', '%1']", _query, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
} call mf_compile;

sqlite_deleteBeacon = {
	private ["_query", "_res"];
	_query = format ["DELETE FROM beacon WHERE Id=%1", _this];
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommandAsync ['%2', '%1']", _query, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
} call mf_compile;

sqlite_loadBeacons = {
	private "_res";
	
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%3', 'UPDATE beacon SET GenerationCount = GenerationCount + 1;DELETE FROM beacon WHERE GenerationCount > 9;SELECT * FROM beacon WHERE GenerationCount < 10 ORDER BY Id ASC LIMIT %1,%2']", _this select 0, _this select 1, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
	_res = ((call compile _res) select 0);
	_res
} call mf_compile;

sqlite_countBeacons = {
	_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%1', 'SELECT Count(*) FROM beacon']", A3W_DatabaseName];
	_res = parseNumber ((((call compile _res) select 0) select 0) select 0);
	_res
} call mf_compile;

sqlite_donatorExists = {
	private ["_player", "_query"];
	_query = format ["SELECT PlayerId FROM donators WHERE PlayerId=''%1'' LIMIT 1", _this];
	_player = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', '%1']", _query, A3W_DatabaseName];
	
	if (count ((call compile _player) select 0) > 0 ) then 
	{
		true
	} else {
		false
	};
} call mf_compile;

sqlite_readDonator = {
	private ["_array", "_uid", "_data", "_player", "_query"];
	_uid = _this;
	
	_query = format ["SELECT * FROM donators WHERE PlayerId=''%1'' LIMIT 1", _uid];
	_player = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', '%1']", _query, A3W_DatabaseName];
		
	_data = ((call compile _player) select 0) select 0;
	
	_data
} call mf_compile;

sqlite_deleteBountyBoard = {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%1', 'DELETE FROM bounties;']", A3W_DatabaseName];
} call mf_compile;

sqlite_saveBountyBoard = {
	private ["_query", "_res"];
	_query = _this;
	_query = [_query, ([_query] call KRON_StrLen) - 1] call KRON_StrLeft;
	_query = "START TRANSACTION;" + _query + ";COMMIT;";
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommandAsync ['%2', '%1']", _query, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
} call mf_compile;

sqlite_countBountyBoard = {
	_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%1', 'SELECT Count(*) FROM bounties']", A3W_DatabaseName];
	_res = parseNumber ((((call compile _res) select 0) select 0) select 0);
	_res
} call mf_compile;

sqlite_loadBountyBoard = {
	private "_res";
	
	_res = nil;
	while {isNil("_res")} do {
		_res = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%3', 'SELECT * FROM bounties ORDER BY PlayerId ASC LIMIT %1,%2']", _this select 0, _this select 1, A3W_DatabaseName];
		if (_res == "") then {
                _res = nil;
        };
        sleep 0.5;
	};
	_res = ((call compile _res) select 0);
	_res
} call mf_compile;

KRON_StrLeft = {
	private["_in","_len","_arr","_out"];
	_in=_this select 0;
	_len=(_this select 1)-1;
	_arr=[_in] call KRON_StrToArray;
	_out="";
	if (_len>=(count _arr)) then {
		_out=_in;
	} else {
		for "_i" from 0 to _len do {
			_out=_out + (_arr select _i);
		};
	};
	_out
} call mf_compile;

KRON_StrLen = {
	private["_in","_arr","_len"];
	_in=_this select 0;
	_arr=[_in] call KRON_StrToArray;
	_len=count (_arr);
	_len
} call mf_compile;

KRON_StrToArray = {
	private["_in","_i","_arr","_out"];
	_in=_this select 0;
	_arr = toArray(_in);
	_out=[];
	for "_i" from 0 to (count _arr)-1 do {
		_out=_out+[toString([_arr select _i])];
	};
	_out
} call mf_compile;
