module(..., package.seeall)  

-- Level Scores DBS
local lfs = require "lfs"
local json = require "json"
-- get raw path to app's Documents directory
local docs_path = system.pathForFile( "", system.DocumentsDirectory )
local score_storage_path
function init()
	-- change current working directory
	local success = lfs.chdir( docs_path ) -- returns true on success
	local dname = "scores"
	if success then
		score_storage_path = lfs.currentdir() .. "/" .. dname
		success = lfs.chdir( score_storage_path )
		if not success then
			success = lfs.mkdir( dname )
			print("Created scores directory since it does not exist",success)
		else
			print("scores directory exists! yeeey!")
		end
	end
end

function CleanAllBadChars(level_id)
	level_id = level_id:gsub("/","")
	level_id = level_id:gsub("\\","")
	level_id = level_id:gsub(":","")
	level_id = level_id:gsub(".lvl","")
	level_id = level_id..".j"
	return level_id
end
function update_score(level_id,level_results)
	local oldScore = get_score(level_id)
	level_id = CleanAllBadChars(level_id)
	local improved = false
	if oldScore then -- normalise data fields so that latest best score results are stored
		if oldScore["stars"] > level_results["stars"] then
			level_results["stars"] = oldScore["stars"]
		else
			improved = true
		end
		
		if oldScore["score"] > level_results["score"] then
			level_results["score"] = oldScore["score"]
		else
			improved = true
		end
	end
	print("Score storage path:",score_storage_path.."/"..level_id)
	local file,reason = io.open( score_storage_path.."/"..level_id, "w" )
	if file then
		local towrite = json.encode(level_results)
		if towrite then
			file:write( towrite )
		end
		io.close( file )
	end
	file = nil
	return improved
end
function get_score(level_id)
	level_id = CleanAllBadChars(level_id)
	local fpath = score_storage_path.."/"..level_id
	--print("Score storage path:",fpath)
	local file,reason = io.open( fpath, "r" )
	if file then
		local data = file:read("*a")
		io.close( file )
		file = nil
		return json.decode(data)
	end
	return nil
end