

function GameMode:Setup_surrenderTable()
    -- setup race reference table
    if GameRules.surrenderTable == nil then
        GameRules.surrenderTable = {}
        GameRules.surrenderTable[1] = 0
        GameRules.surrenderTable[2] = 0
        GameRules.surrenderTable[3] = 0
        GameRules.surrenderTable[4] = 0
        GameRules.surrenderTable[5] = 0
        GameRules.surrenderTable[6] = 0
        GameRules.surrenderTable[7] = 0
        GameRules.surrenderTable[8] = 0
        GameRules.surrenderTable[9] = 0
        GameRules.surrenderTable[10] = 0
        GameRules.surrenderTable[11] = 0
        GameRules.surrenderTable[12] = 0
    end

end


function GameMode:surrender( playerID )

	

	GameMode:Setup_stateTable()
	GameMode:Setup_surrenderTable()

	if GameRules.surrenderTable[playerID+1] ~= 1 then
		local player = PlayerResource:GetPlayer(playerID)
		local teamNumber = PlayerResource:GetTeam(playerID)
		local allies = 0
		local alliesFF = 0
		GameRules.surrenderTable[playerID+1] = 1

		for id=0,12 do
	        if  GameRules.stateTable[id+1] ~= 4 then
	            if PlayerResource:GetTeam(id) == teamNumber then
	              allies = allies + 1
	              if GameRules.surrenderTable[id+1] == 1 then
	              	alliesFF = alliesFF + 1
	          	  end
	            end
	        end
	    end


	    if alliesFF < allies then
	    	if teamNumber == 2 then
	    		GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. " of the Shinobi Alliance did forfeit. " .. alliesFF .. "/" .. allies, 0, 0)
	    	end
		    if teamNumber == 3 then
		    	GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. " of the Akatsuki Force did forfeit. " .. alliesFF .. "/" .. allies, 0, 0)
		    end
		else
			if teamNumber == 2 then
	    		GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. " of the Shinobi Alliance did forfeit. " .. alliesFF .. "/" .. allies, 0, 0)
	    		GameRules:SendCustomMessage("Shinobi Alliance surrendered. VICTORY for the Akatsuki Force.", 0, 0)
	    		GameRules:SetGameWinner(3)
	    	end
		    if teamNumber == 3 then
		    	GameRules:SendCustomMessage(PlayerResource:GetPlayerName(playerID) .. " of the Akatsuki Force did forfeit. " .. alliesFF .. "/" .. allies, 0, 0)
		    	GameRules:SendCustomMessage("Akatsuki Force surrendered. VICTORY for the Shinobi Alliance.", 0, 0)
	    		GameRules:SetGameWinner(2)
		    end
	    end
	end


	
    
end