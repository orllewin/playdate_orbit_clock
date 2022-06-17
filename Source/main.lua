import 'coracle/Coracle'
import 'GravityDrawing'

graphics  = playdate.graphics
timer = playdate.timer

local drawing = GravityDrawing(5)

function playdate.update()	
	drawing:draw()
end