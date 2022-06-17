--[[
  GravityDrawing
  A port of Coracle Gravity: https://orllewin.github.io/coracle/drawings/vector/gravity/
]]	
import 'CoreLibs/sprites'

import 'coracle/Coracle'
import 'coracle/Vector'
import 'Clock'

class('GravityDrawing').extends(Drawing)
class('Particle').extends()

local Orientation = {unknown = "0", landscape = "1", portrait = "2"}

function Particle:init(tailLength)
	Particle.super.init(self)
	self.location = Vector(math.random(width), math.random(height))
	self.velocity = Vector(0, 0)
	self.tailXs = {}
	self.tailYs = {}
		 
	for t = 1, tailLength do
		self.tailXs[t] = -1
		self.tailYs[t] = -1
	end
	
end

function GravityDrawing:init(particleCount)
	GravityDrawing.super.init(self)
	
	self.clock = Clock()
	
	accelerometerStart()
	self.orientation = Orientation.unknown
	self:checkOrientation()
	
	self.clock.sprite:add()
	
	self.drawMass = true
	
	
	self.clockFont = playdate.graphics.font.new('fonts/Roobert-24-Medium')
	graphics.setFont(self.clockFont, "normal")

	self.tailLength = 15
	self.frame = 0

	self.origin = Vector(width/2, height/2)
	self.originSize = 35
	self.originMass = 0.4
	
	self.particles = {}
	
  for i = 1 , particleCount do
		local particle = Particle(self.tailLength)
		table.insert(self.particles, particle)
  end
	
	graphics.setBackgroundColor(black)
	graphics.sprite.setBackgroundDrawingCallback(
			function( x, y, width, height )
					playdate.graphics.clear()
			end
	)
end

function GravityDrawing:draw()
	self.clock:checkTime() 
	graphics.sprite.update() 
  
	self:checkOrientation()
	self:drawParticles()  
	self:scanInput()
  self:update()
	
end

function GravityDrawing:checkOrientation()
	if(isPortrait())then
		if(self.orientation ~= Orientation.portrait)then
			self.clock:setPortrait()
			self.orientation = Orientation.portrait
			playdate.display.setFlipped(false, false)
		end
	else
		if(self.orientation ~= Orientation.landscape)then
			self.clock:setLandscape()
			self.orientation = Orientation.landscape
		end
		if(isUpsideDown())then
			playdate.display.setFlipped(true, true)
		else
			playdate.display.setFlipped(false, false)
		end
	end
end

function GravityDrawing:drawParticles()
	
	if(self.drawMass)then
		fill(0.25)
		circle(self.origin.x, self.origin.y, self.originSize)
	end
	
	graphics.setColor(white)
	for i = 1, #self.particles do
		local particle = self.particles[i]
		circle(particle.location.x, particle.location.y, 6)
	
		for t = 1, self.tailLength do
			cross(particle.tailXs[t], particle.tailYs[t], 1)
		end
	end
end

function GravityDrawing:scanInput()
	if(crankUp())then
		self.originSize = self.originSize + 0.5
		self.originMass = self.originMass + 0.005
	end
	
	if(crankDown())then
		self.originSize = self.originSize - 0.5
		self.originMass = self.originMass - 0.005
	end
	
	if(leftPressed())then
		if(self.drawMass)then
			self.drawMass = false
		else
			self.drawMass = true
		end
	end
	
	-- Screen invert
	if(upPressed())then
		if(playdate.display.getInverted())then
			playdate.display.setInverted(false)
		else
			playdate.display.setInverted(true)
		end
	end
	
	-- Add new particle
	if(aPressed())then
		local newParticle = Particle(self.tailLength)
		table.insert(self.particles, newParticle)
	end
	
	-- Delete random particle
	if(bPressed())then
		local particles = self.particles
		if(#particles > 1)then
			local deleteIndex = math.random(#particles)
			table.remove(self.particles, deleteIndex)
		end
	end
end

function GravityDrawing:update()
  for i = 1, #self.particles do
	
		local particle = self.particles[i]
	
		local originDirection = vectorMinus(self.origin, particle.location)
		originDirection:normalise()
		originDirection:times(self.originMass)
		
		particle.velocity:plus(originDirection)
		particle.location:plus(particle.velocity)
	
		for ii = 1, #self.particles do
	  	if (i ~= ii) then
			local other = self.particles[ii]
			
			bodyDirection = vectorMinus(particle.location, other.location)
			bodyDirection:normalise()
			bodyDirection:times(0.07)
			particle.velocity:plus(bodyDirection)
			particle.velocity:limit(3.0)
			particle.location:plus(particle.velocity)
	
	  	end
		end
	
 		local tailIndex = self.frame % self.tailLength
		particle.tailXs[tailIndex] = particle.location.x
		particle.tailYs[tailIndex] = particle.location.y
		
		-- Screen wrap
		if(particle.location.x < 0)then
			particle.location.x = width
		end
		if(particle.location.x > width)then
			particle.location.x = 0
		end
		if(particle.location.y < 0)then
			particle.location.y = height
		end
		if(particle.location.y > height)then
			particle.location.y = 0
		end
  end
 	
	self.frame = self.frame + 1
end