function love.load()
   bg = love.graphics.newImage("data/bg.jpg")
   human = love.graphics.newImage("data/henri1.png")
end

function love.draw()
    love.graphics.print("Hello World", 400, 300)
	love.graphics.draw(bg, 0, 0)
	love.graphics.draw(human, 100, 100)
end