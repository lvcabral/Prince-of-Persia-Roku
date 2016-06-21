' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Prince of Persia Channel - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: February 2016
' **  Updated: May 2016
' **
' **  Ported to Brighscript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function PlayScene(screen as object, level as integer, fadeIn = true as boolean) as boolean
    'Clear screen (needed for non-OpenGL devices)
    m.mainScreen.Clear(0)
    m.mainScreen.SwapBuffers()
    m.mainScreen.Clear(0)
    'Clear game screen
    if m.flip then FlipScreen()
    DestroyMap()
    DestroyChars()
    'Create scene and draw stage
    if m.settings.spriteMode = m.const.SPRITES_DOS
		suffix = "-dos"
        imgScale = GetScale(screen, 320, 200)
        posScale = imgScale
        width = 320
        height = 200
	else
		suffix = "-mac"
        imgScale = GetScale(screen, 640, 400)
        posScale = GetScale(screen, 320, 200)
        width = 640
        height = 400
	end if
    if fadeIn then m.fade = &hFF else m.fade = 0
    scene = CreateCutscene(level, imgScale)
    if scene = invalid then return true
    stage = []
    back = GetPaintedBitmap(&hFF, width * imgScale, height * imgScale, true)
    stage.Push(m.compositor.NewSprite(0, 0, CreateObject("roRegion", back, 0, 0, width * imgScale, height * imgScale), 1))
    room = ScaleBitmap(CreateObject("roBitmap", "pkg:/assets/scenes/images/princess-room" + suffix + ".png"), imgScale)
    print "scene image scale=";imgScale
    stage.Push(m.compositor.NewSprite(0, 0, CreateObject("roRegion", room, 0, 0, width * imgScale, height * imgScale), 10))
    pillar = scene.regions.Lookup("room_pillar")
    if m.settings.spriteMode = m.const.SPRITES_DOS
        stage.Push(m.compositor.NewSprite(59 * posScale, 120 * posScale, pillar, 30))
        stage.Push(m.compositor.NewSprite(240 * posScale, 120 * posScale, pillar, 30))
    else
        stage.Push(m.compositor.NewSprite(58 * posScale, 109 * posScale, pillar, 30))
        stage.Push(m.compositor.NewSprite(237 * posScale, 109 * posScale, pillar, 30))
    end if
    front = GetPaintedBitmap(m.fade, width * imgScale, height * imgScale, true)
    stage.Push(m.compositor.NewSprite(0, 0, CreateObject("roRegion", front , 0, 0, width * imgScale, height * imgScale), 50))
    'Initialize flags and aux variables
    m.speed = 120 '~8 fps
    skip = false
    'Scene Loop
    m.clock.Mark()
    while true
        event = m.port.GetMessage()
        if type(event) = "roUniversalControlEvent" and fadeIn
            if event.GetInt() < 100 then
                skip = true
                exit while
            end if
        else
            ticks = m.clock.TotalMilliseconds()
            if ticks > m.speed
                if scene.sceneState <> scene.STATE_FADEOUT and m.fade <> 0
                    m.fade = m.fade - 12
                    if m.fade <= 0 then m.fade = 0
                    front = GetPaintedBitmap(m.fade, width * imgScale, height * imgScale, true)
                    stage[4].SetRegion(CreateObject("roRegion", front , 0, 0, width * imgScale, height * imgScale))
                else if scene.sceneState = scene.STATE_FADEOUT
                    m.fade = m.fade + 12
                    if m.fade > &hFF then m.fade = &hFF
                    front = GetPaintedBitmap(m.fade, width * imgScale, height * imgScale, true)
                    stage[4].SetRegion(CreateObject("roRegion", front, 0, 0, width * imgScale, height * imgScale))
                end if
                scene.executeProgram()
        		for each actor in scene.actors
        			if actor <> invalid
                        actor.updateActor()
                        acRegion = actor.regions[actor.face].Lookup(actor.frameName)
                        if actor.faceR()
                            anchorX = (actor.x * posScale) - acRegion.GetWidth()
                        else
                            anchorX = (actor.x * posScale)
                        end if
                        anchorY = (actor.y * posScale) - acRegion.GetHeight()
                        if actor.sprite = invalid
                            actor.sprite = m.compositor.NewSprite(anchorX, anchorY, acRegion, 20)
                        else
                            actor.sprite.SetRegion(acRegion)
                            actor.sprite.MoveTo(anchorX, anchorY)
                        end if
                    end if
        		next
                for each obj in scene.objects
                    if obj.frames = invalid 'stars
                        obj.update()
                        x = obj.x * posScale
                        y = obj.y * posScale
                        if obj.sprite = invalid
                            obj.sprite = m.compositor.NewSprite(x, y, scene.regions.Lookup(obj.frameName), 10)
                        else
                            obj.sprite.SetRegion(scene.regions.Lookup(obj.frameName))
                            obj.sprite.MoveTo(x, y)
                        end if
                    else if obj.sprite = invalid 'torches
                        animation = []
                        for each frameName in obj.frames
                            animation.Push(scene.general.Lookup(frameName))
                        next
                        obj.sprite = m.compositor.NewAnimatedSprite(obj.x * posScale, obj.y * posScale, animation, 10)
                    end if
                next
                for each trob in scene.trobs
                    trob.update()
                    x = trob.x * posScale
                    y = trob.y * posScale
                    if trob.sprite = invalid
                        trob.sprite = m.compositor.NewSprite(x, y, scene.regions.Lookup(trob.frameName), 10)
                        trob.sprite.setDrawableFlag(trob.visible)
                    else
                        trob.sprite.SetRegion(scene.regions.Lookup(trob.frameName))
                        trob.sprite.MoveTo(x, y)
                        trob.sprite.setDrawableFlag(trob.visible)
                    end if
                    if trob.visible and trob.child.visible
                        x = (trob.x + trob.child.x) * posScale
                        y = (trob.y + trob.child.y) * posScale
                        if trob.child.sprite = invalid
                           trob.child.sprite = m.compositor.NewSprite(x, y, scene.regions.Lookup(trob.child.frameName), 10)
                        else
                            trob.child.sprite.SetRegion(scene.regions.Lookup(trob.child.frameName))
                            trob.child.sprite.MoveTo(x, y)
                        end if
                    end if
            	next
                FlashBackStage(scene, stage)
                'Paint Screen
                m.compositor.AnimationTick(ticks)
                m.compositor.DrawAll()
                m.mainScreen.SwapBuffers()
                m.clock.Mark()
                if m.fade >= &hFF then exit while
            end if
        end if
    end while
    'Destroy scene objects
    for each sprite in stage
        if sprite <> invalid then sprite.Remove()
    next
    stage.Clear()
    for each actor in scene.actors
        if actor <> invalid then actor.sprite.Remove()
    next
    scene.actors.Clear()
    for each obj in scene.objects
        if obj.sprite <> invalid then obj.sprite.Remove()
    next
    scene.objects.Clear()
    for each trob in scene.trobs
        if trob.sprite <> invalid then trob.sprite.Remove()
        if trob.child.sprite <> invalid then trob.child.sprite.Remove()
    next
    scene.trobs.Clear()
    scene = invalid
    'reset game speed
    m.speed = 80 '~12 fps
    return skip
End Function

Sub FlashBackStage(scene as object, stage as object)
    if scene.flash
        if scene.tick = 5
            scene.flash = false
            return
        end if
        if scene.tick Mod 2 = 0
            stage[0].SetRegion(CreateObject("roRegion",GetPaintedBitmap(&h000000FF, 640, 400, true), 0, 0, 640, 400))
        else
            stage[0].SetRegion(CreateObject("roRegion",GetPaintedBitmap(&hFFFFFFFF, 640, 400, true), 0, 0, 640, 400))
        end if
        scene.tick = scene.tick + 1
    end if
End Sub
