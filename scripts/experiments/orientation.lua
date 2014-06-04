PhysicsSystem:setDebugDrawingEnabled(true)

do -- Create some entity
	player = GameObjectManager:createGameObject("player")

	player.physics = player:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createBox(3.0, 7.5, 25.0)
	cinfo.position = Vec3(100, 0, 0)
	cinfo.motionType = MotionType.Dynamic
	cinfo.mass = 1
	player.rb = player.physics:createRigidBody(cinfo)

	player.baseViewDir = Vec3(0, 1, 0)
end

function update(dt)
	if InputHandler:wasTriggered(Key.Return) then
		logMessage("reset.")
		player.rb:reset()
		player:setPosition(Vec3(20, 0, 0))
	end

	if InputHandler:wasTriggered(Key.Insert) then
		player.baseViewDir = Vec3(1, 0, 0)
	elseif InputHandler:wasTriggered(Key.Del) then
		player.baseViewDir = Vec3(-1, 0, 0)
	elseif InputHandler:wasTriggered(Key.Home) then
		player.baseViewDir = Vec3(0, 1, 0)
	elseif InputHandler:wasTriggered(Key.End) then
		player.baseViewDir = Vec3(0, -1, 0)
	elseif InputHandler:wasTriggered(Key.Prior) then
		player.baseViewDir = Vec3(0, 0, 1)
	elseif InputHandler:wasTriggered(Key.Next) then
		player.baseViewDir = Vec3(0, 0, -1)
	end
	player:setBaseViewDirection(player.baseViewDir)

	local upDir = player:getUpDirection()
	local viewDir = player:getViewDirection()
	local rightDir = player:getRightDirection()

	local vec = Vec3(0, 0, 0)
	local magnitude = 50
	if InputHandler:isPressed(Key.Left) then
		vec = upDir:mulScalar(-magnitude)
	elseif InputHandler:isPressed(Key.Right) then
		vec = upDir:mulScalar(magnitude)
	elseif InputHandler:isPressed(Key.Up) then
		vec = viewDir:mulScalar(-magnitude)
	elseif InputHandler:isPressed(Key.Down) then
		vec = viewDir:mulScalar(magnitude)
	end
	player.rb:applyAngularImpulse(vec)

	do -- draw the local axes
		local pos = player:getPosition()
		rightDir = rightDir:mulScalar(10)
		viewDir = viewDir:mulScalar(10)
		upDir = upDir:mulScalar(10)
		DebugRenderer:drawLine3DColor(pos, pos + rightDir, Color(1, 0, 0, 1))
		DebugRenderer:drawLine3DColor(pos, pos + viewDir, Color(0, 1, 0, 1))
		DebugRenderer:drawLine3DColor(pos, pos + upDir, Color(0, 0, 1, 1))
	end

	return EventResult.Handled
end

Events.Update:registerListener(update)
