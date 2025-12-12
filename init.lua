-- Source:https://github.com/tekezo/Karabiner/issues/814#issuecomment-415388742
-- Hammerspoon
-- HANDLE SCROLLING WITH MOUSE BUTTON PRESSED
local backMouseButton = 3
local forwardMouseButton = 4
local deferred = false

function triggerNavigation(keystroke)
    -- No click generation needed, just trigger the keystroke
    -- This prevents ghost clicks during scrolling
end

overrideOtherMouseDown = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(e)
    -- print("down")    
    local pressedMouseButton = e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
    if backMouseButton == pressedMouseButton or forwardMouseButton == pressedMouseButton 
    then
            deferred = true
            return true
        end
end)

overrideOtherMouseUp = hs.eventtap.new({ hs.eventtap.event.types.otherMouseUp }, function(e)
     -- print("up")
    local pressedMouseButton = e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
    if backMouseButton == pressedMouseButton
        then
            if (deferred) then
                -- Browser back navigation without generating a click
                hs.eventtap.keyStroke({"cmd"}, "[")
                return true
            end
            return false
        end

        if forwardMouseButton == pressedMouseButton
            then
                if (deferred) then
                    -- Simulate middle-click (opens links in new tab, closes tabs)
                    local currentPos = e:location()
                    local clickDown = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.otherMouseDown, currentPos)
                    clickDown:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, 2)
                    local clickUp = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.otherMouseUp, currentPos)
                    clickUp:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, 2)
                    clickDown:post()
                    clickUp:post()
                    return true
                end
                return false
            end
            return false
end)

local oldmousepos = {}
local scrollmult = -4	-- negative multiplier makes mouse work like traditional scrollwheel

dragOtherToScroll = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDragged }, function(e)
    local pressedMouseButton = e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
    -- print ("pressed mouse " .. pressedMouseButton)
    if backMouseButton == pressedMouseButton or forwardMouseButton == pressedMouseButton 
        then 
            -- print("scroll");
            deferred = false
            oldmousepos = hs.mouse.absolutePosition()    
            local dx = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaX'])
            local dy = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaY'])
            local scroll = hs.eventtap.event.newScrollEvent({dx * scrollmult, dy * scrollmult},{},'pixel')
            -- put the mouse back
            hs.mouse.absolutePosition(oldmousepos)
            return true, {scroll}
        else 
            return false, {}
        end 
end) 

overrideOtherMouseDown:start()
overrideOtherMouseUp:start()
dragOtherToScroll:start()

-- Windows Manager
-- Source: https://github.com/miromannino/miro-windows-manager

local hyper = {"ctrl", "alt", "cmd"}

hs.loadSpoon("MiroWindowsManager")

hs.window.animationDuration = 0.3
spoon.MiroWindowsManager:bindHotkeys({
  up = {hyper, "up"},
  right = {hyper, "right"},
  down = {hyper, "down"},
  left = {hyper, "left"},
  fullscreen = {hyper, "f"},
  nextscreen = {hyper, "n"}
})
