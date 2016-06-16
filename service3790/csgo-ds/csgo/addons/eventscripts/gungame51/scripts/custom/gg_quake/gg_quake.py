# ../addons/eventscripts/gungame51/scripts/custom/gg_quake/gg_quake.py


import es

from gungame51.core.addons.shortcuts import AddonInfo

info = AddonInfo()
info.name = 'gg_quake'
info.title = 'GG Quake' 
info.author = 'DanielB' 
info.version = '1.0'


snd_taken = es.ServerVar('gg_quake_taken')
snd_lost  = es.ServerVar('gg_quake_lost')
snd_tied  = es.ServerVar('gg_quake_tied')


def gg_new_leader(event_var):
    '''
    A players has taken the lead, not tied for it
    This means there is one leader, but may be many old_leaders
    '''
    leader      = event_var['userid']
    old_leaders = event_var['old_leaders']
    
    # Don't play the sound if they were already the leader
    if not leader == old_leaders:
        es.playsound(leader, snd_taken, 1.0)
    
    # Play "lost the lead", if needed
    if old_leaders != 'None':
        for userid in old_leaders.split(','):
            # Play "lost the lead" to all previous leaders,
            # Except the current leader
            if not userid == leader:
                es.playsound(userid, snd_lost, 1.0)
            
def gg_tied_leader(event_var):
    '''
    A player has tied for the lead
    '''
    es.playsound(event_var['userid'], snd_tied, 1.0)
            
            
def addDownloads():
    '''
    Adds the required client files to the stringtable
    '''
    es.stringtable('downloadables', 'sound/' + snd_taken)
    es.stringtable('downloadables', 'sound/' + snd_lost)
    es.stringtable('downloadables', 'sound/' + snd_tied)
    
def load():
    addDownloads()
    
def es_map_start(event_var):
    addDownloads()
    
