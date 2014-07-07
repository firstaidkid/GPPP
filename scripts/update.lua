print("running updates")

local acceleration = 0
local velocityDirection = Vec3(0, 0, 0)

function homePlanetEnter()

	-- ## for Animations + Skaling

	-- homeplanetBody.ac:setReferencePoseWeightThreshold(0.1)
	-- homeplanetBody.ac:easeIn(homeplanetBody.idles[1], 0.0)
	-- homeplanetBody.ac:setBoneDebugDrawingEnabled(true)
end

function characterEnter()

	-- ## for Animations + Skaling
	
	character.ac:setReferencePoseWeightThreshold(0.1)
	character.ac:easeIn(character.idles[1], 0.0)
	-- set attack animation weights
	character.ac:setMasterWeight(character.attacks[1], 1.0)
	character.ac:easeOut(character.attacks[1], 0.0)	
	character.ac:setBoneDebugDrawingEnabled(true)
	
	character.ac:setPlaybackSpeed("Walk", 3)
end



function defaultEnter(enterData)
	characterEnter()
	homePlanetEnter()
	
	return EventResult.Handled
end

function defaultUpdate(updateData)
	local elapsedTime = updateData:getElapsedTime() / 1000.0
	

	updateCharacter(elapsedTime)
	--updateLevel(elapsedTime)
	planetUpdate(elapsedTime)
	for i=1 , numberOfPlanets do
		updatePlanet(planetArr[i])
	end
	
	--updateShortDistance()


	return EventResult.Handled
end


function updateCharacter(  )


	DebugRenderer:printText(Vec2(-0.5, 0.25), "  acceleration: " .. tostring(acceleration))

	local impulse = Vec3(0,0,0)
 	local characterUpDirection = character.go:getUpDirection()
	local characterRightDirection 	= 	character.go:getRightDirection()
 	local quaternion = Quaternion(characterUpDirection, 0)
	
	if (currentGrow < growAim)then
		grow(currentGrow+1)
	elseif(currentGrow>growAim)then
		grow(currentGrow-1)
	end

	
	if(InputHandler:isPressed(Key.S) or InputHandler:isPressed(Key.W)) then
		character.ac:easeIn("Walk", 0.0)
		character.ac:easeOut(character.idles[1], 0.0)
	else
		character.ac:easeIn(character.idles[1], 0.0)
		character.ac:easeOut("Walk", 0.0)
	end
	
		--Key Events
	if(InputHandler:isPressed(Key.S)) then
		--quaternion = Quaternion(characterRightDirection, -2)
		--homeplanetBody.go:setRotation(quaternion * homeplanetBody.go:getWorldRotation())
	end
	if(InputHandler:isPressed(Key.W)) then
		--quaternion = Quaternion(characterRightDirection, 2)
		--homeplanetBody.go:setRotation(quaternion * homeplanetBody.go:getWorldRotation())
	end
	if(InputHandler:isPressed(Key.A)) then
		--quaternion = Quaternion(characterUpDirection, 3)
		--homeplanetBody.go:setRotation(quaternion * homeplanetBody.go:getWorldRotation())
	end
	if(InputHandler:isPressed(Key.D)) then
		--quaternion = Quaternion(characterUpDirection, -3)
		--homeplanetBody.go:setRotation(quaternion * homeplanetBody.go:getWorldRotation())
	end
	if(InputHandler:isPressed(Key.Q) or InputHandler:isPressed(Key.A) or InputHandler:isPressed(Key.Left)) then
		quaternion = Quaternion(homeplanetBody.go:getViewDirection(), -2)
		homeplanetBody.go:setRotation(quaternion * homeplanetBody.go:getWorldRotation())
	end
	if(InputHandler:isPressed(Key.E)  or InputHandler:isPressed(Key.D) or InputHandler:isPressed(Key.Right)) then
		quaternion = Quaternion(homeplanetBody.go:getViewDirection(), 2)
		homeplanetBody.go:setRotation(quaternion * homeplanetBody.go:getWorldRotation())
	end
	
	if (character.activeAttack == 0) then
		if(InputHandler:isPressed(Key.Space)) then
			character.activeAttack = 1
			character.ac:setLocalTimeNormalized(character.attacks[1], 0.0)
			character.ac:easeIn(character.attacks[1], 0.0)
			character.ac:easeOut(character.idles[1], 0.0)
			character.ac:easeOut("Walk", 0.25)
			if (InputHandler:isPressed(Key.Shift)) then
				
				-- homeplanetBody.rb:applyForce(0.5, characterUpDirection:mulScalar(-50000))
				homeplanetBody.rb:setLinearVelocity(characterUpDirection:mulScalar(200))
			else
				if(acceleration>-250)then
					acceleration = acceleration - 6
				end

				velocityDirection = characterUpDirection:mulScalar(acceleration)

				
				-- homeplanetBody.rb:applyForce(0.5, characterUpDirection:mulScalar(-10000))
				
			end
		end
	else
		--local localTimeNormalized = character.ac:getLocalTimeNormalized(character.attacks[1])
		--if (localTimeNormalized > 0.75) then
			character.ac:easeOut(character.attacks[character.activeAttack], 0.25)
			character.ac:easeIn("Walk", 0.25)
			character.activeAttack = 0
		--end
	end

	if(acceleration<-2)then
		acceleration = acceleration + 1
	end
	--characterUpDirection:mulScalar(acceleration)
	homeplanetBody.rb:setLinearVelocity(velocityDirection)
	impulse = impulse + (homeplanetBody.go:getWorldPosition() - character.go:getWorldPosition()):mulScalar(10)

	-- Model verfolgt HauptPlanet
	homePlanetModel.go:setPosition(homeplanetBody.go:getWorldPosition())



	bgOffset = homeplanetBody.go:getWorldPosition()
	bg.go:setPosition(Vec3(bgOffset.x, 3000, bgOffset.z - 6000 ))

end

function getShortDistance()
	
	local vec = (homeplanetBody.go:getWorldPosition() - planetArr[1].go:getWorldPosition())
	local sDistance = vec.x*vec.x+vec.y*vec.y+vec.z*vec.z
	local check = 0
	local positionHP = homeplanetBody.go:getWorldPosition()
	for i = 2, numberOfPlanets do
		vec = (positionHP - planetArr[i].go:getWorldPosition())
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
	
	-- local distanceVec = (homeplanetBody.go:getWorldPosition() - planetArr[1].go:getWorldPosition())
	-- local entfQuad = distanceVec.x * distanceVec.x + distanceVec.y * distanceVec.y + distanceVec.z * distanceVec.z
	local entf = math.sqrt(entfQuad)
	
	DebugRenderer:printText(Vec2(-0.5, 0.75), "  Entfernung: " .. string.format("%5.2f", entf))
	
	
	
	DebugRenderer:drawArrow(homeplanetBody.go:getWorldPosition(), planetArr[nearestPlanet].go:getWorldPosition() )

end


function updatePlanet(planet)
	-- local impulse = Vec3(0,0,0)
	-- local acceleration = 5
	-- local PlanetPosition = planet.go:getWorldPosition()
	-- local homeWorldPosition = homeplanetBody.go:getWorldPosition()
	-- local gravPlanet = (PlanetPosition - homeWorldPosition):mulScalar(1)
	
	-- Gravity to Planet
	-- gravity = inGravityZone(planet)
	-- if(gravity > 0) then
		-- impulse = (impulse + gravPlanet):mulScalar(0.0000009 * gravity)
	-- end
	
	-- Kraft auf den Planeten
	-- local grav = homeplanetBody.rb:getLinearVelocity()
	-- homeplanetBody.rb:setLinearVelocity(grav + impulse)
	

	pos = planet.go:getWorldPosition()

	if(math.abs(pos.x) > REAL_WORLD_SIZE)then
		print("reposition planet")
		local position = Vec3(0, 0, 0)
		planet.go:setPosition(position)

	end


	--print("position: " .. pos.x .. ", " .. pos.z)


	
	if(planet.go.isGone) then
		if(currentCollider.go.size>planet.go.size)then
			print("planet collided : " .. tostring( planet.go.size))
			print("homeplanet Size: " .. tostring( currentCollider.go.size))

			if(growAim<maxSize)then
				growAim = growAim + 1
			end

			local position = Vec3(math.random(-WORLD_SIZE, WORLD_SIZE), 0, math.random(-WORLD_SIZE, WORLD_SIZE))
			planet.go:setPosition(position)
			planet.go.isGone = false
		end
		
	end

	--local planetVelocity = Vec3(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))

	--planetArr[number].rb:setLinearVelocity(planetVelocity)
	--planet.rb:applyForce(0.5, planetVelocity)


end

function planetUpdate( updateData )
	-- body


	if(InputHandler:isPressed(Key._1)) then
		growAim = 10
	elseif(InputHandler:isPressed(Key._2)) then
		growAim = 20
	elseif(InputHandler:isPressed(Key._3)) then
		growAim = 30
	elseif(InputHandler:isPressed(Key._4)) then
		growAim = 40
	elseif(InputHandler:isPressed(Key._5)) then
		growAim = 50
	elseif(InputHandler:isPressed(Key._6)) then
		growAim = 60
	elseif(InputHandler:isPressed(Key._7)) then
		growAim = 70
	elseif(InputHandler:isPressed(Key._8)) then
		growAim = 80
	elseif(InputHandler:isPressed(Key._9)) then
		growAim = 90
	end


	return EventResult.Handled
end

-- Collision Detection in Gravity Sphere return a Value of the Power
-- the return value make a smoothy gravity
function inGravityZone(planet)
	-- x²+y²+z² < r1²+r2²+2*r1*r2
	local gravityHomePlanet = (homeplanetBody.go:getWorldPosition() - planet.go:getWorldPosition())
	-- x²+y²+z² 
	local quadDistance = gravityHomePlanet.x * gravityHomePlanet.x + gravityHomePlanet.y * gravityHomePlanet.y + gravityHomePlanet.z * gravityHomePlanet.z
	-- r1²+r2²+2*r1*r2  -------- RadiusPlanet = 100 RadiusHomePlanet = 50
	local planetSize = planet.size * 2;
	local radiusDistance = homeWorldSize*homeWorldSize + planetSize*planetSize + 2*homeWorldSize*planetSize
	if(quadDistance < radiusDistance) then
		return radiusDistance - quadDistance
	else
		return 0
	end
end


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
	
	--DebugRenderer:printText(Vec2(-0.9, 0.85), "debugCamUpdate")

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
	--DebugRenderer:printText(Vec2(-0.9, 0.80), "  pos: " .. string.format("%5.2f", pos.x) .. ", " .. string.format("%5.2f", pos.y) .. ", " .. string.format("%5.2f", pos.z))
	local dir = debugCam:getViewDirection()
	--DebugRenderer:printText(Vec2(-0.9, 0.75), "  dir: " .. string.format("%5.2f", dir.x) .. ", " .. string.format("%5.2f", dir.y) .. ", " .. string.format("%5.2f", dir.z))
	
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

	--DebugRenderer:printText(Vec2(-0.9, 0.85), "firstPerson")
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

	--DebugRenderer:printText(Vec2(-0.9, 0.85), "thirdPerson")
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
	
	--DebugRenderer:printText(Vec2(-0.9, 0.85), "isometric")
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

function isBehindPlanet(posPlayer, posCamera, posPlanet, radiusPlanet)
	local epsilon = -75 * character_size * radiusPlanet

	-- calculating components
	local a = posPlayer:normalized() * (posCamera - posPlanet)
	local b = (posCamera - posPlanet)
	local c = radiusPlanet

	-- putting stuff together
	local check = a:squaredLength() - b:squaredLength() + c

	-- returning 
	if(check < epsilon) then
		return false
	else
		return true 
	end	
end	

function normalCamIsometricUpdate(updateData)

	-- für Updates
	defaultUpdate(updateData)
	--
	
	player = character.go:getWorldPosition()
	camera = normalCam.isometric.cc:getWorldPosition()
	middle = homeplanetBody.go:getWorldPosition()
	radius = homeWorldSize

   -- logMessage("[player x=" .. round(player.x, 1) .. ", y=" .. round(player.y, 1) .. ", z=" .. round(player.z, 1) .. "]")
 --	logMessage("[camera x=" .. round(camera.x, 1) .. ", y=" .. round(camera.y, 1) .. ", z=" .. round(camera.z, 1) .. "]")
--	logMessage("[planet x=" .. round(middle.x, 1) .. ", y=" .. round(middle.y, 1) .. ", z=" .. round(middle.z, 1) .. homeWorldSize .. "]")

	local behind = isBehindPlanet(character.go:getWorldPosition(), normalCam.isometric.cc:getWorldPosition(), homeplanetBody.go:getWorldPosition(), homeWorldSize)

	if(not (behind == homeplanetBody.wasPreviouslyBehind)) then
		if(behind) then
				homePlanetModel.rc:updatePath("data/models/space/nibiru_50_mario.thModel") 
		else
				homePlanetModel.rc:updatePath("data/models/space/nibiru_50.thModel")
		end	
	end
	

	homeplanetBody.wasPreviouslyBehind = behind

	


	-- DebugRenderer:printText(Vec2(-0.9, 0.85), "isometric")
	local rotationSpeed = 0.1 * math.atan(homeWorldSize) * updateData:getElapsedTime()
	local mouseDelta = InputHandler:getMouseDelta()

	mouseDelta.x = mouseDelta.x * rotationSpeed * 1000
	mouseDelta.y = mouseDelta.y * rotationSpeed * 1000
	normalCam.isometric.cc:look(mouseDelta)
	local viewDir = normalCam.isometric.cc:getViewDirection()

	viewDir = viewDir:mulScalar(math.atan(homeWorldSize) * -(500.0 +currentGrow*20))
	normalCam.isometric.cc:setPosition(character.go:getWorldPosition() + viewDir)



		-- local rayIn = RayCastInput()
		-- rayIn.from = normalCam.isometric.cc:getWorldPosition()
		-- rayIn.to = player - normalCam.isometric.cc:getWorldPosition()

	   
		-- DebugRenderer:drawArrow(rayIn.from, rayIn.to, Color(1,0,0,1))
		-- local rayOut =  world:castRay(rayIn)

		
		-- DebugRenderer:printText(Vec2(-0.9, 0.85),"Hit: " .. tostring(rayOut:hasHit()), Color(1,0,0,1))
		
		if(InputHandler:isPressed(Key.H)) then
			spawnDebris(Vec3(100,100,100), Vec3(1,1,1):normalized())
		end


		if(debris.visible) then
			debris.timer = debris.timer + updateData:getElapsedTime()

			if(debris.timer > debris.maxTime) then
				resetDebris(0.1)
			end
		end



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
			name = "isometric",
			eventListeners = {
				update = { normalCamIsometricUpdate },
				enter = { normalCamIsometricEnter }
			},
		},
	},
	transitions = {
		{ from = "__enter", to = "isometric" },
		
	}
}

StateTransitions{
	parent = "/game/gameRunning",
	{ from = "__enter", to = "debugCam" },
	--{ from = "default", to = "debugCam", condition = function() return InputHandler:wasTriggered(Key.C) end },
	{ from = "debugCam", to = "normalCam(fsm)", condition = function() return InputHandler:wasTriggered(Key.C) end },
	{ from = "normalCam(fsm)", to = "debugCam", condition = function() return InputHandler:wasTriggered(Key.C) end }
}

--StateTransitions{
	--parent = "/game",
	--{ from = "gameRunning", to = "__leave", condition = function() return InputHandler:wasTriggered(Key.Q) end }
--}