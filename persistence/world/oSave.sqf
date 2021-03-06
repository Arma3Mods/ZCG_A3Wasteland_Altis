//	@file Version: 1.2
//	@file Name: oSave.sqf
//	@file Author: [GoT] JoSchaap, AgentRev
//	@file Description: Basesaving script

if (!isServer) exitWith {};

diag_log "oSave started";

countStrChars = {
	count (toArray _this);
} call mf_compile;

_baseQuery = "INSERT INTO objects (SequenceNumber, Name, Position, Direction, SupplyLeft, Weapons, Magazines, Items, IsVehicle, IsSaved, GenerationCount, Owner, Damage, AllowDamage, Texture, AttachedObjects) VALUES ";

while {true} do {
	sleep 30;
	
	waitUntil {!isLoadingObjects};
	
	_trigger = "DoSave" call sqlite_getTrigger;
	
	if (_trigger == 1) then {
		//remove all AI from the mission to speed up the server when saving (since we only need to save before restart with no players on anyways)
		{
			deleteVehicle _x;
		} forEach (allMissionObjects "CAManBase");
		
		_PersistentDB_ObjCount = 1;
		
		_saveQuery = _baseQuery;
		
		{
			_object = _x;
			
			if (_object getVariable ["objectLocked", false] && {alive _object}) then
			{
				_classname = typeOf _object;
				
				// addition to check if the classname matches the building parts
				// if ({_classname == _x} count _saveableObjects > 0) then
				// {
					_pos = getPosATL _object;
					_dir = [vectorDir _object] + [vectorUp _object];

					_supplyleft = 0;

					switch (true) do
					{
						case (_object isKindOf "Land_Sacks_goods_F"):
						{
							_supplyleft = _object getVariable ["food", 20];
						};
						case (_object isKindOf "Land_BarrelWater_F"):
						{ 
							_supplyleft = _object getVariable ["water", 20];
						};
					};
					
					_owner = _object getVariable ["ownerUID", ""];
					_damage = damage _object;
					_allowDamage = if (_object getVariable ["allowDamage", true]) then { 1 } else { 0 };

					// Save weapons & ammo
					_weapons = getWeaponCargo _object;
					_magazines = getMagazineCargo _object;
					_items = getItemCargo _object;
					_isVehicle = 0;
					_texture = _object getVariable ["Texture", ""];
					_attachedObjects = [];
					
					if (_object isKindOf "Car" || _object isKindOf "Air" || _object isKindOf "Ship" || _object isKindOf "Tank" ) then
					{
						_isVehicle = 1;
						
						{
							_attObj = _x;
							_attDir = _attObj getVariable [ "AttachDirection", [] ];
							
							if (!(isNil "_attDir") && (count _attDir > 0)) then
							{
								_attachedObjects set [count _attachedObjects, [ (typeOf _attObj), _attDir, (_object worldToModel (getPosATL _attObj)) ]];
							};
							
						} forEach (attachedObjects _object);
					};
					
					_addQuery = format ["(%1, ''%2'', ''%3'', ''%4'', %5, ''%6'', ''%7'', ''%8'', %9, 0, %10, ''%11'', %12, %13, ''%14'', ''%15''),", _PersistentDB_ObjCount, _classname, _pos, _dir, _supplyleft, _weapons, _magazines, _items, _isvehicle, _object getVariable ["generationCount", 0], _owner, _damage, _allowDamage, _texture, _attachedObjects];
					
					
					
					_PersistentDB_ObjCount = _PersistentDB_ObjCount + 1;
					
					//Save in batches so we don't hit the max 4000 char arma2net string length limit
					if ((_saveQuery call countStrChars) + (_addQuery call countStrChars) > 4000) then { 
						_saveQuery call sqlite_saveBaseObjects;
						
						_saveQuery = _baseQuery;
					};
					
					_saveQuery = _saveQuery + _addQuery;
				// };
			};
		}forEach (allMissionObjects "All");
		
		if ((_saveQuery call countStrChars) > (_baseQuery call countStrChars)) then {
			_saveQuery call sqlite_saveBaseObjects;
			
			diag_log format["A3Wasteland - %1 parts have been saved with DB", _PersistentDB_ObjCount];
		};
		
		call sqlite_commitBaseObject;
		
		_handle = [] execVM "persistence\world\oSaveBounties.sqf"; 
		waitUntil {sleep 0.1;scriptDone _handle};
		
		"DoSave" call sqlite_setTrigger;
	};
};
