#include <sourcemod>
#include <tf2_stocks>


#define PATH_TO_FILE "stock_whitelist.txt"
public Plugin myinfo = {
	name = "[PASS] Stock-Lock",
	author = "EasyE",
	description = "Locks stock weapons",
	version = "1",
	url = "xd"
}

public void OnPluginStart() {
	ConfigLoader()
}

public void ConfigLoader() {
	PrintToServer("STARTED");
	KeyValues kv = new KeyValues("stock_whitelist");
	kv.ImportFromFile(PATH_TO_FILE);
	//if(!kv.GotoNextKey()) {
		//PrintToServer("STOPPED");
		//delete kv;
	//}
	kv.GotoFirstSubKey();
	kv.GotoNextKey();
	char section[32];
	kv.GetSectionName(section, sizeof(section));
	PrintToServer("sect? %s", section);
}