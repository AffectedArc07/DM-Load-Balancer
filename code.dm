var/list/server_list = list()

/proc/load_servers()
	var/list/lines = splittext(file2text("servers.txt"), "\n")
	for(var/line in lines)
		if(length(line) == 0)
			continue
		else if(copytext(line, 1, 2) == "#")
			continue
		server_list |= line

/world/New()
	load_servers()
	world.log << "Initialized. Server count: [length(server_list)]"


/client/New()
	world.log << "[ckey] connected. Polling servers."
	var/list/polled = list()
	for(var/server in server_list)
		polled[server] = text2num(world.Export("byond://[server]?ping"))
		world.log << "[server] polled [polled[server]] players"

	var/lowest_playercount_server
	var/lowest_playercount = 999999 // If we ever get a server with almost 1 million people on, this program will break
	for(var/server in polled)
		if(polled[server] < lowest_playercount)
			lowest_playercount = polled[server]
			lowest_playercount_server = server

	world.log << "[lowest_playercount_server] has [lowest_playercount] online. Routing [ckey] to there"
	src << link("byond://[lowest_playercount_server]")
	del(src)