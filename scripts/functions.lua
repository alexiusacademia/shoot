-- Function to save level to file
function saveLevel( level )
  -- Data to write
  local data = level
  
  -- Path for the file
  local path = system.pathForFile( "level.dat", system.DocumentsDirectory )
  
  -- Open the file handler
  local file, errorString = io.open( path, "w" )
  
  if not file then
    -- Error occured
    print("File error: "..errorString)
  else
    -- Write date to the file
    file:write( data )
    -- Close the file handler
    io.close( file )
  end
  file = nil
end

-- Load level from file
function loadLevel()
  local level = 1
  -- Path for the file
  local path = system.pathForFile( "level.dat", system.DocumentsDirectory )
  print(path)
  -- Open the file handler
  local file, errorString = io.open( path, "r" )
  
  if not file then
    -- Error occurred
    print( "File error: ".. errorString )
  else
    -- Read data from the file
    local contents = file:read( "*a" )
    
    -- Replace the level with the saved level
    level = contents
    io.close( file ) 
  end
  file = nil
  
  return tonumber(level)
end