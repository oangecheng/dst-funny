AddModRPCHandler(
	"ksfun_rpc",
	"taketask",
	function(publisher, player, taskid)
		publisher.ksfun_take_task(publisher, player, taskid)
	end
)


AddModRPCHandler(
	"ksfun_rpc",
	"giveuptask",
	function(player, taskid)
		player.ksfun_giveup_task(player, taskid)
	end
)