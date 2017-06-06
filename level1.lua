
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
require("scripts.functions")

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
local maxStretch

local scWidth = display.contentWidth
local scHeight = display.contentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- Sounds
local bounceSound
local failedSound
local successSound

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
  origX = centerX
  origY = scHeight*.8
  local radius = scWidth*0.05
	ball = display.newCircle( origX, origY, radius )
	ball:setFillColor( 0, 0, 0 )
	--ball.x = origX
	--ball.y = origY
	physics.addBody( ball, "dynamic", {density=2, radius=radius, bounce=0.5, 	friction=objFriction} )
	ball.myName = "ball"
end

-- Load platform
local function displayPlatform( scene )
  platform = display.newRect( centerX, scHeight+5, scWidth, 10 )
  platform:setFillColor(0)
	physics.addBody( platform, "static", { friction=objFriction, bounce=0.3 } )
end

-- Load wall left
local function displayWall1( scene )
	wall1 = display.newRect( scene, -5, centerY, 10, scHeight )
  wall1:setFillColor(0)
	physics.addBody( wall1, "static", { friction=objFriction, bounce=0.3 } )
end

-- Load wall right
local function displayWall2( scene )
	wall2 = display.newRect( scene, scWidth+5, centerY, 10, scHeight )
  wall2:setFillColor(0)
	physics.addBody( wall2, "static", { friction=objFriction, bounce=0.3 } )
end

-- Load ceiling
local function displayCeiling( scene )
	ceiling = display.newRect( scene, centerX, -5, scWidth, 10 )
  ceiling:setFillColor(0)
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
  local radius = scWidth*0.1
	target = display.newCircle( centerX, scHeight*.2, radius )
	target:setFillColor( 1, 0, 0 )

	physics.addBody( target, "static", {radius=radius, density=3} )
	target.myName = "target"
end

-- Create obstacles
local function displayObstacles( scene )
	-- Create obstacle 1
  o1 = display.newRect( centerX, centerY, display.contentWidth*0.5, 10 )
  o1:setFillColor(0.5)
  physics.addBody( o1, "static", {friction=objFriction} )
end

-- Reset objects
local function resetObjects()
	-- Remove objects
	display.remove( levelFailedText )
	display.remove( retryButton )
	display.remove( ball )
	display.remove( target )
	display.remove( o1 )
	display.remove( bg )
	display.remove( nextLevelButton )
	display.remove( levelText )
	display.remove( hitText )
  
  levelFailedText = nil
  retryButton = nil
  ball = nil
  target = nil
  o1 = nil
  bg = nil
  nextLevelButton = nil
  levelText = nil
  hitText = nil
end

-- Reset level
local function resetLevel()
	resetObjects()
  composer.setVariable( "level", level )
	composer.gotoScene( "redirects.backlevel" )
end

-- Trial failed, show failure message and retry button
local function levelFailed()
  local levelFailedTextHeight = scHeight*0.1
	levelFailedText = display.newText( "Level Failed!", display.contentCenterX, display.contentCenterY, native.systemFont, levelFailedTextHeight )
  levelFailedText:setFillColor( 1, 0, 0 )

  local retryButtonTextHeight = centerX*.1
  retryButton = display.newImageRect( "img/play.png", retryButtonTextHeight*2, retryButtonTextHeight*2 )
  retryButton.x = centerX
  retryButton.y = levelFailedText.y + levelFailedText.height/2+10+retryButton.height/2

	retryButton:addEventListener( "tap", resetLevel )

	-- Stop physics
	physics.pause()
end

-- Game over
local function gameOver()
	if (hit == false) then
    -- Play Sound
    audio.play( failedSound )
		-- Show failed
		levelFailed()
	end
end

-- Launch the ball
local function launchBall( vx, vy )
	timer.performWithDelay( timeLimit, gameOver, 1 )
	ball:setLinearVelocity( vx, vy )
end

-- Get distance between two points
local function getDistance(x1, y1, x2, y2)
  return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

local function getMaxLocationX(x1, y1, x2, y2)
  local x3 = origX
  local y3
  local d = 0
  local increment
  
  -- Decide if increment is positive or negative
  if (x2 > x1) then
    increment = 0.1
  else
    increment = -0.1
  end
  
  while (d < maxStretch) do
    x3 = x3 + increment
    d = math.sqrt((x3-x1)^2 + ((y2-y1)/(x2-x1)*(x3-x1))^2)
  end
  y3 = (y2-y1)/(x2-x1)*(x3-x1) + y1

  return x3
end

local function getMaxLocationY(x1, y1, x2, y2)
  local x3 = origX
  local y3
  local d = 0
  local increment
  
  -- Decide if increment is positive or negative
  if (x2 > x1) then
    increment = 0.1
  else
    increment = -0.1
  end
  
  while (d < maxStretch) do
    x3 = x3 + increment
    d = math.sqrt((x3-x1)^2 + ((y2-y1)/(x2-x1)*(x3-x1))^2)
  end
  y3 = (y2-y1)/(x2-x1)*(x3-x1) + y1

  return y3
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
    -- Get the event location
    local newX = event.x - ball.touchOffsetX
    local newY = event.y - ball.touchOffsetY
    
    -- Check for max stretch
    local dist = getDistance(newX, newY, origX, origY)
    
    if (dist > maxStretch) then
      local newLocationX = getMaxLocationX(origX, origY, newX, newY)
      local newLocationY = getMaxLocationY(origX, origY, newX, newY)
      
      ball.x = newLocationX
      ball.y = newLocationY
      print(newX..", "..newY.."|"..ball.x..", "..ball.y)
    else
      ball.x = event.x - ball.touchOffsetX
      ball.y = event.y - ball.touchOffsetY
    end
    
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
    physics.start()
    
    --ball:removeEventListener( "touch", onDrag )
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
  local hitTextHeight = scHeight*0.1
	hitText = display.newText( "HIT!!!", display.contentCenterX, display.contentCenterY, native.systemFont, hitTextHeight )
  hitText:setFillColor( 0, 0, 1 )
	
  local nextLevelButtonHeight = hitTextHeight*0.5
  nextLevelButton = display.newImageRect( "img/next.png", nextLevelButtonHeight*4, nextLevelButtonHeight )
  nextLevelButton.x = display.contentCenterX
  nextLevelButton.y = hitText.y + hitText.height/2 + nextLevelButtonHeight*0.7
	nextLevelButton:setFillColor(0, 1, 0)

	-- Add event listener
	nextLevelButton:addEventListener( "tap", nextLevel)

	-- Play collision sound here
  audio.play( successSound )

	-- Remove drag event listener on the ball
	ball:removeEventListener( "touch", dragBall )
	hit = true
  
  -- Save level
  if (loadLevel() <= level+1) then
    saveLevel( level+1 )
  end
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
    else
      audio.play(bounceSound)
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
  
  -- Setup sounds
  bounceSound = audio.loadSound( "sounds/bounce.wav" )
  failedSound = audio.loadSound( "sounds/failed.wav" )
  successSound = audio.loadSound( "sounds/success.wav" )

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

  maxStretch = scHeight - origY

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
		--physics.start()

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
  
  -- Dispose audios
  audio.dispose( bounceSound )
  audio.dispose( failedSound )
  audio.dispose( successSound )
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
