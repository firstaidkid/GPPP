print("running updates")

function homePlanetEnter()

	-- homeWorld.ac:setReferencePoseWeightThreshold(0.1)
	
	-- homeWorld.ac:easeIn(homeWorld.idles[1], 0.0)
	
	-- homeWorld.ac:setBoneDebugDrawingEnabled(true)
end

function characterEnter()

	character.ac:setReferencePoseWeightThreshold(0.1)
	
	character.ac:easeIn(character.idles[1], 0.0)
	
	-- set attack animation weights
	character.ac:setMasterWeight(character.attacks[1], 1.0)
	character.ac:easeOut(character.attacks[1], 0.0)	
	
	character.ac:setBoneDebugDrawingEnabled(true)
end

function nextGUID()
	local guid_string = tostring(guid)
	guid = guid + 1
	return guid_string
end

function defaultEnter(enterData)
	characterEnter()
	homePlanetEnter()
	
	return EventResult.Handled
end

function defaultUpdate(updateData)
	local elapsedTime = updateData:getElapsedTime() / 1000.0
	
	--updateHomePlanet()
	updateCharacter()
	updatePlanet(planetArr[1])
	updatePlanet(planetArr[2])

	return EventResult.Handled
end

function updateHomePlanet()
	local impulse = Vec3(0,0,0)
	local acceleration = 100
	local characterUpDirection = character.go:getUpDirection()
	-- local planetPosition = homeWorld.go:getWorldPosition()

	
	-- Kraft auf den Planeten

	-- handleScreenBorder(homeWorld.go)
	--DebugRenderer:printText(Vec2(-0.9, 0.65), "homeWorld: x " .. string.format("%.2f", planetPosition.x) .. ", y " .. string.format("%.2f", planetPosition.y) .. ", z " .. string.format("%.2f", planetPosition.z))
end

function updateCharacter(  )
	-- body
	--DebugRenderer:printText(Vec2(-0.9, 0.7), "updateCharacter ")

	local impulse = Vec3(0,0,0)
	local acceleration = 400
	local rotation = Vec3(0,0,0)



 	local view = character.go:getViewDirection()

 	local characterUpDirection = character.go:getUpDirection()
 	local quaternion = Quaternion(characterUpDirection, 0)

	DebugRenderer:drawArrow(view, view:mulScalar(150) )

	if(InputHandler:isPressed(Key.S)) then
		impulse.y = acceleration * view.y
		impulse.x = acceleration * view.x
		impulse.z = acceleration * view.z
	end
	if(InputHandler:isPressed(Key.W)) then
		impulse.y = -acceleration * view.y
		impulse.x = -acceleration * view.x
		impulse.z = -acceleration * view.z
	end
	
	if(InputHandler:isPressed(Key.S) or InputHandler:isPressed(Key.W)) then
		character.ac:easeIn("Walk", 0.0)
		character.ac:easeOut(character.idles[1], 0.0)
	else
		character.ac:easeIn(character.idles[1], 0.0)
		character.ac:easeOut("Walk", 0.0)
	end
	if(InputHandler:isPressed(Key.A)) then
		--rotation.z = -2
		quaternion = Quaternion(characterUpDirection, 1)
		--impulse.x = -acceleration
	end
	if(InputHandler:isPressed(Key.D)) then
		--rotation.z = 2
		--impulse.x = acceleration
		quaternion = Quaternion(characterUpDirection, -1)
	end
	
	if (character.activeAttack == 0) then
		if(InputHandler:isPressed(Key.Space)) then
			character.activeAttack = 1
			character.ac:setLocalTimeNormalized(character.attacks[1], 0.0)
			character.ac:easeIn(character.attacks[1], 0.0)
			character.ac:easeOut(character.idles[1], 0.0)
			character.ac:easeOut("Walk", 0.25)
			if (InputHandler:isPressed(Key.Shift)) then
				
				-- homeWorld.rb:applyForce(0.5, characterUpDirection:mulScalar(-50000))
				homeWorld.rb:setLinearVelocity(characterUpDirection:mulScalar(200))
			else
				
				-- homeWorld.rb:applyForce(0.5, characterUpDirection:mulScalar(-10000))
				homeWorld.rb:setLinearVelocity(characterUpDirection:mulScalar(-200))
			end
		end
	else
		local localTimeNormalized = character.ac:getLocalTimeNormalized(character.attacks[1])
		if (localTimeNormalized > 0.75) then
			character.ac:easeOut(character.attacks[character.activeAttack], 0.25)
			character.ac:easeIn("Walk", 0.25)
			character.activeAttack = 0
		end
	end
	
	impulse = impulse + (homeWorld.go:getWorldPosition() - character.go:getWorldPosition()):mulScalar(100)


	character.rb:applyLinearImpulse(impulse)

	character.go:setRotation(quaternion * character.go:getWorldRotation())

	--character.rb:setAngularVelocity(rotation)

	charPos = character.go:getWorldPosition()
	
	updateShortDistance()

end

function getShortDistance()
	
	local vec = (homeWorld.go:getWorldPosition() - planetArr[1].go:getWorldPosition())
	local sDistance = vec.x*vec.x+vec.y*vec.y+vec.z*vec.z
	local check = 0
	for i = 2, planetAmount, 1 do
		vec = (homeWorld.go:getWorldPosition() - planetArr[i].go:getWorldPosition())
		tempDistance = vec.x*vec.x+vec.y*vec.y+vec.z*vec.z
		if (sDistance > tempDistance) then
			sDistance = tempDistance
			nearestPlanet = i
			check = 1
		end
	end
	if (check == 0) then
		nearestPlanet = 1
	end
	return sDistance
end

function updateShortDistance()
	-- lenght of Vector sqrt(x²,y²,z²)
	
	local entfQuad = getShortDistance()
	
	-- local distanceVec = (homeWorld.go:getWorldPosition() - planetArr[1].go:getWorldPosition())
	-- local entfQuad = distanceVec.x * distanceVec.x + distanceVec.y * distanceVec.y + distanceVec.z * distanceVec.z
	local entf = math.sqrt(entfQuad)
	
	DebugRenderer:printText(Vec2(-0.5, 0.75), "  Entfernung: " .. string.format("%5.2f", entf))
	
	
	
	DebugRenderer:drawArrow(homeWorld.go:getWorldPosition(), planetArr[nearestPlanet].go:getWorldPosition() )

end


function updatePlanet(planet)
	local impulse = Vec3(0,0,0)
	local acceleration = 5
	local PlanetPosition = planet.go:getWorldPosition()
	local homeWorldPosition = homeWorld.go:getWorldPosition()
	local gravPlanet = (PlanetPosition - homeWorldPosition):mulScalar(1)
	
	-- Gravity to Planet
	gravity = inGravityZone(planet)
	if(gravity > 0) then
		impulse = (impulse + gravPlanet):mulScalar(0.000001 * gravity)
	end
	
	-- Kraft auf den Planeten
	local grav = homeWorld.rb:getLinearVelocity()
	homeWorld.rb:setLinearVelocity(grav + impulse)
	
end

-- Collision Detection in Gravity Sphere return a Value of the Power
-- the return value make a smoothy gravity
function inGravityZone(planet)
	-- x²+y²+z² < r1²+r2²+2*r1*r2
	local gravityHomePlanet = (homeWorld.go:getWorldPosition() - planet.go:getWorldPosition())
	-- x²+y²+z² 
	local quadDistance = gravityHomePlanet.x * gravityHomePlanet.x + gravityHomePlanet.y * gravityHomePlanet.y + gravityHomePlanet.z * gravityHomePlanet.z
	-- r1²+r2²+2*r1*r2  -------- RadiusPlanet = 100 RadiusHomePlanet = 50
	local planetSize = planet.size * 1.5;
	local radiusDistance = homeWorldSize*homeWorldSize + planetSize*planetSize + 2*homeWorldSize*planetSize
	if(quadDistance < radiusDistance) then
		return radiusDistance - quadDistance
	else
		return 0
	end
end


-- NEU

--
-- Debug CAM
--

function debugCamEnter(enterData)

	characterEnter()
	homePlanetEnter()

	debugCam:setComponentStates(ComponentState.Active)
	return EventResult.Handled
end

function debugCamUpdate(updateData)

	-- für Updates
	defaultUpdate(updateData)
	--
	
	DebugRenderer:printText(Vec2(-0.9, 0.85), "debugCamUpdate")

	local mouseDelta = InputHandler:getMouseDelta()
	local rotationSpeed = 0.2 * updateData:getElapsedTime()
	local lookVec = mouseDelta:mulScalar(rotationSpeed)
	debugCam.cc:look(lookVec)
	
	local moveVec = Vec3(0.0, 0.0, 0.0)
	local moveSpeed = 0.5 * updateData:getElapsedTime()
	if (InputHandler:isPressed(Key.Shift)) then
		moveSpeed = moveSpeed * 5
	end
	if (InputHandler:isPressed(Key.Up)) then
		moveVec.y = moveSpeed
	elseif (InputHandler:isPressed(Key.Down)) then
		moveVec.y = -moveSpeed
	end
	if (InputHandler:isPressed(Key.Left)) then
		moveVec.x = -moveSpeed
	elseif (InputHandler:isPressed(Key.Right)) then
		moveVec.x = moveSpeed
	end
	debugCam.cc:move(moveVec)
	
	local pos = debugCam.cc:getWorldPosition()
	DebugRenderer:printText(Vec2(-0.9, 0.80), "  pos: " .. string.format("%5.2f", pos.x) .. ", " .. string.format("%5.2f", pos.y) .. ", " .. string.format("%5.2f", pos.z))
	local dir = debugCam:getViewDirection()
	DebugRenderer:printText(Vec2(-0.9, 0.75), "  dir: " .. string.format("%5.2f", dir.x) .. ", " .. string.format("%5.2f", dir.y) .. ", " .. string.format("%5.2f", dir.z))
	
	return EventResult.Handled
end

--
-- normal Cam
--

function normalCamFirstPersonEnter(enterData)
	normalCam.firstPerson:setComponentStates(ComponentState.Active)
	character.go.firstPersonMode = true
	return EventResult.Handled
end

function normalCamFirstPersonUpdate(updateData)
	
	-- für Updates
	defaultUpdate(updateData)
	--

	DebugRenderer:printText(Vec2(-0.9, 0.85), "firstPerson")
	local camPos = character.go:getWorldPosition() + Vec3(0.0, 0.0, 10.0)
	normalCam.firstPerson.cc:setPosition(camPos)
	normalCam.firstPerson.cc:lookAt(camPos + character.go:getViewDirection():mulScalar(100.0) + Vec3(0.0, 0.0, character.go.viewUpDown))
	return EventResult.Handled
end

function normalCamFirstPersonLeave(leaveData)
	character.go.firstPersonMode = false
	return EventResult.Handled
end

function normalCamThirdPersonEnter(enterData)
	normalCam.thirdPerson:setPosition(normalCam.thirdPerson.calcPosTo())
	normalCam.thirdPerson:setComponentStates(ComponentState.Active)
	return EventResult.Handled
end

function normalCamThirdPersonUpdate(updateData)

	-- für Updates
	defaultUpdate(updateData)
	--

	DebugRenderer:printText(Vec2(-0.9, 0.85), "thirdPerson")
	local camPosTo = normalCam.thirdPerson.calcPosTo()
	local camPosIs = normalCam.thirdPerson:getWorldPosition()
	local camPosVel = camPosTo - camPosIs
	if (camPosVel:length() > 1.0 ) then
		normalCam.thirdPerson.pc.rb:setLinearVelocity(camPosVel:mulScalar(2.5))
	end
	normalCam.thirdPerson.cc:lookAt(character.go:getWorldPosition() + Vec3(0.0, 0.0, 30.0))
	return EventResult.Handled
end


function normalCamIsometricEnter(enterData)
	normalCam.isometric:setComponentStates(ComponentState.Active)
	return EventResult.Handled
end

function normalCamIsometricUpdate(updateData)

	-- für Updates
	defaultUpdate(updateData)
	--
	
	DebugRenderer:printText(Vec2(-0.9, 0.85), "isometric")
	local rotationSpeed = 0.05 * updateData:getElapsedTime()
	local mouseDelta = InputHandler:getMouseDelta()
	mouseDelta.x = mouseDelta.x * rotationSpeed
	mouseDelta.y = 0.0
	normalCam.isometric.cc:look(mouseDelta)
	local viewDir = normalCam.isometric.cc:getViewDirection()
	viewDir = viewDir:mulScalar(-750.0)
	viewDir.z = 125.0
	normalCam.isometric.cc:setPosition(character.go:getWorldPosition() + viewDir)
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

State{
	name = "debugCam",
	parent = "/game/gameRunning",
	eventListeners = {
		update = { debugCamUpdate },
		enter = { debugCamEnter }
	}
}

StateMachine{
	name = "normalCam(fsm)",
	parent = "/game/gameRunning",
	states = {
		{
			name = "firstPerson",
			eventListeners = {
				update = { normalCamFirstPersonUpdate },
				enter = { normalCamFirstPersonEnter },
				leave = { normalCamFirstPersonLeave }
			},
		},
		{
			name = "thirdPerson",
			eventListeners = {
				update = { normalCamThirdPersonUpdate },
				enter = { normalCamThirdPersonEnter }
			},
		},
		{
			name = "isometric",
			eventListeners = {
				update = { normalCamIsometricUpdate },
				enter = { normalCamIsometricEnter }
			},
		},
	},
	transitions = {
		{ from = "__enter", to = "firstPerson" },
		{ from = "firstPerson", to = "thirdPerson", condition = function() return InputHandler:wasTriggered(Key.V) end },
		{ from = "thirdPerson", to = "isometric", condition = function() return InputHandler:wasTriggered(Key.V) end },
		{ from = "isometric", to = "firstPerson", condition = function() return InputHandler:wasTriggered(Key.V) end }
	}
}

StateTransitions{
	parent = "/game/gameRunning",
	{ from = "__enter", to = "debugCam" },
	--{ from = "default", to = "debugCam", condition = function() return InputHandler:wasTriggered(Key.C) end },
	{ from = "debugCam", to = "normalCam(fsm)", condition = function() return InputHandler:wasTriggered(Key.C) end },
	{ from = "normalCam(fsm)", to = "debugCam", condition = function() return InputHandler:wasTriggered(Key.C) end }
}

StateTransitions{
	parent = "/game",
	{ from = "gameRunning", to = "__leave", condition = function() return InputHandler:wasTriggered(Key.Q) end }
}