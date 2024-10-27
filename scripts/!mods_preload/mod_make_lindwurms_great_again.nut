::ModMakeLindwurmsGreatAgain <- {
	ID = "mod_make_lindwurms_great_again",
	Name = "Make Lidwurms Great Again",
	Version = "0.1.1",
}

local mod = ::Hooks.register(::ModMakeLindwurmsGreatAgain.ID, ::ModMakeLindwurmsGreatAgain.Version, ::ModMakeLindwurmsGreatAgain.Name);

mod.require("mod_msu >= 1.2.6", "mod_modern_hooks >= 0.4.0");

mod.queue(">mod_msu", ">mod_modern_hooks", ">mod_legends", ">mod_sellswords", function() {
	::ModMakeLindwurmsGreatAgain.Mod <- ::MSU.Class.Mod(::ModMakeLindwurmsGreatAgain.ID, ::ModMakeLindwurmsGreatAgain.Version, ::ModMakeLindwurmsGreatAgain.Name);
	::ModMakeLindwurmsGreatAgain.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/chopeks/MakeLindwurmsGreatAgain");
	::ModMakeLindwurmsGreatAgain.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	local hasLegends = ::mods_getRegisteredMod("mod_legends") != null;
	local hasSSU = ::mods_getRegisteredMod("mod_sellswords") != null;

	local dragons = [
		"lindwurm_tail"
	]
	if (hasLegends) {
		dragons.extend(["legend_stollwurm_tail"]);
	}
	if (hasSSU) {
		dragons.extend(["dryad_lindy_tail"]);
	}

	foreach(dragon in dragons) {
		mod.hook("scripts/entity/tactical/enemies/" + dragon, function(q) {
			q.create = @(__original) function() {
				__original();
				this.getFlags().add("tail");
			};
			q.onDeath =  @(__original) function(_killer, _skill, _tile, _fatalityType) {
				__original(null, _skill, _tile, _fatalityType);
			}
			q.kill = @(__original) function(_killer = null, _skill = null, _fatalityType = this.Const.FatalityType.None, _silent = false ) {
				this.actor.kill(null, _skill, _fatalityType, _silent);
				if (this.m.Body != null && !this.m.Body.isNull() && this.m.Body.isAlive() && !this.m.Body.isDying()) {
					this.m.Body.kill(_killer, _skill, _fatalityType, _silent);
					this.m.Body = null;
				}
			}
		});
	}

	mod.hook("scripts/entity/tactical/tactical_entity_manager", function(q) {
		q.getHostilesNum = @(__original) function() {
			local count = __original();
			if (!::Tactical.State.isScenarioMode()) {
				for (local i = 0; i != ::World.FactionManager.getFactions().len(); i++) {
					if (!::World.FactionManager.isAlliedWithPlayer(i)) {
						for (local j = 0; j != this.m.Instances[i].len(); j++) {
							if (this.m.Instances[i][j].getFlags().has("tail")) {
								count = count - 1;
							}
						}
					}
				}
			}
			return count;
		}
	});

	::include("mod_make_lindwurms_great_again/hooks/config/faction_beasts.nut");
});