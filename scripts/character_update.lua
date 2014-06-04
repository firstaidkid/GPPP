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


function updateCharacter(  )
	-- body
	DebugRenderer:printText(Vec2(-0.9, 0.7), "updateCharacter ")

	local impulse = Vec3(0,0,0)
	local acceleration = 100
	local rotation = Vec3(0,0,0)



 	local view = character.go:getViewDirection()








	if(InputHandler:isPressed(Key.Up)) then
		impulse.y = acceleration
	end
	if(InputHandler:isPressed(Key.Down)) then
		impulse.y = -acceleration
	end
	if(InputHandler:isPressed(Key.Left)) then
		--rotation.z = -acceleration*10
		impulse.x = -acceleration
	end
	if(InputHandler:isPressed(Key.Right)) then
		--rotation.z = acceleration*10
		impulse.x = acceleration
	end




	impulse = impulse + (ground.go:getWorldPosition() - character.go:getWorldPosition()):mulScalar(15)


	character.rb:applyLinearImpulse(impulse)

	character.rb:applyAngularImpulse(rotation)

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