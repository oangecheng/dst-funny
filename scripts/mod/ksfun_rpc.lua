AddModRPCHandler(
	"ksfun_rpc",
	"taketask",
	function(publisher, player, taskid)
		publisher.ksfun_take_task(publisher, player, taskid)
	end
)