local Action_SendEvent = 
{
	SendEventName = "";
}


function Action_SendEvent:Execute()
    print(string.format("Action_SendEvent:Execute SendEventName[%s]", self.SendEventName));

    LuaQuickFireEvent(self.SendEventName, self);

    return true;
end


return Action_SendEvent