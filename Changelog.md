#Changelog

#####v0.10 - 19-Jun-2016 - All Shadow Special Events, Level 3 (Skeleton) can now be finished
* Add: [Events] Level 3 - A checkpoint is activated when kid leaves room 7, it will revive at room 2
* Add: [Events] Level 4 - When the kid jumps into the mirror the Shadow will jump out of it on the other direction
* Add: [Events] Level 5 - In room 24 if the gate is open the Shadow will enter and drink the potion
* Add: [Events] Level 6 - Shadow will show in room 1 behind the gate, if kid open the gate and hang on the edge the shadow walk to close the gate
* Add: [Events] Level 12 - When kid enter room 15 from 18 the sword disappears and the shadow appears to fight, If kid put sword down and run to the shadow they are reunited
* Change: [Usability] The game border color changes to white when in "Shift" of "Fight" modes
* Change: [Map] Moved the button on Level 3 Room 14 to allow the kid reach the gate at room 2 in time using Roku Control
* Fix: Sometimes characters fall in endless loop
* Fix: Kid's animation quickly freezes when Skeleton arises (in Level 3)
* Fix: Skeleton (in Level 3) after falling to room 3 is not shown in the right place
* Fix: Dead Characters do not always press the buttons
* Fix: The max health attribute is not being preserved when changing levels
* Fix: Guard keep trying to stab the kid after he climbed the stairs

#####v0.9 - 31-May-2016 - Cut Scenes, Special Events, Mac sprites (tiles, enemies), Skeleton, Mouse and Jaffar, GitHub
* Add: Game Opening Story
* Add: Game Cut scenes before levels: 2, 4, 6, 8, 9 and 12
* Add: Game Final Scene and Story
* Add: Scene for the end of the game by timeout
* Add: Music played on level exit (level 4 different and no song after level 12 and 13)
* Add: [Events] Level 1 - Initial gate close is a button pressed on room 5
* Add: [Events] Level 3 - Skeleton in room 1 will raise if the exit door is open
* Add: [Events] Level 4 - The exit room song changes after the exit door is raised
* Add: [Events] Level 4 - A mirror will be placed at room 4 and music played (once) when the exit room is opened
* Add: [Events] Level 8 - If exit door is raised the mouse will show up at room 16 (kid needs to be at least 12.5s at the room)
* Add: [Events] Level 12 - Tiles will appear automatically to create a bridge on room 2 to 13
* Add: [Events] Level 12 - Entering room 23 go to level 13
* Add: [Events] Level 13 - No health regeneration or remaining time shown on restarting the level
* Add: [Events] Level 13 - Loose tiles above rooms 16 and 23 will fall when kid enters.
* Add: [Events] Level 13 - Leaving room 3 from the right play a music and after that Jaffar goes engarde
* Add: [Events] Level 13 - After Jaffar dies the button on room 24 is pressed to open exit door when kid enter room 3
* Add: [Events] Level 13 - After Jaffar dies, screen flashes several times white, and show remaining time, the countdown stops
* Add: [Events] Level 14 - The final scene shows entering room 5
* Add: On Final level 14 the screen is changed to Classic Mode (1 room) - Can't move back to previous level
* Add: Menu now can me moved both in vertical and horizontal control modes (thanks renojim)
* Add: Mirror tile on Palace sprite set - Not on JS
* Add: Support for Macintosh sprites (scenes, dungeon and palace tiles, TROBs, Enemies splash and life, skeleton and Jaffar)
* Add: Guard check for barrier and only advance if the path is free
* Add: Kid check for barrier and only go engarde if the path is free
* Fix: Sometimes Running-jump crosses closed gates
* Fix: Kid being stabbed to death does not show splash (thanks David!)
* Fix: Shift mode not working on Horizontal Control mode (thanks gmaster28)
* Fix: Pillar (id=25) is masked out when kid is climbing (L5R2) - Same bug in JS
* Fix: Debris tiles are being painted above the tile on the right
* Fix: Grab to the Left is hanging on the wrong tile - (L4R16, L5R10R7, L1R7) - Same bug in JS
* Fix: Falling after hang between Palace pillars the kid land on air (L5) - Same bug in JS
* Fix: Running into a tapestry shows kids face on the other side, same on gates (L10R1)
* Fix: Guard is not killed by slicer
* Fix: MOBs when falling off the screen on horizontal change is not working (L2)
* Fix: When two plates fall side by side only one debris is shown on floor (L1 & L2)
* Fix: When a plate fall over another plate it's not dropping those and the sprite get stuck (L13)
* Fix: Kid on BlockX = 9 moving right do not change camera focus
* Fix: Kid can't walk through an open gate when it's on the right edge
* Fix: Kid was not sheathing the sword when opponent fall to other Y
* Fix: If kid is really close to the wall and do a turnengarde sometimes there is a crash in opp_left_side and opp_right_side
* Fix: Guard hit when back to a wall, enter the wall (L2)

#####v0.8 - 08-May-2016 - Fight, Slow Fall Potion, Game Timer, Save Game & Options, Mac sprites (kid, guards, sword)
* Add: Settings Menu: Control Mode, Graphics Mode, Credits
* Add: Default Limit of 10 health lives for the kid
* Add: Game timer (60 minutes default) - Message 2 seconds level, 2 seconds timer
* Add: After death timer: 15s after death, start alert for 6s if no button pressed restart game
* Add: Show guards on each level
* Add: Life indicator of the Guards on the Status Bar
* Add: Guards in all 7 colors - not on JS
* Add: Guard lives matching clothes colors - not on JS
* Add: Guard splash matching clothes colors - not on JS
* Add: Support for Macintosh sprites (Kid, Guards and Sword)
* Add: Fighting behavior for kid and guards
* Add: Disable Shift key "toggle mode" when fighting
* Add: Slow Fall Potion (big green): Float down when falling big heights (L7)
* Add: Back key stop the game and return to Menu
* Add: Menus to Save (from level 3) and Restore the Game state (level, health, time)
* Add: Sound Effects: guard hit, sword attack, sword defense, sword drawn, fight death, hang on fall
* Add: Ported Actor.js and Fighter.js code into charActor.brs
* Add: Ported Enemy.js to charGuard.brs
* Add: Disclaimer during intro
* Change: OK button now switch between Regular and Debug modes
* Change: Dark mode is now activated with Replay button when in Debug mode
* Refactor: Extracted common methods and properties from charKid.brs to charActor.brs
* Refactor: Moved game loop to gameScreen.brs
* Refactor: Moved the footstep sound to the CMD_TAP on process_command_kid as the original code
* Refactor: Moved VersionInfo to be shown when Debug mode is enabled
* Refactor: Created function FlipHorizontally to avoid duplicating sprites (left, right)
* Refactor: Reduced the size of images using tinypng.com
* Fix: When the fall is from too high with a plate, the kid is slower (L9R16-15-14)
* Fix: Only change to "engarde" when the kid has the sword (L1) - Same bug on JS
* Fix: Guards moves backward instead of turning when the kid is behind him - Same bug on JS
* Fix: Fight mode is ignoring the CharY - Same bug on JS
* Fix: Guards are not falling to lower level (use stabbed frames) - Same bug on JS
* Fix: Try step on a Loose Plate is making it fall
* Fix: Level 6 in "9 rooms mode" shows decoration over the wall
* Fix: Kid splash shows in front of pillar
* Fix: When drinking potion in a palace level the wall decoration disappears (L4R23)
* Fix: Missing tile on the assets: TILE_TORCH_WITH_DEBRIS = 30 - Same bug on JS
* Fix: When Door is opening and kid exit room and come back the door is closed again (L1 and L7)
* Fix: When engarde with back to the wall and retrieve the kid enter inside the wall (L2R4)
* Fix: Jump towards an opening gate fall forever (L7R3)
* Fix: Guard ignores close gate as a barrier
* Fix: Guard is not killed by spikes
* Fix: Sometimes jump to the right into wall crash (L3R12)
* Fix: Sometimes fall forever when jumping until fall - same bug on JS (L1R6 & L4R17-19)
* Fix: Guard fall forever when pushed down (L4)
* Fix: Crash when fatguard falls on the abyss (L6)
* Fix: Dead kid is not pressing the button (L7)
* Fix: Kid alerts the guard that fall forever (L4R17-18)

#####v0.7 - 10-Apr-2016 - Classic Mode scaled, Die on Slicer/Spikes, Injury by Falling Plates and Mask/Crop fixes
* Add: Classic Mode scaled 2X to be painted in 640x400
* Add: Control options adapted for remote controls without the buttons: Replay, A and B
* Add: Kid will die when running or falling on spikes
* Add: Kid will die when crossing a slicer in the wrong time
* Add: Kid will be injured from falling plate
* Add: Game sound effects: spiked, death, slicer, long fall, harm
* Add: Menu sound effects: menu navigation, menu select
* Add: When level starts in front of an exit door, drop it!
* Add: Turn the kid direction when a level starts
* Add: Use "medland" action on the first level and first room before the "suspense" sound
* Add: Gray border around the game area
* Add: VersionInfo added to the bottom right corner of the screen
* Add: Level transition by falling - not on JS - (L6-L7)
* Refactor: Renamed Chopper tile to Slicer following original Apple II code naming convention
* Refactor: Added a priority system to play the sound effects
* Refactor: Removed deprecated method LoadSpriteAnimations()
* Refactor: Removed the 320x200 mode and the game frame
* Fix: Kid level start horizontal position is wrong
* Fix: Kid can't jump in front of a closed exit door
* Fix: Status bar text center not aligned based on actual text width
* Fix: After death max lives are not restored to 3
* Fix: Gate tile "front sprite" is stuck down when gate is off the screen
* Fix: Slicer should only start when the kid is on the same elevation and room
* Fix: Kid is pressing a button when hanging on a level below (L1R5)
* Fix: Splash showing in the wrong position when kid is standing (L8)
* Fix: Hang on loose plate do not make it fall (same bug on JS code)
* Fix: Hanging on a tapestry do not consider it solid, bouncing into it (same bug on JS code)
* Fix: Pushing plates and fall keep debris on top (L4R16-R17)
* Fix: Walk is not considering the risk of slicer
* Fix: Crash when changing level when a plate is falling (L1R1-R2)
* Fix: Room transition is not exact (horizontally or vertically) - classic only
* Fix: 9 rooms mode does not draw ok when navigating vertically (L2, L9)
* Fix: Gate opening not cropped above ceiling when in multi-room mode (L2)
* Fix: Some artifacts over floor in some rooms (rooms painted in wrong order)
* Fix: In shift mode if you turn and keep pressing the kid runs (same bug on JS code)
* Fix: Mask issues: Jump crossing up ceiling
* Fix: Mask issues: Falling edge crosses the floor
* Fix: Mask issues: Kid hands showing when climb up/down and hanging

#####v0.6 - 26-Mar-2016 - Intro screens, Options Menu, Button Events, Level Changes and Sound Effects
* Add: Intro screens and song
* Add: Start Menu with Screen Mode options
* Add: Allow use the remote control straight or sideways
* Add: Event to Open Gate and Exit Door
* Add: Event to move to next level when enter Exit Door
* Add: Change level with remote keys (REW and FF)
* Add: Bitmap font support for Status Bar
* Add: Event to pick Potion and drink
* Add: Event to Pick Sword
* Add: Flash background depending on the CMD_EFFECT
* Add: Status bar shows kid lives according to health and maxHealth properties
* Add: Status bar blinks when is the last kid's life
* Add: Healing Potion (red): increases 1 energy point
* Add: Life Extension Potion (big red): Extended energy in 1 point and restore all
* Add: Poison Potion (blue): decreases 1 energy point
* Add: Injury from medium fall: : decreases 1 energy point
* Add: Die from high fall
* Add: Sound Effects (Run, Bump, Gate, Suspense, Exit Door, Drink, Land, Loose, Spikes, Sword, Button)
* Add: Loose plate that fall over a button should press it (L4R16->R17) - Not on JS
* Add: Restart game with death
* Fix: Not all spikes are active on level definition
* Fix: Loose plates not falling with kid on 1 room mode
* Fix: Shake on ceiling is not working on top of screen
* Fix: Ceiling for rooms with -1 up is transparent for gates
* Fix: Restart is not restoring the state of tiles
* Fix: Gate not blocking when kid is running
* Fix: TROB pause if kid leave room: ex: gates and spikes are in the same step when return to a room
* Fix: MOB pause if kid leave room: ex: loose plate about to fall when kid change room, do not fall until come back L4R16
* Fix: Jump over spikes in lower level should still activate it
* Fix: Try to hang when falling with shift pressed is crashing the app
* Fix: Hanging on plates do not press button, only standing over it (same as JS)
* Fix: Standing over a button is not keeping gate open (same as JS)
* Fix: Exit door opening as one step (fixed animation and crop)
* Fix: Crash when kid fall with MOB on Level 2 Room 6
* Fix: Room transition is not exact (vertically) - feet on the top and when changing room down L4R16
* Fix: Forcing to bump a closed gate facing right on the edge of a room make the kid cross it - L1R12->R20
* Fix: Shift state not reset after pickup drink or sword
* Fix: Shift state not reset when (re)starting level
* Fix: When fall on abyss dies and stand-up (L2R17)

#####v0.5 - 09-Mar-2016 - Palace and Animated Objects (TROBs and MOBs)
* Add: Support Palace levels
* Add: Exiting room from exit door
* Add: Gate (TROB)
* Add: Button Plate (TROB)
* Add: Spikes (TROB)
* Add: Sword bright (TROB)
* Add: Slicer (TROB)
* Add: Exit Door (TROB)
* Add: Loose Plate (MOB)
* Add: OK hide/show the tiles (Debug feature)
* Add: Open exit door when enter room (Debug feature)
* Fix: Missing top ceiling (3px)
* Fix: Missing left wall for rooms in the edge of the map
* Fix: Missing cover on right when no room exists (multi-room mode)
* Fix: When climb up from 1 room to other (classic mode) camera does not move (L9R7)
* Fix: Can't climb when in top left of the room

#####v0.4 - 05-Mar-2016 - Collision Detection and Room Navigation
* Add: Reset Level (Replay) button
* Add: Jump (A) button with same function of the Up button
* Add: Shift(B) button as a on/off toggle
* Add: Ported moves methods (run, step, fall, jump, climbup, bump)
* Add: Ported collision detection code (some bugs)
* Add: Ported Kid behavior methods (except fighting)
* Add: Changing kid current room
* Add: Placeholder for the status bar
* Add: Pan the map on screen based on kid position
* Fix: Kid can step into a wall after bump over it
* Fix: Kid fall on edge sometimes too early
* Fix: Try to climb left side moves kid to other room
* Fix: Kid vertical position a little off up
* Fix: Behavior "climbdown" is not being triggered
* Fix: Can't climb plates, only walls

#####v0.3 - 01-Mar-2016 - Improved Game Canvas and Kid Animation
* Add: Game canvas resolution configurable
* Add: Game mode single/multiple room configurable (still hardcoded)
* Add: Kid animation improved (turn works, face right fluid as left)

#####v0.2 - 27-Feb-2016 - Maps and kid turn both sides
* Add: Dungeons maps can be loaded (full screen)
* Add: Support one kid sprite bitmaps for each direction (left, right)

#####v0.1 - 21-Feb-2016 - "Basic Sprites"
* Add: Kid sprite moving (limited animation)
