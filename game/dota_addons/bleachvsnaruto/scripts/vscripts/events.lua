-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.
-- Do not remove the GameMode:_Function calls in these events as it will mess with the internal barebones systems.

-- item relevant functions which are fired on events
require('items')
-- music.lua, relevant functions to control the music each will player will listen to/not listen to
require('music')
-- rescale.lua, relevant functions rescale the model sizes
require('rescale')
-- label.lua, relevant functions to modify the name/label of a player
require('label')
-- leaverGold.lua, relevant functions to modify gold income after some1 disconnects the game
require('leaverGold')
require('settings')

--TEAM_1_VIEW = false
--TEAM_2_VIEW = false

--cheats.lua, includes functions which listen to chat inputs of the players
  require('cheats')


-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
  DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  DebugPrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
  DebugPrint( '[BAREBONES] OnPlayerReconnect' )
  DebugPrintTable(keys) 

end

-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
  DebugPrint("[BAREBONES] GameRules State Changed")
  DebugPrintTable(keys)
  -- This internal handling is used to set up main barebones functions
  GameMode:_OnGameRulesStateChange(keys)
  
  --GameRules.ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
  --local courierCost = GameRules.ItemKV["item_courier"].ItemCost
  --local courierStockMax = GameRules.ItemKV["item_courier"].ItemStockMax
  
  local newState = GameRules:State_Get()
  
  if newState == 4 then -- если игра началась - заменяет стандартные модели куррьеров на модели, указанные в "FindByModel"
  print ("state")
     --local shopkeeper = Entities:FindByModel(nil, "models/heroes/shopkeeper/shopkeeper.vmdl")
     --shopkeeper:SetModelScale(2.4)
     --local shopkeeper_dire = Entities:FindByModel(nil, "models/heroes/shopkeeper_dire/shopkeeper_dire.vmdl")
     --shopkeeper_dire:SetModelScale(2.4)
  end -- По непонятной причине это вызывает ошибку, так что видимо нужно изменять модель как-то по-другому...
  
  --Пишет определенный приветственный текст в чате, когда игра начинается. Редактировать текст в файле settings.lua Перевод текста на разные языки осуществляется в resource/addon_russian.txt или addon_english.txt
  if GetMapName() == "dota" then 
  if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		GameRules:SendCustomMessage(_G.helpText1, 2, 3)
		GameRules:SendCustomMessage(_G.helpText2, 2, 3)
  end
  end
 
 if GetMapName() == "2x2" then
  if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		GameRules:SendCustomMessage(_G.helpText1, 2, 3)
		GameRules:SendCustomMessage(_G.helpText2, 2, 3)
		GameRules:SendCustomMessage(_G.helpText4, 2, 3)
		GameRules:SendCustomMessage(_G.helpText5, 2, 3)
  end
  end
  if GetMapName() == "duel" then
  if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		GameRules:SendCustomMessage(_G.helpText1, 2, 3)
		GameRules:SendCustomMessage(_G.helpText2, 2, 3)
		GameRules:SendCustomMessage(_G.helpText4, 2, 3)
		GameRules:SendCustomMessage(_G.helpText5, 2, 3)
  end
  end

  --This function controls the music on each gamestate
  --GameMode:PlayGameMusic(newState)
  

end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)
	
	if not npc or npc:GetClassname() == "npc_dota_thinker" or npc:IsPhantom() then
    return
    end
	
if npc then
   if GetMapName() == "duel" or GetMapName() == "2x2" then --Если была выбрана карта 2х2 или дуэль, то в начале игры каждому игроку выдается курьер и баф на опыт и голду, а каждому курьеру дается баф на скорость.
	if npc:IsRealHero() and npc.bFirstSpawned == nil then --если нпс является игроком и заспавнился впервые за игру
	    npc:AddNewModifier(npc, nil, 'modifier_global_boost', nil) --тогда даем им баф
		npc:AddItemByName("item_courier") --и даем курьера
		npc.bFirstSpawned = true --и говорим, что этот герой был заспавнен, дабы курьер и баф не выдавались повторно после возрождения героя
	end
	if npc:GetUnitName() == "npc_dota_courier" then --если это курьер
		print ("courier")
	    npc:AddNewModifier(npc_dota_courier, nil, 'modifier_courier_speed', nil) --даем ему баф на скорость
	end
   end
		
	local player = "-1"
	if npc:IsHero() and npc:GetPlayerID() then
          if PlayerResource:GetSteamAccountID(npc:GetPlayerID()) == 111179147 then --Проверяю steam id игрока, если совпадает с например 111179147, то у него над головой будет надпись "Game Creator" например.
              npc:SetCustomHealthLabel("Game Creator", 192, 30, 255) --Цифры регулируют цвет надписи по RGB палитре
			  if npc:GetUnitName() == "npc_dota_hero_ogre_magi" then --Если выбран Мадара (который заменяет огр мага)
			    npc:AddItemByName("item_madara_6path_essence") --даю эссенцию Мадары
			  end
          end
		  if PlayerResource:GetSteamAccountID(npc:GetPlayerID()) == 111361955 then
              npc:SetCustomHealthLabel("Game Creator", 192, 30, 255)
			  if npc:GetUnitName() == "npc_dota_hero_ogre_magi" then
			    npc:AddItemByName("item_madara_6path_essence") --даю эссенцию Мадары
			  end
          end
		  if PlayerResource:GetSteamAccountID(npc:GetPlayerID()) == 186770581 then
              npc:SetCustomHealthLabel("Game Creator", 192, 30, 255)
			  if npc:GetUnitName() == "npc_dota_hero_ogre_magi" then
			    npc:AddItemByName("item_madara_6path_essence") --даю эссенцию Мадары
			  end
          end
		  if PlayerResource:GetSteamAccountID(npc:GetPlayerID()) == 326923709 then
              npc:SetCustomHealthLabel("Game Creator", 192, 30, 255)
			  if npc:GetUnitName() == "npc_dota_hero_ogre_magi" then
			    npc:AddItemByName("item_madara_6path_essence") --даю эссенцию Мадары
			  end
          end
		  if PlayerResource:GetSteamAccountID(npc:GetPlayerID()) == 207075511 then
              --npc:SetCustomHealthLabel("Game Creator", 192, 30, 255)
			  if npc:GetUnitName() == "npc_dota_hero_ogre_magi" then
			    npc:AddItemByName("item_madara_6path_essence") --даю эссенцию Мадары
			  end
          end
	end
	end
	
	--Тут в общем было лень думать как по-другому сделать, чтоб у куклы Карасу Канкуро скиллы апались по мере апа самого скилла пизыва Карасу. По хорошему это надо сделать по-другому...
	if npc:GetUnitName() == "npc_dota_lone_druid_bear1" then
		npc:FindAbilityByName("venomancer_poison_nova"):SetLevel(1)
		npc:FindAbilityByName("karasu_daggers"):SetLevel(1)
		npc:FindAbilityByName("karasu_critical_strike"):SetLevel(0)
		npc:FindAbilityByName("lone_druid_spirit_bear_return"):SetLevel(1)
	end
	if npc:GetUnitName() == "npc_dota_lone_druid_bear2" then
		npc:FindAbilityByName("venomancer_poison_nova"):SetLevel(2)
		npc:FindAbilityByName("karasu_daggers"):SetLevel(2)
		npc:FindAbilityByName("karasu_critical_strike"):SetLevel(1)
		npc:FindAbilityByName("lone_druid_spirit_bear_return"):SetLevel(1)
	end
	if npc:GetUnitName() == "npc_dota_lone_druid_bear3" then
		npc:FindAbilityByName("venomancer_poison_nova"):SetLevel(3)
		npc:FindAbilityByName("karasu_daggers"):SetLevel(2)
		npc:FindAbilityByName("karasu_critical_strike"):SetLevel(2)
		npc:FindAbilityByName("lone_druid_spirit_bear_return"):SetLevel(2)
	end
	if npc:GetUnitName() == "npc_dota_lone_druid_bear4" then
		npc:FindAbilityByName("venomancer_poison_nova"):SetLevel(4)
		npc:FindAbilityByName("karasu_daggers"):SetLevel(3)
		npc:FindAbilityByName("karasu_critical_strike"):SetLevel(3)
		npc:FindAbilityByName("lone_druid_spirit_bear_return"):SetLevel(3)
	end

    if npc:IsRealHero() then
      GameMode:RemoveWearables( npc )
      if npc:GetTeamNumber() == 1 and not TEAM_1_VIEW then
        AddFOWViewer(npc:GetTeamNumber(),Vector(5528, 5000, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(1500, 1000, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(-2500, 6000, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(6200, -500, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(-2500, -2000, 240), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(-5932, -5348, 240), 10000000000, 0.1, false)
        TEAM_1_VIEW= true
       -- if npc:GetUnitName() == "npc_dota_hero_lion" then
      --    npc:AddItem(CreateItem("item_chakra_armor_male", npc, npc))
       -- end
      end
      if npc:GetTeamNumber() == 2 and not TEAM_2_VIEW then
        AddFOWViewer(npc:GetTeamNumber(),Vector(5528, 5000, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(1500, 1000, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(-2500, 6000, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(6200, -500, 256), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(-2500, -2000, 240), 10000000000, 0.1, false)
        AddFOWViewer(npc:GetTeamNumber(),Vector(-5932, -5348, 240), 10000000000, 0.1, false)
       -- if npc:GetUnitName() == "npc_dota_hero_lion" then
      --    npc:AddItem(CreateItem("item_chakra_armor_male", npc, npc))
       -- end
       TEAM_2_VIEW = true
      end
    end
    GameMode:RescaleUnit(npc)
end

function empty_weapon(keys)
              caster = keys.caster
			  item = keys.ability
			  
              Timers:CreateTimer({
			  endTime = 30, -- delay before
			  callback = function()
                     caster:RemoveItem(item)
			  end})
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
  --DebugPrint("[BAREBONES] Entity Hurt")
  --DebugPrintTable(keys)

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  if keys.entindex_attacker ~= nil then
    local entCause = EntIndexToHScript(keys.entindex_attacker)
  end
  local entVictim = EntIndexToHScript(keys.entindex_killed)
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
  DebugPrint( '[BAREBONES] OnItemPickedUp' )
  DebugPrintTable(keys)
  local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname
end



-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
  DebugPrint( '[BAREBONES] OnItemPurchased' )
  DebugPrintTable(keys)
    print("sd")
  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
  
  local player = PlayerResource:GetPlayer(keys.PlayerID)

  if itemName == "item_forehead_protector" then
    GameMode:ForeheadProtectorOnItemPickedUp(player, itemName)
  end 


  if itemName == "item_flying_courier" then --этот код изменяет модель летающих курьеров, из-за этого возможно тоже будет ошибка, но это не точно, проверьте сами
    --Timers:CreateTimer( 0.5, function()
    --    local flying_courier = Entities:FindByModel(nil, "models/props_gameplay/donkey_wings.vmdl")
    --    flying_courier:SetModelScale(1.2)
    --    return nil
     --end
     --)
  end 
  if itemName == "courier_radiant_flying" then
    --Timers:CreateTimer( 0.5, function()
    --    local flying_courier = Entities:FindByModel(nil, "models/props_gameplay/donkey_dire.vmdl")
    --    flying_courier:SetModelScale(1.2)
    --    return nil
    -- end
    -- )
  end 
 
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
  DebugPrint('[BAREBONES] AbilityUsed')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.PlayerID)
  local abilityname = keys.abilityname
end



-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
  DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
  DebugPrintTable(keys)

  local abilityname = keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
  DebugPrint('[BAREBONES] OnPlayerChangedName')
  DebugPrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
  DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
  DebugPrint('[BAREBONES] OnAbilityChannelFinished')
  DebugPrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
  DebugPrint('[BAREBONES] OnPlayerLevelUp')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
  DebugPrint('[BAREBONES] OnLastHit')
  DebugPrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
  DebugPrint('[BAREBONES] OnTreeCut')
  DebugPrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
  DebugPrint('[BAREBONES] OnRuneActivated')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_BOUNTY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
  DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
  DebugPrint('OnPlayerPickHero')
  DebugPrintTable(keys)
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
  DebugPrint('[BAREBONES] OnTeamKillCredit')
  DebugPrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end

-- An entity died
function GameMode:OnEntityKilled( keys )
  DebugPrint( '[BAREBONES] OnEntityKilled Called' )
  DebugPrintTable( keys )

  GameMode:_OnEntityKilled( keys )
  

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  --Items
  if killerEntity ~= nil then
    GameMode:SupportItemCooldownReset(killedUnit, killerEntity)
    GameMode:PlayKillSound(killerEntity, killedUnit)
  end



end



-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
  DebugPrint('[BAREBONES] PlayerConnect')
  DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
  DebugPrint('[BAREBONES] OnConnectFull')
  DebugPrintTable(keys)

  GameMode:_OnConnectFull(keys)
  
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function GameMode:OnIllusionsCreated(keys)
  DebugPrint('[BAREBONES] OnIllusionsCreated')
  DebugPrintTable(keys)

  local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
  DebugPrint('[BAREBONES] OnItemCombined')
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end
  local player = PlayerResource:GetPlayer(plyID)

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost

  if itemName == "item_chakra_armor" then
    GameMode:ChakraArmorOnItemPickedUp(player, itemName)
  end

end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function GameMode:OnAbilityCastBegins(keys)
  DebugPrint('[BAREBONES] OnAbilityCastBegins')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)
  DebugPrint('[BAREBONES] OnTowerKill')
  DebugPrintTable(keys)

  local gold = keys.gold
  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local team = keys.teamnumber
  
  if GetMapName() == "duel" then
  if keys.teamnumber == 2 then
  	GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
  else
  	GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
  end
  end
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)
  DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.player_id)
  local success = (keys.success == 1)
  local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
  DebugPrint('[BAREBONES] OnNPCGoalReached')
  DebugPrintTable(keys)

  local goalEntity = EntIndexToHScript(keys.goal_entindex)
  local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
  local npc = EntIndexToHScript(keys.npc_entindex)
end