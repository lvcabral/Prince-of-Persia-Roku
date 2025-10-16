' ********************************************************************************************************
' ********************************************************************************************************
' **  Prince of Persia for Roku - http://github.com/lvcabral/Prince-of-Persia-Roku
' **
' **  Created: May 2016
' **  Updated: February 2023
' **
' **  Ported to BrightScript by Marcelo Lv Cabral from the Git projects:
' **  https://github.com/ultrabolido/PrinceJS - HTML5 version by Ultrabolido
' **  https://github.com/jmechner/Prince-of-Persia-Apple-II - Original Apple II version by Jordan Mechner
' **
' ********************************************************************************************************
' ********************************************************************************************************

Function PlayScene(screen as object, level as integer, fadeIn = true as boolean) as boolean
    'Define scale based on Sprite Mode
    if m.settings.spriteMode = m.const.SPRITES_MAC
		suffix = "-mac"
        imgScale = GetScale(screen, 640, 400)
        posScale = GetScale(screen, 320, 200)
        regScale = imgScale * 2
        width = 640
        height = 400
    else
        suffix = "-dos"
        imgScale = GetScale(screen, 320, 200)
        posScale = imgScale
        regScale = imgScale
        width = 320
        height = 200
	end if
    scene = CreateCutscene(level, imgScale)
    if scene = invalid then return true
    'Setup screen and destroy objects
    if m.flip then FlipScreen()
    DestroyMap()
    DestroyChars()
    LoadGameSprites(m.settings.spriteMode, -1, regScale)
    'Draw scene stage
    stage = []
    if fadeIn
        m.fade = &hFF
    else
        m.fade = 0
    end if
    back = GetPaintedBitmap(&hFF, width * imgScale, height * imgScale, true)
    stage.Push(m.compositor.NewSprite(0, 0, CreateObject("roRegion", back, 0, 0, width * imgScale, height * imgScale), 1))
    stage.Push(m.compositor.NewSprite(0, 0, m.regions.scenes["princess-room"], 10))
    pillar = m.regions.scenes["room-pillar"]
    if m.settings.spriteMode = m.const.SPRITES_MAC
        stage.Push(m.compositor.NewSprite(237 * posScale, 109 * posScale, pillar, 30))
    else
        stage.Push(m.compositor.NewSprite(240 * posScale, 120 * posScale, pillar, 30))
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
            if event.GetInt() < 100
                skip = true
                exit while
            end if
        else
            ticks = m.clock.TotalMilliseconds()
            if ticks > m.speed
                if scene.sceneState <> scene.STATE_FADEOUT and m.fade <> 0
                    m.fade -= 12
                    if m.fade <= 0
                        m.fade = 0
                    end if
                    front = GetPaintedBitmap(m.fade, width * imgScale, height * imgScale, true)
                    stage[3].SetRegion(CreateObject("roRegion", front , 0, 0, width * imgScale, height * imgScale))
                else if scene.sceneState = scene.STATE_FADEOUT
                    m.fade += 12
                    if m.fade > &hFF
                        m.fade = &hFF
                    end if
                    front = GetPaintedBitmap(m.fade, width * imgScale, height * imgScale, true)
                    stage[3].SetRegion(CreateObject("roRegion", front, 0, 0, width * imgScale, height * imgScale))
                end if
                scene.executeProgram()
        		for each actor in scene.actors
        			if actor <> invalid
                        actor.updateActor()
                        acRegion = m.regions[actor.charName][actor.face][actor.frameName]
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
                            obj.sprite = m.compositor.NewSprite(x, y, m.regions.scenes[obj.frameName], 10)
                        else
                            obj.sprite.SetRegion(m.regions.scenes[obj.frameName])
                            obj.sprite.MoveTo(x, y)
                        end if
                    else if obj.sprite = invalid 'torches
                        animation = []
                        for each frameName in obj.frames
                            animation.Push(m.regions.general[frameName])
                        next
                        obj.sprite = m.compositor.NewAnimatedSprite(obj.x * posScale, obj.y * posScale, animation, 10)
                    end if
                next
                for each trob in scene.trobs
                    trob.update()
                    x = trob.x * posScale
                    y = trob.y * posScale
                    if trob.sprite = invalid
                        trob.sprite = m.compositor.NewSprite(x, y, m.regions.scenes[trob.frameName], 10)
                        trob.sprite.setDrawableFlag(trob.visible)
                    else
                        trob.sprite.SetRegion(m.regions.scenes[trob.frameName])
                        trob.sprite.MoveTo(x, y)
                        trob.sprite.setDrawableFlag(trob.visible)
                    end if
                    if trob.visible and trob.child.visible
                        x = (trob.x + trob.child.x) * posScale
                        y = (trob.y + trob.child.y) * posScale
                        if trob.child.sprite = invalid
                           trob.child.sprite = m.compositor.NewSprite(x, y, m.regions.scenes[trob.child.frameName], 10)
                        else
                            trob.child.sprite.SetRegion(m.regions.scenes[trob.child.frameName])
                            trob.child.sprite.MoveTo(x, y)
                        end if
                    end if
            	next
                FlashBackStage(scene, stage)
                'Paint Screen
                m.compositor.AnimationTick(ticks)
                m.compositor.DrawAll()
                if type(m.gameScreen) = "roBitmap"
                    if m.gameScale <> 1.0
                        m.mainScreen.drawscaledobject(m.gameXOff, m.gameYOff, m.gameScale, m.gameScale, m.gameScreen)
                    else
                        m.mainScreen.drawobject(m.gameXOff, m.gameYOff, m.gameScreen)
                    end if
                end if
                m.mainScreen.SwapBuffers()
                m.clock.Mark()
                if m.fade >= &hFF
                    exit while
                end if
            end if
        end if
    end while
    'Destroy scene objects
    for each sprite in stage
        if sprite <> invalid
            sprite.Remove()
        end if
    next
    stage.Clear()
    for each actor in scene.actors
        if actor <> invalid
            actor.sprite.Remove()
        end if
    next
    scene.actors.Clear()
    for each obj in scene.objects
        if obj.sprite <> invalid
            obj.sprite.Remove()
        end if
    next
    scene.objects.Clear()
    for each trob in scene.trobs
        if trob.sprite <> invalid
            trob.sprite.Remove()
        end if
        if trob.child.sprite <> invalid
            trob.child.sprite.Remove()
        end if
    next
    scene.trobs.Clear()
    scene = invalid
    'reset game speed
    m.speed = 80 '~12 fps
    return skip
End Function

Sub FlashBackStage(scene as object, stage as object)
    if scene.flash
        width = stage[0].GetRegion().GetWidth()
        height = stage[0].GetRegion().GetHeight()
        if scene.tick = 5
            scene.flash = false
            return
        end if
        if scene.tick Mod 2 = 0
            stage[0].SetRegion(CreateObject("roRegion",GetPaintedBitmap(&h000000FF, width, height, true), 0, 0, width, height))
        else
            stage[0].SetRegion(CreateObject("roRegion",GetPaintedBitmap(&hFFFFFFFF, width, height, true), 0, 0, width, height))
        end if
        scene.tick++
    end if
End Sub
