
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
require( "scripts.functions" )

-- Variables
local level     -- Default value
local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- Widgets
local currentLevelLabel
local currentLevel
local playButton

display.setDefault("background", 1)

-- Show current level
currentLevelLabel = display.newText( "Current Level", centerX, centerY-50, native.systemFont, 28 )
currentLevelLabel.anchorY = 0
currentLevelLabel:setFillColor(0.5)

local function displayLevel()
  currentLevel = display.newText( level, centerX, currentLevelLabel.y+    currentLevelLabel.height/2+20+11, native.systemFont, 22 )
  currentLevel:setFillColor(0.5, .5, 1)
end

local function displayPlayButton()
  playButton = display.newImageRect( "img/play.png", centerX*0.2, centerX*0.2 )
  playButton.x = centerX
  playButton.y = currentLevel.y + currentLevel.height/2+20 + playButton.height
  playButton.anchorY = 1
end


-- Go to level
local function gotoLevel()
  composer.gotoScene( "level"..level )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
  
  -- Load the level from file
  level = loadLevel()
  displayLevel()
  displayPlayButton()
  
  playButton:addEventListener( "tap", gotoLevel )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
    display.remove( currentLevelLabel )
    display.remove( currentLevel )
    display.remove( playButton )
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    composer.removeScene( "menu" )
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
