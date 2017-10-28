// TF2 plugin to stop stickies from bouncing off players
// Requires CollisionHook extension: https://forums.alliedmods.net/showthread.php?t=197815

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>
#include <collisionhook>

ConVar g_hTeamOnly;
bool   g_bTeamOnly;

public Plugin myinfo =
{
    name = "stopstickybounce",
    author = "Larry",
    description = "Prevent stickies from bouncing off players",
    version = "1.0.0",
    url = "https://steamcommunity.com/id/pancakelarry"
};

public OnPluginStart()
{
   g_hTeamOnly = CreateConVar("stopstickybounce_teamonly", "0", "Stop stickies from bouncing off only friendly players", FCVAR_NOTIFY, true, 0.0, true, 1.0);

   HookConVarChange(g_hTeamOnly, OnTeamOnlyChanged);
}

void OnTeamOnlyChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_bTeamOnly = StringToInt(newValue) == 1 ? true : false;
}

public Action CH_PassFilter(ent1, ent2, &bool:result)
{
	char ent1name[256];
	char ent2name[256];
	GetEntityClassname(ent1, ent1name, sizeof(ent1name));
	GetEntityClassname(ent2, ent2name, sizeof(ent2name));

	// Check if ent1 = sticky && ent2 = player
	if(StrEqual(ent1name, "tf_projectile_pipe_remote", false))
	{
		if(0 < ent2 < MAXPLAYERS)
		{
			if(g_bTeamOnly)
			{
				int ent1owner = GetEntPropEnt(ent1, Prop_Data, "m_hThrower");
				if(TF2_GetClientTeam(ent1owner) == TF2_GetClientTeam(ent2))
				{
					result = false; 
					return Plugin_Handled; 
				}
			}
			else
			{
				result = false; 
				return Plugin_Handled; 
			}
		}
	}

	// Check if ent2 = sticky && ent1 = player
	if(StrEqual(ent2name, "tf_projectile_pipe_remote", false))
	{
		if(0 < ent1 < MAXPLAYERS)
		{
			if(g_bTeamOnly)
			{
				int ent2owner = GetEntPropEnt(ent2, Prop_Data, "m_hThrower");
				if(TF2_GetClientTeam(ent2owner) == TF2_GetClientTeam(ent1))
				{
					result = false; 
					return Plugin_Handled; 
				}
			}
			else
			{
				result = false; 
				return Plugin_Handled; 
			}
		}
	}

	return Plugin_Continue;
}