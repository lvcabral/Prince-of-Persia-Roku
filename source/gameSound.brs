' ********************************************************************************************************
' ********************************************************************************************************
' **  Prince of Persia for Roku - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: February 2016
' **  Updated: October 2024
' **
' **  Ported to BrightScript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function LoadSounds(enable as boolean) as object
    sounds = {  enabled:enable,
                mp3: {clip:"", priority:0, cycles:0},
                wav: {clip:"", priority:0, cycles:0},
                metadata : ParseJson(ReadAsciiFile("pkg:/assets/sounds/sounds.json")),
                navSingle : CreateObject("roAudioResource", "navsingle"),
                roll : CreateObject("roAudioResource", "navmulti"),
                deadend : CreateObject("roAudioResource", "deadend"),
                select : CreateObject("roAudioResource", "select")
             }
    for each name in sounds.metadata.clips
        clip = sounds.metadata.clips[name]
        if clip.type = "wav"
            sounds.AddReplace(name,CreateObject("roAudioResource", "pkg:/assets/sounds/" + name + ".wav"))
        end if
    next
    return sounds
End Function

Sub LoadModSounds()
    if m.settings.modId <> invalid and m.mods[m.settings.modId].sounds
        m.sounds.modId = invalid
        modPath = m.mods[m.settings.modId].url + m.mods[m.settings.modId].path
        if Left(modPath, 3) = "pkg"
            modPath = modPath + "sounds/"
        end if
        for each name in m.sounds.metadata.clips
            clip = m.sounds.metadata.clips[name]
            wav = modPath + name + ".wav"
            if clip.type = "wav" and m.files.Exists(wav)
                m.sounds.AddReplace(name, CreateObject("roAudioResource", wav))
                m.sounds.modId = m.settings.modId
            else if clip.type = "wav"
                m.sounds.AddReplace(name, CreateObject("roAudioResource", "pkg:/assets/sounds/" + name + ".wav"))
            end if
        next
    else if m.sounds.modId <> invalid
        m.sounds.modId = invalid
        for each name in m.sounds.metadata.clips
            clip = m.sounds.metadata.clips[name]
            if clip.type = "wav"
                m.sounds.AddReplace(name, CreateObject("roAudioResource", "pkg:/assets/sounds/" + name + ".wav"))
            end if
        next
    end if
End Sub

Function IsSilent() as boolean
    return (m.sounds.mp3.cycles = 0 and m.sounds.wav.cycles = 0)
End Function

Sub SoundUpdate()
    if not m.sounds.enabled then return
    m.audioPort.GetMessage()
    if m.sounds.mp3.cycles > 0
        m.sounds.mp3.cycles = m.sounds.mp3.cycles - 1
    end if
    if m.sounds.wav.cycles > 0
        m.sounds.wav.cycles = m.sounds.wav.cycles - 1
    end if
End Sub

Sub PlaySound(clip as string, overlap = false as boolean, volume = 100 as integer)
    g = GetGlobalAA()
    meta = g.sounds.metadata.clips[clip]
    if meta.type = "mp3"
        PlaySoundMp3(clip, overlap)
    else
        PlaySoundWav(clip, overlap, volume)
    end if
End Sub

Sub PlaySoundMp3(clip as string, overlap as boolean)
    g = GetGlobalAA()
    if not g.sounds.enabled then return
    ctrl = g.sounds.mp3
    meta = g.sounds.metadata.clips[clip]
    if meta = invalid then return
    if ctrl.cycles = 0 or meta.priority > ctrl.priority or (ctrl.clip = clip and overlap)
        ' print "play sound mp3: "; clip
        ctrl.clip = clip
        ctrl.priority = meta.priority
        ctrl.cycles = cint(meta.duration / g.speed)
        g.audioPlayer.SetContentList([{url:"pkg:/assets/sounds/" + clip + ".mp3"}])
        g.audioPlayer.setLoop(false)
        g.audioPlayer.play()
    end if
End Sub

Sub PlaySoundWav(clip as  string, overlap = false as boolean, volume = 50 as integer)
    g = GetGlobalAA()
    if not g.sounds.enabled then return
    ctrl = g.sounds.wav
    meta = g.sounds.metadata.clips[clip]
    if meta <> invalid and (meta.priority >= ctrl.priority or ctrl.cycles = 0)
        ' print "play sound wav: "; clip
        ctrl.clip = clip
        ctrl.priority = meta.priority
        ctrl.cycles = cint(meta.duration / g.speed)
        sound = g.sounds[clip]
        if overlap or not sound.IsPlaying()
            sound.Trigger(volume)
        end if
    end if
End Sub

Sub PlaySong(clip as string, loop = false as boolean)
    g = GetGlobalAA()
    if g.sounds.enabled
        g.audioPlayer.SetContentList([{url:"pkg:/assets/songs/" + clip + ".mp3"}])
        g.audioPlayer.setLoop(loop)
        g.audioPlayer.play()
    end if
End Sub

Sub StopAudio()
    g = GetGlobalAA()
    if g.sounds.enabled
        g.audioPlayer.stop()
        g.sounds.mp3 = {clip:"", priority:0, cycles:0}
    end if
End Sub
