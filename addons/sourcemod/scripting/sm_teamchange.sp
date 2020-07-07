#pragma semicolon 1

public Plugin:myinfo = {
    name        = "TeamChange",
    author      = "Otstrel.ru Team",
    description = "Change team with /spec, /t, /ct commands",
    version     = "1.0",
    url         = "http://otstrel.ru/forum/css/obmen_opytom/45996-last_updated_sourcemod_plugins.html#post853421"
};

public OnPluginStart() {
    RegConsoleCmd("spec", Command_Spec);
    RegConsoleCmd("t", Command_T);
    RegConsoleCmd("ct", Command_CT);
}

public Action:Command_Spec(client, args) {
    UTIL_ChangeClientTeam(client, 1);
    return Plugin_Handled;
}

public Action:Command_T(client, args) {
    UTIL_ChangeClientTeam(client, 2);
    return Plugin_Handled;
}

public Action:Command_CT(client, args) {
    UTIL_ChangeClientTeam(client, 3);
    return Plugin_Handled;
}

UTIL_ChangeClientTeam(client, team) {
    if (!IsClientInGame(client)) {
        return;
    }

    new Handle:data;
    data = CreateDataPack();
    WritePackCell(data, client);
    WritePackCell(data, team);

    if (GetClientTeam(client) > 1) {
        CreateTimer(3.0, Timer_Step1_ChangeTeam, data);
    } else {
        ChangeClientTeam(client, team);
    }

    if (IsPlayerAlive(client)) {
        SetEntityMoveType(client, MOVETYPE_NONE);
    }
}

public Action:Timer_Step1_ChangeTeam(Handle:timer, any:data) {
    ResetPack(data);
    new client = ReadPackCell(data);
    new team = ReadPackCell(data);
    CloseHandle(data);

    if (IsClientInGame(client)) {
        ChangeClientTeam(client, 1);
        if (team > 1) {
            new Handle:data2;
            data2 = CreateDataPack();
            WritePackCell(data2, client);
            WritePackCell(data2, team);
            CreateTimer(1.0, Timer_Step2_ChangeTeam, data2);
        }
    }
}

public Action:Timer_Step2_ChangeTeam(Handle:timer, any:data) {
    ResetPack(data);
    new client = ReadPackCell(data);
    new team = ReadPackCell(data);
    CloseHandle(data);

    if (IsClientInGame(client)) {
        ChangeClientTeam(client, team);
    }
}
