-- ## MOD SETUP ##

local arsGoetia_id = SMODS.current_mod.id
local arsGoetia_name = SMODS.current_mod.name

assert(SMODS.load_file("src/jokers.lua"))()
assert(SMODS.load_file("src/misc.lua"))()


-- ## JOKER ATLAS ##

SMODS.Atlas {
	key = "arsGoetiaPacts",
	path = "arsGoetiaPacts.png",
	px = 71,
	py = 95

}

-- ## MISC ATLAS ##

SMODS.Atlas {
    key = "arsGoetiaMisc",
    path = "arsGoetiaMisc.png",
    px = 71,
    py = 95
}

-- ## POOLS ##

--perishable and eternal don't work here, since these can only
--exist during blinds, so stuff like golden joker won't work
SMODS.ObjectType({
    key = "arsGoetia_illusionJokers", -- The prefix is not added automatically so it's recommended to add it yourself
    default = "j_joker",
    cards = {
		--VANILLA
		j_joker            = true,
		j_greedy_joker     = true,
		j_lusty_joker      = true,
		j_wrathful_joker   = true,
		j_gluttenous_joker = true,
		j_jolly            = true,
		j_zany             = true,
		j_mad              = true,
		j_crazy            = true,
		j_droll            = true,
		j_sly              = true,
		j_wily             = true,
		j_clever           = true,
		j_devious          = true,
		j_crafty           = true,
		
		j_half             = true,
		j_stencil          = true,
		j_four_fingers     = true,
		j_mime             = true,
		j_banner           = true,
		j_mystic_summit    = true,
		j_8_ball           = true,
		j_misprint         = true,
		j_dusk             = true,
		j_raised_fist      = true,       
		
		j_fibonacci        = true,
		j_steel_joker      = true,
		j_scary_face       = true,
		j_abstract         = true,
		j_hack             = true,
		j_pareidolia       = true,
		j_gros_michel      = true,
		j_even_steven      = true,
		j_odd_todd         = true,
		j_scholar          = true,
		j_business         = true,
		j_supernova        = true,
		j_space            = true,
		
		j_blackboard       = true,
		j_ice_cream        = true,
		j_dna              = true,
		j_splash           = true,
		j_blue_joker       = true,
		j_sixth_sense      = true,
		j_hiker            = true,
		j_faceless         = true,
		j_superposition    = true,
		j_todo_list        = true,
		
		j_cavendish        = true,
		j_card_sharp       = true,
		j_seance           = true,
		j_shortcut         = true,
		j_vagabond         = true,
		j_baron            = true,
		
		j_midas_mask       = true,
		j_luchador         = true,
		j_photograph       = true,
		j_turtle_bean      = true,
		j_erosion          = true,
		j_reserved_parking = true,
		j_mail             = true,
		j_juggler          = true,
		j_drunkard         = true,
		j_stone            = true,
		
		j_baseball         = true,
		j_bull             = true,
		j_diet_cola        = true,
		j_trading          = true,
		j_popcorn          = true,
		j_ancient          = true,
		j_ramen            = true,
		j_walkie_talkie    = true,
		j_selzer           = true,
		j_smiley           = true,
		
		j_ticket           = true,
		j_acrobat          = true,
		j_sock_and_buskin  = true,
		j_swashbuckler     = true,
		j_smeared          = true,
		j_hanging_chad     = true,
		j_rough_gem        = true,
		j_bloodstone       = true,
		j_arrowhead        = true,
		j_onyx_agate       = true,
		
		j_ring_master      = true,
		j_flower_pot       = true,
		j_blueprint        = true,
		j_merry_andy       = true,
		j_oops             = true,
		j_idol             = true,
		j_seeing_double    = true,
		j_matador          = true,
		j_duo              = true,
		j_trio             = true,
		j_family           = true,
		j_order            = true,
		j_tribe            = true,
		
		j_stuntman         = true,
		j_invisible        = true,
		j_brainstorm       = true,
		j_shoot_the_moon   = true,
		j_burnt            = true,
		j_bootstraps       = true,    
		j_triboulet        = true,
		j_chicot           = true,
		
		--ARS GOETIA
		j_arsGoetia_agares         = true,
		j_arsGoetia_vassago        = true,
		j_arsGoetia_gamigin        = true,
		j_arsGoetia_barbas         = true,
		j_arsGoetia_aamon          = true,
		j_arsGoetia_barbatos       = true,
		--j_arsGoetia_paimon         = true,
		--j_arsGoetia_sitri          = true,
		j_arsGoetia_beleth         = true,
		j_arsGoetia_leraje         = true,
		j_arsGoetia_eligos         = true,
		
		j_arsGoetia_zepar          = true,
		j_arsGoetia_botis          = true,
		j_arsGoetia_ipos           = true,
		--j_arsGoetia_aim            = true,
		j_arsGoetia_glasya_labolas = true,
		j_arsGoetia_berith         = true,
		j_arsGoetia_forneus        = true,
		
		j_arsGoetia_foras          = true,
		j_arsGoetia_marchosias     = true,
		j_arsGoetia_phenex         = true,
		j_arsGoetia_malthus        = true,
		j_arsGoetia_raum           = true,
		j_arsGoetia_focalor        = true,
		j_arsGoetia_vepar          = true,
		
		j_arsGoetia_vual           = true,
		j_arsGoetia_haagenti       = true,
		j_arsGoetia_crocell        = true,
		--j_arsGoetia_furcas         = true,
		j_arsGoetia_balam          = true,
		j_arsGoetia_allocer        = true,
		j_arsGoetia_camio          = true,
		j_arsGoetia_gremory        = true,
		j_arsGoetia_vapula         = true,
		
		j_arsGoetia_zagan          = true,
		j_arsGoetia_valac          = true,
		j_arsGoetia_andras         = true,
		j_arsGoetia_flauros        = true,
		j_arsGoetia_decarabia      = true,
		j_arsGoetia_dantalion      = true,
		j_arsGoetia_cain           = true,
		j_arsGoetia_satan          = true,
    },
})

-- ## HOOKS ##
--setup for illusion sticker
local set_cost_hook = Card.set_cost 
function Card.set_cost(self)
	ret = set_cost_hook(self)
	if self.ability.arsGoetia_illusion then
		self.sell_cost = 0
	end
	return ret
end

function Card:set_illusion(_illusion)
	self.ability.arsGoetia_illusion = true
    self:set_cost()
end


--as it turns out making half-planet levels is more complicated than just adapting one function for it
--function update_hand_text(config, vals)
--    G.E_MANAGER:add_event(Event({--This is the Hand name text for the poker hand
--    trigger = 'before',
--    blockable = not config.immediate,
--    delay = config.delay or 0.8,
--    func = function()
--        local col = G.C.GREEN
--        if vals.chips and G.GAME.current_round.current_hand.chips ~= vals.chips then
--            local delta = (type(vals.chips) == 'number' and type(G.GAME.current_round.current_hand.chips) == 'number') and (vals.chips - G.GAME.current_round.current_hand.chips) or 0
--            if delta < 0 then delta = ''..delta; col = G.C.RED
--            elseif delta > 0 then delta = '+'..delta
--            else delta = ''..delta
--            end
--            if type(vals.chips) == 'string' then delta = vals.chips end
--            G.GAME.current_round.current_hand.chips = vals.chips
--            G.hand_text_area.chips:update(0)
--            if vals.StatusText then 
--                attention_text({
--                    text =delta,
--                    scale = 0.8, 
--                    hold = 1,
--                    cover = G.hand_text_area.chips.parent,
--                    cover_colour = mix_colours(G.C.CHIPS, col, 0.1),
--                    emboss = 0.05,
--                    align = 'cm',
--                    cover_align = 'cr'
--                })
--            end
--        end
--        if vals.mult and G.GAME.current_round.current_hand.mult ~= vals.mult then
--            local delta = (type(vals.mult) == 'number' and type(G.GAME.current_round.current_hand.mult) == 'number')and (vals.mult - G.GAME.current_round.current_hand.mult) or 0
--            if delta < 0 then delta = ''..delta; col = G.C.RED
--            elseif delta > 0 then delta = '+'..delta
--            else delta = ''..delta
--            end
--            if type(vals.mult) == 'string' then delta = vals.mult end
--            G.GAME.current_round.current_hand.mult = vals.mult
--            G.hand_text_area.mult:update(0)
--            if vals.StatusText then 
--                attention_text({
--                    text =delta,
--                    scale = 0.8, 
--                    hold = 1,
--                    cover = G.hand_text_area.mult.parent,
--                    cover_colour = mix_colours(G.C.MULT, col, 0.1),
--                    emboss = 0.05,
--                    align = 'cm',
--                    cover_align = 'cl'
--                })
--            end
--            if not G.TAROT_INTERRUPT then G.hand_text_area.mult:juice_up() end
--        end
--        if vals.handname and G.GAME.current_round.current_hand.handname ~= vals.handname then
--            G.GAME.current_round.current_hand.handname = vals.handname
--            if not config.nopulse then 
--                G.hand_text_area.handname.config.object:pulse(0.2)
--            end
--        end
--        if vals.chip_total then G.GAME.current_round.current_hand.chip_total = vals.chip_total;G.hand_text_area.chip_total.config.object:pulse(0.5) end
--        if vals.level and G.GAME.current_round.current_hand.hand_level ~= ' '..localize('k_lvl')..tostring(vals.level) then
--            if vals.level == '' then
--                G.GAME.current_round.current_hand.hand_level = vals.level
--            else
--                G.GAME.current_round.current_hand.hand_level = ' '..localize('k_lvl')..tostring(vals.level)
--                if type(vals.level) == 'number' then 
--                    G.hand_text_area.hand_level.config.colour = G.C.HAND_LEVELS[math.min(math.floor(vals.level), 7)]
--                else
--                    G.hand_text_area.hand_level.config.colour = G.C.HAND_LEVELS[1]
--                end
--                G.hand_text_area.hand_level:juice_up()
--            end
--        end
--        if config.sound and not config.modded then play_sound(config.sound, config.pitch or 1, config.volume or 1) end
--        if config.modded then 
--            G.HUD_blind:get_UIE_by_ID('HUD_blind_debuff_1'):juice_up(0.3, 0)
--            G.HUD_blind:get_UIE_by_ID('HUD_blind_debuff_2'):juice_up(0.3, 0)
--            G.GAME.blind:juice_up()
--            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
--                play_sound('tarot2', 0.76, 0.4);return true end}))
--            play_sound('tarot2', 1, 0.4)
--        end
--        return true
--    end}))
--end
--
--
--function create_UIBox_current_hand_row(handname, simple)
--  return (G.GAME.hands[handname].visible) and
--  (not simple and
--    {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = darken(G.C.JOKER_GREY, 0.1), emboss = 0.05, hover = true, force_focus = true, on_demand_tooltip = {text = localize(handname, 'poker_hand_descriptions'), filler = {func = create_UIBox_hand_tip, args = handname}}}, nodes={
--      {n=G.UIT.C, config={align = "cl", padding = 0, minw = 5}, nodes={
--        {n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, colour = G.C.HAND_LEVELS[math.min(7, math.floor(G.GAME.hands[handname].level))], minw = 1.5, outline = 0.8, outline_colour = G.C.WHITE}, nodes={
--          {n=G.UIT.T, config={text = localize('k_level_prefix')..G.GAME.hands[handname].level, scale = 0.5, colour = G.C.UI.TEXT_DARK}}
--        }},
--        {n=G.UIT.C, config={align = "cm", minw = 4.5, maxw = 4.5}, nodes={
--          {n=G.UIT.T, config={text = ' '..localize(handname,'poker_hands'), scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
--        }}
--      }},
--      {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.BLACK,r = 0.1}, nodes={
--        {n=G.UIT.C, config={align = "cr", padding = 0.01, r = 0.1, colour = G.C.CHIPS, minw = 1.1}, nodes={
--          {n=G.UIT.T, config={text = G.GAME.hands[handname].chips, scale = 0.45, colour = G.C.UI.TEXT_LIGHT}},
--          {n=G.UIT.B, config={w = 0.08, h = 0.01}}
--        }},
--        {n=G.UIT.T, config={text = "X", scale = 0.45, colour = G.C.MULT}},
--        {n=G.UIT.C, config={align = "cl", padding = 0.01, r = 0.1, colour = G.C.MULT, minw = 1.1}, nodes={
--          {n=G.UIT.B, config={w = 0.08,h = 0.01}},
--          {n=G.UIT.T, config={text = G.GAME.hands[handname].mult, scale = 0.45, colour = G.C.UI.TEXT_LIGHT}}
--        }}
--      }},
--      {n=G.UIT.C, config={align = "cm"}, nodes={
--          {n=G.UIT.T, config={text = '  #', scale = 0.45, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
--        }},
--      {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.L_BLACK,r = 0.1, minw = 0.9}, nodes={
--        {n=G.UIT.T, config={text = G.GAME.hands[handname].played, scale = 0.45, colour = G.C.FILTER, shadow = true}},
--      }}
--    }}
--  or {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = darken(G.C.JOKER_GREY, 0.1), force_focus = true, emboss = 0.05, hover = true, on_demand_tooltip = {text = localize(handname, 'poker_hand_descriptions'), filler = {func = create_UIBox_hand_tip, args = handname}}, focus_args = {snap_to = (simple and handname == 'Straight Flush')}}, nodes={
--    {n=G.UIT.C, config={align = "cm", padding = 0, minw = 5}, nodes={
--        {n=G.UIT.T, config={text = localize(handname,'poker_hands'), scale = 0.5, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
--    }}
--  }})
--  or nil
--end