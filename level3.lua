
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

display.setDefault( "background", 1)

-- physics
local physics = require( "physics" )
physics.start(  )
physics.setGravity( 0, 0 )

-- *************************
--  Set Variables
-- *************************
-- 1] Objects
local ball
local target
local flooring
local ceiling
local wallLeft
local wallRight
local obs1
local obs2
local obs3
-- 2] Texts
local levelText
local levelFailedText
local retryButton
-- 3] Variables
local level = 3
local frictionValue = 0.8
local origX = display.contentCenterX
local origY = display.contentHeight-100
local destX                             -- Stretch direction
local destY                             -- Stretch direction
local gameTimer = {}
local timeLimit = 4000		-- Limit of time before game over
local hit = false

-- *************************
--  Functions
-- *************************

-- Set Flooring
local function setFlooring()
  flooring = display.newRect( display.contentCenterX, display.contentHeight+5, display.contentWidth, 10 )
  physics.addBody( flooring, "static", {friction=frictionValue, bounce=0.5} )
end
-- Set Ceiling
local function setCeiling()
  ceiling = display.newRect( display.contentCenterX, -5, display.contentWidth, 10 )
  physics.addBody( ceiling, "static", {friction=frictionValue, bounce=0.5} )
end
-- Set Walls
local function setWalls()
  wallLeft = display.newRect( 20, display.contentCenterY, 10, display.contentHeight )

  wallRight = display.newRect( display.contentWidth-20, display.contentCenterY, 10, display.contentHeight )

  physics.addBody( wallLeft, "static", {friction=frictionValue, bounce=0.5} )
  physics.addBody( wallRight, "static", {friction=frictionValue, bounce=0.5} )
end

-- Show ball
local function showBall()
  ball = display.newCircle( origX, origY, 15 )
  physics.addBody( ball, "dynamic", {density=2, friction=frictionValue, bounce=0.5, radius=15} )
  ball:setFillColor(0,0,.2)
  ball.myName = "ball"
end

-- Show target
local function showTarget()
  target = display.newCircle( display.contentWidth-60, 40, 30 )
  physics.addBody( target, "static", {radius=30, friction=frictionValue} )
  target:setFillColor( 1, 0, 0 )
  target.myName = "target"
end

-- Show Obstacles
local function showObstacles()
  
  local obstacleWidth = display.contentWidth * 0.2
  local obstacleHeight = 10
  
  obs1 = display.newRect( display.contentCenterX, display.contentCenterY, obstacleWidth, obstacleHeight )
  obs1:setFillColor(0.5)
  
  obs2 = display.newRect( display.contentWidth-obstacleWidth, display.contentCenterY-50, obstacleWidth, obstacleHeight )
  obs2:setFillColor(0.5)
  
  obs3 = display.newRect( obstacleWidth, display.contentCenterY/2+50, obstacleWidth, obstacleHeight )
  obs3.anchorX = 0
  obs3:setFillColor(0.5)

  physics.addBody( obs1, "static", {friction=frictionValue} )
  physics.addBody( obs2, "static", {friction=frictionValue} )
  physics.addBody( obs3, "static", {friction=frictionValue} )
end

-- Show level
local function showLevel( x )
  levelText = display.newText( "Level: " .. x, 30, 20 )
  levelText.anchorX = 0
  levelText:setFillColor( 0.3 )
end

-- Reset objects
local function resetObjects()
	-- Remove objects
	display.remove( levelFailedText )
	display.remove( retryButton )
	display.remove( ball )
	display.remove( target )
	display.remove( obs1 )
  display.remove( obs2 )
  display.remove( obs3 )
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
	composer.gotoScene( "redirects.backlevel"..level )
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

-- Launching the ball
local function launchBall( vx, vy )
	timer.performWithDelay( timeLimit, gameOver, 1 )
	ball:setLinearVelocity( vx, vy )
end

-- ***********************
--    Listeners
-- ***********************
local function onDrag( event )
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
	--nextLevelButton = display.newText( "Level 2 >>", display.contentCenterX, display.contentCenterY+22+10+12, native.systemFont, 22 )
  nextLevelButton = display.newImageRect( "img/next.png", 80, 20 )
  nextLevelButton.x = display.contentCenterX
  nextLevelButton.y = display.contentCenterY+22+10+12
	nextLevelButton:setFillColor(0, 1, 0)

	-- Add event listener
	nextLevelButton:addEventListener( "tap", nextLevel)

	-- Play collision sound here

	-- Remove drag event listener on the ball
	ball:removeEventListener( "touch", onDrag )
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

  -- Pause physics engine
  physics.pause()

  -- Create objects
  setFlooring()
  setCeiling()
  setWalls()
  showBall()
  showTarget()
  showObstacles()
  showLevel(level)
  
  -- Add event listeners
  Runtime:addEventListener( "collision", onCollision )
end

-- Game Timer
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

    ball:addEventListener( "touch", onDrag )
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