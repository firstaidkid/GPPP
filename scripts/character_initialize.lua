logMessage("Initializing character_initialize.lua ...")

do -- Physics world
	local cinfo 		= 	WorldCInfo()
	cinfo.gravity 		= 	Vec3(0, 0, 0)
	cinfo.worldSize 	= 	20000.0
	local world 		= 	PhysicsFactory:createWorld(cinfo)
	PhysicsSystem:setWorld(world)
	guid = 1

	local currentHomeplanet
	
end


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
	character.pc = character.go:createPhysicsComponent()

	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createBox(Vec3(20, 20, 1))
	cinfo.motionType = MotionType.Character
	cinfo.restitution = 0
	cinfo.friction = 0
	cinfo.position = Vec3(0,0,500)
	cinfo.gravityFactor = 10
	cinfo.mass = 90
	cinfo.maxLinearVelocity = 1000

	cinfo.linearDamping = 1
	cinfo.angularDamping = 1
	character.rb = character.pc:createRigidBody(cinfo)
	character.sc = character.go:createScriptComponent()
	local renderComponent = character.go:createRenderComponent()
	renderComponent:setPath("data/models/mario/mario.thModel")

	-- collision event
	--character.pc:getContactPointEvent():registerListener(collisionCharacter)
	--character.sc:setUpdateFunction(updateCharacter)

end



function nextGUID()
	local guid_string = tostring(guid)
	guid = guid + 1
	return guid_string
end

function grow( i )
	-- body

	local characterUpDirection 	= 	character.go:getUpDirection()
	local impulse = (homeplanet.go:getWorldPosition() + character.go:getWorldPosition()):mulScalar(20)


	-- apply impulse
	--character.go:setPosition(characterUpDirection:mulScalar(i *20))


	--targetObject:setScale(Vec3(2,2,2))
	for k,v in pairs(planets) do
		--planets[k].go:setPosition(homeplanet.go:getWorldPosition())
		planets[k].go:setComponentStates(ComponentState.Inactive)
		if(k==i)then
			planets[k].go:setComponentStates(ComponentState.Active)
		end

	end

	currentHomeplanet = planets[i]


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
	
	-- parenting geht nicht
	--planet.go:setParent(homeplanet.go)
	return planet

end


-- create planet 
function create_random_Planet( size, type )
	-- body
	local planet 				= 	{}
	planet.go 			= 	GameObjectManager:createGameObject(nextGUID())
	planet.pc 			= 	planet.go:createPhysicsComponent()
	local cinfo 			= 	RigidBodyCInfo()
	cinfo.position 			= 	Vec3(math.random(-5000,5000),math.random(-5000,5000),math.random(-5000,5000))
	cinfo.shape 			= 	PhysicsFactory:createSphere(size)
	cinfo.motionType 		= 	type
	cinfo.restitution 		= 	0
	cinfo.friction 			= 	0
	cinfo.gravityFactor 	= 	0
	cinfo.mass 				= 	900000
	cinfo.maxLinearVelocity = 	10000
	--cinfo.linearDamping 	= 	1
	planet.rb 			= 	planet.pc:createRigidBody(cinfo)
	planet.rb:setLinearVelocity(Vec3(math.random(-100,100),math.random(-100,100),math.random(-100,100)))
	
	-- parenting geht nicht
	--planet.go:setParent(homeplanet.go)
	return planet

end





do
	--Create Little Home Planet
	homeplanet 				= 	{}
	homeplanet.go 			= 	GameObjectManager:createGameObject("homeplanet")
	homeplanet.pc 			= 	homeplanet.go:createPhysicsComponent()
	local cinfo 			= 	RigidBodyCInfo()
	cinfo.position 			= 	Vec3(0,0,0)
	cinfo.shape 			= 	PhysicsFactory:createSphere(200)
	--cinfo.motionType 		= 	MotionType.Dynamic
	cinfo.motionType 		= 	MotionType.Keyframed
	cinfo.restitution 		= 	0
	cinfo.friction 			= 	0
	cinfo.gravityFactor 	= 	0
	cinfo.mass 				= 	900000
	cinfo.maxLinearVelocity = 	10000
	--cinfo.linearDamping 	= 	1
	homeplanet.rb 			= 	homeplanet.pc:createRigidBody(cinfo)
	
	planets = {}


	for i=1,10 do 
		print(i) 
		--planets[i] = create_Planet( i* 20 + 100, MotionType.Keyframed )
		planets[i] = create_Planet( i, MotionType.Keyframed )
	end

	for a=1,500 do 
		--print(i) 
		create_random_Planet( math.random(100, 200), MotionType.Dynamic )
	end

	grow( 5 )
end
-- create ID

















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
 	local quaternion 			= 	Quaternion(characterUpDirection, 0)


 	--Debug View
	DebugRenderer:printText(Vec2(-0.9, 0.7), round(view.x, 2) .. " , " .. round(view.y, 2) .." , " .. round(view.z, 2))
	DebugRenderer:drawArrow(view, view:mulScalar(150) )


	--Key Events
	if(InputHandler:isPressed(Key.Up)) then
		impulse.y = acceleration * view.y
		impulse.x = acceleration * view.x
		impulse.z = acceleration * view.z
	end
	if(InputHandler:isPressed(Key.Down)) then
		impulse.y = -acceleration * view.y
		impulse.x = -acceleration * view.x
		impulse.z = -acceleration * view.z
	end
	if(InputHandler:isPressed(Key.Left)) then
		quaternion = Quaternion(characterUpDirection, 1)
	end
	if(InputHandler:isPressed(Key.Right)) then
		quaternion = Quaternion(characterUpDirection, -1)
	end



	-- gravity to homeplanet
	impulse = impulse + (homeplanet.go:getWorldPosition() - character.go:getWorldPosition()):mulScalar(10)


	-- apply impulse
	character.rb:applyLinearImpulse(impulse)

	-- apply rotation
	character.go:setRotation(quaternion * character.go:getWorldRotation())


	--if(InputHandler:isPressed(Key.Space) and character.grounded) then
	--	character.rb:applyForce(0.5, Vec3(0,0,150000))
	--	character.grounded = false
	--end


	-- camera update
	charPos = character.go:getWorldPosition()


	if(InputHandler:isPressed(Key.Space)) then
		homeplanet.rb:setLinearVelocity(characterUpDirection:mulScalar(-100))
		--parentImpulseToChildren( characterUpDirection:mulScalar(-200) )

	--	character.grounded = false
	end

	debugCam.cc:setPosition((homeplanet.go:getWorldPosition() - character.go:getWorldPosition()):mulScalar(-3));
	--debugCam.cc:setPosition(Vec3(view.x*1000, view.y *1000, view.z * 1000));
	debugCam.cc:lookAt(homeplanet.go:getWorldPosition())

	return EventResult.Handled
end


function parentImpulseToChildren( velocity )
	-- body

	
	for k,v in pairs(planets) do
		planets[k].go:setPosition(homeplanet.go:getWorldPosition())
		--planets[k].rb:setLinearVelocity(velocity)
	end
end




function planetUpdate( updateData )
	-- body
	
	for k,v in pairs(planets) do
		planets[k].go:setPosition(homeplanet.go:getWorldPosition())
		--planets[k].rb:setLinearVelocity(velocity)
	end


	if(InputHandler:isPressed(Key._1)) then
		grow(1)
	elseif(InputHandler:isPressed(Key._2)) then
		grow(2)
	elseif(InputHandler:isPressed(Key._3)) then
		grow(3)
	elseif(InputHandler:isPressed(Key._4)) then
		grow(4)
	elseif(InputHandler:isPressed(Key._5)) then
		grow(5)
	elseif(InputHandler:isPressed(Key._6)) then
		grow(6)
	elseif(InputHandler:isPressed(Key._7)) then
		grow(7)
	elseif(InputHandler:isPressed(Key._8)) then
		grow(8)
	elseif(InputHandler:isPressed(Key._9)) then
		grow(9)
	end

	--homeplanet.go:getWorldPosition()
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
