#define PLUGIN_AUTHOR "Vortéx!"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <cstrike>

int salacakct;
int gececekt;
ConVar KlanTagi;
char c_PluginTag[64];
int roundTime;
int currentTime; 

public Plugin myinfo = 
{
	name = "Koruma Hak Salma",
	author = PLUGIN_AUTHOR,
	description = "Korumalar haklarini T'den birine salabilirler!",
	version = PLUGIN_VERSION,
	url = "TurkModders.COM"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_haksal", menuac);
	KlanTagi = CreateConVar("turkmodders_eklenti_taglari", "TurkModders.COM", "Sunucunuzun Adini Giriniz");
	GetConVarString(KlanTagi, c_PluginTag, sizeof(c_PluginTag));
	HookEvent("round_end", bitir);
	HookEvent("round_start", OnRoundStart);
}

public Action OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    roundTime = GetTime();
}


public Action bitir(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(4.0, bitttir);
}

public Action bitttir(Handle timer)
{
	gececekt = 0;
	salacakct = 0;
}

public Action menuac(int client, int args)
{
    currentTime = GetTime();
    
    if (currentTime-roundTime < 30) // ilk 30 saniye icinde
    {
		if(GetClientTeam(client) == 3)
		{
			hakmenu(client);
			salacakct = client;
		}
		else CPrintToChat(client, "{darkred}[%s] {darkblue}!haksal {default}için {darkblue}CT takımında {lime}olmalısınız.", c_PluginTag);
	}
	else CPrintToChat(client, "{darkred}[%s] {orchid}Hak salma {default}yalnızca {orange}ilk 30 saniye {green}gerçekleştirilebilir.", c_PluginTag);
}

public Action:hakmenu(clientId)
{
	new Handle:menu = CreateMenu(MenuCallBack);
	SetMenuTitle(menu, "Korumalığınızı kime salmak istiyorsunuz?");
	char sName[MAX_NAME_LENGTH];
	char sUserId[10];
	for(new i=1;i<=MaxClients;i++)
	{
	    if(IsClientInGame(i) && GetClientTeam(i) == 2)
	    {
	        GetClientName(i, sName, sizeof(sName));
	        IntToString(GetClientUserId(i), sUserId, sizeof(sUserId));
	        AddMenuItem(menu, sUserId, sName);
	    }
	}  
   
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, clientId, MENU_TIME_FOREVER);
	return Plugin_Handled; 
}

public MenuCallBack(Handle:menu, MenuAction:action, client, itemNum)
{
    if ( action == MenuAction_Select )
    {
		new String:info[32];
		GetMenuItem(menu, itemNum, info, sizeof(info));
		GetClientOfUserId(StringToInt(info));
		int target = GetClientOfUserId(StringToInt(info));
		gececekt = target;
		evethayir(target);
	}
}


public Action:evethayir(clientId)
{
    new Handle:menu = CreateMenu(MenuCallBack2);
    SetMenuTitle(menu, "%N - korumalığını size salmak istiyor, CT geçmek istiyor musunuz?", salacakct);
     
    decl String:opcionmenu[124];
     
    Format(opcionmenu, 124, "✓ Evet, istiyorum.");
    AddMenuItem(menu, "option1", opcionmenu);
   
    Format(opcionmenu, 124, "✕ Hayır, istemiyorum.");
    AddMenuItem(menu, "option2", opcionmenu);
   
    SetMenuExitBackButton(menu, true);
    DisplayMenu(menu, clientId, MENU_TIME_FOREVER);
    return Plugin_Handled; 
}

public MenuCallBack2(Handle:menu, MenuAction:action, client, itemNum)
{
    if ( action == MenuAction_Select )
    {
        new String:info[32];
     
        GetMenuItem(menu, itemNum, info, sizeof(info));
        if ( strcmp(info,"option1") == 0 )
        {
			ChangeClientTeam(salacakct, CS_TEAM_T);
			ChangeClientTeam(gececekt, CS_TEAM_CT);
			CS_RespawnPlayer(salacakct);
			CS_RespawnPlayer(gececekt);
			CPrintToChatAll("{darkred}[%s] {orange}%N {darkblue}koruma hakkını {orange}%N'ye {orchid}saldı.", c_PluginTag, salacakct, gececekt);
        }
        else if ( strcmp(info,"option2") == 0 )
        {
			gececekt = 0;
			salacakct = 0;
        }
    }
}