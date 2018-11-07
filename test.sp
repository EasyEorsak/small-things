#include <sourcemod>
#include <sdktools>


Menu jackMenu;
Menu setJackMenu;
Menu teleJackMenu;

float jackLocations[5][3];
//float jackTop[3] =  {0.000000, 0.000000, 1437.308959};
//float jackBottom[3] =  { 0.000000, -0.000122, -174.007003 };


public void OnPluginStart() {
	RegAdminCmd("sm_jack", Command_JackMenu, ADMFLAG_GENERIC);
	RegAdminCmd("sm_setjack", Command_SetJack, ADMFLAG_GENERIC);
	RegAdminCmd("sm_telejack", Command_TeleJack, ADMFLAG_GENERIC);
	RegAdminCmd("sm_givejack", Command_GiveJack, ADMFLAG_GENERIC);
	RegAdminCmd("sm_test", test, ADMFLAG_GENERIC);
	HookEvent("teamplay_broadcast_audio", hook, EventHookMode_Post);
	jackMenu = new Menu(JackMenuHandler);
	jackMenu.SetTitle("rollout menu");
	jackMenu.AddItem("setjack", "Set jack telepoint");
	jackMenu.AddItem("telejack", "Telejack");
	
	setJackMenu = new Menu(SetJackMenuHandler);
	setJackMenu.SetTitle("Set Telepoint Locations");
	setJackMenu.AddItem("1", "Set telepoint 1");
	setJackMenu.AddItem("2", "Set telepoint 2");
	setJackMenu.AddItem("3", "Set telepoint 3");
	setJackMenu.AddItem("4", "Set telepoint 4");
	setJackMenu.AddItem("5", "Set telepoint 5");
	SetMenuExitBackButton(setJackMenu, true);
	
	teleJackMenu = new Menu(TeleJackMenuHandler);
	teleJackMenu.SetTitle("Teleport Jack");
	teleJackMenu.AddItem("1", "Telejack 1");
	teleJackMenu.AddItem("2", "Telejack 2");
	teleJackMenu.AddItem("3", "telejack 3");
	teleJackMenu.AddItem("4", "telejack 4");
	teleJackMenu.AddItem("5", "telejack 5");
	SetMenuExitBackButton(teleJackMenu, true);
}


public Action hook(Event event, char[] name, bool dontBroadcast) {
	char string[64];
	event.GetString("sound", string, sizeof(string));
	//if(StrEqual(string, "Merasmus.RoundBegins5seconds")) {
	//	CreateTimer(5.0, getball);
	//}
}

/*public Action getball(Handle timer) {
	PrintToChatAll("Jack timer started");
	int ent = FindEntityByClassname(-1, "passtime_ball");
	int offset = FindDataMapInfo(ent, "m_vecAbsOrigin");
	float jackVec[3];
	GetEntDataVector(ent, offset, jackVec);
	PrintToChatAll("%f, %f, %f", jackVec[0], jackVec[1], jackVec[2]);
}*/
 /***************************\
	   COMMAND CALLBACKS	  
 \***************************/
 
 
 public Action test(int client, int args) {
 	CreateTimer(1.0, BallTimer, _, TIMER_REPEAT);
 }
 public Action Command_SetJack(int client, int args) {
 	char arg1[32];
 	if (args >= 1 && GetCmdArg(1, arg1, sizeof(arg1))) {
 		int n = StringToInt(arg1);
 		if (n < 1 || n > 5) { 
 			PrintToChat(client, "[JACK] Enter a number 1-5");
 			return Plugin_Handled;
 		}
 		GetClientAbsOrigin(client, jackLocations[n]);
 		PrintToChat(client, "[JACK] Jack location %d set", n);
 	}
 	return Plugin_Handled;
 }
 
 public Action Command_TeleJack(int client, int args) {
 	char arg1[32];
 	if (args >= 1 && GetCmdArg(1, arg1, sizeof(arg1))) {
 		int n = StringToInt(arg1);
 		if (n < 1 || n > 5) {
 			PrintToChat(client, "[JACK] Enter a number 1-5");
 			return Plugin_Handled;
 		}
 		int ent = FindEntityByClassname(-1, "passtime_ball");
 		TeleportEntity(ent, jackLocations[n], NULL_VECTOR, NULL_VECTOR);
 	}
 	return Plugin_Handled;
 }
 
public Action Command_GiveJack(int client, int args) {
	if (!IsValidClient(client))return Plugin_Handled;
	float vec[3];
	GetClientAbsOrigin(client, vec);
	int ent = FindEntityByClassname(-1, "passtime_ball");
	PrintToChatAll("passtime entity index %d", ent);
	if(!IsValidEntity(ent)) {
		PrintToChatAll("invalid ent");
		return Plugin_Handled;
	}
	TeleportEntity(ent, vec, NULL_VECTOR, NULL_VECTOR);
	return Plugin_Handled;
}

public Action Command_JackMenu(int client, int args) {
	if (!IsValidClient(client))return Plugin_Handled;
	jackMenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}


/***************************\
		MENU HANDLERS		  
\***************************/


public int JackMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32];
		menu.GetItem(param2, info, sizeof(info));
		if(StrEqual(info, "setjack")) {
			setJackMenu.Display(param1, MENU_TIME_FOREVER);
		}
		if(StrEqual(info, "telejack")) {
			teleJackMenu.Display(param1, MENU_TIME_FOREVER);
		}
	}
}

public int SetJackMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32];
		menu.GetItem(param2, info, sizeof(info));
		int n = StringToInt(info);
		FakeClientCommand(param1, "sm_setjack %d", n);
		menu.Display(param1, MENU_TIME_FOREVER);
	}
}

public int TeleJackMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32];
		menu.GetItem(param2, info, sizeof(info));
		int n = StringToInt(info);
		FakeClientCommand(param1, "sm_telejack %d", n);
		menu.Display(param1, MENU_TIME_FOREVER);
	}
}

public Action BallTimer(Handle timer) {
	static int nPrinted = 5;
	int ent = FindEntityByClassname(-1, "tf_gamerules");
	if (nPrinted == 0) {
		EmitGameSoundToAll("Passtime.BallSpawn", ent);
		nPrinted = 5;
		return Plugin_Stop;
	}
	char sound[64];
	Format(sound, sizeof(sound), "Announcer.RoundBegins%seconds", nPrinted);
	EmitGameSoundToAll(sound, ent);
	nPrinted--;
	return Plugin_Continue;
}
//yo shoutout to TheXeon for giving me this snippet like 2 years ago
public bool IsValidClient(int client) {
	if (client > 4096) client = EntRefToEntIndex(client);
	if (client < 1 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	if (IsFakeClient(client)) return false;
	if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	return true;
}