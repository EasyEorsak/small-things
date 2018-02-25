#include <sourcemod>
#include <tf2_stocks>

bool blueOffclassing = false;
bool redOffclassing = false;

public Plugin myinfo = {
	name = "[TF2] Offclass-Locker",
	author = "EasyE",
	description = "Prevents pyro/heavy/engi being used when your teams 2nd point has not been captured",
	version = "0.1",
	url = "http://steamcommunity.com/id/eeeasye/"
}

public void OnPluginStart() {
	HookEvent("teamplay_point_captured", Event_PointCaptured, EventHookMode_Post);
	HookEvent("player_changeclass", Event_ChangeClass, EventHookMode_Pre);
	HookEvent("teamplay_round_start", Event_RoundStart, EventHookMode_Post);
}

public Action Event_PointCaptured(Event event, const char[] name, bool dontBroadcast) {
	int cp = event.GetInt("cp")
	switch (cp) {
		case 0: {
			blueOffclassing = false;
			redOffclassing = false;
		}
		case 1: {
			blueOffclassing = true;
		}
		case 2: {
			blueOffclassing = false;
			redOffclassing = false;
		}
		case 3: {
			redOffclassing = true;
		}
		case 4: {
			blueOffclassing = false;
			redOffclassing = false;
		}
	}
}

public Action Event_ChangeClass(Event event, const char[] name, bool dontBroadcast) {
	int id = event.GetInt("userid");
	int client = GetClientOfUserId(id);
	int class = event.GetInt("class");
	TFClassType currentClass = TF2_GetPlayerClass(client);
	TFTeam team = TF2_GetClientTeam(client);
	if (team == TFTeam_Blue) {
		if (!blueOffclassing) {
			if (class == 7 || class == 6 || class == 9) {
				TF2_SetPlayerClass(client, currentClass);
				return Plugin_Handled;
			}
		}
	}
	else if (team == TFTeam_Red) {
		if (!redOffclassing) {
			if (class == 7 || class == 6 || class == 9) {
				TF2_SetPlayerClass(client, currentClass);
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Handled;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	bool full_reset = event.GetBool("full_reset");
	if (full_reset)PrintToChatAll("yes");
	else PrintToChatAll("no");
}