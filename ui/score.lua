score = {
}

function score:draw(kills)
	windowwidth, windowheight = love.window.getMode()

	love.graphics.setColor(0,0,0)
	love.graphics.print(
		string.format("Pontos: %d", kills),
		10,
		windowheight - 60,
		0,
		2
	)
end

return score