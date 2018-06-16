
-- Outlaw
local _BladeFlurry = 13877;
local _RolltheBones = 193316;
local _TrueBearing = 193359;
local _SharkInfestedWaters = 193357;
local _GhostlyStrike = 196937;
local _CurseoftheDreadblades = 202665;
local _AdrenalineRush = 13750;
local _MarkedforDeath = 137619;
local _RunThrough = 2098;
local _Broadsides = 193356;
local _PistolShot = 185763;
local _Opportunity = 195627;
local _SaberSlash = 193315;
local _Vanish = 1856;
local _Ambush = 8676;
local _CheapShot = 1833;
local _PreyontheWeak = 131511;
local _DeeperStratagem = 193531;
local _JollyRoger = 199603;
local _GrandMelee = 193358;
local _BuriedTreasure = 199600;
local _SliceandDice = 5171;
local _DeathfromAbove = 152150;
local _Vigor = 14983;
local _CombatPotency = 35551;
local _Bloodlust = 2825;
local _Heroism = 32182;
local _TimeWarp = 80353;
local _Ruthlessness = 14161;
local _Sprint = 2983;
local _BetweentheEyes = 199804;
local _Blind = 2094;
local _CloakofShadows = 31224;
local _Riposte = 199754;
local _GrapplingHook = 195457;
local _CannonballBarrage = 185767;
local _KillingSpree = 51690;
local _Feint = 1966;
local _Elusiveness = 79008;
local _CheatDeath = 31230;
local _CrimsonVial = 185311;
local _Stealth = 1784;
local _HiddenBlade = 202753;
local _Garrote = 202753;
local _Kingsbane = 202753;
local _ToxicBlade = 202753;
local _Envenom = 202753;
local _Mutilate = 202753;
local _Rupture = 1943;

-- Subtlety
local _Nightblade = 195452;
local _ShadowBlades = 121471;
local _ShadowDance = 185313;
local _EnvelopingShadows = 206237;
local _Shadowstrike = 185438;
local _Anticipation = 114015;
local _MasterofShadows = 196976;
local _SymbolsofDeath = 212283;
local _GoremawsBite = 209783;
local _Eviscerate = 196819;
local _Backstab = 53;


-- Auras
local _Stealth = 1784;
local _GreenskinsWaterloggedWristcuffs = 209420;
local _MasterAssassinsInitiative = 235022;

-- Talents
local _isGhostlyStrike = false;
local _isMarkedforDeath = false;
local _isAnticipation = false;
MaxDps.Rogue = {};

function MaxDps.Rogue.CheckTalents()
    MaxDps:CheckTalents();
    _isGhostlyStrike = MaxDps:HasTalent(_GhostlyStrike);
    _isMarkedforDeath = MaxDps:HasTalent(_MarkedforDeath);
    _isAnticipation = MaxDps:HasTalent(_Anticipation);
end

function MaxDps:EnableRotationModule(mode)
    mode = mode or 1;
    MaxDps.Description = 'Rogue [Outlaw]';
    MaxDps.ModuleOnEnable = MaxDps.Rogue.CheckTalents;
    if mode == 1 then
        MaxDps.NextSpell = MaxDps.Rogue.Assassination;
    end;
    if mode == 2 then
        MaxDps.NextSpell = MaxDps.Rogue.Outlaw;
    end;
    if mode == 3 then
        MaxDps.NextSpell = MaxDps.Rogue.Subtlety;
    end;
end

function MaxDps.Rogue.Assassination()
    local timeShift, currentSpell, gcd = MaxDps:EndCast();
    local energy = UnitPower('player', SPELL_POWER_ENERGY);
    local combo = GetComboPoints('player', 'target');

    MaxDps:GlowCooldown(_Vendetta, MaxDps:SpellAvailable(_Vendetta, timeShift));
    
    if MaxDps:PersistentAura(_Stealth, timeShift) then
        return _Garrote;
    end
    
    if MaxDps:SpellAvailable(_Rupture, timeShift) and combo == 5 then
        return _Rupture;
    end      
    
    if MaxDps:SpellAvailable(_Garrote, timeShift) then
        return _Garrote;
    end  

    if MaxDps:SpellAvailable(_Kingsbane, timeShift) then
        return _Kingsbane;
    end

    if MaxDps:SpellAvailable(_ToxicBlade, timeShift) then
        return _ToxicBlade;
    end  

    if MaxDps:SpellAvailable(_Envenom, timeShift) and combo >=4 then
        return _Envenom;
    end    

    if MaxDps:SpellAvailable(_Mutilate, timeShift) then
        return _Mutilate;
    end      
    
    if talents[_Nightstalker] and combo == 5 then
        return _Vanish;
    end

end

function MaxDps.Rogue.Outlaw()
    local timeShift, currentSpell, gcd = MaxDps:EndCast();

    local energy = UnitPower('player', SPELL_POWER_ENERGY);
    local combo = GetComboPoints('player', 'target');

    MaxDps:GlowCooldown(_AdrenalineRush, MaxDps:SpellAvailable(_AdrenalineRush, timeShift));
    MaxDps:GlowCooldown(_CurseoftheDreadblades, MaxDps:SpellAvailable(_CurseoftheDreadblades, timeShift));
    MaxDps:GlowCooldown(_KillingSpree, MaxDps:SpellAvailable(_KillingSpree, timeShift));

    if MaxDps:PersistentAura(_Stealth, timeShift) then
        return _Ambush;
    end

    local curse = MaxDps:Aura(_CurseoftheDreadblades, timeShift, 'HARMFUL');

    -- roll the bones auras
    local rb = {
        TB = MaxDps:Aura(_TrueBearing, timeShift + 3),
        SIW = MaxDps:Aura(_SharkInfestedWaters, timeShift + 3),
        JR = MaxDps:Aura(_JollyRoger, timeShift + 3),
        GM = MaxDps:Aura(_GrandMelee, timeShift + 3),
        BS = MaxDps:Aura(_Broadsides, timeShift + 3),
        BT = MaxDps:Aura(_BuriedTreasure, timeShift + 3),
    }
    -- buty, sprint co CD
    local rbCount = 0;
    for k, v in pairs(rb) do
        if v then
            rbCount = rbCount + 1;
        end
    end

    local shouldRoll = not rb.TB and rbCount < 2;

    if shouldRoll and combo >=4 and energy >= 20 then
        return _RolltheBones;
    end

    if _isGhostlyStrike and not MaxDps:TargetAura(_GhostlyStrike, timeShift + 3) and energy > 27 then
        return _GhostlyStrike;
    end

    if _isMarkedforDeath and combo < 2 and MaxDps:SpellAvailable(_MarkedforDeath, timeShift) then
        return _MarkedforDeath;
    end
    
    if combo >= 5 and MaxDps:Aura(_GreenskinsWaterloggedWristcuffs, timeShift) and MaxDps:Aura(_MasterAssassinsInitiative, timeShift) then
        return _BetweentheEyes;
    end

    if (combo >= 6 or (combo >= 5 and rb.BS)) then
        return _RunThrough;
    end

    if MaxDps:Aura(_Opportunity, timeShift) and combo <= 4 then
        return _PistolShot;
    end

    return _SaberSlash;
end

function MaxDps.Rogue.Subtlety()
    local timeShift, currentSpell, gcd = MaxDps:EndCast();
    local ShadowDancecd, ShadowDancecurrentCharges, ShadowDancemaxCharges = MaxDps:SpellCharges(_ShadowDance, timeShift)
    local energy = UnitPower('player', SPELL_POWER_ENERGY);
    local combo = GetComboPoints('player', 'target');
    
    --Use Shadowstrike as long you are Stealthed and have less than 5 combo points (7 with Anticipation).
    if _isAnticipation and MaxDps:PersistentAura(_Stealth, timeShift) and combo <= 7 then
        return _Shadowstrike;
    elseif MaxDps:PersistentAura(_Stealth, timeShift) and combo <= 5 then
        return _Shadowstrike;
    end

    --1.Maintain Nightblade.
    if MaxDps:SpellAvailable(_Nightblade, timeShift) and not MaxDps:Aura(_Nightblade, timeShift) then
        return _Nightblade;
    end
    
    --2.Activate Shadow Blades if available.
    if MaxDps:SpellAvailable(_ShadowBlades, timeShift) then
        return _ShadowBlades;
    end

    --3.Enter Shadow Dance if you have 2 charges, or there is less than 20 seconds remaining before you get your second charge (3 charges and 30 seconds for Enveloping Shadows).
    --Shadow Dance should be activated as close to Energy cap as possible (80 with Master of Shadows).
    --Use Shadowstrike as long you are Stealthed and have less than 5 combo points (7 with Anticipation).
    if _isEnvelopingShadows and (ShadowDancecurrentCharges = 3 and ShadowDancecd <= 30 and energy >= 80) then
        return _ShadowDance;
    elseif ShadowDancecurrentCharges = 2 and energy >= 80 or (ShadowDancecurrentCharges = 1 and ShadowDancecd <= 20 and energy >= 80) then
        return _ShadowDance;
    end

    --4.Activate the Symbols of Death buff in combination with at least 1 Shadow Dance charge and Death from Above when you are below 60 Energy.
    if MaxDps:SpellAvailable(_SymbolsofDeath, timeShift) and ShadowDancecurrentCharges >= 1 and energy <= 60 then
        return _SymbolsofDeath;
    end
    
    if isDeathfromAbove then
        return _DeathfromAbove;
    end
    
    --5.Activate Vanish and then Shadowstrike when available if you are at or below 3 Combo Points.
    if combo <= 3 then
        return _Vanish;
    end

    --6.Cast Goremaw's Bite Icon Goremaw's Bite if you are not in Stealth or Shadow Dance, at or below 3 Combo Points, and have less than 50 Energy.
    if MaxDps:SpellAvailable(_GoremawsBite, timeShift) and not MaxDps:PersistentAura(_Stealth, timeShift) and not MaxDps:PersistentAura(_ShadowDance, timeShift) and combo <= 3 and energy <= 50 then
        return _GoremawsBite;
    end
        
    --7.Cast Death from Above at 5+ Combo Points. Always combine with Shadow Dance and Symbols of Death.
    if combo >= 5 and MaxDps:Aura(_ShadowDance, timeShift) and MaxDps:Aura(_SymbolsofDeath, timeShift) then
        return _DeathfromAbove;
    end
    
    --8.Cast Eviscerate to spend Combo Points with 5+.
    if combo >= 5
        return _Eviscerate;
    end
    
    --9.Cast Backstab to generate Combo Points (from behind the target whenever possible).
    return _Backstab;

end
