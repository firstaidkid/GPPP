print("running updates")

function cameraUpdate(elapsedTime)
	local camPosTo = player.go:getWorldPosition() + player.go:getViewDirection():mulScalar(1.0) + Vec3(0.0, 0.0, 0.0)
	local camPosIs = camera.go:getWorldPosition()
	local camPosVel = camPosTo - camPosIs
	if (camPosVel:length() > 1.0 ) then
		camera.pc.rb:setLinearVelocity(camPosVel:mulScalar(2.5))
	end
end

function playerUpdate(guid, elapsedTime)
	local acceleration = 100
	local jumpPower = 120000
	local impulse = Vec3(0, 0, 0)
	if (InputHandler:isPressed(Key.Up)) then
		impulse.y = acceleration
	end
	if (InputHandler:isPressed(Key.Down)) then
		impulse.y = -acceleration
	end
	if (InputHandler:isPressed(Key.Left)) then
		impulse.x = -acceleration
	end
	if (InputHandler:isPressed(Key.Right)) then
		impulse.x = acceleration
	end

	player.rb:applyLinearImpulse(impulse)
end


function defaultUpdate(updateData)
	local elapsedTime = updateData:getElapsedTime() / 1000.0

	updateLevel(elapsedTime)
	playerUpdate(elapsedTime)
	cameraUpdate(elapsedTime)

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
	{ from = "__enter", to = "default" }
}

StateTransitions{
	parent = "/game",
	{ from = "gameRunning", to = "__leave", condition = function() return bit32.btest(InputHandler:gamepad(0):buttonsPressed(), bit32.bor(Button.Start, Button.Back)) end }
}