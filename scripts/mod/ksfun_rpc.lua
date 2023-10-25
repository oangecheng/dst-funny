AddModRPCHandler(
	"ksfun_rpc",
	"taketask",
	function(player, taskid)
		TheWorld:ksfun_take_task(player, taskid)
	end
)