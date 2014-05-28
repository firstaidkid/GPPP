
do -- Physics world
	local cinfo = WorldCInfo()
	cinfo.gravity = Vec3(0, 0, 0)
	cinfo.worldSize = 2000.0
	local world = PhysicsFactory:createWorld(cinfo)
	PhysicsSystem:setWorld(world)
end

do -- debugCam
	debugCam = GameObjectManager:createGameObject("debugCam")
	debugCam.cc = debugCam:createCameraComponent()
	debugCam.eye = Vec3(100.0, -100.0, 100.0)  -- camera position
	debugCam.aim = Vec3(0.0, 0.0, 75.0) -- camera target
	debugCam.rotSpeed = 20.0
	debugCam.zoomSpeed = 50.0
	debugCam.maxZoom = 1000.0
	debugCam.minZoom = 10.0
	debugCam.zoom = (debugCam.aim - debugCam.eye):length() -- initialer zoom, die länge des vektors: target-position
	debugCam.cc:setPosition(debugCam.eye)
	debugCam.cc:lookAt(debugCam.aim)
end

do -- Character
	character = GameObjectManager:createGameObject("character")
	character.ac = character:createAnimationComponent() -- animation-component für GameObject erstellen
	character.ac:setSkeletonFile("data/animations/Barbarian/Barbarian.hkt") -- animationsskelet der AniComp hinzufügen
	character.ac:setSkinFile("data/animations/Barbarian/Barbarian.hkt") -- Havok-Notwendigkeit
	
	character.idles = { "Idle", "IdleFidget", "IdleFidget2", "IdleFidget3" }
	character.ac:addAnimationFile(character.idles[1], "data/animations/Barbarian/Barbarian_Idle.hkt")
	character.ac:addAnimationFile(character.idles[2], "data/animations/Barbarian/Barbarian_IdleFidget.hkt")
	character.ac:addAnimationFile(character.idles[3], "data/animations/Barbarian/Barbarian_IdleFidget2.hkt")
	character.ac:addAnimationFile(character.idles[4], "data/animations/Barbarian/Barbarian_IdleFidget3.hkt")
	character.activeIdle = 1
	
	character.ac:addAnimationFile("Walk", "data/animations/Barbarian/Barbarian_Walk.hkt")
	character.ac:addAnimationFile("Run", "data/animations/Barbarian/Barbarian_Run.hkt")
	character.acceleration = 20.0
	character.damping = 10.0
	character.velocity = 0.0
	character.maxVelocity = 10.0

	character.attacks = { "Attack", "Attack2", "Attack3", "Attack4", "SpecialAttack" }
	character.ac:addAnimationFile(character.attacks[1], "data/animations/Barbarian/Barbarian_Attack.hkt")
	character.ac:addAnimationFile(character.attacks[2], "data/animations/Barbarian/Barbarian_Attack2.hkt")
	character.ac:addAnimationFile(character.attacks[3], "data/animations/Barbarian/Barbarian_Attack3.hkt")
	character.ac:addAnimationFile(character.attacks[4], "data/animations/Barbarian/Barbarian_Attack4.hkt")
	character.ac:addAnimationFile(character.attacks[5], "data/animations/Barbarian/Barbarian_SpecialAttack.hkt")
	character.activeAttack = 0 -- no attack
end

function idleEventListener(eventData)
	
	-- select a new idle animation
	character.ac:easeOut(character.idles[character.activeIdle], 1.0) -- fade current idle-anim out in 1 sec
	local idleDuration = 0
	if (character.activeIdle == 1) then -- main idle?
		-- random idle
		character.activeIdle = math.random(2, #character.idles) -- start random idle
		idleDuration = character.ac:getAnimationDuration(character.idles[character.activeIdle]) - 0.1 -- get duration of anim -0.1sec for easeIn
	else
		-- default idle
		character.activeIdle = 1
		idleDuration = math.random(5, 10) -- play main-idle for 5-10 sec
	end
	character.ac:setLocalTimeNormalized(character.idles[character.activeIdle], 0.0) -- stop current animation, reset to t=0.0
	character.ac:easeIn(character.idles[character.activeIdle], 1.0)
	
	-- re-create the idle timer event
	local idleEvent = Events.create()
	idleEvent:registerListener(idleEventListener)
	idleEvent:delayedTrigger(idleDuration, {}) -- new delayed event with current anim-duration

	return EventResult.Handled
end

function characterEnter()

	character.ac:setReferencePoseWeightThreshold(0.1)

	-- set idle animation weights, only play one (1) at a time
	for i = 1, #character.idles do
		character.ac:setMasterWeight(character.idles[i], 0.1) -- minimal weight for idles, have them be overwritten by other anims
		if (i == character.activeIdle) then
			character.ac:easeIn(character.idles[i], 0.0) -- idle-easing in 0.0 secs
		else
			character.ac:easeOut(character.idles[i], 0.0) -- blend all other anims out
		end
	end

	-- trigger the first idle animation
	local idleEvent = Events.create()
	idleEvent:registerListener(idleEventListener)
	idleEvent:delayedTrigger(5, {}) -- change idle anim. after 5 sec

	-- set walk and run animation weights
	character.ac:setMasterWeight("Walk", 0.0)
	character.ac:setMasterWeight("Run", 0.0)
	
	-- set attack animation weights
	for i = 1, #character.attacks do
		character.ac:setMasterWeight(character.attacks[i], 1.0)
		character.ac:easeOut(character.attacks[i], 0.0)
	end
	
	character.ac:setBoneDebugDrawingEnabled(true) -- animations-bones zeichnen
end

function defaultEnter(enterData)

	characterEnter();

	return EventResult.Handled
end

function cameraUpdate(elapsedTime)

	local mouseDelta = InputHandler:getMouseDelta()

	-- rotation
	local invDir = debugCam.cc:getViewDirection():mulScalar(-1.0) -- vektor from target to cam-position (inverse of view-direction)
	local rotQuat = Quaternion(Vec3(0.0, 0.0, 1.0), mouseDelta.x * debugCam.rotSpeed * elapsedTime)	-- rotations-quaternion, w/ rotating z-axis
	local rotMat = rotQuat:toMat3() -- 3x3 rot-matrix from quaternion
	local rotInvDir = rotMat:mulVec3(invDir) -- richtungsvektor mit rot-matrix multiplizieren, also vektor rotieren

	-- zoom
	debugCam.zoom = debugCam.zoom + mouseDelta.y * debugCam.zoomSpeed * elapsedTime  -- zoom abhängig von der mouse y-position 
	if (debugCam.zoom > debugCam.maxZoom ) then debugCam.zoom = debugCam.maxZoom end  -- bounds
	if (debugCam.zoom < debugCam.minZoom ) then debugCam.zoom = debugCam.minZoom end
	
	-- set new values
	debugCam.eye = debugCam.aim + rotInvDir:mulScalar(debugCam.zoom)
	debugCam.cc:setPosition(debugCam.eye)
	debugCam.cc:lookAt(debugCam.aim)
end

function characterUpdate(elapsedTime)

	DebugRenderer:printText(Vec2(-0.9, 0.8), "character.activeIdle " .. character.idles[character.activeIdle])

	-- walking forward
	if (InputHandler:isPressed(Key.Up)) then
		character.velocity = character.velocity + character.acceleration * elapsedTime
	end
	character.velocity = character.velocity - character.damping * elapsedTime
	if (character.velocity > character.maxVelocity) then
		character.velocity = character.maxVelocity
	end
	if (character.velocity < 0.0) then
		character.velocity = 0.0
	end
	DebugRenderer:printText(Vec2(-0.9, 0.70), "character.velocity " .. string.format("%6.3f", character.velocity))
	
	-- walk and run animation weights
--
--	
--	w |     /\    / run
--	e |    /  \  /
--	i |   /    \/
--	g |  /     /\ 
--	h |_/_____/__\_ idle-weight = 0.1
--	t |/_____/____\ walk 
--       velocity
--
	local relativeVelocity = character.velocity / character.maxVelocity
	local maxWeight = 1.0
	local threshold = 0.65
	local walkWeight = 0.0
	local runWeight = 0.0
	if (relativeVelocity <= threshold) then 	-- threshold for run-start
		walkWeight = maxWeight * (relativeVelocity / threshold)
	else
		walkWeight = maxWeight * (1.0 - ((relativeVelocity - threshold) / (1.0 - threshold)))
		runWeight = maxWeight - walkWeight		-- runweight is inverse to walk
	end
	character.ac:setMasterWeight("Walk", walkWeight)
	DebugRenderer:printText(Vec2(-0.9, 0.65), "walkWeight " .. string.format("%6.3f", walkWeight))
	character.ac:setMasterWeight("Run", runWeight)
	DebugRenderer:printText(Vec2(-0.9, 0.60), "runWeight " .. string.format("%6.3f", runWeight))
	
	-- attack
	if (character.activeAttack == 0) then	-- only if no character-attack is active
		DebugRenderer:printText(Vec2(-0.9, 0.50), "character.activeAttack none")
		if (InputHandler:wasTriggered(Key.Space)) then
			character.activeAttack = math.random(1, #character.attacks)	-- chose random attack
			character.ac:setLocalTimeNormalized(character.attacks[character.activeAttack], 0.0) 	-- reset chosen attack-anim
			character.ac:easeIn(character.attacks[character.activeAttack], 0.25) 	-- blend animation in 
			character.ac:easeOut("Walk", 0.25) 	-- blend walk out
			character.ac:easeOut("Run", 0.25) 	-- blend run out
		end
	else
		DebugRenderer:printText(Vec2(-0.9, 0.50), "character.activeAttack " .. character.attacks[character.activeAttack])
		local localTimeNormalized = character.ac:getLocalTimeNormalized(character.attacks[character.activeAttack]) -- anim-time
		DebugRenderer:printText(Vec2(-0.9, 0.45), "getLocalTimeNormalized " .. string.format("%6.3f", localTimeNormalized))
		if (localTimeNormalized > 0.75) then  -- is the animation 75% done?
			character.ac:easeOut(character.attacks[character.activeAttack], 0.25) -- blend the attack-animation out 
			character.ac:easeIn("Walk", 0.25) -- blend walk / run back in
			character.ac:easeIn("Run", 0.25)
			character.activeAttack = 0
		end
	end
end

function defaultUpdate(updateData)

	local elapsedTime = updateData:getElapsedTime() / 1000.0
	
	cameraUpdate(elapsedTime)
	characterUpdate(elapsedTime)

	return EventResult.Handled
end

State{
	name = "default",
	parent = "/game/gameRunning",
	eventListeners = {
		enter = { defaultEnter },
		update = { defaultUpdate }
	}
}

StateTransitions{
	parent = "/game/gameRunning",
	{ from = "__enter", to = "default" },
}
