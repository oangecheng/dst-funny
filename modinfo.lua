-- 判断是否是中文
local ch = locale == "zh" or locale == "zhr"

-- 名称
name = ch and "更好玩的饥荒！" or "funny dst"

-- 描述
description = ch and
[[
    更好玩的饥荒！
]] 
or
[[ 
    funny dst!
]]

-- 作者
author = "Zax"
-- 版本
version = "0.1.0"
-- klei官方论坛地址，为空则默认是工坊的地址
forumthread = ""
-- modicon 下一篇再介绍怎么创建的
-- icon_atlas = "images/modicon.xml"
-- icon = "images/modicon.tex"
icon_atlas = "modicon.xml"
icon = "modicon.tex"
-- dst兼容
dst_compatible = true
-- 是否是客户端mod
client_only_mod = false
-- 是否是所有客户端都需要安装
all_clients_require_mod = true
-- 饥荒api版本，固定填10
api_version = 10



-- mod的配置项，后面介绍
configuration_options = {

    -- 难度配置，支持3种难度
	{
		name  = "diffculty",
		label = ch and "难度" or "diffculty",
		options = {
			{description = ch and "简单" or "easy",    data = -1},
			{description = ch and "默认" or "default", data = 0 },
            {description = ch and "困难" or "hard",    data = 1 },
		},
		default = 0,
	},

    -- 玩法模式设置
    -- 默认竞争模式，角色和物品属性有获取次数限制
    -- 娱乐模式没有限制
    {
        name  = "mode",
        label = ch and "模式" or "mode",
        options = {
            { description = ch and "娱乐" or "entertainment", data = 0 },
            { description = ch and "竞争" or "competition",   data = 1 },
        },
        default = 1
    },
}