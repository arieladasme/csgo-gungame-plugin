/* ========================================================================== */
/*                                                                            */
/*   gg_winner_menu.sp                                                              */
/*   (c) 2009 Stinkyfax                                                       */
/*                                                                            */
/*   Description                                                              */
/*                                                                            */
/* ========================================================================== */

#define VERSION "1.0beta"

#define COLOR_DEFAULT 0x01
#define COLOR_LIGHTGREEN 0x03
#define COLOR_GREEN 0x04 // DOD = Red

#include <gungame>

#pragma semicolon 1




new Handle:g_hData=INVALID_HANDLE; //database handle
new String:g_sPath[PLATFORM_MAX_PATH]; //path to database
new bool:g_bModify=false; //Whether to modify settings
new bool:g_bUnload=false; //Whether to unload previous
new bool:g_bMapLoaded=false; //Check to prevent bugs with manual configs execution
new String:g_sCommand[200]; //The command to run if modify is required
new String:g_sUCommand[200]; //Command to unload current type

public Plugin:myinfo = 
{
  name = "gg Winner Menu",
  author = "Stinkyfax",
  description = "Converted plugin from ES:Python",
  version = VERSION,
  url = "http://sourcemod.net/"
};

public bool:AskPluginLoad(Handle:plugin,bool:late,String:error[],error_maxlen)   {
  return true;
}

public OnPluginStart()  {
   

   PrintToServer("[gg_winner_menu]: -- Loading --"); 
   //Load cvars
   CreateConVar("sm_ggwinner_version", VERSION, "Current version of the Trophies", 
                  FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

   //end of load cvars
   
   //for testing only
   RegAdminCmd("gg_call_menu",AdminCmd_Test,ADMFLAG_CUSTOM6);
   
   //AutoExecConfig(true, "ggwinner");
   
   //Generate path to data
   decl String:thepath[255];
   Format (thepath,sizeof(thepath),"data/ggwinner.txt");
   BuildPath(Path_SM,g_sPath,PLATFORM_MAX_PATH,thepath);
   
   PrintToServer("[gg_winner_menu]: -- Finished --");
}

public Action:AdminCmd_Test(client, argc) {
   GG_OnWinner(client, "");
   return Plugin_Handled;
}

public GG_OnWinner(client, const String:weap[]) {
   KVLoad(); //Reload the menu file
   new Handle:menu = CreateMenu(GGMenuHandle);
   SetMenuTitle(menu, "Choose the type for next map");
   AddMenuItem(menu, "", "-----------------------", ITEMDRAW_DISABLED);
   
   KvRewind(g_hData);
   if(KvGotoFirstSubKey(g_hData)) do {
      decl String:load[200];
      KvGetString(g_hData, "load", load, sizeof(load));
      if(!StrEqual(load, g_sCommand))  {
         decl String:title[100];
         decl String:sKey[10];
         new key;
         if(KvGetSectionSymbol(g_hData,key))  {
            KvGetString(g_hData, "title", title, sizeof(title));
            IntToString(key, sKey, sizeof(sKey));
            AddMenuItem(menu, sKey, title);
         }
      }
   } while (KvGotoNextKey(g_hData));
   
   AddMenuItem(menu, "", "-----------------------", ITEMDRAW_DISABLED);
   
   DisplayMenu(menu,client,MENU_TIME_FOREVER);
}

public GGMenuHandle(Handle:menu,MenuAction:action,client,slot)
{
  new key;
  if(action==MenuAction_Select)
  {
    decl String:buffer[255];
    GetMenuItem(menu,slot,buffer,sizeof(buffer));
    key = StringToInt(buffer);
    KvRewind(g_hData);
    KvJumpToKeySymbol(g_hData, key);
    decl String:info[100];
    KvGetString(g_hData, "load", g_sCommand, sizeof(g_sCommand));
    UnloadCurrent();
    KvGetString(g_hData, "unload", g_sUCommand, sizeof(g_sUCommand));
    KvGetString(g_hData, "title", info, sizeof(info));
    g_bModify=true;  //Load on next map
    g_bUnload=false; //It is already unloaded
    //tell everyone
    decl String:name[40];
    GetClientName(client, name, sizeof(name));
    Format(buffer, sizeof(buffer), "%c[GG Winner]%c: %c%s %chas chosen %c%s %cgame.",
            COLOR_GREEN, COLOR_DEFAULT, COLOR_LIGHTGREEN, name, COLOR_DEFAULT, COLOR_GREEN, info, COLOR_DEFAULT);
    PrintToChatAll(buffer);
  }
  if(action==MenuAction_Cancel)
    if(slot==MenuCancel_ExitBack)    {
    }
  if(action==MenuAction_End)
    CloseHandle(menu);
}

public OnMapStart()  {
   g_bMapLoaded=true;
   PrintToServer("map loaded");
}

public OnConfigsExecuted() {
   PrintToServer("line 130");
   if(!g_bMapLoaded)  {
      return;
   }
   PrintToServer("line 133");
   g_bMapLoaded=false;
   UnloadCurrent();
   if(g_bModify)  {
      PrintToServer("Running Command: %s", g_sCommand);
      ServerCommand(g_sCommand);
      g_bModify=false;
      g_bUnload=true;
   }
}

UnloadCurrent() {
   PrintToServer("line 145");
   if(g_bUnload)  {
      PrintToServer("Running UNCommand: %s", g_sUCommand);
      ServerCommand(g_sUCommand);
      g_bUnload=false;
   }
}

KVLoad()   {
   if(g_hData!=INVALID_HANDLE)
      CloseHandle(g_hData);
   g_hData = CreateKeyValues("winner");
   FileToKeyValues(g_hData,g_sPath); 
}



public OnPluginEnd() {
}