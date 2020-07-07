# ../addons/eventscripts/gungame51/scripts/custom/gg_quake/gg_quake_config

# ============================================================================
# >> IMPORTS
# ============================================================================
# EventScripts Imports
import es
import cfglib

# GunGame Imports
from gungame51.core.cfg import generate_header

# ============================================================================
# >> GLOBAL VARIABLES
# ============================================================================
config = cfglib.AddonCFG('%s/cfg/' %es.ServerVar('eventscripts_gamedir') +
    'gungame51/custom_addon_configs/gg_quake.cfg')
        
# ============================================================================
# >> LOAD & UNLOAD
# ============================================================================
def load():
    generate_header(config)

    # Elimination
    config.text('')
    config.text('='*76)
    config.text('>> GG QUAKE')
    config.text('='*76)
    config.text('Description:')
    config.text('   Adds sound effects for the leaders')
    config.text('   Adds: Lost the lead, Gained the lead, tied for the lead')
    
    config.text('Options:')
    config.text('   0 = (Disabled) Do not load gg_quake.')
    config.text('   1 = (Enabled) Load gg_quake.')
    config.text('Default Value: 1')
    config.cvar('gg_quake', 1, 'Enables/Disables gg_quake.').addFlag('notify')
    
    config.cvar('gg_quake_taken', 'misc/takenlead.wav', 'Sound to play to the new leader')
    config.cvar('gg_quake_lost',  'misc/lostlead.wav',      'Sound to play to the old leader(s)')
    config.cvar('gg_quake_tied',  'misc/tiedlead.wav',  'Sound to play to the leaders')

    config.write()
    es.dbgmsg(0, '\tgg_quake.cfg')

def unload():
    global config

    # Remove the "notify" flags as set by addFlag('notify')
    for cvar in config.getCvars().keys():
        es.flags('remove', 'notify', cvar)
    
    # Delete the cfglib.AddonCFG instance
    del config