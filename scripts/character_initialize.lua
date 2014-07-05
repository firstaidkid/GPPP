logMessage("Initializing character_initialize.lua ...")



-- physics world
local cinfo = WorldCInfo()
cinfo.gravity = Vec3(0, 0, 0)
cinfo.worldSize = 20000
world = PhysicsFactory:createWorld(cinfo)
world:setCollisionFilter(PhysicsFactory:createCollisionFilter_Simple())
PhysicsSystem:setWorld(world)
PhysicsSystem:setDebugDrawingEnabled(true)



guid = 1

maxSize = 100

growAim = 5
currentGrow = 0






PhysicsSystem:setDebugDrawingEnabled(true)

do -- debugCam
	debugCam 				= 	GameObjectManager:createGameObject("debugCam")
	debugCam.cc 			= 	debugCam:createCameraComponent()
	debugCam.cc:setPosition(Vec3(-1000.0, 0.0, 0.0))
	debugCam.cc:setViewDirection(Vec3(1.0, 0.0, 0.0))
	debugCam.baseViewDir 	= 	Vec3(1.0, 0.0, 0.0)
	debugCam.cc:setBaseViewDirection(debugCam.baseViewDir)
end


-- Create Character
do
	character = {}
	character.go = GameObjectManager:createGameObject("character")

	--character.pc = character.go:createPhysicsComponent()

	--local cinfo = RigidBodyCInfo()
	--cinfo.shape = PhysicsFactory:createBox(Vec3(20, 20, 1))
	--cinfo.motionType = MotionType.Dynamic
	--cinfo.restitution = 0
	--cinfo.friction = 0
	--cinfo.position = Vec3(0,0,500)
	--cinfo.gravityFactor = 10
	--cinfo.mass = 90
	--cinfo.maxLinearVelocity = 1000
	--cinfo.collisionFilterInfo = 0xff1f

	--cinfo.linearDamping = 1
	--cinfo.angularDamping = 1
	--character.rb = character.pc:createRigidBody(cinfo)
	character.sc = character.go:createScriptComponent()
	character.rc = character.go:createRenderComponent()
	character.rc:setPath("data/models/mario/mario.thModel")

	-- collision event
	--character.pc:getContactPointEvent():registerListener(collisionCharacter)
	--character.sc:setUpdateFunction(updateCharacter)

end



function nextGUID()
	local guid_string = "GUID" .. tostring(guid)
	guid = guid + 1
	return guid_string
end

function grow( i )
	-- body

	local characterUpDirection 	= 	character.go:getUpDirection()
	local impulse = (homeplanetBody.go:getWorldPosition() + character.go:getWorldPosition()):mulScalar(20)


	--character.rc:setScale(Vec3(i,i,i))

	-- apply impulse
	--character.go:setPosition(characterUpDirection:mulScalar(i *20))


	--targetObject:setScale(Vec3(2,2,2))
	for k,v in pairs(planets) do
		--planets[k].go:setPosition(homeplanetColliderBody.go:getWorldPosition())
		planets[k].go:setComponentStates(ComponentState.Inactive)
		collisionSpheres[k].go:setComponentStates(ComponentState.Inactive)
		if(k==i)then
			planets[k].go:setComponentStates(ComponentState.Active)
			collisionSpheres[k].go:setComponentStates(ComponentState.Active)
		end

	end
	character.go:setPosition(Vec3(0, 0, planetRadien[i]))

	homeplanetBody.rc:setScale(Vec3(i/5,i/5,i/5))

	currentGrow = i

end


-- create planet 
function create_Planet( size, type )
	-- body
	local planet 				= 	{}
	planet.go 			= 	GameObjectManager:createGameObject(nextGUID())
	planet.pc 			= 	planet.go:createPhysicsComponent()
	local cinfo 			= 	RigidBodyCInfo()
	cinfo.position 			= 	Vec3(0,0,0)
	cinfo.shape 			= 	PhysicsFactory:createSphere(size)
	cinfo.motionType 		= 	type
	cinfo.restitution 		= 	0
	cinfo.friction 			= 	0
	cinfo.gravityFactor 	= 	0
	cinfo.mass 				= 	900000
	cinfo.maxLinearVelocity = 	10000
	--cinfo.linearDamping 	= 	1
	planet.rb 			= 	planet.pc:createRigidBody(cinfo)
	return planet

end


-- create planet 
function create_random_Planet( size, type, name )
	-- body
	local planet 				= 	{}
	planet.go 			= 	GameObjectManager:createGameObject(tostring(name) )

	planet.pc 			= 	planet.go:createPhysicsComponent()
	local cinfo 			= 	RigidBodyCInfo()
	cinfo.position 			= 	Vec3(math.random(-5000,5000),math.random(-5000,5000),math.random(-5000,5000))
	--cinfo.position 			= 	Vec3(0,math.random(-5000,5000),0)
	cinfo.shape 			= 	PhysicsFactory:createSphere(size)
	cinfo.motionType 		= 	type
	cinfo.restitution 		= 	0
	cinfo.friction 			= 	0
	cinfo.gravityFactor 	= 	0
	cinfo.mass 				= 	900000
	cinfo.maxLinearVelocity = 	10000
	cinfo.collisionFilterInfo = 0xff1f
	--cinfo.linearDamping 	= 	1
	planet.rb 			= 	planet.pc:createRigidBody(cinfo)
	planet.rb:setLinearVelocity(Vec3(math.random(-50,50),math.random(-50,50),math.random(-50,50)))
	
	-- stores the table inside the rigidbody
	planet.rb:setUserData(planet)


	return planet

end


--erzeuge mehrere Kollisioner für den Planeten
function create_collisionSphere( size )
	-- body
	collisionSphere 				= 	{}
	collisionSphere.go 			= 	GameObjectManager:createGameObject(nextGUID())
	collisionSphere.pc 			= 	collisionSphere.go:createPhysicsComponent()

	local cinfo 			= 	RigidBodyCInfo()
	cinfo.position 			= 	Vec3(0,0,0)
	cinfo.shape 			= 	PhysicsFactory:createSphere(size)
	cinfo.motionType 		= 	MotionType.Keyframed
	cinfo.restitution 		= 	0
	cinfo.friction 			= 	0
	cinfo.gravityFactor 	= 	0
	cinfo.mass 				= 	900000
	cinfo.maxLinearVelocity = 	10000
	cinfo.collisionFilterInfo = 0xff1f
	cinfo.isTriggerVolume = true
	collisionSphere.rb 			= 	collisionSphere.pc:createRigidBody(cinfo)
	
	-- stores the table inside the rigidbody
	collisionSphere.rb:setUserData(collisionSphere)

	collisionSphere.rb:getTriggerEvent():registerListener(function(args)
		local go = args:getRigidBody():getUserData().go
		local rb = args:getRigidBody():getUserData().rb
		--print((int)go:getName())
		--print(go:getName())
		
		--otherPlanets[tonumber(go:getName())].go:setComponentStates(ComponentState.Inactive)
		--go:setParent(homeplanetBody.go)

		if(growAim<maxSize)then
			--print("grow")
			--growAim = growAim + 1
		end

		
		--print(GameObjectManager:getGameObject(go:getName()):
		--GameObjectManager:getGameObject(go:getName()):setComponentStates(ComponentState.Inactive)
		if args:getEventType() == TriggerEventType.Entered then
			print("Hit " .. go:getName())
			rb:setLinearVelocity(Vec3(math.random(-50,50),math.random(-50,50),math.random(-50,50)))
			go:setComponentStates(ComponentState.Inactive)
			--go:setPosition(Vec3(0,0,0))
--			--local hitDir = axe:getViewDirection()
			--local hitDir = axe:getUpDirection()
			--go.pc.rb:applyLinearImpulse(hitDir:mulScalar(-50000.0))
		elseif args:getEventType() == TriggerEventType.Left then
			print("Not hitting " .. go:getName() .. " anymore.")
		end
		return EventResult.Handled
	end)
	collisionSphere.go:setParent(homeplanetBody.go)

	return collisionSphere
end








do
	--Create Little Home Planet
	homeplanetBody 				= 	{}
	homeplanetBody.go 			= 	GameObjectManager:createGameObject("homeplanetBody")
	homeplanetBody.pc 			= 	homeplanetBody.go:createPhysicsComponent()

	local cinfo 			= 	RigidBodyCInfo()
	cinfo.position 			= 	Vec3(0,0,0)
	cinfo.shape 			= 	PhysicsFactory:createSphere(10)
	cinfo.motionType 		= 	MotionType.Dynamic
	--cinfo.motionType 		= 	MotionType.Keyframed
	cinfo.restitution 		= 	0
	cinfo.friction 			= 	0
	cinfo.gravityFactor 	= 	0
	cinfo.mass 				= 	900000
	cinfo.maxLinearVelocity = 	10000


	homeplanetBody.sc = homeplanetBody.go:createScriptComponent()
	homeplanetBody.rc = homeplanetBody.go:createRenderComponent()
	homeplanetBody.rc:setPath("data/models/space/nibiru_50.thModel")

	--cinfo.linearDamping 	= 	1
	homeplanetBody.rb 			= 	homeplanetBody.pc:createRigidBody(cinfo)
end



--Alle homeplaneten
planets = {}

-- Alle Planeten Radien
planetRadien = {}

-- Alle Collisons Planeten vom Homeplanet
collisionSpheres = {}

-- Alle anderen Planeten
otherPlanets = {}



for i=1,maxSize do 
	print(i)
	planetRadien[i] = i* 10
	planets[i] = create_Planet( planetRadien[i], MotionType.Keyframed )
	collisionSpheres[i] = create_collisionSphere(planetRadien[i])
end

for a=1,800 do 
	--print(i) 
	otherPlanets[a] = create_random_Planet( math.random(100, 200), MotionType.Dynamic, a )

end

grow( 5 )


-- create ID




character.go:setParent(homeplanetBody.go)




function round(num, idp)

	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end


















function debugCamEnter(enterData)
	debugCam:setComponentStates(ComponentState.Active)
	return EventResult.Handled
end

function debugCamUpdate(updateData)

	local mouseDelta = InputHandler:getMouseDelta()
	local rotationSpeed = 0.2 * updateData:getElapsedTime()
	local lookVec = mouseDelta:mulScalar(rotationSpeed)
	debugCam.cc:look(lookVec)


	local moveVec = Vec3(0.0, 0.0, 0.0)
	local moveSpeed = 0.5 * updateData:getElapsedTime()
	if (InputHandler:isPressed(Key.Shift)) then
		moveSpeed = moveSpeed * 5
	end
	if (InputHandler:isPressed(Key.W)) then
		moveVec.y = moveSpeed
	elseif (InputHandler:isPressed(Key.S)) then
		moveVec.y = -moveSpeed
	end
	if (InputHandler:isPressed(Key.A)) then
		moveVec.x = -moveSpeed
	elseif (InputHandler:isPressed(Key.D)) then
		moveVec.x = moveSpeed
	end
	debugCam.cc:move(moveVec)

	return EventResult.Handled
end


function characterUpdate(updateData)

	-- body
	local impulse 				= 	Vec3(0,0,0)
	local acceleration 			= 	400
	local view 					= 	character.go:getViewDirection()
 	local characterUpDirection 	= 	character.go:getUpDirection()
 	local characterRightDirection 	= 	character.go:getRightDirection()
 	local quaternion 			= 	Quaternion(characterUpDirection, 0)


	if (currentGrow < growAim)then
		grow(currentGrow+1)
	elseif(currentGrow>growAim)then
		grow(currentGrow-1)
	end

 	--raycast
 	--local rayIn 				= 	RayCastInput()
 	--rayIn.from	= homeplanetColliderBody.go:getWorldPosition() + character.go:getWorldPosition():mulScalar(2)
 	--rayIn.to = homeplanetColliderBody.go:getWorldPosition()

 	--rayIn.filterInfo = 0xff1f
 	
 	--local rayOut = world:castRay(rayIn)
	--DebugRenderer:printText(Vec2(-0.9, 0.50), "rayOut:hasHit(): " .. tostring(rayOut:hasHit()))


	--local distance = 100
	--local ray      = view:mulScalar(distance)


	--local pointOfCollision = rayIn.from + ray:mulScalar(rayOut.hitFraction)


 	--DebugRenderer:printText(Vec2(0.4, 0.55), "rayIn.from: " .. string.format("%5.2f", rayIn.from.x) .. ", " .. string.format("%5.2f", rayIn.from.y) .. ", " .. string.format("%5.2f", rayIn.from.z))
	--DebugRenderer:printText(Vec2(0.4, 0.50), "rayIn.to: " .. string.format("%5.2f", rayIn.to.x) .. ", " .. string.format("%5.2f", rayIn.to.y) .. ", " .. string.format("%5.2f", rayIn.to.z))
	--DebugRenderer:drawArrow(rayIn.from, rayIn.to, Color(1, 0, 1, 1))

 	


	--local rayOut = world:castRay(rayIn)
	--DebugRenderer:printText(Vec2(-0.9, 0.70), "rayOut:hasHit(): " .. tostring(rayOut:hasHit()))

 	--Debug View
	DebugRenderer:printText(Vec2(-0.9, 0.7), round(view.x, 2) .. " , " .. round(view.y, 2) .." , " .. round(view.z, 2))
	DebugRenderer:drawArrow(view, view:mulScalar(150) )


	--Key Events
	if(InputHandler:isPressed(Key.Up)) then
		quaternion = Quaternion(characterRightDirection, -2)
		homeplanetBody.go:setRotation(quaternion * homeplanetBody.go:getWorldRotation())
	end
	if(InputHandler:isPressed(Key.Down)) then
		quaternion = Quaternion(characterRightDirection, 2)
		homeplanetBody.go:setRotation(quaternion * homeplanetBody.go:getWorldRotation())
	end
	if(InputHandler:isPressed(Key.Left)) then
		quaternion = Quaternion(characterUpDirection, 3)
		homeplanetBody.go:setRotation(quaternion * homeplanetBody.go:getWorldRotation())
	end
	if(InputHandler:isPressed(Key.Right)) then
		quaternion = Quaternion(characterUpDirection, -3)
		homeplanetBody.go:setRotation(quaternion * homeplanetBody.go:getWorldRotation())
	end



	-- gravity to homeplanetColliderBody
	impulse = impulse + (homeplanetBody.go:getWorldPosition() - character.go:getWorldPosition()):mulScalar(10)


	-- apply impulse
	--character.rb:applyLinearImpulse(impulse)

	-- apply rotation
	


	--if(InputHandler:isPressed(Key.Space) and character.grounded) then
	--	character.rb:applyForce(0.5, Vec3(0,0,150000))
	--	character.grounded = false
	--end


	-- camera update
	charPos = character.go:getWorldPosition()


	if(InputHandler:isPressed(Key.Space)) then
		homeplanetBody.rb:setLinearVelocity(characterUpDirection:mulScalar(-100))
		--parentImpulseToChildren( characterUpDirection:mulScalar(-200) )

	--	character.grounded = false
	end

	--debugCam.cc:setPosition((homeplanetColliderBody.go:getWorldPosition() - character.go:getWorldPosition()):mulScalar(-3));
	--debugCam.cc:setPosition(Vec3(view.x*1000, view.y *1000, view.z * 1000));
	debugCam.cc:lookAt(homeplanetBody.go:getWorldPosition())

	return EventResult.Handled
end


function parentImpulseToChildren( velocity )
	-- body

	
	for k,v in pairs(planets) do
		planets[k].go:setPosition(homeplanetBody.go:getWorldPosition())
		--planets[k].rb:setLinearVelocity(velocity)
	end
end




function planetUpdate( updateData )
	-- body
	
	for k,v in pairs(planets) do
		planets[k].go:setPosition(homeplanetBody.go:getWorldPosition())
		--planets[k].rb:setLinearVelocity(velocity)
	end


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



State{
	name = "debugCam",
	parent = "/game/gameRunning",
	eventListeners = {
		update = { 
			debugCamUpdate ,
			characterUpdate,
			planetUpdate

		},
		enter = { debugCamEnter 
			}
	}
}

StateTransitions{
	parent = "/game/gameRunning",
	{ from = "__enter", to = "debugCam" },
}

logMessage("... finished initializing defaults.lua.")
