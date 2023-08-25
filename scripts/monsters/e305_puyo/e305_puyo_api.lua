local Puyo = setmetatable({}, include("scripts/monsters/e305_puyo/e305_puyo_core"))

Puyo.PuyoSkills = include("scripts/monsters/e305_puyo/e305_puyo_skills")
Puyo.PuyoSpecific = include("scripts/monsters/e305_puyo/e305_puyo_specific")

return Puyo