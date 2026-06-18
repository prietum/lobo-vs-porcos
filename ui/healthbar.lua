--singleton
healthbar = {
	width = 300,
	height = 25,
	padding = 2,
	margin = 65,
	lowmargin=20
}

function healthbar:draw(plr)
	windowwidth, windowheight = love.window.getMode()

	anchx = windowwidth/2 - self.width/2
	anchy1 = windowheight - self.height - self.margin
	anchy2 = windowheight - self.height - self.lowmargin
	lifew = (self.width - self.padding*(plr.maxhp+1))/plr.maxhp

	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",
		anchx,
		anchy1,
		self.width,
		self.height
		)

	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",
		anchx,
		anchy2,
		self.width,
		self.height
		)

	love.graphics.print(
		"Vida",
		anchx,
		anchy1 - 20
	)

	love.graphics.print(
		"Energia",
		anchx,
		anchy2 - 20
	)

	love.graphics.setColor(1,0,0)
	for i = plr.hp-1, 0, -1 do
		love.graphics.rectangle("fill",
			anchx + self.padding + (lifew+self.padding)*i,
			anchy1 + self.padding,
			lifew,
			self.height - self.padding*2
		)
	end

	love.graphics.setColor(1,1,1)
	love.graphics.rectangle("fill",
			anchx + self.padding,
			anchy2 + self.padding,
			(self.width - self.padding*2)*(plr.pp/plr.maxpp),
			(self.height - self.padding*2)
		)
end

return healthbar