-- ## JOKERS ##

-- 01 Baal
SMODS.Joker {
	key = 'baal',
	loc_txt = {
		name = 'Baal',
		text = {
			"When blind is selected,",
			"create {C:attention}#1#{} {C:dark_edition}Negative{} Jokers",
			"with {C:dark_edition}Illusion Stickers{}"
		}
	},
	config = { extra = { jokersAmount = 3} },
	loc_vars = function(self, info_queue, card)
		--add Negative popup
		info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
		--add perish tag popup
		info_queue[#info_queue + 1] = { set = "Other", key = 'arsGoetia_illusion' }
		return { vars = { card.ability.extra.jokersAmount } }
	end,
	rarity = 3,
	atlas = 'arsGoetiaPacts',
	pos = { x = 0, y = 0 },
	cost = 9,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		--when selecting a blind,
		if context.setting_blind then
			G.E_MANAGER:add_event(Event({
				func = function() 
					for i = 1, card.ability.extra.jokersAmount do
						local newJoker = create_card('arsGoetia_illusionJokers', G.jokers, nil, 0, nil, nil, nil, 'baal')
						newJoker:add_to_deck()
						
						newJoker:set_edition({negative = true}, true)
						newJoker:set_illusion()
						
						G.jokers:emplace(newJoker)
						newJoker:start_materialize()
					end
					return true
            end}))   
			
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_joker'), colour = G.C.BLUE}) 
            return true
		end
	end
}

-- 02 Agares
SMODS.Joker {
	key = 'agares',
	loc_txt = {
		name = 'Agares',
		text = {
			"Each {C:attention}Jack{}",
			"held in hand",
			"gives {C:chips}+#1#{} Chips"
		}
	},
	config = { extra = { chips = 60 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 1, y = 0 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		--when checking in-hand cards
		if context.individual
		and context.cardarea == G.hand
		and not context.end_of_round then
			--if card is a jack
			if context.other_card:get_id() == 11 then
				--if card is debuffed, do debuff message
				if context.other_card.debuff then
					return {
						message = localize('k_debuffed'),
						colour = G.C.RED
					}
				end
				--do chips amount
				return {
					chips = card.ability.extra.chips
				}
			end
		end
	end
}

-- 03 Vassago
SMODS.Joker {
	key = 'vassago',
	loc_txt = {
		name = 'Vassago',
		text = {
			"{C:green}#3# in #1#{} chance",
			"to continuously",
			"retrigger {C:attention}Lucky Cards{}",
			"{C:inactive}(Max of #2# times each){}"
		}
	},
	config = { extra = { odds = 4, maxRetriggers = 3 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
		return { vars = { card.ability.extra.odds, card.ability.extra.maxRetriggers, ''..(G.GAME and G.GAME.probabilities.normal or 1) } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 2, y = 0 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_lucky',
	calculate = function(self, card, context)
		if context.cardarea == G.play
		and context.repetition
		and not context.repetition_only
		then
			if context.other_card.ability.name == G.P_CENTERS.m_lucky.name then
				--loop for each possible amount of retriggers, going down
				for i = card.ability.extra.maxRetriggers, 1, -1 do
					if pseudorandom('vassago') < (G.GAME.probabilities.normal ^ i)/(card.ability.extra.odds ^ i) then
						return {
							repetitions = i
						}
					end
				end
			end
		end
	end
}

-- 04 Gamgin
SMODS.Joker {
	key = 'gamgin',
	loc_txt = {
		name = 'Gamgin',
		text = {
			"{C:mult}+#2#{} Mult if the ranks",
			"of cards in played",
			"hand totals to {C:attention}#1#{}"
		}
	},
	config = { extra = { rankreq = 21, mult = 21 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.rankreq, card.ability.extra.mult } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 3, y = 0 },
	cost = 4,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.joker_main then
			local rankTotal = 0
			local acesCount = 0
			
			--k is int i, v is curCard
			for k, v in ipairs(context.full_hand) do
				--start with add being the nominal (rank)
				local add = v.base.nominal
				--if stone card or non-standard rank, add 0
				if v.ability.name == G.P_CENTERS.m_stone.name then
					add = 0
				end
				
				--if ace, don't add it yet and put a tab on it for later
				if add == 11 then
					acesCount = acesCount + 1
					add = 0
				end
				
				--add to total
				rankTotal = rankTotal + add
			end
			
			--for each ace
			for i = 1, acesCount do
				--if played hand gets to 21 via an ace, do that
				--for some reason, i made this compatible if you want to play over 11 cards
				if rankTotal == 10 and i == acesCount then
					rankTotal = rankTotal + 11
				--otherwise, don't do that
				else
					rankTotal = rankTotal + 1
				end
			end
			
			if rankTotal == card.ability.extra.rankreq then
				return {
					mult_mod = card.ability.extra.mult,
					message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
				}
			end
		end
	end
}

-- 05 Marbas
SMODS.Joker {
	key = 'marbas',
	loc_txt = {
		name = 'Marbas',
		text = {
			"Randomly change the {C:attention}rank{}",
			"and {C:attention}suit{} of all played",
			"cards after scoring"
		}
	},
	config = { extra = {} },
	loc_vars = function(self, info_queue, card)
		return { vars = {} }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 4, y = 0 },
	cost = 3,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.after then
			card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Shuffle!"})
			
			--wait
			delay(0.4)
				
			--for each card in played hand,
			for i = 1, #context.full_hand do
				--get some percent for sound idk
				local percent = 1.15 - (i-0.999)/(#context.full_hand - 0.998) * 0.3
				--flip the card and play the sound after 0.15 seconds
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() context.full_hand[i]:flip();play_sound('card1', percent);context.full_hand[i]:juice_up(0.3, 0.3);return true end }))
			end
			
			--wait
			delay(0.5)
			
			--for each,
			for i = 1, #context.full_hand do
				--set the card enhancement and wait 0.1 seconds
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,
				
				func = function()
					local suits = {'S_', 'H_', 'C_', 'D_'}
					local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'}
					local suit_prefix = pseudorandom_element(suits, pseudoseed('barbas'))
					local rank_suffix = pseudorandom_element(ranks, pseudoseed('barbas'))
					context.full_hand[i]:set_base(G.P_CARDS[suit_prefix..rank_suffix])
					
					return true
				end }))
			end
			
			for i = 1, #context.full_hand do
				--flip the card back over and wait
				percent = 0.85 + (i-0.999)/(#context.full_hand-0.998)*0.3
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() context.full_hand[i]:flip();play_sound('tarot2', percent, 0.6);context.full_hand[i]:juice_up(0.3, 0.3);return true end }))
			end
			
			--wait again
			delay(1.2)
			
			--return
			return true
		end
	end
}

-- 06 Valefar
SMODS.Joker {
	key = 'valefar',
	loc_txt = {
		name = 'Valefar',
		text = {
			"If played hand is a",
			"{C:attention}Four of a Kind{}, convert",
			"non-scoring #1# to",
			"the same {C:attention}rank{} as the",
			"scoring cards afterwards"
		}
	},
	config = { extra = { plural = 'card' } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.plural } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 5, y = 0 },
	cost = 7,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	blueprint_compat = true,
	perishable_compat = true,
	eternal_compat = true,
	calculate = function(self, card, context)
		if context.after
		and context.scoring_name == "Four of a Kind"
		then
			card_eval_status_text(card, 'extra', nil, nil, nil, { message = "As One!"})
			local rank_suffix = nil
			local cardsToChange = {}
			
			--go through each card in hand
			for i = 1, #context.full_hand do
				local isScoring = false
				
				--see if that card is scoring
				for j = 1, #context.scoring_hand do
					if i == j then
						isScoring = true
					end
				end
				
				--if so, grab its rank. functionally, the last
				--card scoring's rank is copied
				if isScoring == true then
					--rank suffix bit is copied from strength
					rank_suffix = context.full_hand[i].base.id
					if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
					elseif rank_suffix == 10 then rank_suffix = 'T'
					elseif rank_suffix == 11 then rank_suffix = 'J'
					elseif rank_suffix == 12 then rank_suffix = 'Q'
					elseif rank_suffix == 13 then rank_suffix = 'K'
					elseif rank_suffix == 14 then rank_suffix = 'A'
					end
				else
					--if card is not scoring, put it in the array
					cardsToChange[#cardsToChange + 1] = context.full_hand[i]
					
					--this is stored as an array rather than a single value to
					--account for mods that let you select more that 5 cards
					if #cardsToChange >= 2 then
						card.ability.extra.plural = 'card(s)'
					end
				end
			end
			
			--if rank suffix is still nil, abort function
			if rank_suffix == nil then
				return false
			end
			
			--wait
			delay(0.4)
			
			--for each card in played hand,
			for i = 1, #cardsToChange do
				--get some percent for sound idk
				local percent = 1.15 - (i-0.999)/(#cardsToChange - 0.998) * 0.3
				--flip the card and play the sound after 0.15 seconds
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() cardsToChange[i]:flip();play_sound('card1', percent);cardsToChange[i]:juice_up(0.3, 0.3);return true end }))
			end
			
			--wait
			delay(0.5)
			
			--for each,
			for i = 1, #cardsToChange do
				--set the card enhancement and wait 0.1 seconds
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,
				
				func = function()
					local suit_prefix = string.sub(cardsToChange[i].base.suit, 1, 1)..'_'
					cardsToChange[i]:set_base(G.P_CARDS[suit_prefix..rank_suffix])
					
					return true
				end }))
			end
			
			for i = 1, #cardsToChange do
				--flip the card back over and wait
				percent = 0.85 + (i-0.999)/(#cardsToChange-0.998)*0.3
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() cardsToChange[i]:flip();play_sound('tarot2', percent, 0.6);cardsToChange[i]:juice_up(0.3, 0.3);return true end }))
			end
			
			--wait again
			delay(1.5)
			
			--return
			return true
		end
	end
}

-- 07 Aamon
SMODS.Joker {
	key = 'aamon',
	loc_txt = {
		name = 'Aamon',
		text = {
			"{C:mult}+5{} Mult for",
			"each {C:attention}suit{} of cards",
			"scored in played hand"
		}
	},
	config = { extra = { multAdd = 5 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.multAdd } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 6, y = 0 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.joker_main then
			local suitsScored = {}
			local wildCount = 0
			
			for i = 1, #context.scoring_hand do
				if context.scoring_hand[i].ability.name == G.P_CENTERS.m_wild.name then
					wildCount = wildCount + 1
				else
					local suitIsThereAlready = false
					
					for i = 1, #suitsScored do
						if context.scoring_hand[i].base.suit == suitsScored[i] then
							suitIsThereAlready = true
						end
					end
					
					if not suitIsThereAlready
					and context.scoring_hand[i].ability.name ~= G.P_CENTERS.m_stone.name
					then
						suitsScored[#suitsScored + 1] = context.scoring_hand[i]
					end
				end
			end
			
			--cap number of suits to 4
			local multTotal = card.ability.extra.multAdd * math.min(4, #suitsScored + wildCount)
			
			return {
				mult_mod = multTotal,
				message = localize { type = 'variable', key = 'a_mult', vars = { multTotal } }
			}
		end
	end
}

-- 08 Barbatos
SMODS.Joker {
	key = 'barbatos',
	loc_txt = {
		name = 'Barbatos',
		text = {
			"Played {C:attention}Stone Cards{} have a",
			"{C:green}#2# in #1#{} chance to gain a",
			"random {C:dark_edition}Edition{} before scoring"
		}
	},
	config = { extra = { odds = 4 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.odds, ''..(G.GAME and G.GAME.probabilities.normal or 1) } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 7, y = 0 },
	cost = 8,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_stone',
	calculate = function(self, card, context)
		if context.before
		and context.cardarea == G.jokers
		and not context.blueprint then
			local editionFlag = false
                for k, v in ipairs(context.scoring_hand) do
                    if v.ability.name == G.P_CENTERS.m_stone.name
					and not v.edition
					and pseudorandom('barbatos') < G.GAME.probabilities.normal / card.ability.extra.odds
					and not v.debuff then
                        editionFlag = true
						
                        G.E_MANAGER:add_event(Event({
							trigger = 'before',
                            func = function()
								local edition = poll_edition('barbatos', nil, true, true)
								v:set_edition(edition, true)
							
                                v:juice_up()
                                return true
                            end
                        })) 
                    end
                end
			    
                if editionFlag == true then 
                    return {
                        message = "Edition",
						colour = G.C.DARK_EDITION
                    }
                end
		end
	end
}

-- 09 Paimon
SMODS.Joker {
	key = 'paimon',
	loc_txt = {
		name = '#1#',
		text = {
			"{V:1,B:2}#2##3#{} Mult"
		}
	},
	config = { extra = { name = "Joker",
	                     description = "+",
						 name2 = "Paimon",
                         description2 = "X",
						 Xmult = 4,
						 revealed = false
						 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.name,
		                  card.ability.extra.description,
						  card.ability.extra.Xmult,
						  colours = {
						  	card.ability.extra.revealed and G.C.WHITE or G.C.MULT, --text
							card.ability.extra.revealed and G.C.MULT or {0, 0, 0, 0} --bg
						  }
				     	} }
	end,
	rarity = 3,
	atlas = 'arsGoetiaPacts',
	pos = { x = 8, y = 7 },
	cost = 2,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.joker_main then
			--if not revealed, reveal
			if not card.ability.extra.revealed then
				card.ability.extra.revealed = true
				
				local index = 1
				
				for i = 0, #G.jokers.cards, 1 do
					if G.jokers.cards[i] == card then
						index = 1
						break
					end
				end
				
				--get percent for card flip
				local percent = 1.15 - (index-0.999)/(#G.jokers.cards - 0.998) * 0.3
				--flip the card and play the sound after 0.15 seconds
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() card:flip();play_sound('card1', percent);card:juice_up(0.3, 0.3);return true end }))
				
				--wait
				delay(0.7)
				
				--set position & call to update sprite
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0,func = function() self.rarity = 3;card:set_sprites(card.config.center);return true end }))
				
				--update name & description variables
				card.ability.extra.name = card.ability.extra.name2
				card.ability.extra.description = card.ability.extra.description2
				self.cost = 10
				
				--flip the card back over and wait
				percent = 0.85 + (index-0.999)/(#G.jokers.cards-0.998)*0.3
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() card:flip();play_sound('tarot2', percent, 0.6);card:juice_up(0.3, 0.3);return true end }))
				
				delay(1)
			end
			
			--standard-issue return
			return {
				Xmult_mod = card.ability.extra.Xmult,
				message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } }
			}
		end
	end
}

--manually update rarity when hovering over hidden paimon card
local card_hover_hook = Card.hover
function Card:hover()
	if self.ability ~= nil then
		if self.ability.name == "j_arsGoetia_paimon" then
			if self.ability.extra.revealed == false then
				self.config.center.rarity = 1
			end
		end
	end

	local ret = card_hover_hook(self)
	
	if self.ability ~= nil then
		if self.ability.name == "j_arsGoetia_paimon" then
			if self.ability.extra.revealed == false then
				self.config.center.rarity = 3
			end
		end
	end
	
	return ret
end


local card_set_sprites_hook = Card.set_sprites
function Card:set_sprites(_center, _front)
	if self.ability ~= nil then
		if self.ability.name == "j_arsGoetia_paimon" then
			if self.ability.extra.revealed == true then
				self.config.center.pos = { x = 8, y = 0 }
			end
		end
	end
	
	local ret = card_set_sprites_hook(self, _center, _front)
	
	return ret
end


-- 10 Buer
SMODS.Joker {
	key = 'buer',
	loc_txt = {
		name = 'Buer',
		text = {
			"This Pact gains {C:chips}+#2#{} Chips",
			"for each {C:money}${} spent on",
			"rerolls this {C:attention}Ante{}",
			"{C:inactive}(Currently{} {C:chips}+#1#{} {C:inactive}Chips){}"
		}
	},
	config = { extra = { chips = 0, chipsScaling = 3, preRerollCost = 0 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips, card.ability.extra.chipsScaling } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 9, y = 0 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.reroll_shop then
			card.ability.extra.chips = card.ability.extra.chips + (math.max(0, card.ability.extra.preRerollCost) * card.ability.extra.chipsScaling)
			
			return {
				message = localize('k_upgrade_ex')
			}
		end
		
		if context.end_of_round
		and context.cardarea == G.jokers
		and G.GAME.blind.boss
		then
			card.ability.extra.chips = 0
			
			return {
				message = localize('k_reset')
			}
		end
		
		if context.joker_main
		and card.ability.extra.chips > 0
		then
			return {
				chip_mod = card.ability.extra.chips,
				message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } }
			}
		end
	end
}

--the base context thinger happens after the reroll, so i need to
--save the cost of the reroll before it's changed
local reroll_shop_hook = G.FUNCS.reroll_shop
function G.FUNCS:reroll_shop()
	
	for i = 1, #G.jokers.cards do
		if G.jokers.cards[i].ability.name == "j_arsGoetia_buer" then
			G.jokers.cards[i].ability.extra.preRerollCost = G.GAME.current_round.reroll_cost
		end
    end
	
	local ret = reroll_shop_hook(self)
	
	return ret
end


-- 11 Augusyon
SMODS.Joker {
	key = 'augusyon',
	loc_txt = {
		name = 'Augusyon',
		text = {
			"Create a {C:attention}Voucher Tag{} after",
			"discarding a {C:attention}full set{} of ranks",
			"{C:inactive}(Remaining:{} {C:attention}#1#{C:inactive}#2#){}"
		}
	},
	config = { extra = { remainingCards = {14,13,12,11,10,9,8,7,6,5,4,3,2},
						 desc1 = "13",
						 desc2 = " ranks"
					   } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.desc1, card.ability.extra.desc2 } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 0, y = 1 },
	cost = 6,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.discard then
			local doReturn = false
		
			--for each card discarded,
			for i = 1, #card.ability.extra.remainingCards do
				if context.other_card.base.id == card.ability.extra.remainingCards[i] then
					--remove that thinger and break this inner for loop
					table.remove(card.ability.extra.remainingCards, i)
					break
				end
			end
			
			if #card.ability.extra.remainingCards == 0 then
				add_tag(Tag("tag_voucher"))
				--reset remaining cards
				card.ability.extra.remainingCards = {14,13,12,11,10,9,8,7,6,5,4,3,2}
				doReturn = true
			end
			
			--update description
			if #card.ability.extra.remainingCards >= 9 then
				card.ability.extra.desc1 = #card.ability.extra.remainingCards
				card.ability.extra.desc2 = " ranks"
			else
				local desc1String = ''
				for i = 1, #card.ability.extra.remainingCards do
					local thingToAdd = card.ability.extra.remainingCards[i]
					
					if thingToAdd < 10 then thingToAdd = tostring(thingToAdd)
                    --elseif thingToAdd == 10 then thingToAdd = 'T'
                    elseif thingToAdd == 11 then thingToAdd = 'J'
                    elseif thingToAdd == 12 then thingToAdd = 'Q'
                    elseif thingToAdd == 13 then thingToAdd = 'K'
                    elseif thingToAdd == 14 then thingToAdd = 'A'
					end
				
					
					desc1String = desc1String .. thingToAdd .. (i == #card.ability.extra.remainingCards and '' or ', ')
				end
				
				card.ability.extra.desc1 = desc1String
				card.ability.extra.desc2 = ""
			end
			
			if doReturn == true then
				return {
					message = "Voucher!"
				}
			end
		end
	end
}

-- 12 Sitri
SMODS.Joker {
	key = 'sitri',
	loc_txt = {
		name = 'Sitri',
		text = {
			"Each played {C:attention}6{} or {C:attention}9{}",
			"gives {C:mult}+#1#{} Mult",
			"when scored"
		}
	},
	config = { extra = { mult = 11 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 1, y = 1 },
	soul_pos = {x = 9, y = 7},
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		--when checking individual played cards,
		if context.individual
		and context.cardarea == G.play
		and not context.blueprint then
			if context.other_card:get_id() == 6
			or context.other_card:get_id() == 9
			then
				return {
					mult = card.ability.extra.mult
				}
			end
		end
	end
}

-- 13 Beleth
SMODS.Joker {
	key = 'beleth',
	loc_txt = {
		name = 'Beleth',
		text = {
			"Played {C:attention}Aces{} give an",
			"additional {X:mult,C:white}X#1#{} Mult",
			"for each scoring {C:attention}Ace{}"
		}
	},
	config = { extra = { xmult = 0.15 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult } }
	end,
	rarity = 3,
	atlas = 'arsGoetiaPacts',
	pos = { x = 2, y = 1 },
	cost = 8,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play then
			if context.other_card:get_id() == 14 then
				if context.other_card.debuff then
					return {
						message = localize('k_debuffed'),
						colour = G.C.RED
					}
				end
				
				local acesAmount = 0
				--for each card in the scoring hand...
				for i = 1, #context.scoring_hand do
					--check if it's an ace, and update aces total if so
					if context.scoring_hand[i]:get_id() == 14 then
						acesAmount = acesAmount + 1
					end
				end
				
				return {
					x_mult = 1 + (card.ability.extra.xmult * acesAmount)
				}
			end
		end
	end
}

-- 14 Leraje
SMODS.Joker {
	key = 'leraje',
	loc_txt = {
		name = 'Leraje',
		text = {
			"Each played {V:1}#2#{} or {V:2}#3#{}",
			"card give {C:mult}+7{} Mult when scored,",
			"suits change every round"
		}
	},
	config = { extra = { mult = 7 } },
	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.extra.mult,
				localize(G.GAME.current_round.leraje_suit.suit1, 'suits_singular'), -- gets the localized name of the suit
				localize(G.GAME.current_round.leraje_suit.suit2, 'suits_singular'), -- gets the localized name of the suit
				colours = {
					G.C.SUITS[G.GAME.current_round.leraje_suit.suit1],
					G.C.SUITS[G.GAME.current_round.leraje_suit.suit2]
				} -- sets the colour of the text affected by V:1 and V:2
			}
		}
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 3, y = 1 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play then
			if context.other_card:is_suit(G.GAME.current_round.leraje_suit.suit1, nil, true)
			or context.other_card:is_suit(G.GAME.current_round.leraje_suit.suit2, nil, true)
			then
				if context.other_card.debuff then
					return {
						message = localize('k_debuffed'),
						colour = G.C.RED
					}
				end
				
				return {
					mult = card.ability.extra.mult
				}
			end
		end
	end
}

local igo = Game.init_game_object
function Game:init_game_object()
	local ret = igo(self)
	ret.current_round.leraje_suit = { suit1 = 'Spades', suit2 = 'Hearts' }
	return ret
end

-- This is a part 2 of the above thing, to make the custom G.GAME variable change every round.
function SMODS.current_mod.reset_game_globals(run_start)
	-- The suit changes every round, so we use reset_game_globals to choose a suit.
	G.GAME.current_round.leraje_suit = { suit1 = 'Spades', suit2 = 'Hearts' }
	
	G.GAME.current_round.leraje_suit.suit1 = GetLerajeSuit(nil)
	G.GAME.current_round.leraje_suit.suit2 = GetLerajeSuit(G.GAME.current_round.leraje_suit.suit1)
end

function GetLerajeSuit(otherSuit)
	local valid_suit_cards = {}
	for _, v in ipairs(G.playing_cards) do
		--check if not stone card and if not previous suit
		if not SMODS.has_no_suit(v)
		and v.base.suit ~= otherSuit
		then
			valid_suit_cards[#valid_suit_cards + 1] = v
		end
	end
	if valid_suit_cards[1] then
		local rand_card = pseudorandom_element(valid_suit_cards, pseudoseed('leraje' .. G.GAME.round_resets.ante))
		return rand_card.base.suit
	end
end


-- 15 Eligos
SMODS.Joker {
	key = 'eligos',
	loc_txt = {
		name = 'Eligos',
		text = {
			"{X:mult,C:white}X#1#{} Mult if all",
			"cards in played hand",
			"are {C:attention}face{} cards"
		}
	},
	config = { extra = { xmult = 3 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult} }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 4, y = 1 },
	cost = 7,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.joker_main then
			local noFace = true
		
			--for each card in scoring hand, check to see if that card is not a face card
			for i = 1, #context.scoring_hand do
			--if it isn't, break the statement early
				if not context.scoring_hand[i]:is_face() then
					noFace = false
					break
				end
			end
			
			--if flag is still true
			if noFace == true then
				return {
					--add Xmult with message
					Xmult_mod = card.ability.extra.xmult,
					message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } }
				}
			end
		end
	end
}

-- 16 Zepar
SMODS.Joker {
	key = 'zepar',
	loc_txt = {
		name = 'Zepar',
		text = {
			"{C:attention}Alchemy Cards{} have a",
			"{C:green}1 in 10{} chance to create",
			"a {C:dark_edition}Negative{} {C:planet}Planet{} card for",
			"the current played {C:attention}poker hand{}"
		}
	},
	config = { extra = { odds = 10 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS['m_arsGoetia_alchemy']
		return { vars = { card.ability.extra.odds, ''..(G.GAME and G.GAME.probabilities.normal or 1) } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 5, y = 1 },
	cost = 8,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_arsGoetia_alchemy',
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play
		and not context.blueprint then
			--if checked card is an alchemy card
			if context.other_card.ability.name == G.P_CENTERS['m_arsGoetia_alchemy'].name
			and pseudorandom('zepar') < G.GAME.probabilities.normal/card.ability.extra.odds
			then
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_plus_planet'), colour = G.C.SECONDARY_SET.Planet})
			
				G.E_MANAGER:add_event(Event({
				trigger = 'before',
				delay = 0.0,
				func = (function()
					if G.GAME.last_hand_played then
						--get the key for the current played hand
						local planetKey = 0
						for k, v in pairs(G.P_CENTER_POOLS.Planet) do
							if v.config.hand_type == G.GAME.last_hand_played then
								planetKey = v.key
								break
							end
						end
						
						--make the card and add it
						local newPlanet = create_card('Planet', G.consumeables, nil, nil, nil, nil, planetKey, 'zepar')
						newPlanet:set_edition({negative = true}, true)
                        newPlanet:add_to_deck()
                        G.consumeables:emplace(newPlanet)
					end
					return true
				end)}))
			end
		end
	end
}

-- 17 Botis
SMODS.Joker {
	key = 'botis',
	loc_txt = {
		name = 'Botis',
		text = {
			"{C:mult}+#1#{} Mult if played",
			"hand contains {C:attention}2{} cards of",
			"the same {C:attention}suit{} and {C:attention}rank{}"
		}
	},
	config = { extra = { mult = 20 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 6, y = 1 },
	cost = 4,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.joker_main then
			--make a cards list
			local cardsList = {}
			--for each card in the scoring hand...
			for i = 1, #context.scoring_hand do
				--...check it against each card previously scored
				for j = 1, #cardsList do				
					if context.scoring_hand[i]:get_id() == cardsList[j]:get_id()
					and (context.scoring_hand[i].base.suit == cardsList[j].base.suit
					or context.scoring_hand[i].ability.name == G.P_CENTERS.m_wild.name
					or cardsList[j].ability.name == G.P_CENTERS.m_wild.name)
					then
						return {
							mult_mod = card.ability.extra.mult,
							message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
						}
					end
				end
				
				cardsList[#cardsList + 1] = context.scoring_hand[i]
			end
		end
	end
}

-- 18 Bathin
SMODS.Joker {
	key = 'bathin',
	loc_txt = {
		name = 'Bathin',
		text = {
			"This Pact gains {X:mult,C:white}X#2#{} Mult",
			"per {C:attention}consecutive{} hand played",
			"with {C:attention}5{} scoring cards",
			"{C:inactive}(Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult){}"
		}
	},
	config = { extra = { xmult = 1, xmultScaling = 0.1 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult, card.ability.extra.xmultScaling } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 7, y = 1 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.joker_main then
			if #context.scoring_hand == 5 then
				card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmultScaling
			
				return {
					Xmult_mod = card.ability.extra.xmult,
					message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } }
				}
			elseif card.ability.extra.xmult ~= 1 then
				
				card.ability.extra.xmult = 1
				
				return {
					message = localize('k_reset')
				}
			end
			
		end
	end
}

-- 19 Saleos
SMODS.Joker {
	key = 'saleos',
	loc_txt = {
		name = 'Saleos',
		text = {
			"{C:attention}Alchemy Cards{} give an",
			"additional {X:mult,C:white}X#2#{} Mult for each",
			"{C:tarot}Tarot{} card used during the",
			"current round when scored",
			"{C:inactive}(Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult){}"
		}
	},
	config = { extra = { Xmult = 1, XmultScaling = 0.1 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS['m_arsGoetia_alchemy']
		return { vars = { card.ability.extra.Xmult, card.ability.extra.XmultScaling } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 8, y = 1 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_arsGoetia_alchemy',
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play
		and not context.blueprint then
			--if checked card is an alchemy card
			if context.other_card.ability.name == G.P_CENTERS['m_arsGoetia_alchemy'].name
			and card.ability.extra.Xmult ~= 1
			then
				return {
					x_mult = card.ability.extra.Xmult
				}
			end
		elseif context.using_consumeable
		and context.consumeable.ability.set == "Tarot" then
			card.ability.extra.Xmult = card.ability.extra.X + card.ability.extra.XmultScaling
			return {
					message = localize('k_upgrade_ex')
				}
		elseif context.end_of_round
		and context.cardarea == G.jokers
		and card.ability.extra.Xmult ~= 1 then
			card.ability.extra.Xmult = 1
			return {
					message = localize('k_reset')
				}
		end
	end
}

-- 20 Purson
SMODS.Joker {
	key = 'purson',
	loc_txt = {
		name = 'Purson',
		text = {
			"{X:mult,C:white}X#1#{} Mult,",
			"Set {C:blue}Hands{} and {C:red}Discards{} to {C:attention}#2#{}",
			"when {C:attention}Blind{} is selected"
		}
	},
	config = { extra = { xmult = 10, HandsDiscards = 1 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult, card.ability.extra.HandsDiscards } }
	end,
	rarity = 3,
	atlas = 'arsGoetiaPacts',
	pos = { x = 9, y = 1 },
	cost = 8,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		--decrease hands and discards at the start of the blind (but not via blueprint)
		if context.setting_blind and not context.blueprint then
			handsAmount = 1 - G.GAME.current_round.hands_left
			
			--if the blind is very specifically the needle, don't reduce hands
			--this is a hack-job solution, but if it works, it works
			if G.GAME.blind.name == G.P_BLINDS.bl_needle.name then
				handsAmount = 0
			end
			
			return {
				ease_hands_played(handsAmount, nil, true),
				ease_discard(1 - G.GAME.current_round.discards_left, nil, true)
			}
		end
		
		--do scoring during main joker phase. blueprint can copy this
		if context.joker_main then
			return {
				Xmult_mod = card.ability.extra.xmult,
				message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } }
			}
		end
	end
}

-- 21 Morax
SMODS.Joker {
	key = 'morax',
	loc_txt = {
		name = 'Morax',
		text = {
			"Create {C:attention}#1#{} {C:planet}Planet{} cards",
			"when {C:attention}Blind{} is selected",
			"{C:inactive}(Must have room){}"
		}
	},
	config = { extra = { amount = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.amount } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 0, y = 2 },
	cost = 3,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		--create planet card when selecting blind (and also making sure it's below the consumeable limit)
		if context.setting_blind then
			--lua is inclusive when doing loops, so start with 1
			for i = 1, card.ability.extra.amount do
				if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
					SMODS.add_card { set = 'Planet', soulable = false }
					card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, { message = localize('k_plus_planet'), colour = G.C.SECONDARY_SET.Planet })
				end
				
				delay(0.2)
			end
		end
		
		return returnFlag
	end
}

-- 22 Ipos
SMODS.Joker {
	key = 'ipos',
	loc_txt = {
		name = 'Ipos',
		text = {
			"Reveals the top {C:attention}#1#{}",
			"cards in the deck:",
			"{V:1}#2#{}",
			"{V:2}#3#{}",
			"{V:3}#4#{}"
		}
	},
	config = { extra = { reveal = 3,
						 card1 = '(Hidden)',
						 card2 = '(Hidden)',
						 card3 = '(Hidden)',
						 suit1 = 'None',
						 suit2 = 'None',
						 suit3 = 'None',
						 isActive = true
					 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.reveal,
						  card.ability.extra.card1,
						  card.ability.extra.card2,
						  card.ability.extra.card3,
						  colours = {
						  	card.ability.extra.suit1 ~= 'None' and G.C.SUITS[card.ability.extra.suit1] or G.C.UI.TEXT_INACTIVE, --card 1
						  	card.ability.extra.suit2 ~= 'None' and G.C.SUITS[card.ability.extra.suit2] or G.C.UI.TEXT_INACTIVE, --card 2
						  	card.ability.extra.suit3 ~= 'None' and G.C.SUITS[card.ability.extra.suit3] or G.C.UI.TEXT_INACTIVE  --card 3
						  }
					  } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 1, y = 2 },
	cost = 4,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.first_hand_drawn then
			card.ability.extra.isActive = true
		elseif context.end_of_round and context.cardarea == G.jokers then
			card.ability.extra.isActive = false
			
			card.ability.extra.suit1 = 'None'
			card.ability.extra.card1 = '(None)'
			card.ability.extra.suit2 = 'None'
			card.ability.extra.card2 = '(None)'
			card.ability.extra.suit3 = 'None'
			card.ability.extra.card3 = '(None)'
		end
		
		--need to rely on an external variable instead of context,
		--since cards can be drawn through a variety of means
		if card.ability.extra.isActive then
			card.ability.extra.suit1 = (G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.suit or 'None')
			card.ability.extra.card1 = (G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.value..' of '..card.ability.extra.suit1 or '(Nothing)')
			card.ability.extra.suit2 = (G.deck and G.deck.cards[2] and G.deck.cards[#G.deck.cards - 1].base.suit or 'None')
			card.ability.extra.card2 = (G.deck and G.deck.cards[2] and G.deck.cards[#G.deck.cards - 1].base.value..' of '..card.ability.extra.suit2 or '(Nothing)')
			card.ability.extra.suit3 = (G.deck and G.deck.cards[3] and G.deck.cards[#G.deck.cards - 2].base.suit or 'None')
			card.ability.extra.card3 = (G.deck and G.deck.cards[3] and G.deck.cards[#G.deck.cards - 2].base.value..' of '..card.ability.extra.suit3 or '(Nothing)')
		else
			card.ability.extra.suit1 = 'None'
			card.ability.extra.card1 = '(None)'
			card.ability.extra.suit2 = 'None'
			card.ability.extra.card2 = '(None)'
			card.ability.extra.suit3 = 'None'
			card.ability.extra.card3 = '(None)'
		end
	end
}

-- 23 Aim
SMODS.Joker {
	key = 'aim',
	loc_txt = {
		name = 'Aim',
		text = {
			"Played cards give {X:mult,C:white}X#1#{} Mult",
			"when scored if all cards",
			"in played hand are",
			"{C:hearts}Hearts{} or {C:diamonds}Diamonds{}"
		}
	},
	config = { extra = { Xmult = 1.25 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.Xmult } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 2, y = 2 },
	cost = 8,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play then
			local blackFlag = false
			
			--for each card in the scoring hand...
			for i = 1, #context.scoring_hand do
				--check if it's not a red card
				if not (context.scoring_hand[i]:is_suit('Hearts', nil, true) or context.scoring_hand[i]:is_suit('Diamonds', nil, true)) then
					blackFlag = true
					break
				end
			end
			
			--if there were any non-red cards, don't do stuff
			if blackFlag == false then
				if context.other_card.debuff then
					return {
						message = localize('k_debuffed'),
						colour = G.C.RED
					}
				end
				
				return {
					x_mult = card.ability.extra.Xmult
				}
			end
		end
	end
}

-- 24 Naberius
SMODS.Joker {
	key = 'naberius',
	loc_txt = {
		name = 'Naberius',
		text = {
			"This Pact gains {C:chips}+#2#{} Chips",
			"for each {C:attention}consecutive{} card",
			"scored without scoring a {V:1}#3#{},",
			"suit changes every hand",
			"{C:inactive}(Currently{} {C:chips}+#1#{} {C:inactive}Chips){}"
		}
	},
	config = { extra = { chips = 0, chipsScaling = 4 } },
	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.extra.chips,
				card.ability.extra.chipsScaling,
				localize(G.GAME.current_round.naberius_suit.suit, 'suits_singular'), -- gets the localized name of the suit
				colours = { G.C.SUITS[G.GAME.current_round.naberius_suit.suit] } -- sets the colour of the text affected by `{V:1}`
			}
		}
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 3, y = 2 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		
		if context.individual
		and context.cardarea == G.play
		and not context.blueprint then
			if not context.other_card:is_suit(G.GAME.current_round.castle_card.suit) then
				card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chipsScaling
			
				return {
					extra = {focus = card, message = localize('k_upgrade_ex')}
				}
			elseif card.ability.extra.chips ~= 0 then
				card.ability.extra.chips = 0
			
				return {
					extra = {focus = card, message = localize('k_reset')}
				}
			end
		end
		
		if context.joker_main and card.ability.extra.chips ~= 0 then
			return {
				chip_mod = card.ability.extra.chips,
				message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } }
			}
		end
		
		--change suit within naberius itself, since i'm not sure if there's
		--a global function i can use that gets called after hands like there
		--is with castle and ancient joker
		if context.after then
			local valid_suit_cards = {}
			for _, v in ipairs(G.playing_cards) do
				--check if not stone card and if not previous suit
				if not SMODS.has_no_suit(v) then
					valid_suit_cards[#valid_suit_cards + 1] = v
				end
			end
			if valid_suit_cards[1] then
				local rand_card = pseudorandom_element(valid_suit_cards, pseudoseed('naberius' .. G.GAME.round_resets.ante))
				G.GAME.current_round.naberius_suit.suit = rand_card.base.suit
			end
		end
	end
}

local igo = Game.init_game_object
function Game:init_game_object()
	local ret = igo(self)
	ret.current_round.naberius_suit = { suit = "Spades" }
	return ret
end

-- 25 Glasya-Labolas
SMODS.Joker {
	key = 'glasya_labolas',
	loc_txt = {
		name = 'Glasya-Labolas',
		text = {
			"Played {C:attention}non-face{} cards give",
			"{C:mult}+Mult{} equal to {C:attention}half of{}",
			"their {C:chips}Chips{} when scored"
		}
	},
	config = { extra = { divider = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 4, y = 2 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play then
			if not context.other_card:is_face() then
				--this last bit here is to round the number down
				local cardChips = context.other_card:get_chip_bonus()
				
				return {
					mult = (cardChips - (cardChips % 2)) / 2
				}
			end
		end
	end
}

-- 26 Bune
SMODS.Joker {
	key = 'bune',
	loc_txt = {
		name = 'Bune',
		text = {
			"Earn {C:money}$#1#{} at end of round,",
			"{X:mult,C:white}X0{} Mult except for the",
			"{C:attention}final hand{} of each round"
		}
	},
	config = { extra = { money = 8 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 5, y = 2 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.joker_main
		and G.GAME.current_round.hands_left ~= 0
		then
			return {
				Xmult_mod = 0,
				message = localize { type = 'variable', key = 'a_xmult', vars = { 0 } }
			}
		end
	end,
	
	calc_dollar_bonus = function(self, card)
		local bonus = card.ability.extra.money
		if bonus > 0 then
			return bonus
		end
	end
}

-- 27 Ronove
SMODS.Joker {
	key = 'ronove',
	loc_txt = {
		name = 'Ronove',
		text = {
			"When {C:attention}Blind{} is selected,",
			"{C:green}reroll{} all held consumables",
			"to new consumables",
			"of the {C:attention}same type{}"
		}
	},
	config = { extra = { } },
	loc_vars = function(self, info_queue, card)
		return { vars = { } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 6, y = 2 },
	cost = 3,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.setting_blind then
			card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Shuffle!"})
			
			--wait
			delay(0.4)
				
			--for each held consumable,
			for i = 1, #G.consumeables.cards do
				--get some percent for sound idk
				local percent = 1.15 - (i-0.999)/(#G.consumeables.cards - 0.998) * 0.3
				--flip the card and play the sound after 0.15 seconds
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.consumeables.cards[i]:flip();play_sound('card1', percent);G.consumeables.cards[i]:juice_up(0.3, 0.3);return true end }))
			end
			
			--wait
			delay(0.5)
			
			--for each consumable,
			for i = 1, #G.consumeables.cards do
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,
				func = function()
					--get the new ability based on consumable ability set (ie. tarot, planet)
					local newAbility = pseudorandom_element(G.P_CENTER_POOLS[G.consumeables.cards[i].ability.set], pseudoseed('ronove'))
					
					G.consumeables.cards[i]:set_ability(newAbility)
					
					return true
				end }))
			end
			
			for i = 1, #G.consumeables.cards do
				--flip the card back over and wait
				percent = 0.85 + (i-0.999)/(#G.consumeables.cards-0.998)*0.3
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.consumeables.cards[i]:flip();play_sound('tarot2', percent, 0.6);G.consumeables.cards[i]:juice_up(0.3, 0.3);return true end }))
			end
			
			--wait again
			delay(1.2)
			
			--return
			return true
		end
	end
}

-- 28 Berith
SMODS.Joker {
	key = 'berith',
	loc_txt = {
		name = 'Berith',
		text = {
			"Gain {C:money}$#1#{} when {C:gold}Gold Seal{}",
			"and {C:attention}Gold Card{} effects",
			"are triggered"
		}
	},
	config = { extra = { money = 3 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
		info_queue[#info_queue + 1] = G.P_SEALS['Gold']
		return { vars = { card.ability.extra.money } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 7, y = 2 },
	cost = 7,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_gold' or 'Gold', --legitimately not sure if gold seals even have a check
	calculate = function(self, card, context)
		if context.individual then
			local flag = false
		
			if context.cardarea == G.play then
				if context.other_card.seal == 'Gold' then
					flag = true
				end
			elseif context.cardarea == G.hand and context.end_of_round then
				if context.other_card.ability.name == G.P_CENTERS.m_gold.name then
					flag = true
				end
			end
			
			if flag then
				return {
					dollars = card.ability.extra.money
				}
			end
		end
	end
}

-- 29 Astaroth
SMODS.Joker {
	key = 'astaroth',
	loc_txt = {
		name = 'Astaroth',
		text = {
			"Create a {C:dark_edition}Negative{} {C:rare}Rare{}",
			"Joker after skipping",
			"{C:attention}#2# consecutive Blinds{}",
			"{C:inactive}(Currently:{} {C:attention}#1#{}{C:inactive}/#2#){}"
		}
	},
	config = { extra = { skipped = 0, skippedReq = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.skipped, card.ability.extra.skippedReq} }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 8, y = 2 },
	cost = 5,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.skip_blind
		and not context.blueprint then
			card.ability.extra.skipped = card.ability.extra.skipped + 1
			
			if card.ability.extra.skipped == 2 then
				--create the joker
				
				card.ability.extra.skipped = 0
				return {
					message = '+1 Joker',
					colour = G.C.RED
				}
			else
				return {
					message = card.ability.extra.skipped..'/'..card.ability.extra.skippedReq
				}
			end
		end
		
		if context.setting_blind and G.GAME.blind.boss then
			card.ability.extra.skipped = 0
		end
	end
}

-- 30 Forneus
SMODS.Joker {
	key = 'forneus',
	loc_txt = {
		name = 'Forneus',
		text = {
			"Retrigger each",
			"played {C:attention}Ace{}"
		}
	},
	config = {},
	loc_vars = function(self, info_queue, card)
		return {}
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 9, y = 2 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.cardarea == G.play
		and context.repetition
		and not context.repetition_only then
			if context.other_card:get_id() == 14 then
				return {
					repetitions = 1
				}
			end
		end
	end
}

-- 31 Foras
SMODS.Joker {
	key = 'foras',
	loc_txt = {
		name = 'Foras',
		text = {
			"{C:attention}Swap{} scored {C:blue}Chips{}",
			"and {C:red}Mult{} when this",
			"Pact is scored"
		}
	},
	config = { extra = {} },
	loc_vars = function(self, info_queue, card)
		return { vars = {} }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 0, y = 3 },
	cost = 5,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.joker_main
		and not context.blueprint then
			card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Swap!", colour = G.C.PURPLE })
			
			local saved_chips = hand_chips
			local saved_mult = mult
			mult = mod_mult(saved_chips)
			hand_chips = mod_chips(saved_mult)
			
			return true
		end
	end
}

-- 32 Asmodeus
SMODS.Joker {
	key = 'asmodeus',
	loc_txt = {
		name = 'Asmodeus',
		text = {
			"When blind is selected,",
			"create {C:attention}#1# {C:dark_edition}Negative{} {C:tarot}Tarot{}",
			"cards with {C:dark_edition}Illusion Stickers{}"
		}
	},
	config = { extra = { tarotsAmount = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.tarotsAmount } }
	end,
	rarity = 3,
	atlas = 'arsGoetiaPacts',
	pos = { x = 1, y = 3 },
	cost = 8,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		--when selecting a blind,
		if context.setting_blind then
			G.E_MANAGER:add_event(Event({
				func = function() 
					for i = 1, card.ability.extra.tarotsAmount do
						local newTarot = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'asmodeus')
						newTarot:add_to_deck()
						
						newTarot:set_edition({negative = true}, true)
						newTarot:set_illusion()
						
						G.consumeables:emplace(newTarot)
					end
					return true
            end}))   
			
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.SECONDARY_SET.Tarot}) 
            return true
		end
	end
}

-- 33 Gaap
SMODS.Joker {
	key = 'gaap',
	loc_txt = {
		name = 'Gaap',
		text = {
			"Triples all {C:attention}listed{}",
			"{C:green}probabilities{} on",
			"{C:attention}final hand{} of round",
			"{C:inactive}(ex: {C:green}1 in 3{} {C:inactive}->{} {C:green}#1# in 3{}{C:inactive}){}"
		}
	},
	config = { extra = { oddsMult = 3, active = false } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.oddsMult } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 2, y = 3 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = false,
    eternal_compat = true,
	calculate = function(self, card, context)
		--set up odds
		if context.before
		and G.GAME.current_round.hands_left == 0
		and card.ability.extra.active == false
		then
			card.ability.extra.active = true
			for k, v in pairs(G.GAME.probabilities) do 
                G.GAME.probabilities[k] = v * card.ability.extra.oddsMult
            end
		end
		
		if context.end_of_round
		and context.cardarea == G.jokers
		and card.ability.extra.active == true
		then
			card.ability.extra.active = false
			for k, v in pairs(G.GAME.probabilities) do 
                G.GAME.probabilities[k] = v / card.ability.extra.oddsMult
            end
		end
	end
}

-- 34 Furfur
SMODS.Joker {
	key = 'furfur',
	loc_txt = {
		name = 'Furfur',
		text = {
			"This Pact gains {C:chips}Chips{} for",
			"each playing card destroyed",
			"equal to {C:attention}double{} its rank",
			"{C:inactive}(Currently{} {C:chips}+#1#{} {C:inactive}Chips){}"
		}
	},
	config = { extra = { chips = 0 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 3, y = 3 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.cards_destroyed
		or context.remove_playing_cards
		and not context.blueprint
		then
            local addChips = 0
			
			if context.cards_destroyed then
				for k, v in ipairs(context.glass_shattered) do
					addChips = addChips + (v.base.nominal * 2)
				end
			else if context.remove_playing_cards then
				for k, v in ipairs(context.removed) do
					addChips = addChips + (v.base.nominal * 2)
				end
			end
			
            G.E_MANAGER:add_event(Event({
                func = function()
				G.E_MANAGER:add_event(Event({
					func = function()
						card.ability.extra.chips = card.ability.extra.chips + addChips
					return true
					end
				}))
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips + addChips}}})
				return true
				end
            }))

            return
			
			end
		end
	
		if context.joker_main then
			return {
				chip_mod = card.ability.extra.chips,
				message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } }
			}
		end
	end
}

-- 35 Marchosias
SMODS.Joker {
	key = 'marchosias',
	loc_txt = {
		name = 'Marchosias',
		text = {
			"{C:chips}+#1#{} Chips if played",
			"hand does not contain",
			"cards with the same {C:attention}suit{}"
		}
	},
	config = { extra = { chips = 120 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 4, y = 3 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.joker_main then
			local flag = true
			local cardsList = {}
			--for each card in the scoring hand...
			for i = 1, #context.scoring_hand do
				--...check it against each card previously scored
				for j = 1, #cardsList do				
					if (context.scoring_hand[i].base.suit == cardsList[j].base.suit
					or context.scoring_hand[i].ability.name == G.P_CENTERS.m_wild.name
					or cardsList[j].ability.name == G.P_CENTERS.m_wild.name)
					then
						flag = false
					end
				end
				
				cardsList[#cardsList + 1] = context.scoring_hand[i]
			end
			
			if flag == true then
				return {
					chip_mod = card.ability.extra.chips,
					message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } }
				}
			end
		end
	end
}

-- 36 Stolas
SMODS.Joker {
	key = 'stolas',
	loc_txt = {
		name = 'Stolas',
		text = {
			"{C:green}#2# in #1#{} chance to add",
			"an extra {C:attention}level{} when",
			"using a {C:planet}Planet{} card"
		}
	},
	config = { extra = { odds = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.odds, ''..(G.GAME and G.GAME.probabilities.normal or 1) } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 5, y = 3 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.using_consumeable then
			if context.consumeable.ability.set == 'Planet'
			and pseudorandom('stolas') < G.GAME.probabilities.normal/card.ability.extra.odds
			then
				--do retrigger text
				card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, { message = localize('k_again_ex') })
				
				--update level
				update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(context.consumeable.ability.hand_type, 'poker_hands'),chips = G.GAME.hands[context.consumeable.ability.hand_type].chips, mult = G.GAME.hands[context.consumeable.ability.hand_type].mult, level=G.GAME.hands[context.consumeable.ability.hand_type].level})
				level_up_hand(context.consumeable, context.consumeable.ability.hand_type, _, 1)
				update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
			end
		end
	end
}

-- 37 Phenex
SMODS.Joker {
	key = 'phenex',
	loc_txt = {
		name = 'Phenex',
		text = {
			"{C:attention}Glass Cards{} give an",
			"additional {X:mult,C:white}X#1#{} Mult,",
			"but always {C:attention}shatter{}"
		}
	},
	config = { extra = { Xmult = 1.5 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.Xmult } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 6, y = 3 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_glass',
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play
		and not context.blueprint then
			--if checked card is a Bonus or Mult Card
			if context.other_card.ability.name == G.P_CENTERS.m_glass.name then
				return {
					x_mult = card.ability.extra.Xmult
				}
			end
		end
		
		if context.destroying_card
		and not context.blueprint then
			local killCards = {}
			
			for i = 1, #context.scoring_hand do
				if context.scoring_hand[i].ability.name == G.P_CENTERS.m_glass.name then
					--scoring_hand[i]card:shatter()
					killCards[#killCards + 1] = context.scoring_hand[i]
				end
			end
			
			SMODS.destroy_cards(killCards)
		end
	end
}

-- 38 Malthus
SMODS.Joker {
	key = 'malthus',
	loc_txt = {
		name = 'Malthus',
		text = {
			"Create a {C:spectral}Spectral{}",
			"card for every {C:attention}#1#{}",
			"{C:attention}Alchemy Cards{} scored",
			"{C:inactive}(Currently:{} {C:attention}#2#{}{C:inactive}/#1#){}"
		}
	},
	config = { extra = { req = 13, prog = 0 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS['m_arsGoetia_alchemy']
		return { vars = { card.ability.extra.req, card.ability.extra.prog } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 7, y = 3 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_arsGoetia_alchemy',
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play
		and not context.blueprint then
			--if checked card is an alchemy card
			if context.other_card.ability.name == G.P_CENTERS['m_arsGoetia_alchemy'].name
			then
				--gonna be nice here and not have charge vanish if there's no room for the spectral
				if card.ability.extra.prog > card.ability.extra.req - 1
				and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit
				then
					card.ability.extra.prog = 0
					
					card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral})
					G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
					
					G.E_MANAGER:add_event(Event({
					trigger = 'before',
					delay = 0.0,
					func = (function()
						if G.GAME.last_hand_played then
							--make the card and add it
							local newSpectral = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'malthus')
							newSpectral:add_to_deck()
							G.consumeables:emplace(newSpectral)
							G.GAME.consumeable_buffer = 0
						end
						return true
					end)}))
				else
					card.ability.extra.prog = card.ability.extra.prog + 1
				
					G.E_MANAGER:add_event(Event({
					trigger = 'before',
					delay = 0.0,
					func = (function()
						card:juice_up()
						return true
					end)}))
				end
			end
		end
	end
}

-- 39 Malphas
SMODS.Joker {
	key = 'malphas',
	loc_txt = {
		name = 'Malphas',
		text = {
			"Create a {C:tarot}Tarot{}",
			"card when a {C:planet}Planet{}",
			"card is {C:attention}sold{}"
		}
	},
	config = { extra = { } },
	loc_vars = function(self, info_queue, card)
		return { vars = { } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 8, y = 3 },
	cost = 4,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.selling_card then
			if context.card.ability.set == "Planet" then
				G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
				print(context.card.edition)
				G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
					G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
					if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit
					then
						SMODS.add_card { set = 'Tarot', soulable = false }
						
						card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, { message = localize('k_plus_tarot'), colour = G.C.SECONDARY_SET.Tarot })
					end
					return true
				end }))
			end
		end
	end
}
--this implementation doesn't deal with negative planets made from
--perkeo, so i'm choosing to just ignore them and say this works
--like invisible joker


-- 40 Raum
SMODS.Joker {
	key = 'raum',
	loc_txt = {
		name = 'Raum',
		text = {
			"{C:common}Common{} Jokers each",
			"give {C:chips}+#1#{} Chips.",
			"{C:rare}Rare{} Jokers each",
			"give {X:mult,C:white}X#2#{} Mult"
		}
	},
	config = { extra = { commonChips = 60, rareXmult = 0.75 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.commonChips, card.ability.extra.rareXmult } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 9, y = 3 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.other_joker
		then
			--for common jokers
			if context.other_joker.config.center.rarity == 1 then
			
				if context.other_joker ~= card then
					G.E_MANAGER:add_event(Event({
						func = function()
							context.other_joker:juice_up(0.5, 0.5)
							return true
						end
					}))
				end
				
                return {
                    message = localize { type = 'variable', key = 'a_chips', vars = {card.ability.extra.commonChips}},
                    chip_mod = card.ability.extra.commonChips
                }
			end
			
			--for rare jokers
			if context.other_joker.config.center.rarity == 3 then
				G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_joker:juice_up(0.5, 0.5)
                        return true
                    end
                })) 
                return {
                    message = localize { type = 'variable', key = 'a_xmult', vars = {card.ability.extra.rareXmult}},
                    Xmult_mod = card.ability.extra.rareXmult
                }
			end
		end
	end
}

-- 41 Focalor
SMODS.Joker {
	key = 'focalor',
	loc_txt = {
		name = 'Focalor',
		text = {
			"Apply a {C:purple}Purple Seal{}",
			"to the {C:attention}first discarded{}",
			"card each round for",
			"the next {C:attention}#1#{} #2#"
		}
	},
	config = { extra = { rounds = 3, roundsCur = 3 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_SEALS['Purple']
		return { vars = { card.ability.extra.roundsCur, card.ability.extra.roundsCur == 1 and 'round' or 'rounds' } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 0, y = 4 },
	cost = 7,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.discard
		and not context.blueprint
		and G.GAME.current_round.discards_used == 0
		then
			if context.other_card == context.full_hand[1]
			and not context.other_card.getting_sliced
			then
				context.other_card:set_seal('Purple')
				
				G.E_MANAGER:add_event(Event({
				trigger = 'before',
				delay = 0.0,
				func = (function()
					card:juice_up()
					return true
				end)}))
			end
		end
		
		if context.end_of_round and context.cardarea == G.jokers then
			card.ability.extra.roundsCur = card.ability.extra.roundsCur - 1
			
			if card.ability.extra.roundsCur == 0 then
				SMODS.destroy_cards(card)
			end
		end
	end
}

-- 42 Vepar
SMODS.Joker {
	key = 'vepar',
	loc_txt = {
		name = 'Vepar',
		text = {
			"Retrigger",
			"each played {C:attention}6{},",
			"{C:attention}7{}, {C:attention}8{}, {C:attention}9{}, or {C:attention}10{}"
		}
	},
	config = {},
	loc_vars = function(self, info_queue, card)
		return {}
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 1, y = 4 },
	cost = 7,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.cardarea == G.play
		and context.repetition
		and not context.repetition_only then
			if context.other_card:get_id() == 6
			or context.other_card:get_id() == 7
			or context.other_card:get_id() == 8
			or context.other_card:get_id() == 9
			or context.other_card:get_id() == 10
			then
				return {
					repetitions = 1
				}
			end
		end
	end
}

-- 43 Sabnock
SMODS.Joker {
	key = 'sabnock',
	loc_txt = {
		name = 'Sabnock',
		text = {
			"{C:mult}+#1#{} Mult if combined",
			"rank of cards held",
			"in hand is below {C:attention}#2#{}"
		}
	},
	config = { extra = { mult = 10, rankReq = 30 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.rankReq } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 2, y = 4 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
        if context.joker_main then
			local totalRank = 0
			
			for i = 1, #G.hand.cards do
				totalRank = totalRank + G.hand.cards[i].base.nominal
			end
			
			if totalRank <= card.ability.extra.rankReq then
				return {
					mult_mod = card.ability.extra.mult,
					message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
				}
			end
		end
    end
}

-- 44 Shax
SMODS.Joker {
	key = 'shax',
	loc_txt = {
		name = 'Shax',
		text = {
			"{X:mult,C:white}X#1#{} Mult if played hand",
			"contains a scoring {C:attention}#2#{},",
			"rank changes each round"
		}
	},
	config = { extra = { Xmult = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.Xmult, G.GAME.current_round.shax_rank } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 3, y = 4 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.joker_main then
			local isThere = false
			
			for i = 1, #context.scoring_hand do
				--if not a stone card and has the same value string as the shared rank
				if context.scoring_hand[i]:get_id() > 0
				and context.scoring_hand[i].base.value == G.GAME.current_round.shax_rank then
					isThere = true
					break
				end
			end
			
			if isThere == true then
				return {
					Xmult_mod = card.ability.extra.Xmult,
					message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } }
				}
			end
		end
	end
}

local igo = Game.init_game_object
function Game:init_game_object()
	local ret = igo(self)
	ret.current_round.shax_rank = 'Ace'
	return ret
end

-- This is a part 2 of the above thing, to make the custom G.GAME variable change every round.
function SMODS.current_mod.reset_game_globals(run_start)
	-- rank changes every round, start it at aces and go from there
	G.GAME.current_round.shax_rank = 'Ace'
	
	local valid_rank_cards = {}
	for _, v in ipairs(G.playing_cards) do
		--check if not stone card
		if v:get_id() > 0
		then
			valid_rank_cards[#valid_rank_cards + 1] = v
		end
	end
	if valid_rank_cards[1] then
		local rand_card = pseudorandom_element(valid_rank_cards, pseudoseed('shax' .. G.GAME.round_resets.ante))
		G.GAME.current_round.shax_rank = rand_card.base.value
	end
end

-- 45 Vine
SMODS.Joker {
	key = 'vine',
	loc_txt = {
		name = 'Vine',
		text = {
			"{C:attention}Destroy{} all cards",
			"held in hand before",
			"the end of the round"
		}
	},
	config = { extra = {} },
	loc_vars = function(self, info_queue, card)
		return { vars = {} }
	end,
	rarity = 3,
	atlas = 'arsGoetiaPacts',
	pos = { x = 4, y = 4 },
	cost = 8,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = false,
	calculate = function(self, card, context)
		if context.end_of_round
		and context.cardarea == G.jokers
		and not context.blueprint then
			local destroyFlag = false
			--k is int i, v is curCard
			for k, v in ipairs(G.hand.cards) do
				--can't kill a card already getting destroyed
				if not v.getting_sliced then
					SMODS.destroy_cards(v)
					destroyFlag = true
				end
			end
			
			if destroyFlag then
				G.E_MANAGER:add_event(Event({
				trigger = 'before',
				delay = 0.0,
				func = (function()
					card:juice_up()
					return true
				end)}))
			end
		end
	end
}

-- 46 Bifrons
SMODS.Joker {
	key = 'bifrons',
	loc_txt = {
		name = 'Bifrons',
		text = {
			"{C:mult}+#1#{} Mult if played",
			"poker hand is your",
			"{C:attention}most played{} poker hand"
		}
	},
	config = { extra = { mult = 10 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 5, y = 4 },
	cost = 4,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.joker_main then
			local isHighest = true
			--grab amount of times current hand was played
			local currentPlayed = G.GAME.hands[context.scoring_name].played or 0
			--for each hand type
            for k, v in pairs(G.GAME.hands) do
				print(currentPlayed)
				print(v.played)
			
                if v.played > currentPlayed and v.visible then
                    isHighest = false
					break
                end
            end
		
			if isHighest == true then
				return {
					mult_mod = card.ability.extra.mult,
					message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
				}
			end
		end
	end
}

-- 47 Vual
SMODS.Joker {
	key = 'vual',
	loc_txt = {
		name = 'Vual',
		text = {
			"Apply a {C:red}Red Seal{} to",
			"the {C:attention}last{} scoring card",
			"in {C:attention}first{} played hand",
			"for the next {C:attention}#1#{} #2#"
		}
	},
	config = { extra = { rounds = 3, roundsCur = 3 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_SEALS['Red']
		return { vars = { card.ability.extra.roundsCur, card.ability.extra.roundsCur == 1 and 'round' or 'rounds' } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 6, y = 4 },
	cost = 7,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.before
		and not context.blueprint
		and G.GAME.current_round.hands_played == 0
		then
			if not context.scoring_hand[#context.scoring_hand].getting_sliced
			then
				context.scoring_hand[#context.scoring_hand]:set_seal('Red')
				
				G.E_MANAGER:add_event(Event({
				trigger = 'before',
				delay = 0.0,
				func = (function()
					card:juice_up()
					return true
				end)}))
			end
		end
		
		if context.end_of_round and context.cardarea == G.jokers then
			card.ability.extra.roundsCur = card.ability.extra.roundsCur - 1
			
			if card.ability.extra.roundsCur == 0 then
				SMODS.destroy_cards(card)
			end
		end
	end
}

-- 48 Haagenti
SMODS.Joker {
	key = 'haagenti',
	loc_txt = {
		name = 'Haagenti',
		text = {
			"{C:attention}Gold Cards{} give {X:mult,C:white}X#1#{} Mult",
			"when held in hand, and held",
			"{C:attention}Steel Cards{} give {C:money}$#2#{} at",
			"the end of the round"
		}
	},
	config = { extra = { Xmult = 1.5, money = 3 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
		info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
		return { vars = { card.ability.extra.Xmult, card.ability.extra.money } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 7, y = 4 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_steel' or 'm_gold', --not sure if this works
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.hand then
			if context.end_of_round then
				if context.other_card.ability.name == G.P_CENTERS.m_steel.name then
					if context.other_card.debuff then
						return {
							message = localize('k_debuffed'),
							colour = G.C.RED
						}
					end
				
					return {
						dollars = card.ability.extra.money
					}
				end
			elseif context.other_card.ability.name == G.P_CENTERS.m_gold.name then
				if context.other_card.debuff then
					return {
						message = localize('k_debuffed'),
						colour = G.C.RED
					}
				end
			
				return {
					x_mult = card.ability.extra.Xmult
				}
			end
		end
	end
}

-- 49 Crocell
SMODS.Joker {
	key = 'crocell',
	loc_txt = {
		name = 'Crocell',
		text = {
			"Played {C:attention}non-face{} cards",
			"have a {C:green}#1# in #2#{} chance",
			"to give {C:money}$Rank{}"
		}
	},
	config = { extra = { odds = 8 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { ''..(G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 8, y = 4 },
	cost = 7,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play then
			if not context.other_card:is_face() then
				--get rank of card
				local rank = context.other_card.base.nominal
				
				if pseudorandom('crocell') < G.GAME.probabilities.normal / card.ability.extra.odds then
					return {
						dollars = rank
					}
				end
			end
		end
	end
}

-- 50 Furcas
SMODS.Joker {
	key = 'furcas',
	loc_txt = {
		name = 'Furcas',
		text = {
			"This Pact gains",
			"{C:mult}+#2#{} Mult for each",
			"used {C:attention}consumable{}",
			"{C:inactive}(Currently{} {C:mult}+#1#{} {C:inactive}Mult){}"
		}
	},
	config = { extra = { mult = 0, multScaling = 0.5 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.multScaling } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 9, y = 4 },
	cost = 4,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.using_consumeable then
			card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.multScaling
                G.E_MANAGER:add_event(Event({
                func = function() card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}}}); return true
                end}))
		end
	
		if context.joker_main then
			return {
				mult_mod = card.ability.extra.mult,
				message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
			}
		end
	end
}

-- 51 Balam
SMODS.Joker {
	key = 'balam',
	loc_txt = {
		name = 'Balam',
		text = {
			"Played {C:attention}7s{} have a {C:green}#4# in #3#{}",
			"chance to give {X:mult,C:white}X#1#{} Mult",
			"when scored, but give",
			"{X:mult,C:white}X#2#{} Mult otherwise"
		}
	},
	config = { extra = { xmultGood = 2, xmultBad = 0.75, odds = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmultGood, card.ability.extra.xmultBad, card.ability.extra.odds, ''..(G.GAME and G.GAME.probabilities.normal or 1) } }
	end,
	rarity = 3,
	atlas = 'arsGoetiaPacts',
	pos = { x = 0, y = 5 },
	cost = 8,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play then
			if context.other_card:get_id() == 7 then
				if context.other_card.debuff then
					return {
						message = localize('k_debuffed'),
						colour = G.C.RED
					}
				end
				
				local multAmount = card.ability.extra.xmultBad
				if pseudorandom('balam') < G.GAME.probabilities.normal/card.ability.extra.odds then
					multAmount = card.ability.extra.xmultGood
				end
				
				return {
					x_mult = multAmount
				}
			end
		end
	end
}

-- 52 Allocer
SMODS.Joker {
	key = 'allocer',
	loc_txt = {
		name = 'Allocer',
		text = {
			"Apply a {C:blue}Blue Seal{} to the",
			"{C:attention}leftmost{} card held in hand",
			"before the end of the round",
			"for the next {C:attention}#1#{} #2#",
			"{C:inactive}(Drag to rearrange){}"
		}
	},
	config = { extra = { rounds = 3, roundsCur = 3 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_SEALS['Blue']
		return { vars = { card.ability.extra.roundsCur, card.ability.extra.roundsCur == 1 and 'round' or 'rounds' } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 1, y = 5 },
	cost = 7,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.end_of_round
		and not context.blueprint
		and context.cardarea == G.jokers
		then
			if not G.hand.cards[1].getting_sliced
			then
				G.hand.cards[1]:set_seal('Blue')
				
				G.E_MANAGER:add_event(Event({
				trigger = 'before',
				delay = 0.0,
				func = (function()
					card:juice_up()
					return true
				end)}))
			end
		end
		
		if context.end_of_round and context.cardarea == G.jokers then
			card.ability.extra.roundsCur = card.ability.extra.roundsCur - 1
			
			if card.ability.extra.roundsCur == 0 then
				SMODS.destroy_cards(card)
			end
		end
	end
}

-- 53 Camio
SMODS.Joker {
	key = 'camio',
	loc_txt = {
		name = 'Camio',
		text = {
			"If played hand consists",
			"of {C:attention}1{} scoring card, retrigger",
			"that card {C:attention}#1#{} times"
		}
	},
	config = { extra = { repetitions = 3 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.repetitions } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 2, y = 5 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.cardarea == G.play
		and context.repetition
		and not context.repetition_only then
			if #context.scoring_hand == 1 then
				return {
						repetitions = card.ability.extra.repetitions,
				}
			end
		end
	end
}

-- 54 Murmur
SMODS.Joker {
	key = 'murmur',
	loc_txt = {
		name = 'Murmur',
		text = {
			"Every played {C:attention}card{}",
			"permanently gains",
			"{C:mult}+1{} Mult when scored"
		}
	},
	config = { extra = { permaMult = 1 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.permaMult } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 3, y = 5 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
			--establish variable if not there
            context.other_card.ability.perma_mult = context.other_card.ability.perma_mult or 0
			--then add to it
            context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + card.ability.extra.permaMult
            return {
                message = localize('k_upgrade_ex'), colour = G.C.MULT
            }
        end
    end
}

-- 55 Orobas
SMODS.Joker {
	key = 'orobas',
	loc_txt = {
		name = 'Orobas',
		text = {
			"This Pact gains {C:mult}+#2#{} Mult per",
			"{C:attention}consecutive{} hand played",
			"without {C:attention}selling{} a card",
			"{C:inactive}(Currently{} {C:mult}+#1#{} {C:inactive}Mult){}"
		}
	},
	config = { extra = { mult = 0, multScaling = 1 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.multScaling } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 4, y = 5 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.selling_card then
			card.ability.extra.mult = 0
			
			return {
				extra = {focus = card, message = localize('k_reset')}
			}
		end
		
		if context.joker_main then
			card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.multScaling
		
			return {
				mult_mod = card.ability.extra.mult,
				message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
			}
		end
	end
}

-- 56 Gremory
SMODS.Joker {
	key = 'gremory',
	loc_txt = {
		name = 'Gremory',
		text = {
			"Played {C:attention}Wild Cards{} give",
			"{C:chips}+#1#{} Chips, {C:mult}+#2#{} Mult,",
			"and {C:money}$#3#{} when scored"
		}
	},
	config = { extra = { chips = 15, mult = 3, money = 1 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
		return { vars = { card.ability.extra.chips, card.ability.extra.mult, card.ability.extra.money } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 5, y = 5 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_wild',
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play then
			if context.other_card.ability.name == G.P_CENTERS.m_wild.name then
				return {
					chips = card.ability.extra.chips,
					mult = card.ability.extra.mult,
					dollars = card.ability.extra.money
				}
			end
		end
	end
}

-- 57 Ose
SMODS.Joker {
	key = 'ose',
	loc_txt = {
		name = 'Ose',
		text = {
			"If scored hand contains",
			"{C:red}debuffed{} cards in a {C:attention}Boss Blind{},",
			"destroy those cards and",
			"{C:attention}disable{} current {C:attention}Boss Blind{}"
		}
	},
	config = { extra = { didTheThing = false} },
	loc_vars = function(self, info_queue, card)
		return { vars = { } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 6, y = 5 },
	cost = 5,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.setting_blind
		and card.ability.extra.didTheThing == true
		then
			card.ability.extra.didTheThing = false
		end
	
		if context.destroying_card
		and G.GAME.blind.boss
		and card.ability.extra.didTheThing == false
		then
			local killCards = {}
			
			for i = 1, #context.scoring_hand, 1 do
				if context.scoring_hand[i].debuff then
					killCards[#killCards + 1] = context.scoring_hand[i]
				end
			end
			
			if #killCards > 0 then
				card.ability.extra.didTheThing = true
				SMODS.destroy_cards(killCards)
				
				--copied from chicot
				G.E_MANAGER:add_event(Event({func = function()
					G.E_MANAGER:add_event(Event({func = function()
						G.GAME.blind:disable()
						play_sound('timpani')
						delay(0.4)
						return true end }))
					card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('ph_boss_disabled')})
				return true end }))
			end
		end
	end
}

-- 58 Amy
SMODS.Joker {
	key = 'amy',
	loc_txt = {
		name = 'Amy',
		text = {
			"{C:blue}+#2#{} hand each round",
			"{C:attention}#1#{} hand size"
		}
	},
	config = { h_size = -1, extra = { extraHands = 1 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.h_size, card.ability.extra.extraHands } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 7, y = 5 },
	cost = 4,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		--decrease hands and discards at the start of the blind (but not via blueprint)
		if context.setting_blind and not context.blueprint then
			return {
				ease_hands_played(1, nil, true),
			}
		end
	end
}

-- 59 Orias
SMODS.Joker {
	key = 'orias',
	loc_txt = {
		name = 'Orias',
		text = {
			"{C:planet}Planet{} cards upgrade",
			"another random",
			"{C:attention}poker hand{} when used"
		}
	},
	config = { extra = { } },
	loc_vars = function(self, info_queue, card)
		return { vars = { } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 8, y = 5 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.using_consumeable then
			if context.consumeable.ability.set == 'Planet'
			then
				local handType
				local i = 0
				
				while true do
					handType = pseudorandom_element(G.handlist, pseudoseed('orias') .. i)
					
					--make sure the hand type is visible (ie. not flush five)
					--and also that it's a different hand type
					if G.GAME.hands[handType].visible == true
					and context.consumeable.ability.hand_type ~= handType
					then
						break
					end
					
					i = i + 1
				end
				
				--do retrigger text
				card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, { message = localize('k_level_up_ex') })
				
				--update level
				update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(handType, 'poker_hands'),chips = G.GAME.hands[handType].chips, mult = G.GAME.hands[handType].mult, level=G.GAME.hands[handType].level})
				level_up_hand(context.consumeable, handType, _, 1)
				update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
			end
		end
	end
}

-- 60 Vapula
SMODS.Joker {
	key = 'vapula',
	loc_txt = {
		name = 'Vapula',
		text = {
			"Apply a {C:gold}Gold Seal{} to",
			"the {C:attention}first{} scoring card",
			"in {C:attention}first{} played hand",
			"for the next {C:attention}#1#{} #2#"
		}
	},
	config = { extra = { rounds = 3, roundsCur = 3 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_SEALS['Gold']
		return { vars = { card.ability.extra.roundsCur, card.ability.extra.roundsCur == 1 and 'round' or 'rounds' } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 9, y = 5 },
	cost = 7,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.before
		and not context.blueprint
		and G.GAME.current_round.hands_played == 0
		then
			if not context.scoring_hand[1].getting_sliced
			then
				context.scoring_hand[1]:set_seal('Gold')
				
				G.E_MANAGER:add_event(Event({
				trigger = 'before',
				delay = 0.0,
				func = (function()
					card:juice_up()
					return true
				end)}))
			end
		end
		
		if context.end_of_round and context.cardarea == G.jokers then
			card.ability.extra.roundsCur = card.ability.extra.roundsCur - 1
			
			if card.ability.extra.roundsCur == 0 then
				SMODS.destroy_cards(card)
			end
		end
	end
}

-- 61 Zagan
SMODS.Joker {
	key = 'zagan',
	loc_txt = {
		name = 'Zagan',
		text = {
			"{C:attention}Bonus Cards{} and",
			"{C:attention}Mult Cards{} give",
			"{X:mult,C:white}X#1#{} Mult when scored"
		}
	},
	config = { extra = { Xmult = 1.5 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_bonus
		info_queue[#info_queue + 1] = G.P_CENTERS.m_mult
		return { vars = { card.ability.extra.Xmult } }
	end,
	rarity = 3,
	atlas = 'arsGoetiaPacts',
	pos = { x = 0, y = 6 },
	cost = 8,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_bonus' or 'm_mult',
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play
		and not context.blueprint then
			--if checked card is a Bonus or Mult Card
			if context.other_card.ability.name == G.P_CENTERS.m_bonus.name
			or context.other_card.ability.name == G.P_CENTERS.m_mult.name then
				return {
					x_mult = card.ability.extra.Xmult
				}
			end
		end
	end
}

-- 62 Valac
SMODS.Joker {
	key = 'valac',
	loc_txt = {
		name = 'Valac',
		text = {
			"At {C:attention}start of blind{}, give",
			"all cards held in hand a",
			"random {C:attention}Enhancement{} and",
			"destroy this Pact"
		}
	},
	config = { extra = { } },
	loc_vars = function(self, info_queue, card)
		return { vars = { } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 1, y = 6 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.first_hand_drawn then
			--wait for 0.4 seconds and play the sound
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
				play_sound('tarot1')
				--used_tarot:juice_up(0.3, 0.5) --this line shakes the consumables box for some reason
				return true end }))
				
			--for each card selected,
			for i = 1, #G.hand.cards do
				--get some percent for sound idk
				local percent = 1.15 - (i-0.999)/(#G.hand.cards-0.998)*0.3
				--flip the card and play the sound after 0.15 seconds
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() G.hand.cards[i]:flip();play_sound('card1', percent);G.hand.cards[i]:juice_up(0.3, 0.3);return true end }))
			end
			
			--wait
			delay(0.1)
			
			--for each,
			for i = 1, #G.hand.cards do
				--get a random number from 1 to the amount of enhancements in the game
				local randomEnhancement = math.floor((pseudorandom('valac') * 1000) % #G.P_CENTER_POOLS.Enhanced) + 1
				
				--set the card enhancement and wait 0.1 seconds
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.05,func = function() G.hand.cards[i]:set_ability(G.P_CENTER_POOLS.Enhanced[randomEnhancement].key);return true end }))
			end
			
			for i = 1, #G.hand.cards do
				--flip the card back over and wait
				percent = 0.85 + (i-0.999)/(#G.hand.cards-0.998)*0.3
				G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() G.hand.cards[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.cards[i]:juice_up(0.3, 0.3);return true end }))
			end
			
			--wait
			delay(0.5)
			
			SMODS.destroy_cards(card)
		end
	end
}

-- 63 Andras
SMODS.Joker {
	key = 'andras',
	loc_txt = {
		name = 'Andras',
		text = {
			"{C:green}#3# in #1#{} chance for",
			"{C:attention}Lucky Cards{} to",
			"give {C:chips}+#2#{} Chips",
			"when scored"
		}
	},
	config = { extra = { odds = 2, chips = 50 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
		return { vars = { card.ability.extra.odds, card.ability.extra.chips, ''..(G.GAME and G.GAME.probabilities.normal or 1) } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 2, y = 6 },
	cost = 5,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_lucky',
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play
		then
			if context.other_card.ability.name == G.P_CENTERS.m_lucky.name
			and pseudorandom('andras') < G.GAME.probabilities.normal / card.ability.extra.odds
			then
				return {
					chips = card.ability.extra.chips
				}
			end
		end
	end
}

-- 64 Flauros
SMODS.Joker {
	key = 'flauros',
	loc_txt = {
		name = 'Flauros',
		text = {
			"Destroy the {C:attention}rightmost{}",
			"card held in hand",
			"after the {C:attention}first{}",
			"hand of each round",
			"{C:inactive}(Drag to rearrange){}"
		}
	},
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 3, y = 6 },
	cost = 6,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.destroying_card
		and not context.blueprint then
			if G.GAME.current_round.hands_played == 0 then
				SMODS.destroy_cards(G.hand.cards[#G.hand.cards])
            end
		end
	end
}

-- 65 Andrealphus
SMODS.Joker {
	key = 'andrealphus',
	loc_txt = {
		name = 'Andrealphus',
		text = {
			"This Pact gains {C:chips}+#2#{} Chips",
			"when a {C:attention}Bonus Card{} is scored",
			"{C:inactive}(Currently{} {C:chips}+#1#{} {C:inactive}Chips){}"
		}
	},
	config = { extra = { chips = 0, chipsScaling = 8 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_bonus
		return { vars = { card.ability.extra.chips, card.ability.extra.chipsScaling } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 4, y = 6 },
	cost = 4,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_bonus',
	calculate = function(self, card, context)
		--when checking individual played cards,
		if context.individual
		and context.cardarea == G.play
		and not context.blueprint then
			--if checked card is a Bonus Card
			if context.other_card.ability.name == G.P_CENTERS.m_bonus.name then
				card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chipsScaling
				
				--display upgrade message on this Pact, not the card
				return {
					extra = {focus = card, message = localize('k_upgrade_ex')}
				}
			end
		end
		
		--standard-issue return chips here
		if context.joker_main and card.ability.extra.chips ~= 0 then
			return {
				chip_mod = card.ability.extra.chips,
				message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } }
			}
		end
	end
}

-- 66 Kimaris
SMODS.Joker {
	key = 'kimaris',
	loc_txt = {
		name = 'Kimaris',
		text = {
			"This Pact gains {C:mult}+#2#{} Mult",
			"when a {C:attention}Mult Card{} is scored",
			"{C:inactive}(Currently{} {C:mult}+#1#{} {C:inactive}Mult){}"
		}
	},
	config = { extra = { mult = 0, multScaling = 1 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_mult
		return { vars = { card.ability.extra.mult, card.ability.extra.multScaling } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 5, y = 6 },
	cost = 4,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_mult',
	calculate = function(self, card, context)
		--when checking individual played cards,
		if context.individual
		and context.cardarea == G.play
		and not context.blueprint then
			--if checked card is a Mult Card
			if context.other_card.ability.name == G.P_CENTERS.m_mult.name then
				card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.multScaling
				
				--display upgrade message on this Pact, not the card
				return {
					extra = {focus = card, message = localize('k_upgrade_ex')}
				}
			end
		end
		
		--standard-issue return mult here
		if context.joker_main and card.ability.extra.mult ~= 0 then
			return {
				mult_mod = card.ability.extra.mult,
				message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
			}
		end
	end
}

-- 67 Amdusias
SMODS.Joker {
	key = 'amdusias',
	loc_txt = {
		name = 'Amdusias',
		text = {
			"{C:attention}Non-Wild Cards{} give",
			"{X:mult,C:white}X1.5{} Mult for each",
			"{C:attention}Wild Card{} scored",
			"in the same hand"
		}
	},
	config = { extra = { Xmult = 1.5 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
		return { vars = { card.ability.extra.Xmult } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 6, y = 6 },
	cost = 7,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_wild',
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play
		then
			if context.other_card.ability.name ~= G.P_CENTERS.m_wild.name then
				local wildAmount = 0
				
				--loop for each possible amount of retriggers, going down
				for i = 1, #context.scoring_hand do
					if context.scoring_hand[i].ability.name == G.P_CENTERS.m_wild.name then
						wildAmount = wildAmount + 1
					end
				end
				
				return {
					x_mult = card.ability.extra.Xmult ^ wildAmount
				}
			end
		end
	end
}

-- 68 Belial
SMODS.Joker {
	key = 'belial',
	loc_txt = {
		name = 'Belial',
		text = {
			"When round begins, add {C:attention}#1#{}",
			"{C:dark_edition}Negative{} playing cards with",
			"{C:dark_edition}Illusion Stickers{} to hand"
		}
	},
	config = { extra = { cardsAmount = 5 } },
	loc_vars = function(self, info_queue, card)
		--add Negative popup
		info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
		--add perish tag popup
		info_queue[#info_queue + 1] = { set = "Other", key = 'arsGoetia_illusion' }
		return { vars = { card.ability.extra.cardsAmount } }
	end,
	rarity = 3,
	atlas = 'arsGoetiaPacts',
	pos = { x = 7, y = 6 },
	cost = 9,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.first_hand_drawn then
			for i = 1, card.ability.extra.cardsAmount do
				G.E_MANAGER:add_event(Event({
					func = function() 
						local _card = create_playing_card({
							front = pseudorandom_element(G.P_CARDS, pseudoseed('belial')), 
							center = G.P_CENTERS.c_base}, G.hand, nil, nil, {G.C.SECONDARY_SET.Enhanced})
							
						_card:set_edition({negative = true}, true)
						_card:set_illusion()
							
						G.GAME.blind:debuff_card(_card)
						G.hand:sort()
						
						return true
				end}))
			end
			
			if context.blueprint_card then
				context.blueprint_card:juice_up()
			else
				card:juice_up()
			end
            playing_card_joker_effects({true})
		end
	end
}
--[][][]there's currently an issue with belial where hand size
--is taking too long to update. dunno if there's a way to force it

-- 69 Decarabia
SMODS.Joker {
	key = 'decarabia',
	loc_txt = {
		name = 'Decarabia',
		text = {
			"Played {C:attention}Stone Cards{}",
			"give {C:mult}+#1#{} Mult",
			"when scored"
		}
	},
	config = { extra = { mult = 10 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 8, y = 6 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_stone',
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play
		then
			if context.other_card.ability.name == G.P_CENTERS.m_stone.name then
				return {
					mult = card.ability.extra.mult
				}
			end
		end
	end
}

-- 70 Seir
SMODS.Joker {
	key = 'seir',
	loc_txt = {
		name = 'Seir',
		text = {
			"{X:mult,C:white}X#1#{} Mult if previous",
			"Blind was {C:attention}skipped{}",
			"{C:inactive}(Currently{} {C:attention}#2#{}{C:inactive}){}"
		}
	},
	config = { extra = { xmult = 3, isActive = false } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult, card.ability.extra.isActive and localize('k_active_ex') or "inactive" } }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 9, y = 6 },
	cost = 4,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.skip_blind
		and not context.blueprint then
			if card.ability.extra.isActive == false then
				card.ability.extra.isActive = true
				return {
					message = localize('k_active_ex')
				}
			end
		end
	
		if context.joker_main and card.ability.extra.isActive == true then
			return {
				Xmult_mod = card.ability.extra.xmult,
				message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } }
			}
		end
		
		if context.end_of_round and not context.blueprint then
			card.ability.extra.isActive = false
		end
	end
}

-- 71 Dantalion
SMODS.Joker {
	key = 'dantalion',
	loc_txt = {
		name = 'Dantalion',
		text = {
			"Played {C:attention}Steel Cards{}",
			"give {X:mult,C:white}X#1#{} Mult",
			"when scored"
		}
	},
	config = { extra = { Xmult = 1.75 } },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
		return { vars = { card.ability.extra.Xmult } }
	end,
	rarity = 2,
	atlas = 'arsGoetiaPacts',
	pos = { x = 0, y = 7 },
	cost = 6,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	enhancement_gate = 'm_steel',
	calculate = function(self, card, context)
		if context.individual
		and context.cardarea == G.play then
			if context.other_card.ability.name == G.P_CENTERS.m_steel.name then
				if context.other_card.debuff then
					return {
						message = localize('k_debuffed'),
						colour = G.C.RED
					}
				end
				
				return {
					x_mult = card.ability.extra.Xmult
				}
			end
		end
	end
}

-- 72 Andromalius
SMODS.Joker {
	key = 'andromalius',
	loc_txt = {
		name = 'Andromalius',
		text = {
			"Create a {C:spectral}Spectral{}",
			"card after defeating",
			"a {C:attention}Boss Blind{}"
		}
	},
	config = { extra = {} },
	loc_vars = function(self, info_queue, card)
		return { vars = {} }
	end,
	rarity = 1,
	atlas = 'arsGoetiaPacts',
	pos = { x = 1, y = 7 },
	cost = 5,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.end_of_round
		and context.cardarea == G.jokers
		and G.GAME.blind.boss
		and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
			SMODS.add_card { set = 'Spectral', soulable = false }
			
			return {
                message = localize('k_plus_spectral'),
                colour = G.C.SECONDARY_SET.Spectral
            }
		end
	end
}

-- 73 Cain
SMODS.Joker {
	key = 'cain',
	loc_txt = {
		name = 'Cain',
		text = {
			"Destroy all discarded",
			"{C:attention}Enhanced cards{}"
		}
	},
	config = { extra = {} },
	loc_vars = function(self, info_queue, card)
		return { vars = { } }
	end,
	rarity = 4,
	atlas = 'arsGoetiaPacts',
	pos = { x = 2, y = 7 },
	soul_pos = { x = 5, y = 7 },
	cost = 20,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.discard and not context.blueprint then
			--if card has a non-base ability and is not debuffed or already getting destroyed
			if      context.other_card.config.center ~= G.P_CENTERS.c_base
			and not context.other_card.debuff
			and not context.other_card.vampired --doesn't really apply here, but just in case
			and not context.other_card.getting_sliced
			then
				SMODS.destroy_cards(context.other_card)
			end
		end
	end
}

-- 74 Judas
SMODS.Joker {
	key = 'judas',
	loc_txt = {
		name = 'Judas',
		text = {
			"At end of round, destroy",
			"Joker to the right and",
			"gain {X:attention,C:white}X#1#{} its {C:money}sell value{}"
		}
	},
	config = { extra = { sellMult = 5 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.sellMult } }
	end,
	rarity = 4,
	atlas = 'arsGoetiaPacts',
	pos = { x = 3, y = 7 },
	soul_pos = { x = 6, y = 7 },
	cost = 20,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		if context.end_of_round
		and context.cardarea == G.jokers
		and not card.getting_sliced then
		
			--get position
			local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
					my_pos = i;
					break
				end
            end
			
			local savedSellValue = 0
            if my_pos
			and G.jokers.cards[my_pos+1]
			and not card.getting_sliced
			and not G.jokers.cards[my_pos+1].ability.eternal
			and not G.jokers.cards[my_pos+1].getting_sliced then
				--kill the joker to the right and save its sell value
                local sliced_card = G.jokers.cards[my_pos+1]
                sliced_card.getting_sliced = true
                G.GAME.joker_buffer = G.GAME.joker_buffer - 1
                G.E_MANAGER:add_event(Event({func = function()
                    G.GAME.joker_buffer = 0
                    savedSellValue = sliced_card.sell_cost * card.ability.extra.sellMult
                    card:juice_up(0.8, 0.8)
                    sliced_card:start_dissolve({HEX("57ecab")}, nil, 1.6)
                    play_sound('slice1', 0.96+math.random()*0.08)
					
					--increase money + message after delay
					delay(0.3)
					ease_dollars(savedSellValue)
					card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('$')..savedSellValue, colour = G.C.MONEY})
                return true end }))
            end
		end
	end
}

-- 75 Satan
SMODS.Joker {
	key = 'satan',
	loc_txt = {
		name = 'Satan',
		text = {
			"Jokers created from {C:tarot}Judgement{}",
			"have a {C:green}#2# in #1#{} chance to gain",
			"a {C:dark_edition}Negative{} edition"
		}
	},
	config = { extra = { odds = 4 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.odds, ''..(G.GAME and G.GAME.probabilities.normal or 1) } }
	end,
	rarity = 4,
	atlas = 'arsGoetiaPacts',
	pos = { x = 4, y = 7 },
	soul_pos = { x = 7, y = 7 },
	cost = 20,
    blueprint_compat = false,
    perishable_compat = true,
    eternal_compat = true,
	calculate = function(self, card, context)
		--The Funny (tm)
		if context.joker_main and not context.blueprint then
			if #context.full_hand == 3 then
				if context.full_hand[1]:get_id() == 6
				and context.full_hand[2]:get_id() == 6
				and context.full_hand[3]:get_id() == 6 then
					return {
						message = "Very Funny.",
						colour = G.C.DARK_EDITION
					}
				end
			end
		end
	end
}

--override judgement for satan ability
SMODS.Consumable:take_ownership("c_judgement",{
    use = function(self, card, context)
		local satanFlag = false
		for i = 1, #G.jokers.cards do
			--if any jokers are satan, check for the 1/4 chance and set flag if passed
			if G.jokers.cards[i].ability.name == 'j_arsGoetia_satan'
			and pseudorandom('satan') < G.GAME.probabilities.normal / G.jokers.cards[i].ability.extra.odds
			then
				satanFlag = true
				break
			end
		end
		
		--recreate normal judgement effect here, just with the extra negative condition
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
			play_sound('timpani')
			
			local newJoker = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'jud')
			newJoker:add_to_deck()
			if satanFlag then
				newJoker:set_edition({negative = true}, true)
			end
			G.jokers:emplace(newJoker)
			
			card:juice_up(0.3, 0.5)
			return true end }))
		delay(0.6)
		
		return true
	end,
}, true)