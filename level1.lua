
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

display.setDefault( "background", 1 )

-- Physics
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Variables
local level = 1
local ball
local bg
local platform
local wall1, wall2
local ceiling
local target
local numberOfObstacles = 1			-- Number of obstacles
local origX = display.contentCenterX
local origY = display.contentHeight-80
local destX			-- Stretch direction
local destY			-- Stretch direction
local path			-- Ball's target path
local objFriction = 0.8		-- Friction for all objects
local gameTimer = {}
local timeLimit = 4000		-- Limit of time before game over
local hit = false					-- Change to true if the target has been hit
local retryButton					-- Retry button
local levelFailedText
local targetX = display.contentCenterX
local targetY = 100
local nextLevelButton
local hitText
local levelText

-- Obstacles
local o1									-- Obstacle 1

-- Function to load and display background
local function displayBackground( scene )
	bg = display.newImageRect( scene, "img/bg.png", 320, 480 )
	bg.x = display.contentCenterX
	bg.y = display.contentCenterY
end

-- Function to load and display ball
local function displayBall( scene )
	ball = display.newCircle( origX, origY, 15 )
	ball:setFillColor( 0, 0, 1 )
	--ball.x = origX
	--ball.y = origY
	physics.addBody( ball, "dynamic", {density=2, radius=15, bounce=0.5, 	friction=objFriction} )
	ball.myName = "ball"
end

-- Load platform
local function displayPlatform( scene )
	platform = display.newImageRect( scene, "img/platform.png", 320, 22 )
	platform.x = display.contentCenterX
	platform.y = display.contentHeight+11
	physics.addBody( platform, "static", { friction=objFriction, bounce=0.3 } )
end

-- Load wall left
local function displayWall1( scene )
	wall1 = display.newImageRect( scene, "img/wall.png", 10, 480 )
	wall1.anchorX = 1
	wall1.x = 25
	wall1.y = display.contentCenterY
	physics.addBody( wall1, "static", { friction=objFriction, bounce=0.3 } )
end

-- Load wall right
local function displayWall2( scene )
	wall2 = display.newImageRect( scene, "img/wall.png", 10, 480 )
	wall2.anchorX = 0
	wall2.x = display.contentWidth-25
	wall2.y = display.contentCenterY
	physics.addBody( wall2, "static", { friction=objFriction, bounce=0.3 } )
end

-- Load ceiling
local function displayCeiling( scene )
	ceiling = display.newImageRect( scene, "img/platform.png", 320, 22 )
	ceiling.x = display.contentCenterX
	ceiling.y = -11
	physics.addBody( ceiling, "static", { friction=objFriction, bounce=0.3 } )
end

-- Display level
local function displayLevel( scene )
	levelText = display.newText( "Level: " .. level, 30, 20 )
	levelText.anchorX = 0
  levelText:setFillColor(0.3)
end

-- Load target
local function displayTarget( scene )
	target = display.newCircle( display.contentCenterX, 100, 30 )
	target:setFillColor( 1, 0, 0 )

	physics.addBody( target, "static", {radius=30, density=3} )
	target.myName = "target"
end

-- Create obstacles
local function displayObstacles( scene )
	-- Create polygon vertices
	local vertices = {0, -30, 30, 0, 0, 30, -30, 0}

	-- Create obstacle 1
  o1 = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth*0.2, 10 )
  o1:setFillColor(0.5)
  physics.addBody( o1, "static", {friction=objFriction} )
end

-- Reset objects
local function resetObjects()

	--physics.start()
	--physics.removeBody( ball )
	--physics.removeBody( target )
	--physics.removeBody( o1 )

	-- Remove objects
	display.remove( levelFailedText )
	display.remove( retryButton )
	display.remove( ball )
	display.remove( target )
	display.remove( o1 )
	display.remove( bg )
	display.remove( nextLevelButton )
	display.remove( levelText )
	display.remove( nextLevelButton )
	display.remove( hitText )

	--physics.stop()
end

-- Reset level
local function resetLevel()
	resetObjects()
  composer.setVariable( "level", level )
	composer.gotoScene( "redirects.backlevel" )
end

-- Trial failed, show failure message and retry button
local function levelFailed()
	levelFailedText = display.newText( "Level Failed!", display.contentCenterX, display.contentCenterY, native.systemFont, 44 )
  levelFailedText:setFillColor( 1, 0, 0 )

	retryButton = display.newText( "| Retry |", display.contentCenterX, display.contentCenterY + 22 + 16 + 20, native.systemFont, 18 )
  retryButton:setFillColor( 1, 0, 0 )

	retryButton:addEventListener( "tap", resetLevel )

	-- Stop physics
	physics.pause()
end

-- Game over
local function gameOver()
	if (hit == false) then
		-- Show failed
		levelFailed()
	end
end

-- Launch the ball
local function launchBall( vx, vy )
	timer.performWithDelay( timeLimit, gameOver, 1 )
	ball:setLinearVelocity( vx, vy )
end

-- Dragging the ball
local function dragBall( event )
  local ball = event.target
	local phase = event.phase

	if ( phase == "began" ) then
		-- Set touch focus on the ball
		display.currentStage:setFocus( ball )
		-- Store initial offset position
		ball.touchOffsetX = event.x - ball.x
		ball.touchOffsetY = event.y - ball.y
	elseif ( phase == "moved" ) then
		-- Move the ball to the new position
		ball.x = event.x - ball.touchOffsetX
		ball.y = event.y - ball.touchOffsetY

		destX = ball.x
		destY = ball.y

		display.remove( path )

		path = display.newLine( origX, origY, destX, destY )
		path:setStrokeColor( .5, .5, .5, 1 )
		path.strokeWidth = 1
	elseif ( phase == "ended" ) then
		-- When touch ended
		display.currentStage:setFocus( nil )
		destX = ball.x
		destY = ball.y

		display.remove( path )

		path = display.newLine( origX, origY, destX, destY )
		path:setStrokeColor( .5, .5, .5, 1 )
		path.strokeWidth = 1

		local x = destX - origX
		local y = destY - origY
		launchBall( x * -10, y * -10 )

		display.remove( path )
	end
	return true
end

-- Go to next level
local function nextLevel()
	resetObjects()
	composer.gotoScene( "level"..level+1, {timer=800, effect="crossFade"} )
end

-- Show hit message
local function hasHit()
	hitText = display.newText( "HIT!!!", display.contentCenterX, display.contentCenterY, native.systemFont, 44 )
  hitText:setFillColor( 0, 0, 1 )
	
  nextLevelButton = display.newImageRect( "img/next.png", 80, 20 )
  nextLevelButton.x = display.contentCenterX
  nextLevelButton.y = display.contentCenterY+22+10+12
	nextLevelButton:setFillColor(0, 1, 0)

	-- Add event listener
	nextLevelButton:addEventListener( "tap", nextLevel)

	-- Play collision sound here

	-- Remove drag event listener on the ball
	ball:removeEventListener( "touch", dragBall )
	hit = true
end

-- On collision
local function onCollision( event )
	if (event.phase == "began") then
		local obj1 = event.object1
		local obj2 = event.object2

		if ( (obj1.myName == "ball" and obj2.myName == "target") or
					(obj1.myName == "target" and obj2.myName == "ball") ) then
						-- Target has been hit!
						hasHit()
		end

	elseif (event.phase == "ended") then
		local obj1 = event.object1
		local obj2 = event.object2

		if ( (obj1.myName == "ball" and obj2.myName == "target") or
					(obj1.myName == "target" and obj2.myName == "ball") ) then

						timer.performWithDelay( 100, physics.stop )

		end
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- Pause physics
	physics.pause()

	-- Display level
	displayLevel( sceneGroup )

	-- Load background
	--displayBackground( sceneGroup )

	-- Load platform
	displayPlatform( sceneGroup )

	-- Load walls
	displayWall1( sceneGroup )
	displayWall2( sceneGroup )

	-- Load ceiling
	displayCeiling( sceneGroup )

	-- Load ball
	displayBall( sceneGroup )

	-- Load target
	displayTarget( sceneGroup )

	-- Load obstacles
	displayObstacles( sceneGroup )

	-- Add event listeners
	ball:addEventListener( "touch", dragBall )

	Runtime:addEventListener( "collision", onCollision )

end

function gameTimer:timer ( event )
	local count = event.count
	if count >= 1 then
		timer.cancel( event.source )
	end
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener( "collision", onCollision )
		--physics.pause()
		composer.removeScene( "level"..level )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
