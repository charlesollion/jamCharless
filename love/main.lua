PI = 3.1415

function love.load()
   bg = love.graphics.newImage("data/bg.jpg")
   henriImages = {}
	henriImages[0] = love.graphics.newImage("data/henri1.png")
	henriImages[1] = love.graphics.newImage("data/henri2.png")
	potinImage = love.graphics.newImage("data/potin.png")
	potins = {}	
	henri = {x = 500.0, y = 500.0, angle = 0.0, speed = 50.0, timer = 0.0, range = 500.0}
	
   success = love.window.setMode( 1000, 1000)
end

function dist(x,y,x2,y2)
	return math.sqrt((x-x2)*(x-x2) + (y-y2)*(y-y2))
end

function findClosestPotin(x, y)
	max_dist = 2000.0
	ipotin = -1
	for i,potin in ipairs(potins) do			
		distance = dist(x, y, potin.x, potin.y)
		if distance < max_dist then
			max_dist = distance
			ipotin = i
		end
	end
	return 	ipotin, max_dist
end

function love.update(dt)	
	henri.x = henri.x + (henri.speed*dt * math.cos(henri.angle))
	henri.y = henri.y + (henri.speed*dt * math.sin(henri.angle))
	henri.timer = henri.timer + dt
 	if henri.timer > 0.5 then
		henri.timer = 0		
		i, distance = findClosestPotin(henri.x, henri.y)
		if i == -1 then
			henri.angle = math.random() * 2 * PI
		else
			proba = math.min(0.0, 0.8 - distance / henri.range)
			if distance < henri.range and math.random() < proba then			
				henri.angle = math.atan2(potins[i].y - henri.y, potins[i].x - henri.x)
			else
				henri.angle = math.random() * 2 * 3.1415
			end
		end
	end
	for i,potin in ipairs(potins) do
		potin.timer = potin.timer - dt
		if potin.timer < 0.0 then
			table.remove(potins, i)
		end
	end
end

function love.mousereleased(x, y, button)
   if button == "l" then
	  local potin = {x = x, y = y, timer = 20.0, initial_timer = 20.0, img=potinImage}
      table.insert(potins, potin)
   end
end

function love.draw()    
	love.graphics.draw(bg, 0, 0)
	for i, potin in ipairs(potins) do
		love.graphics.draw(potin.img, potin.x, potin.y)
	end
	love.graphics.draw(henriImages[math.random(0,1)], henri.x, henri.y)	
end