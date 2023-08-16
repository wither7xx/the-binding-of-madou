The Binding of Madou
Beta v0.1.1
6/3/2023

==CREDITS==
Coder: 
wither2x

Designers: 
Sadship
wither2x

Sprites:
Taoyufei
wither2x

==Introduction==
This is a fan-made mod based on Madou Monogatari and Puyo Puyo series, which features 1 new player, 2 new items and 1 new challenge.
This mod is still under development. More new content is planned to be added soon, including collectibles, trinkets, characters, bosses, and story.
The program part of this mod needs to be improved. You are welcome to make suggestions for its improvement.
This mod supports local co-op mode and controller.
This mod has compatibility with External Item Descriptions and Mod Config Menu.

==New Character==
◇Arle Nadja
  ▷Starting attributes
    Health: 3 red hearts
    Speed: 0.9
    Tears: 2.53
    Damage: 3
    Range: 5.5
    Shot Speed: 1
    Luck: 0
  ▷Starting items
    Blue grimoire (Pocket active item)
    x20 Mana points
  ▷Features
   ▷Level & exp
    Killing enemies grants exp points to the player. The player levels up when reaches a certain amount of exp points.
    The amount of exp points obtained is related to the max health point of the enemy. Champion enemies grant 1 bonus exp point on death.
    When levels up, all red hearts and mana points will be restored, and the player will gain mp cap increase and 1 random stat increase. The possibilities include:
	+0.2 Flat damage
	+0.1 Tears up
	+0.5 Range up
	+0.05 Speed up
	+0.2 Luck up
    If the player reaches Lv.15, opens the door to the Boss Rush regardless of the timer. If the player reaches Lv.25, opens the door to the Blue Womb regardless of the timer.
   ▷Critical hit
    The player has a chance to cause a critical hit when deals damage to enemies. Critical hit deals 200% player's Damage.
    The player has 4% Critical Chance at the start of a new run.
    The Critical Chance is positively correlated with player's Luck, with a minimum of 1%. The Teardrop Charm grants +3% Critical Chance to player.
   ▷Compatibilities:
    ·Blue Grimoire
    While held: Hearts, Coins, bombs and keys have 1/10 chance to be replaced into mana pickups, restores 20 mp after picked up. However, the mp won't be restored automatically after cleaning a room.
	Monsters have 5% chance to drop mana pickups on death if player's mp is less than 15%.
    The player can held 8 different spells.
    	Press L Alt or R Ctrl (or D-pad Left or D-pad Right on controller) to switch among these spells. If you are using keyboard, you can use the number keys (1~8) to select and use a spell directly.
    	Fire (Phase 1) and Ice Storm (Phase 1) will be unlocked automatically at the start of a new run. Other spells will be unlocked if the player reachs a certain level or has certain items or kills cettain bosses.
    On use, consumes several mp and grants the selected spell effect.It takes some spells few time to recharge before the player can use them again.
    The spells Arle can use are introduced in further detail below.
	·Fire (Will be unlocked at the start of a new run; reach Lv.7, Lv.16, and Lv.26 to upgrade)
	 Type: Aggressive
	 Effects:
	 Phase 1: The player has a chance to fire tears that burn enemies.
	 Phase 2: Grants player a chance to shoot fires alongside the regular tears. Grants immunity to fire.
	 Phase 3: Lights all enemies on fire on use. Grants immunity to explosions.
	 Phase 4: The player always fires buring tears.
	 Increases Luck if the player has Fire Mind.
	·Ice Storm (Will be unlocked at the start of a new run; reach Lv.9, Lv.18, and Lv.28 to upgrade)
	 Type: Aggressive
	 Effects:
	 Phase 1: The player has a chance to fire tears that slow enemies.
	 Phase 2: Grants player a chance to fire iced tears like Uranus.
	 Phase 3: Freezes all enemies on use.
	 Phase 4: The player always fires iced tears.
	 Increases Tears if the player has Uranus.
	·Thunder (Reach Lv.5, Lv.11, Lv.22, and Lv.30 to unlock or upgrade)
	 Type: Aggressive
	 Effects:
	 Phase 1: Fire static tears like Technology Zero.
	 Phase 2: Fire electric tears like Jacob's Ladder.
	 Phase 3: Grants player a chance to fire confusion tears.
	 Phase 4: Grants player a chance to fire petrifying tears.
	 Increases Damage if the player has Technology Zero or Jacob's Ladder.
	·Healing (Reach Lv.2 to unlock)
	 Type: Defensive
	 Effects:
	 Heals one red heart on use. Grants a half soul heart at full hp.
         In co-op mode, heals all other co-op players for one red heart.
	·Diacute (Reach Lv.3, Lv.13, Lv.24 or defeat Mom's Heart (or It Lives!) to unlock or upgrade)
	 Type: Special
	 Effects:
	 Spawns a light orb orbital that mimic the player's shoot direction and tears. Lasts for 30 seconds.
	 The tears will inherite all tear effects of player except special weapons like Brimstone and Mom's Knife.
	 The upper limit of the amount of orbs equivalent to the phase of this spell. The player may only have up to 4 orbs within a spell cycle.
	 Compatibilities with other spells:
	    Healing: Decrease the recharging time of Healing spell.
	    Bayoen: If the enemies have a tainted veasion, the spell has a chance to morphs them into tainted versions before charming them. It is invalid for the enemies spawned by bosses.
	    Revia: Stacks multiple Holy Mantle effects to player. Deals more damage to enemies when the Holy Mantle is broken.
	    Jugem: Grants immunity to explosions.
	·Bayoen (Reach Lv.14 to unlock)
	 Type: Defensive
	 Effects:
	 Adds a permanent charmed effect to all enemies. They will follow the player to different rooms.
	 The bosses and enemies spawned by bosses makes the effect temporary instead.
	·Revia (Reach Lv.20 to unlock)
	 Type: Defensive
	 Effects:
	 Grants a temporary Holy Mantle effect for current room. Makes player invincible for 10 seconds if the player already has Holy Mantle effect.
	 When the Holy Mantle is broken, deals 30 + 5 * player's Damage to all enemies.
	·Jugem (Obtain the Green Grimoire to unlock)
	 Type: Lock-on
	 Effects:
	 On use, spawns a cone of laser sight to shine from the player's chest in the direction they're facing, which causes a lock-on target mark on the enemies that are within it. Enemies can be targeted repeatedly if they have enough hp.
	 On use again, summons a missile to the position of targeted enemy. Missiles deal 2000% player's damage.
	 Up to 4 enemies will be targeted with each use. The laser sight will turn red when the maximum amount of targets is reached.
	 Grants immunity to explosions if the player has Epic Fetus.
    ▷Book of Virtues
     Wisp type depends on current spell (Defensive and Special only):
	Healing: 20% chance for enemy to drop heart on kill like Yum Heart.
	Diacute: 7.5% chance for Mark tears like Best Friend.
	Bayoen: Adds a grey normal wisp.
	Revia: Immune to projectiles like Book of Shadows.
    ▷Birthright
     Description: Flash shoot exam
     Effects: Increases the amount of exp points by up to 300% if enemies are quickly killed when entering a new room.

==New Items==
◇Blue Grimoire
  Description: Let's start learning magic!
  Quality: 3
  Type: Active item
  Charges: N/A
  Item Pools: Treasure Room, Library
  ▷▷Effects
    On pickup, grants 5 mp and 15 mp cap.
    While held: Hearts, Coins, bombs and keys have 1/24 chance to be replaced into mana pickups, restores 5 mp after picked up. Restores 1 mp after clearing a room.
	Monsters have 5% chance to drop mana pickups on death.
    On use, consumes 5 mp and grants one of the following spell effects:
	Fire: Player's tears have burning effect. Having the same effect increases Luck instead.
	Ice: Player's tears have slow and iced effect. Having the same effect increases Tears instead.
	Thunder: Player's tears have static and electric effect. Having the same effect increases Damage instead.
  ▷Compatibilities
	Bethany: Soul charges can be consumed as mp.
	Tainted Bethany: Blood charges can be consumed as mp.
    	Alre Nadja: See the character information above for details.
	The Battary: Increases the mp cap to 30.
	Void: No longer consumes mp to trigger the spell effects. Consumes the charge of Void instead. 
	Book of Virtues: Wisp type depends on current spell:
	  Fire: Fires explosive tears like Kamikaze.
	  Ice: Fires slow tears like Spider Butt.
	  Thunder: Fires laser tears like the redstone wisp of Notched Axe.
	Judas & Birthright: x130% magic damage.
◇Green Grimoire
  Description: Magic power up!
  Quality: 3
  Type: Passive item
  Item Pools: None
  Method of obtaining: Enemies from Depth II or Mausoleum II onwards have 1/200 chance (1/180 instead in hard mode) to grant this item on death if the character can unlock related spells.
    ·In co-op mode, this chance will be increased if there are more characters who meet the requirements.
  ▷Effects
    If the character is Arle Nadja, unlocks Jugem. 
    See the character information above for details.

==New Challenge==
◇Meteor Shower
  ▷Character: Arle Nadja
  ▷Starting items: Blue Grimoire (Pocket active item), Green Grimoire
  ▷Goal: Chest
  ▷Forbidden rooms: Treasure Room
  ▷Forbidden items: Epic Fetus, Pyromaniac, Host Hat
  ▷Special rules:
    Player is blindfolded in this challenge.
    Player has infinite mp in this challenge.
    All spells except Jugem are not available in this challenge.

==Misc==
◇Debug Console Command
  ▷tbom_debug
    Syntax: tbom_debug [rule] (tdb [rule])
    Effect: Enables/Disables various cheats.
    Parameters ([rule]): 
      No parameters: Lists available parameters.
      1：Infinite MP: Using spells does not cost the player's mp.
      2：No Spell CD: Removes the recharge countdown of spells.
      3：High Exp Multipler: Increases the amount of exp points by 500%.