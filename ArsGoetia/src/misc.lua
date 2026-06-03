SMODS.Consumable({
    set = "Tarot",
    key = "doctor",
    loc_txt = {
        name = "The Doctor",
        text = {
            "Enhances {C:attention}#1#{} selected",
			"cards to {C:attention}Alchemy Cards{}"
        }
    },
	config = { max_highlighted = 2, extra = 'm_arsGoetia_alchemy' },
	loc_vars = function(self, info_queue)
        info_queue[#info_queue + 1] = G.P_CENTERS[self.config.extra]
        return { vars = {self.config.max_highlighted} }
    end,
    atlas = 'arsGoetiaMisc',
	pos = { x = 0, y = 1 },
    cost = 3,
	
    can_use = function(self, card)
        if G.STATE ~= G.STATES.HAND_PLAYED
		and G.STATE ~= G.STATES.DRAW_TO_HAND
		and G.STATE ~= G.STATES.PLAY_TAROT
		or any_state then
            if #G.hand.highlighted >= 1
			and #G.hand.highlighted <= self.config.max_highlighted then
                return true
            else
				return false
			end
        end
    end,
	
    use = function(card, area, copier)
        local used_tarot = (copier or card)
		
		--wait for 0.4 seconds and play the sound
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('tarot1')
            --used_tarot:juice_up(0.3, 0.5) --this line shakes the consumables box for some reason
            return true end }))
			
		--for each card selected,
		for i = 1, #G.hand.highlighted do
			--get some percent for sound idk
			local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
			--flip the card and play the sound after 0.15 seconds
			G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
		end
		
		--wait
		delay(0.2)
		
		--for each,
		for i = 1, #G.hand.highlighted do
			--set the card enhancement and wait 0.1 seconds
			G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() G.hand.highlighted[i]:set_ability(G.P_CENTERS['m_arsGoetia_alchemy']);return true end }))
		end
		
		for i = 1, #G.hand.highlighted do
			--flip the card back over and wait
			percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
			G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
		end
		
		--unhighlight everything + wait
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
		
		--wait again
		delay(0.5)
		
		--return
        return true
    end,
})

SMODS.Enhancement({
	name = "Alchemy Card",
    key = "alchemy",
    badge_colour = G.C.SECONDARY_SET.Enhanced,
	config = { odds = 3 },
    loc_txt = {
        -- Badge name (displayed on card description when seal is applied)
        label = 'Alchemy Card',
        -- Tooltip description
        name = 'Alchemy Card',
        text = {
            '{C:green}#2# in #1#{} chance to',
			'create a {C:tarot}Tarot{} card'
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = {self.config.odds, ''..(G.GAME and G.GAME.probabilities.normal or 1) } }
    end,
    atlas = "arsGoetiaMisc",
    pos = { x = 1, y = 1 },
	
    -- self = this enhancement prototype
    -- card = card this enhancement is applied to
    calculate = function(self, card, context)
        -- main_scoring context is used whenever the card is scored
        if context.main_scoring
		and context.cardarea == G.play
		and pseudorandom('alchemy') < G.GAME.probabilities.normal /self.config.odds
		and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit
		then
			G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
			return {
                extra = {focus = card, message = localize('k_plus_tarot'), colour = G.C.SECONDARY_SET.Tarot, func = function()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = (function()
                                local newTarot = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'alchemy')
                                newTarot:add_to_deck()
                                G.consumeables:emplace(newTarot)
                                G.GAME.consumeable_buffer = 0
                            return true
                        end)}))
                end}
            }
        end
    end,
})

SMODS.Sticker({
	name = "Illusion",
    key = "illusion",
    badge_colour = G.C.DARK_EDITION,--{0.30, 0.20, 0.70, 1},
	config = { },
    loc_txt = {
        -- Badge name (displayed on card description when seal is applied)
        label = 'Illusion',
        -- Tooltip description
        name = 'Illusion',
        text = {
            '{C:attention}Destroyed{} after',
			'round ends.',
			'No {C:money}sell value{}'
        }
    },
    loc_vars = function(self, info_queue)
        return { vars = { } }
    end,
    atlas = "arsGoetiaMisc",
    pos = { x = 2, y = 1 },
	rate = 0,
	
	sets = { arsGoetia_illusionJokers = true },
	
    calculate = function(self, card, context)
		--destroy card if card is part of played hand
		if context.destroying_card then
			local isInPlayedHandFlag = false
			
			--not sure if there's just a function for this, but whatever
			for i = 1, #context.full_hand do
				if context.full_hand[i] == card then
					isInPlayedHandFlag = true
					break
				end
			end
		
			if isInPlayedHandFlag then
				SMODS.destroy_cards(card)
				
				delay(0.5)
			end
		end
	
        --destroy card at end of round
        if context.end_of_round then
			SMODS.destroy_cards(card)
        end
    end,
})

SMODS.Back({
    name = 'limbo_deck',
    key = 'limbo_deck',
    loc_txt = {
        name = 'Limbo Deck',
        text = {
            "Start run with",
			"{C:attention,T:v_blank}Blank{} voucher",
			"and {C:tarot,T:c_fool}The Fool{}"
        }
    },
	atlas = "arsGoetiaMisc",
    pos = { x = 0, y = 0 },
    config = {
        vouchers = { 'v_blank' },
        consumables = { 'c_fool' },
    },
    discovered = true,
    unlocked = true
})

SMODS.Back({
    name = 'lust_deck',
    key = 'lust_deck',
    loc_txt = {
        name = 'Lust Deck',
        text = {
            "At start of blind, fill",
			"empty consumable slots",
			"with {C:dark_edition,T:arsGoetia_illusion}Illusion{} {C:tarot,T:c_lovers}Lovers"
        }
    },
	atlas = "arsGoetiaMisc",
    pos = { x = 1, y = 0 },
    config = { },
    discovered = true,
    unlocked = true,
	
	calculate = function(self, back, context)
		if context.setting_blind then
			G.GAME.consumeable_buffer = G.consumeables.config.card_limit - #G.consumeables.cards
			
			G.E_MANAGER:add_event(Event({
			trigger = 'before',
			delay = 0.0,
			func = (function()
				for i = 1, G.consumeables.config.card_limit - #G.consumeables.cards do
					local newTarot = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_lovers', 'lust_deck')
					newTarot:add_to_deck()
					
					newTarot:set_illusion()
					
					G.consumeables:emplace(newTarot)
				end
				G.GAME.consumeable_buffer = 0
				return true
			end)}))
		end
	end
})

SMODS.Back({
    name = 'gluttony_deck',
    key = 'gluttony_deck',
    loc_txt = {
        name = 'Gluttony Deck',
        text = {
            "Start run with",
			"{C:attention,T:v_reroll_surplus}Reroll Surplus{}"--,
			--"and {C:attention,T:v_reroll_glut}Reroll Glut{}"
        }
    },
	atlas = "arsGoetiaMisc",
    pos = { x = 2, y = 0 },
    config = {
        vouchers = { 'v_reroll_surplus' }--,
		--vouchers = { 'v_reroll_glut' }
    },
    discovered = true,
    unlocked = true
})

SMODS.Back({
    name = 'greed_deck',
    key = 'greed_deck',
    loc_txt = {
        name = 'Greed Deck',
        text = {
            "Start run with",
			"{C:attention,T:v_seed_money}Seed Money{}",
			"and {C:attention,T:v_money_tree}Money Tree{}"
        }
    },
	atlas = "arsGoetiaMisc",
    pos = { x = 3, y = 0 },
    config = {
        vouchers = { 'v_seed_money' },
		vouchers = { 'v_money_tree' }
    },
    discovered = true,
    unlocked = true
})

SMODS.Back({
    name = 'wrath_deck',
    key = 'wrath_deck',
    loc_txt = {
        name = 'Wrath Deck',
        text = {
            "{C:attention}+#1#{} Joker slot,",
			"Destroy the {C:attention}leftmost{}",
			"{V:1}non-Eternal{} Joker after",
			"clearing a {C:attention}Boss Blind{}",
			"starting in {C:attention}Ante 3{}"
        }
    },
	config = { joker_slot = 1, extra = { destroyLeftJokers = 1 } }, --this was originally 2 lmao
	loc_vars = function(self)
        return { vars = { self.config.joker_slot,
		                  self.config.extra.destroyLeftJokers,
						  colours = {
						  	{0.76, 0.27, 0.47, 1}
						  }
					    }}
    end,
	atlas = "arsGoetiaMisc",
    pos = { x = 4, y = 0 },
    discovered = true,
    unlocked = true,
	
	calculate = function(self, back, context)
		if context.end_of_round
		and G.GAME.blind.boss
		and G.GAME.round_resets.ante >= 3
		then
			G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.0,
			func = (function()
				--kill first 2 cards
				local kills = 0
				for i = 1, #G.jokers.cards do
					if G.jokers.cards[i] ~= nil then
						--skip card if it's eternal
						if not G.jokers.cards[i].ability.eternal == true then
							SMODS.destroy_cards(G.jokers.cards[i])
							kills = kills + 1
						end
					end
					
					if kills >= self.config.extra.destroyLeftJokers then
						break
					end
				end
				
				return true
			end)}))
		end
	end
})

SMODS.Back({
    name = 'heresy_deck',
    key = 'heresy_deck',
    loc_txt = {
        name = 'Heresy Deck',
        text = {
            "Create a {C:dark_edition,T:e_negative}Negative{} {C:dark_edition,T:arsGoetia_illusion}Illusion{}",
			"{C:tarot,T:c_devil}The Devil{} and lose {C:money}$Ante{},",
			"when selecting blind"
        }
    },
	atlas = "arsGoetiaMisc",
    pos = { x = 5, y = 0 },
    config = { },
    discovered = true,
    unlocked = true,
	
	calculate = function(self, back, context)
		if context.setting_blind then
			G.E_MANAGER:add_event(Event({
			trigger = 'before',
			delay = 0.0,
			func = (function()
				local newTarot = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_devil', 'heresy_deck')
				newTarot:add_to_deck()
				
				newTarot:set_edition({negative = true}, true)
				newTarot:set_illusion()
				
				G.consumeables:emplace(newTarot)
				
				ease_dollars(-G.GAME.round_resets.ante)
				return true
			end)}))
		end
	end
})

SMODS.Back({
    name = 'violence_deck',
    key = 'violence_deck',
    loc_txt = {
        name = 'Violence Deck',
        text = {
            "{C:attention}+#1#{} hand size",
			"Scoring cards have",
			"a {C:green}#3# in #2#{} chance",
			"to be {C:attention}destroyed{}"
        }
    },
	config = { hand_size = 1, extra = { odds = 20 } },
	loc_vars = function(self)
        return { vars = { self.config.hand_size, self.config.extra.odds, ''..(G.GAME and G.GAME.probabilities.normal or 1) }}
    end,
	atlas = "arsGoetiaMisc",
    pos = { x = 6, y = 0 },
    discovered = true,
    unlocked = true,
	
	calculate = function(self, back, context)
		if context.after then
		
			for i = 1, #context.scoring_hand do
				if pseudorandom('violence') < G.GAME.probabilities.normal /self.config.extra.odds then
					SMODS.destroy_cards(context.scoring_hand[i])
				end
			end
			
			delay(1)
		end
	end
})

SMODS.Back({
    name = 'fraud_deck',
    key = 'fraud_deck',
    loc_txt = {
        name = 'Fraud Deck',
        text = {
            "Start with",
			"{C:attention,T:v_directors_cut}Director's Cut{}",
			"and {C:attention,T:v_retcon}Retcon{}"
        }
    },
	atlas = "arsGoetiaMisc",
    pos = { x = 7, y = 0 },
    config = {
        vouchers = { 'v_directors_cut' },
		vouchers = { 'v_retcon' }
    },
    discovered = true,
    unlocked = true
})

SMODS.Back({
    name = 'treachery_deck',
    key = 'treachery_deck',
    loc_txt = {
        name = 'Treachery Deck',
        text = {
            "{C:red}#1#{} Joker slot,",
			"{C:attention}+#2#{} Joker slots during blinds",
			"Start run with {C:tarot,T:c_judgement}Judgement{}"
        }
    },
	config = { joker_slot = -1, consumables = { 'c_judgement' }, extra = { roundJokers = 3, alreadyTriggered = false} },
	loc_vars = function(self)
        return { vars = { self.config.joker_slot, self.config.extra.roundJokers }}
    end,
	atlas = "arsGoetiaMisc",
    pos = { x = 8, y = 0 },
    discovered = true,
    unlocked = true,
	
	calculate = function(self, back, context)
		if context.setting_blind then
			alreadyTriggered = false
			G.jokers.config.card_limit = G.jokers.config.card_limit + self.config.extra.roundJokers
		end
		
		if context.end_of_round
		and alreadyTriggered == false
		then
			alreadyTriggered = true
			G.jokers.config.card_limit = G.jokers.config.card_limit - self.config.extra.roundJokers
		end
	end
})