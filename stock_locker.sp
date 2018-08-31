#include <sourcemod>
#include <tf2_stocks>


ConVar stockEnable;
public Plugin myinfo = {
	name = "[PASS] Stock-Lock",
	author = "EasyE",
	description = "Locks stock weapons",
	version = "1",
	url = "xd"
}

public void OnPluginStart() {
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("post_inventory_application", Event_PlayerResup, EventHookMode_Post);
	stockEnable = CreateConVar("sm_passtime_whitelist", "0", "Enables/Disables passtime stock weapon locking");
}


public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"))
	RemoveShotty(client);
}

public Action Event_PlayerResup(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"))
	RemoveShotty(client);
}

public void RemoveShotty(int client) {
	if(stockEnable.BoolValue) {
		int iWep = GetPlayerWeaponSlot(client, 1)
		if(iWep >= 0) {
			char classname[64];
			GetEntityClassname(iWep, classname, sizeof(classname));
			if (strcmp(classname, "tf_weapon_shotgun_soldier") || strcmp(classname, "tf_weapon_pipebomblauncher")) {
				PrintToChat(client, "\x07ff0000 [PASS] Shotgun/Stickies equipped");
				TF2_RemoveWeaponSlot(client, 1);
			}
		}
	}
}