#include <sourcemod>
#include <tf2_stocks>


bool deadPlayers[MAXPLAYERS + 1];
ConVar stockEnable;

public Plugin myinfo = {
	name = "[TF2] PasstimeControl",
	author = "EasyE",
	description = "Locks stock weapons",
	version = "1",
	url = "xd"
}

public void OnPluginStart() {
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("post_inventory_application", Event_PlayerResup, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	AddCommandListener(OnChangeClass, "joinclass");
	stockEnable = CreateConVar("sm_passtime_whitelist", "0", "Enables/Disables passtime stock weapon locking and fixed respawn time");
}

public void OnClientDisconnect(int client) {
	deadPlayers[client] = false;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"))
	deadPlayers[client] = true;
}


public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"))
	deadPlayers[client] = false;
	RemoveShotty(client);
}

public Action Event_PlayerResup(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"))
	RemoveShotty(client);
}

public Action OnChangeClass(int client, const char[] strCommand, int args) {
    if(deadPlayers[client] == true && stockEnable.BoolValue) {
        PrintCenterText(client, "You can't change class yet.");
        return Plugin_Handled;
    }
        
    return Plugin_Continue;
}


public void RemoveShotty(int client) {
	if(stockEnable.BoolValue) {
		TFClassType class = TF2_GetPlayerClass(client);
		int iWep;
		if (class == TFClass_DemoMan || class == TFClass_Soldier) iWep = GetPlayerWeaponSlot(client, 1)
		else if (class == TFClass_Medic) iWep = GetPlayerWeaponSlot(client, 0);
		if(iWep >= 0) {
			char classname[64];
			GetEntityClassname(iWep, classname, sizeof(classname));
			if (StrEqual(classname, "tf_weapon_shotgun_soldier") || StrEqual(classname, "tf_weapon_pipebomblauncher")) {
				PrintToChat(client, "\x07ff0000 [PASS] Shotgun/Stickies equipped");
				TF2_RemoveWeaponSlot(client, 1);
			}
			if (StrEqual(classname, "tf_weapon_syringegun_medic")) {
				PrintToChat(client, "\x07ff0000 [PASS] Syringe Gun equipped");
				TF2_RemoveWeaponSlot(client, 0);
			}
		}
	}
}