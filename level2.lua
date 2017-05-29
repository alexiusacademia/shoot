
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
-- 2] Texts
local levelText
-- 3] Variables
local frictionValue = 0.8
local origX = display.contentCenterX
local origY = display.contentHeight-100
local destX                             -- Stretch direction
local destY                             -- Stretch direction

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
  target = display.newCircle( display.contentWidth-100, 100, 30 )
  physics.addBody( target, "static", {radius=30, friction=frictionValue} )
  target:setFillColor( 1, 0, 0 )
  target.myName = "target"
end

-- Show Obstacles
local function showObstacles()
  obs1 = display.newRect( display.contentCenterX+50, display.contentCenterY, display.contentWidth*0.2, 10 )
  obs1:setFillColor(0.5)

  physics.addBody( obs1, "static", {friction=frictionValue} )
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
