print("running updates")

function nextGUID()
	local guid_string = tostring(guid)
	guid = guid + 1
	return guid_string
end

function defaultUpdate(updateData)
	local elapsedTime = updateData:getElapsedTime() / 1000.0

	updateHomePlanet()
	updateCharacter()
	updatePlanet(planet)
	updatePlanet(planetTwo)

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

function updateHomePlanet()
	local impulse = Vec3(0,0,0)
	local acceleration = 100
	-- local planetPosition = homeWorld.go:getPosition()
	
	if(InputHandler:isPressed(Key.W)) then
		impulse.x = acceleration
	end
	if(InputHandler:isPressed(Key.S)) then
		impulse.x = -acceleration
	end
	if(InputHandler:isPressed(Key.A)) then
		impulse.y = acceleration
	end
	if(InputHandler:isPressed(Key.D)) then
		impulse.y = -acceleration
	end
	
	-- Kraft auf den Planeten
	homeWorld.rb:setLinearVelocity(impulse)

	-- handleScreenBorder(homeWorld.go)
	--DebugRenderer:printText(Vec2(-0.9, 0.65), "homeWorld: x " .. string.format("%.2f", planetPosition.x) .. ", y " .. string.format("%.2f", planetPosition.y) .. ", z " .. string.format("%.2f", planetPosition.z))
end

function updateCharacter(  )
	-- body
	DebugRenderer:printText(Vec2(-0.9, 0.7), "updateCharacter ")

	local impulse = Vec3(0,0,0)
	local acceleration = 50
	local rotationSpeed = 50
	local rotation = Vec3(0,0,0)
	local temp
	-- Vector of gravitation
	local gravPlanet = (homeWorld.go:getWorldPosition() - character.go:getWorldPosition()):mulScalar(15)
	
	local view = character.go:getViewDirection()
	
	local viewDirection = Vec3(0,0,0)
	-- um 90° drehen
		viewDirection.z = view.y
		viewDirection.y = -view.z
		viewDirection.x = view.x
	-- //

	if(InputHandler:isPressed(Key.Up)) then
		-- um 90° drehen
		-- temp = view.z
		-- view.z = view.y
		-- view.y = -temp
		-- //
		impulse = (impulse + viewDirection):mulScalar(acceleration)
	end
	if(InputHandler:isPressed(Key.Down)) then
		impulse = (impulse - viewDirection):mulScalar(acceleration)
	end
	if(InputHandler:isPressed(Key.Left)) then
		rotation.x = viewDirection.y
		rotation.y = -viewDirection.x
		rotation.z = viewDirection.z
		rotation = rotation:mulScalar(acceleration)
		-- rotation.z = rotationSpeed
	end
	if(InputHandler:isPressed(Key.Right)) then
		rotation.z = -rotationSpeed
	end

	impulse = impulse + gravPlanet


	character.rb:applyLinearImpulse(impulse)

	character.rb:applyAngularImpulse(rotation)

	if(InputHandler:isPressed(Key.Space) and character.grounded) then
		character.rb:applyForce(0.5, Vec3(0,0,15000))
	end

	charPos = character.go:getWorldPosition()

	-- camera.cc:setPosition(Vec3(charPos.x, charPos.y - 500, charPos.z + 100));
	-- camera.cc:lookAt(charPos)
	
	--handleScreenBorder(character.go)
	DebugRenderer:printText(Vec2(-0.9, 0.75), "character: x " .. string.format("%.2f", charPos.x) .. ", y " .. string.format("%.2f", charPos.y) .. ", z " .. string.format("%.2f", charPos.z))
	DebugRenderer:printText(Vec2(-0.9, 0.55), "characterView: x " .. string.format("%.2f", viewDirection.x) .. ", y " .. string.format("%.2f", viewDirection.y) .. ", z " .. string.format("%.2f", viewDirection.z))
	DebugRenderer:printText(Vec2(-0.9, 0.45), "gravPlanet: x " .. string.format("%.2f", gravPlanet.x) .. ", y " .. string.format("%.2f", gravPlanet.y) .. ", z " .. string.format("%.2f", gravPlanet.z))
end

function updatePlanet(planet)
	local impulse = Vec3(0,0,0)
	local acceleration = 5
	local PlanetPosition = planet.go:getWorldPosition()
	local homeWorldPosition = homeWorld.go:getWorldPosition()
	local gravPlanet = (PlanetPosition - homeWorldPosition):mulScalar(15)
	
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
	local radiusDistance = homeWorldSize*homeWorldSize + planetSize*planetSize + 2*homeWorldSize*planetSize
	if(quadDistance < radiusDistance) then
		return radiusDistance - quadDistance
	else
		return 0
	end
end

function collisionCharacter( event )
	-- body
	DebugRenderer:printText(Vec2(-0.9, 0.7), "collisionCharacter ")

	if(character.rb.__ptr == event:getBody(event:getSource()).__ptr) then
		DebugRenderer:printText(Vec2(-0.9, 0.11), "jump ")
		character.grounded = true
	elseif(ground.rb.__ptr == event:getBody(event:getSource()).__ptr) then
		DebugRenderer:printText(Vec2(-0.9, 0.11), "enemy ")
		character.grounded = true
	end
end