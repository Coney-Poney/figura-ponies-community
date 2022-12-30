local path = animations.pony

local allAnims = {

}

local excluAnims = {

}


local incluAnims = {

}

local hp = 20
local oldhp = 20
local animsTable={
    allVar = false,
    excluVar = false,
    incluVar = false
}

function events.entity_init()
    hp = player:getHealth() + player:getNbt().AbsorptionAmount
    oldhp = hp
end

function events.tick()
    for key, value in ipairs(allAnims) do
        if value:getPlayState() == "PLAYING" then
            animsTable.allVar = true
            break
        else
            animsTable.allVar = false
        end
    end
    for key, value in ipairs(excluAnims) do
        if value:getPlayState() == "PLAYING" then
            animsTable.excluVar = true
            break
        else
            animsTable.excluVar = false
        end
    end
    for key, value in ipairs(incluAnims) do
        if value:getPlayState() == "PLAYING" then
            animsTable.incluVar = true
            break
        else
            animsTable.incluVar = false
        end
    end
    oldhp = hp
    hp = player:getHealth() + player:getNbt().AbsorptionAmount
    local posing = player:getPose()
    local velocity = player:getVelocity()
    local water = player:isInWater()
    local vehicle = player:getVehicle() ~= nil
    local movingstate = player:isClimbing() or player:isFlying() or vehicle or posing ~= "STANDING"
    local jumpingstate = velocity.y > 0 or velocity.y < 0
    local sprint = player:isSprinting()
    local handedness = player:isLeftHanded()
    local rightActive = handedness and "OFF_HAND" or "MAIN_HAND"
    local leftActive = not handedness and "OFF_HAND" or "MAIN_HAND"
    local activeness = player:getActiveHand()
    local using = player:isUsingItem()
    local pv = player:getVelocity():mul(1, 0, 1):normalize()
    local pl = models:partToWorldMatrix():applyDir(0,0,-1):mul(1, 0, 1):normalize()
    local fwd = pv:dot(pl)
    local backwards = fwd < -.8
    local sleeping = posing == "SLEEPING"
    local rightSwing = player:getSwingArm() == rightActive and not sleeping
    local leftSwing = player:getSwingArm() == leftActive and not sleeping
    local rightItem = player:getHeldItem(handedness)
    local leftItem = player:getHeldItem(not handedness)
    local usingR = activeness == rightActive and rightItem:getUseAction()
    local usingL = activeness == leftActive and leftItem:getUseAction()

    local crossR = rightItem.tag and rightItem.tag["Charged"] == 1
    local crossL = leftItem.tag and leftItem.tag["Charged"] == 1
    local drinkingR = using and usingR == "DRINK"
    local drinkingL = using and usingL == "DRINK"
    local eatingR = (using and usingR == "EAT") or (drinkingR and not path.drinkingR)
    local eatingL = (using and usingL == "EAT") or (drinkingL and not path.drinkingL)
    local blockingR = using and usingR == "BLOCK"
    local blockingL = using and usingL == "BLOCK"
    local bowingR = using and usingR == "BOW"
    local bowingL = using and usingL == "BOW"
    local spearR = using and usingR == "SPEAR"
    local spearL = using and usingL == "SPEAR"
    local spyglassR = using and usingR == "SPYGLASS"
    local spyglassL = using and usingL == "SPYGLASS"
    local hornR = using and usingR == "TOOT_HORN"
    local hornL = using and usingL == "TOOT_HORN"
    local loadingR = using and usingR == "CROSSBOW"
    local loadingL = using and usingL == "CROSSBOW"
    local crouchwalkbackstate = posing == "CROUCHING" and backwards
    local crouchwalkstate = (posing == "CROUCHING" and velocity:length() > 0  and not backwards) or (crouchwalkbackstate and not path.crouchwalkback)
    local crouchstate =  (posing == "CROUCHING" and velocity:length() == 0) or (crouchwalkstate and not path.crouchwalk)
    local crawlstillstate = posing == "SWIMMING" and not water and velocity:length() == 0
    local crawlstate = (posing == "SWIMMING" and not water and velocity:length() > 0) or (crawlstillstate and not path.crawlstill)
    local swimstate = (posing == "SWIMMING" and water) or (crawlstate and not path.crawl)
    local elytradownstate = posing == "FALL_FLYING" and velocity.y < 0
    local elytrastate = (posing == "FALL_FLYING" and velocity.y > 0) or (elytradownstate and not path.elytradown)
    local flystate = player:isFlying() and not vehicle
    local vehiclestate = vehicle
    local sleepstate = sleeping
    local climbstate = player:isClimbing() and posing ~= "CROUCHING"
    local tridentstate = player:getPose() == "SPIN_ATTACK"
    local fallstate = not movingstate and velocity.y < -.6
    local jumpdownstate = (not movingstate and velocity.y < 0 and velocity.y > -.52) or (fallstate and not path.fall)
    local jumpupstate =  (not movingstate and velocity.y > 0 and not player:isFlying()) or (tridentstate and not path.trident) or (jumpdownstate and not path.jumpdown)
    local deadstate = hp == 0
    local sprintstate = not movingstate and not jumpingstate and sprint and posing == "STANDING"
    local walkbackstate = not movingstate and not jumpingstate and velocity:length() > 0 and not sprint and posing == "STANDING" and backwards
    local walkstate = (not movingstate and not jumpingstate and velocity:length() > 0 and not sprint and posing == "STANDING" and not backwards) 
    or (walkbackstate and not path.walkback) or (sprintstate and not path.sprint) or (climbstate and not path.climb) or (swimstate and not path.swim) or (elytrastate and not path.elytra)
    or (jumpupstate and not path.jumpup)
    local idlestate = (not movingstate and velocity:length() == 0 and (posing == "STANDING" or posing == "SWIMMING" and not water)) or (sleepstate and not path.sleep) or (vehiclestate and not path.vehicle) or (flystate and not path.fly)

    if oldhp > hp and hp ~= 0 and oldhp ~= 0 then
        if path.hurt then path.hurt:restart() end
    end
    
    local exclustate = (not animsTable.allVar and not animsTable.excluVar) and not deadstate
    local inclustate = not animsTable.allVar and not animsTable.incluVar

    path.walk:setPlaying(exclustate and walkstate)
    path.idle:setPlaying(exclustate and idlestate)
    path.crouch:setPlaying(exclustate and crouchstate)
    if path.walkback then path.walkback:setPlaying(exclustate and walkbackstate) end
    if path.sprint then path.sprint:setPlaying(exclustate and sprintstate) end
    if path.crouchwalk then path.crouchwalk:setPlaying(exclustate and crouchwalkstate) end
    if path.crouchwalkback then path.crouchwalkback:setPlaying(exclustate and crouchwalkbackstate) end
    if path.elytra then path.elytra:setPlaying(exclustate and elytrastate) end
    if path.elytradown then path.elytradown:setPlaying(exclustate and elytradownstate) end
    if path.fly then path.fly:setPlaying(exclustate and flystate) end
    if path.vehicle then path.vehicle:setPlaying(exclustate and vehiclestate) end
    if path.sleep then path.sleep:setPlaying(exclustate and sleepstate) end
    if path.climb then path.climb:setPlaying(exclustate and climbstate) end
    if path.swim then path.swim:setPlaying(exclustate and swimstate) end
    if path.crawl then path.crawl:setPlaying(exclustate and crawlstate) end
    if path.crawlstill then path.crawlstill:setPlaying(exclustate and crawlstillstate) end
    if path.fall then path.fall:setPlaying(exclustate and fallstate) end
    if path.jumpup then path.jumpup:setPlaying(exclustate and jumpupstate) end
    if path.jumpdown then path.jumpdown:setPlaying(exclustate and jumpdownstate) end
    if path.trident then path.trident:setPlaying(exclustate and tridentstate) end
    if path.death then path.death:setPlaying(deadstate) end

    if path.eatingR then path.eatingR:setPlaying(inclustate and eatingR) end
    if path.eatingL then path.eatingL:setPlaying(inclustate and eatingL) end
    if path.drinkingR then path.drinkingR:setPlaying(inclustate and drinkingR) end
    if path.drinkingL then path.drinkingL:setPlaying(inclustate and drinkingL) end
    if path.blockingR then path.blockingR:setPlaying(inclustate and blockingR) end
    if path.blockingL then path.blockingL:setPlaying(inclustate and blockingL) end
    if path.bowR then path.bowR:setPlaying(inclustate and bowingR) end
    if path.bowL then path.bowL:setPlaying(inclustate and bowingL) end
    if path.crossbowR then path.crossbowR:setPlaying(inclustate and crossR) end
    if path.crossbowL then path.crossbowL:setPlaying(inclustate and crossL) end
    if path.loadingR then path.loadingR:setPlaying(inclustate and loadingR) end
    if path.loadingL then path.loadingL:setPlaying(inclustate and loadingL) end
    if path.spearR then path.spearR:setPlaying(inclustate and spearR) end
    if path.spearL then path.spearL:setPlaying(inclustate and spearL) end
    if path.spyglassR then path.spyglassR:setPlaying(inclustate and spyglassR) end
    if path.spyglassL then path.spyglassL:setPlaying(inclustate and spyglassL) end
    if path.hornR then path.hornR:setPlaying(inclustate and hornR) end
    if path.hornL then path.hornL:setPlaying(inclustate and hornL) end
    if path.attackR then path.attackR:setPlaying(inclustate and rightSwing) end
    if path.attackL then path.attackL:setPlaying(inclustate and leftSwing) end

    path.crouch:blendTime(posing == "CROUCHING" and 5 or 0)
    --path.crouchwalk:blendTime(posing == "CROUCHING" and 5 or 0)
    --path.crouchwalkback:blendTime(posing == "CROUCHING" and 5 or 0)
end

path.walk:speed(1.5)

require("GSAnimBlend")

path.idle:blendTime(5)
path.walk:blendTime(5)
--path.walkback:blendTime(5)
path.sprint:blendTime(5)

path.jumpup:blendTime(5)
path.jumpdown:blendTime(5)
path.fall:blendTime(5)
--path.elytra:blendTime(5)
--path.elytradown:blendTime(5)
path.climb:blendTime(5)
path.crawl:blendTime(5)
--path.crawlstill:blendTime(5)
path.swim:blendTime(5)
--path.fly:blendTime(5)

return animsTable