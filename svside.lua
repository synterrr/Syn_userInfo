function vRPFramework()

end

function ESXFramework()

end

function Standalone()

end

CreateThread(function()
    if IsDuplicityVersion() then
        if GetResourceState('vrp') == "started" then
            vRPFramework()
        elseif GetResourceState('esx') == "started" then
            ESXFramework()
        else
            Standalone()
        end
    end
end)