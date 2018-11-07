#include <sourcemod>
#include <tf2_stocks>

#pragma newdecls required
#pragma semicolon 1

#define PLUGIN_VERSION "1.0"

Menu rolloutMenu;
Menu setJumpsMenu;
Menu jumpsMenu;
Menu optionsMenu;


float fJumpVelocity[3];
float fJumpLocation[MAXPLAYERS + 1][5][3];
float fJumpAngles[MAXPLAYERS + 1][5][3];

int iJumpHealth = 200;
int iJumpAmmo = 4;
int iJumpReserveAmmo = 20;

bool bJumpEnabled[5];
int bRetainAngle = true;
int bRetainVelocity = false;


public Plugin myinfo = {
	name = "[TF2] Name-Placeholder",
	author = "EasyE",
	description = "Plugin to make practicing jumps easier",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/eeeasye/"
}

public void OnPluginStart() {
	//client commands
	
	//RegConsoleCmd("sm_test", TEST, "test");
	RegConsoleCmd("sm_sj", Command_SetJump, "Set's the teleport slot to the players current location");
	RegConsoleCmd("sm_jumpmenu", Command_Rollout, "Opens the jump menu");
	RegConsoleCmd("sm_jm", Command_Rollout, "Opens the jump menu");
	RegConsoleCmd("sm_jump", Command_GotoJump, "Goes to the teleport slot and sets your health/ammo");
	RegConsoleCmd("sm_jh", Command_JumpHealth, "Set's the amount of health for jumps (default 200, set to 0 to disable)");
	RegConsoleCmd("sm_ja", Command_JumpAmmo, "Set's the amount of ammo for jumps(default 4, set to 0 to disable)");
	RegConsoleCmd("sm_jr", Command_JumpReserve, "Set's the amount of reserve ammo for jumps(default 20, set to 0 to disable)");
	RegConsoleCmd("sm_ra", Command_RetainAngle, "Disable/enable angle retaining when teleporting to jump");
	RegConsoleCmd("sm_rv", Command_RetainVelocity, "Disable/enable velocity retaining when teleporting to jump");
	//RegConsoleCmd("sm_test", TEST, "");
	//Menus
	
	rolloutMenu = new Menu(RolloutMenuHandler);
	rolloutMenu.SetTitle("rollout menu");
	rolloutMenu.AddItem("setjumps", "Set Jumps");
	rolloutMenu.AddItem("gotojumps", "Goto Jumps");
	rolloutMenu.AddItem("jumpoptions", "Jump Options");
	
	setJumpsMenu = new Menu(SetJumpsMenuHandler);
	setJumpsMenu.SetTitle("Set jump locations");
	setJumpsMenu.AddItem("1", "Set jump 1");
	setJumpsMenu.AddItem("2", "Set jump 2");
	setJumpsMenu.AddItem("3", "Set jump 3");
	setJumpsMenu.AddItem("4", "Set jump 4");
	setJumpsMenu.AddItem("5", "Set jump 5");
	SetMenuExitBackButton(setJumpsMenu, true);
	
	jumpsMenu = new Menu(JumpsMenuHandler);
	jumpsMenu.SetTitle("Goto jump locations");
	jumpsMenu.AddItem("1", "Goto jump 1");
	jumpsMenu.AddItem("2", "Goto jump 2");
	jumpsMenu.AddItem("3", "Goto jump 3");
	jumpsMenu.AddItem("4", "Goto jump 4");
	jumpsMenu.AddItem("5", "Goto jump 5");
	SetMenuExitBackButton(jumpsMenu, true);
	
	optionsMenu = new Menu(JumpOptionsMenuHandler);
	optionsMenu.SetTitle("Jump options");
	optionsMenuBuilder();
	
}

public void OnMapStart() {
	for (int i = 0; i < 5; i++) {
		bJumpEnabled[i] = false;
	}
}

 /***************************\
	   COMMAND CALLBACKS	  
 \***************************/


public Action TEST(int client, int args) {
	SetEntProp(client, Prop_Data, "m_iAmmo", 66, 4, 0);
	SetEntProp(client, Prop_Data, "m_iAmmo", 67, 4, 1);
	SetEntProp(client, Prop_Data, "m_iAmmo", 68, 4, 2);
	SetEntProp(client, Prop_Data, "m_iAmmo", 69, 4, 3);
}
public Action Command_SetJump(int client, int args) {
	if (!IsValidClient(client))return Plugin_Handled;
	char arg1[32];
	if (args >= 1 && GetCmdArg(1, arg1, sizeof(arg1))) {
		int index = StringToInt(arg1);
		if (index > 0 && index < 6) {
			PrintToChat(client, "[placeholder] Jump %d set", index);
			index--;
			GetClientAbsOrigin(client, fJumpLocation[client][index]);
			bJumpEnabled[index] = true;
			GetClientAbsAngles(client, fJumpAngles[client][index]);
		}
		else {
			PrintToChat(client, "[placeholder] Usage: !setjump 1-5");
		}
	}
	else {
		PrintToChat(client, "[placeholder] Usage: !setjump 1-5");
	}
	return Plugin_Handled;
}

public Action Command_GotoJump(int client, int args) {
	if (!IsValidClient(client))return Plugin_Handled;
	char arg1[32];
	if (args >= 1 && GetCmdArg(1, arg1, sizeof(arg1))) {
		int index = StringToInt(arg1);
		if (index > 0 && index < 6) {
			index--;
			if (bJumpEnabled[index] != true) {
				PrintToChat(client, "[placeholder] Jump not set");
				return Plugin_Handled;
			}
			TeleportEntity(client, fJumpLocation[client][index], NULL_VECTOR, NULL_VECTOR);
			if (!bRetainAngle) TeleportEntity(client, NULL_VECTOR, fJumpAngles[client][index], NULL_VECTOR);
			if (!bRetainVelocity) TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fJumpVelocity);
			if (iJumpHealth != 0) SetEntityHealth(client, iJumpHealth);
			if (iJumpAmmo != 0) {
				int weapon;
				if (TF2_GetPlayerClass(client) == TFClass_Soldier)
					weapon = GetPlayerWeaponSlot(client, 0);
				else if (TF2_GetPlayerClass(client) == TFClass_DemoMan)
					weapon = GetPlayerWeaponSlot(client, 1);
				else {
					PrintToChat(client, "[placeholder] Invalid class, can not regen ammo");
					return Plugin_Handled;
				}
				int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
				SetEntData(weapon, iAmmoTable, iJumpAmmo, 4, true);
				int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
				int iAmmoTable2 = FindSendPropInfo("CTFPlayer", "m_iAmmo");
				SetEntData(client, iAmmoTable2+iOffset, iJumpReserveAmmo, 4, true);
			}
		}
		else {
			PrintToChat(client, "[placeholder] Usage: !gotojump 1-5");
		}
	}
	return Plugin_Handled;
}

public Action Command_JumpHealth(int client, int args) {
	char arg1[32];
	if (args >= 1 && GetCmdArg(1, arg1, sizeof(arg1))) {
		int health = StringToInt(arg1);
		if (health > 0) {
			iJumpHealth = health;
			PrintToChat(client, "[placeholder] Jump health has been set to %d", health);
		}
		else if (health == 0) {
			PrintToChat(client, "[placeholder] Health regen disabled");
		}
		else {
			PrintToChat(client, "[placeholder] Usage: !jumphealth <value>");
		}
	}
	else {
		PrintToChat(client, "[placeholder] Usage: !jumphealth <value> (0 to disable)");
	}
	return Plugin_Handled;
}

public Action Command_JumpAmmo(int client, int args) {
	char arg1[32];
	if (args >= 1 && GetCmdArg(1, arg1, sizeof(arg1))) {
		int ammo = StringToInt(arg1);
		if (ammo > 0) {
			iJumpAmmo = ammo;
			PrintToChat(client, "[placeholder] Jump ammo has been set to %d", ammo);
		}
		else if (ammo == 0 ) {
			iJumpAmmo = ammo;
			PrintToChat(client, "[placeholder] Ammo regen has been disabled");
		}
		else {
			PrintToChat(client, "[placeholder] Usage: !jumpammmo <value> (0 to disable)");
		}
	}
	else {
		PrintToChat(client, "[placeholder] Usage: !jumpammmo <value> (0 to disable)");
	}
	return Plugin_Handled;
}

public Action Command_JumpReserve(int client, int args) {
	char arg1[32];
	if (args >= 1 && GetCmdArg(1, arg1, sizeof(arg1))) {
		int ammo = StringToInt(arg1);
		if (ammo > 0) {
			iJumpReserveAmmo = ammo;
			PrintToChat(client, "[placeholder] Jump reserve ammo has been set to %d", ammo);
		}
		else if (ammo == 0 ) {
			iJumpReserveAmmo = ammo;
			PrintToChat(client, "[placeholder] Reserve ammo regen has been disabled");
		}
		else {
			PrintToChat(client, "[placeholder] Usage: !jr <value> (0 to disable)");
		}
	}
	else {
		PrintToChat(client, "[placeholder] Usage: !jr <value> (0 to disable)");
	}
	return Plugin_Handled;
}

public Action Command_RetainVelocity(int client, int args) {
	char arg1[32];
	if(args >= 1 && GetCmdArg(1, arg1, sizeof(arg1))) {
		int value = StringToInt(arg1);
		if(value >= 0) {
			bRetainVelocity = value;
			if (value)PrintToChat(client, "[placeholder] Retaining velocity has been enabled");
			else PrintToChat(client, "[placeholder] Retaining velocity has been disabled");
		}
		else {
			PrintToChat(client, "[placeholder] Usage: !retainvelocity 1/0");
		}
	}
	else {
		if (bRetainVelocity) {
			bRetainVelocity = false;
			PrintToChat(client, "[placeholder] Retaining velocity has been disabled");
		}
		else {
			bRetainVelocity = true;
			PrintToChat(client, "[placeholder] Retaining velocity has been enabled");
		}
	}
	optionsMenuBuilder();
	return Plugin_Handled;
}

public Action Command_RetainAngle(int client, int args) {
	char arg1[32];
	if(args >= 1 && GetCmdArg(1, arg1, sizeof(arg1))) {
		int value = StringToInt(arg1);
		if(value >= 0) {
			bRetainAngle = value;
			if (value)PrintToChat(client, "[placeholder] Retaining angles has been enabled");
			else PrintToChat(client, "[placeholder] Retaining angles has been disabled");
		}
		else {
			PrintToChat(client, "[placeholder] Usage: !retainangle 1/0");
		}
	}
	else {
		if (bRetainAngle) {
			bRetainAngle = false;
			PrintToChat(client, "[placeholder] Retaining angles has been disabled");
		}
		else {
			bRetainAngle = true;
			PrintToChat(client, "[placeholder] Retaining angles has been enabled");
		}
	}
	optionsMenuBuilder();
	return Plugin_Handled;
}

public Action Command_Rollout(int client, int args) {
	if (!IsValidClient(client))return Plugin_Handled;
	rolloutMenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}


/***************************\
		MENU HANDLERS		  
\***************************/


public int RolloutMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32];
		rolloutMenu.GetItem(param2, info, sizeof(info));
		if (StrEqual(info, "setjumps")) {
			setJumpsMenu.Display(param1, MENU_TIME_FOREVER);
		}
		if (StrEqual(info, "gotojumps")) {
			jumpsMenu.Display(param1, MENU_TIME_FOREVER);
		}
		if (StrEqual(info, "jumpoptions")) {
			optionsMenu.Display(param1, MENU_TIME_FOREVER);
		}
	}
	
}

public int SetJumpsMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32];
		setJumpsMenu.GetItem(param2, info, sizeof(info));
		if(!StringToInt(info)) {
			
		}
		else {
			int i = StringToInt(info);
			FakeClientCommand(param1, "sm_sj %d", i);
		}
		setJumpsMenu.Display(param1, MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
		rolloutMenu.Display(param1, MENU_TIME_FOREVER);
}

public int JumpsMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32];
		jumpsMenu.GetItem(param2, info, sizeof(info));
		if(!StringToInt(info)) {
			
		}
		else {
			int i = StringToInt(info);
			FakeClientCommand(param1, "sm_jump %d", i);
		}
		jumpsMenu.Display(param1, MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
		rolloutMenu.Display(param1, MENU_TIME_FOREVER);
}

public int JumpOptionsMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		char info[32];
		optionsMenu.GetItem(param2, info, sizeof(info));
		if (StrEqual(info, "ra")) {
			FakeClientCommand(param1, "sm_ra");
			optionsMenu.Display(param1, MENU_TIME_FOREVER);
		}
		if (StrEqual(info, "rv")) {
			FakeClientCommand(param1, "sm_rv");
			optionsMenu.Display(param1, MENU_TIME_FOREVER);
		}
	}
}


/***************************\
		  FUNCTIONS		     
\***************************/


public void optionsMenuBuilder() {
	optionsMenu.RemoveAllItems();
	char rvString[64], raString[64];
	Format(raString, sizeof(raString), "Retain angles: %s", bRetainAngle ? "Enabled" : "Disabled");
	Format(rvString, sizeof(rvString), "Retain velocity: %s", bRetainVelocity ? "Enabled" : "Disabled");
	optionsMenu.AddItem("ra", raString);
	optionsMenu.AddItem("rv", rvString);
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
