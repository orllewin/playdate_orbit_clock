class('Clock').extends()

import 'coracle/Coracle'

local clockRectHeight = 36

function Clock:init()
	 Clock.super.init(self)
	 self.sprite = playdate.graphics.sprite.new(nil)
	 self.image = nil
	 self.hour = -1
	 self.minute = -1
end

function Clock:checkTime()
	local time = playdate.getTime()
	if(self.minute ~= time.minute)then
		self:redraw(time.hour, time.minute)
	end
end

function Clock:setLandscape()
	self.sprite:setRotation(0)
	self.sprite:setScale(1.0)
	if(self.image ~= nil)then
		local width, height = self.image:getSize()
		print("Clock image width: " .. width .. " height: " .. height)
		self.sprite:moveTo((width/2) + 10, 120)
	else
		self.sprite:moveTo(44 + 10, 120)
	end
end

function Clock:setPortrait()
	self.sprite:setScale(1.5)
	self.sprite:setRotation(90)
	self.sprite:moveTo(400 - 36, 120)
end

function Clock:redraw(hour, minute)
	print("redrawing clock, time is " .. hour.. ":" .. minute)
	local timeLabel = '' .. string.format("%02d", hour) .. ":" .. string.format("%02d", minute)
	
	--get text width
	local timeLabelWidth = playdate.graphics.getFont():getTextWidth(timeLabel)
	local rectWidth = timeLabelWidth + 20
	local rectHeight = 36
	local timeImage = playdate.graphics.image.new(rectWidth, rectHeight)
	playdate.graphics.pushContext(timeImage)
	playdate.graphics.setColor(graphics.kColorWhite)
	playdate.graphics.fillRoundRect(0, 0, rectWidth, rectHeight, 9)
	playdate.graphics.setColor(graphics.kColorBlack)
	playdate.graphics.drawTextInRect(timeLabel, 10, 3, rectWidth, rectHeight)
	playdate.graphics.popContext()
	self.image = timeImage
	self.hour = hour
	self.minute = minute
	self.sprite:setImage(timeImage)
end