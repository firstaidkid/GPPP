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



function round(num, idp)

	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
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


	DebugRenderer:printText(Vec2(-0.9, 0.7), round(view.x, 2) .. " , " .. round(view.y, 2) .." , " .. round(view.z, 2))

	DebugRenderer:drawArrow(view, view:mulScalar(150) )



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
		--rotation.z = -2
		quaternion = Quaternion(characterUpDirection, 1)
		--impulse.x = -acceleration
	end
	if(InputHandler:isPressed(Key.Right)) then
		--rotation.z = 2
		--impulse.x = acceleration
		quaternion = Quaternion(characterUpDirection, -1)
	end




	impulse = impulse + (ground.go:getWorldPosition() - character.go:getWorldPosition()):mulScalar(100)


	character.rb:applyLinearImpulse(impulse)

	character.go:setRotation(quaternion * character.go:getWorldRotation())

	--character.rb:setAngularVelocity(rotation)

	if(InputHandler:isPressed(Key.Space) and character.grounded) then
		character.rb:applyForce(0.5, Vec3(0,0,150000))
		character.grounded = false
	end







	charPos = character.go:getWorldPosition()





	debugCam.cc:setPosition(Vec3(charPos.x, charPos.y - 500, charPos.z + 100));
	debugCam.cc:lookAt(charPos)


end

function update(elapsedTime)
	DebugRenderer:printText(Vec2(-0.9, 0.8), "elapsedTime " .. elapsedTime)


end