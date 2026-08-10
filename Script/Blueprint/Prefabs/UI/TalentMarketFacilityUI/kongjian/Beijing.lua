---@class Beijing_C:UUserWidget
---@field Button_77 UButton
---@field Button_131 UButton
---@field Image_296 UImage
---@field 背景 UImage
--Edit Below--
local Beijing = { bInitDoOnce = false } 


function Beijing:Construct()
	self:LuaInit();
	
end


-- function Beijing:Tick(MyGeometry, InDeltaTime)

-- end

-- function Beijing:Destruct()

-- end

-- [Editor Generated Lua] function define Begin:
function Beijing:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	self.Button_131.OnClicked:Add(self.Button_131_OnClicked, self);
	-- [Editor Generated Lua] BindingEvent End;
end

function Beijing:Button_131_OnClicked()
	return nil;
end

-- [Editor Generated Lua] function define End;

return Beijing