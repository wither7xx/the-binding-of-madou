local CM_EID_Desc_zh_cn = {}

local modCollectibleType = tbom.modCollectibleType
local modTrinketType = tbom.modTrinketType
local modPlayerType = tbom.modPlayerType

local lang = "zh_cn"

CM_EID_Desc_zh_cn.Collectibles = {
	--[[
	[modCollectibleType.XXX] = {
		Name = "",
		Description = "",
		bookOfVirtuesWisps = "",
		bookOfBelialBuffs = "",
	},
	]]
	[modCollectibleType.COLLECTIBLE_BLUE_GRIMOIRE] = {
		Name = "蓝色魔导书",
		Description = "持有时，角色遇到的基础掉落物有几率被转化为魔导力#使用后，消耗5点魔导力，当前房间内获得随机法术效果#{{Player"..modPlayerType.PLAYER_ARLENADJA.."}}阿露露可以同时拥有8种法术",
		bookOfVirtuesWisps = "火炎术：爆炸泪弹；冰冻术：减速泪弹；闪电术：激光泪弹#{{Player"..modPlayerType.PLAYER_ARLENADJA.."}}只对以下法术有效：治疗术：20%几率杀怪掉落红心；二阶强化术：灰色普通灵火；繁花乱象：7.5%几率发射标记泪弹；荆棘障壁：护盾灵火",
		bookOfBelialBuffs = "x130%魔法伤害",
	},
	[modCollectibleType.COLLECTIBLE_PUYO_HAT] = {
		Name = "噗哟帽",
		Description = "噗哟不再发射子弹，接触噗哟时不再受到伤害#噗哟生成几率+15%#{{Damage}} 凝胶提供的属性加成x500%",
	},
	[modCollectibleType.COLLECTIBLE_WORMHOLE_APPLE] = {
		Name = "虫洞苹果",
		Description = "限时答题，全部答完可领取奖励#在规定时间内答对的题目越多，则奖励的品质越高",
		bookOfVirtuesWisps = "答题后生成错误灵火",
	},
	[modCollectibleType.COLLECTIBLE_HEART_SHAPED_COOKIE] = {
		Name = "心形饼干",
		Description = "不再受到接触伤害#{{Player"..PlayerType.PLAYER_MAGDALENE_B.."}}堕化抹大拉：50%几率#!!! 对堕化以扫无效",
	},
	[modCollectibleType.COLLECTIBLE_GREEN_GRIMOIRE] = {
		Name = "绿色魔导书",
		Description = "{{Player"..modPlayerType.PLAYER_ARLENADJA.."}}解锁禁断法术“气爆弹”",
	},
}

CM_EID_Desc_zh_cn.Trinkets = {
	[modTrinketType.TRINKET_ANOTHER_CARTRIDE] = {
		Name = "另一张游戏卡带",
		Description = "在每层随机一个普通房间内的随机位置生成外星联络点#在外星联络点上引爆炸弹可重置并重新开始所在楼层#!!! 除非站在附近，否则外星联络点完全隐形",
	},
}

CM_EID_Desc_zh_cn.Birthrights = {
	[modPlayerType.PLAYER_ARLENADJA] = {
		Description = "进入新房间时，快速击杀敌怪可获得额外经验值#最多可获得3倍的经验值",
		PlayerName = "阿露露·娜嘉",
		--PlayerName = "亚鲁鲁·纳贾",
	},
}

return CM_EID_Desc_zh_cn
