
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

shop_cosmetic_item := class<concrete>():

    # Gets triggered when the player walks over the button
    @editable
    TriggerMutatorZone : mutator_zone_device = mutator_zone_device{}

    # Determines whether the player owns the cosmetic (if you want to enable persistence for item ownership, modify the perssistance settings of the switch device)
    @editable
    OwnershipStatusSwitch : switch_device = switch_device{}

    # The visual effect that will be spawned when the player picks up the cosmetic
    @editable
    CosmeticVFXPowerUp : visual_effect_powerup_device = visual_effect_powerup_device{}

    # Used to determine whether the player has enough items to purchase the cosmetic
    @editable
    CosmeticPurchaseConditionalButton : conditional_button_device = conditional_button_device{}

    # Signaled when the player picks up(wears) the cosmetic
    CosmeticPicked<public> : event(agent) = event(agent){}

    # Used to display messages to the player
    var HudMSGDevice : hud_message_device = hud_message_device{}

    Init(DefaultHUDMSG : hud_message_device):void=
        set HudMSGDevice = DefaultHUDMSG

    # Gets triggered when the player walks over the button
    OnTriggered(Agent : agent):void=
        spawn:
            AsyncOnTriggered(Agent)


    AsyncOnTriggered(Agent : agent)<suspends>:void=
        # Check if the player already owns the cosmetic
        if(OwnershipStatusSwitch.GetCurrentState[Agent]):
            EquipCosmetic(Agent)
        else:
            # Check if the player has enough items to purchase the cosmetic
            if(CosmeticPurchaseConditionalButton.HasAllItems[Agent]):
                sync:
                    # Activates the conditional button, which will trigger the ActivatedEvent or NotEnoughItemsEvent depending on whether the player has enough items
                    block:
                        Sleep(0.05)
                        CosmeticPurchaseConditionalButton.Activate(Agent)

                    block:
                        # Wait for the conditional button to signal whether the player has enough items
                        Res := race:
                            block:
                                CosmeticPurchaseConditionalButton.ActivatedEvent.Await()
                                true
                            block:
                                CosmeticPurchaseConditionalButton.NotEnoughItemsEvent.Await()
                                false

                        if(Res?):
                            OwnershipStatusSwitch.TurnOn(Agent) # Set the ownership status to true
                            EquipCosmetic(Agent) 

            else:
                HudMSGDevice.Show(Agent) # Displays "Not enough items" to the player

    # Equips the cosmetic to the player
    EquipCosmetic(Agent : agent):void=
        CosmeticVFXPowerUp.Pickup(Agent)
        CosmeticPicked.Signal(Agent)



shop_cosmetic_manager := class(creative_device):

    # List of all cosmetic items in the shop
    @editable
    CosmeticItems : []shop_cosmetic_item = array{}

    # The HUD message device that will be used to display messages to the player
    @editable
    DefaultHUDMSG : hud_message_device = hud_message_device{}


    # List of all players and their equipped cosmetics (used to re-equip the cosmetic when the player respawns)
    # See https://forums.unrealengine.com/t/vfx-powerup-persist-on-elimination-not-working/1837676/8
    # You will need a list like this for each cosmetic TYPE (e.g. 1 for all hats, 1 for all wings, etc.)
    var PlayerCosmetics : [agent]visual_effect_powerup_device = map{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(CosmeticItem : CosmeticItems):

            CosmeticItem.Init(DefaultHUDMSG) # Initialize the cosmetic item
            
            CosmeticItem.TriggerMutatorZone.AgentEntersEvent.Subscribe(CosmeticItem.OnTriggered)

            # Listen for the event that gets triggered when the player picks up a cosmetic
            spawn:
                ListenForCosmeticPickedEvent(CosmeticItem)



    # Listens for the event that gets triggered when the player picks up a cosmetic   
    ListenForCosmeticPickedEvent(CosmeticItem : shop_cosmetic_item)<suspends>:void=
        loop:
            TargetPlayer := CosmeticItem.CosmeticPicked.Await()
            UpdatePlayerCosmetic(TargetPlayer, CosmeticItem) # Updates the player's equipped cosmetic
            Sleep(0.0)


    # Updates the player's equipped cosmetic
    UpdatePlayerCosmetic(Agent : agent, CosmeticItem : shop_cosmetic_item):void=
        if:
            set PlayerCosmetics[Agent] = CosmeticItem.CosmeticVFXPowerUp
        then:
            Print("Updated player cosmetic list")
        else:
            Print("Failed to update player cosmetic list")

    # Re-equips the player's cosmetic when they respawn (this should be called from a class/device that listens to the player's respawn event)
    ReEquipPlayerCosmetic<public>(Agent : agent):void=
        # Check if the player has a cosmetic equipped
        if:
            CurrentPlayerCosmetic := PlayerCosmetics[Agent]
        then:
            CurrentPlayerCosmetic.Spawn()
            CurrentPlayerCosmetic.Pickup(Agent)
