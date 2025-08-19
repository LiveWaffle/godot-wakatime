@tool
extends EditorPlugin

var API_KEY = ""

func sendHeartBeat():
	var projectName = ProjectSettings.get_setting("application/config/name")
	var heartbeatInterval = 30
	var inactiveThreshold = 30
	# this goes all the way back to the user directory idk it was easier this way
	var currentUser = OS.get_user_data_dir()
	var wakatimeExePath = currentUser + "/../../../../../.wakatime/wakatime-cli.exe"
	var wakatimeExe = wakatimeExePath.simplify_path()
	var output = []
	var wakatimeConfigPath = currentUser + "/../../../../../"
	var wakatimeConfigPathSimple = wakatimeConfigPath.simplify_path()
	var fileOpen = FileAccess.open(wakatimeConfigPath+".wakatime.cfg", FileAccess.READ)
	var fileContents = fileOpen.get_as_text()
	var splitFileContents = fileContents.split("\n")
	print("starting for loop")
	for line in splitFileContents:
		if line.find("api_key") != -1:
			var equalPosition = line.find("=")
			API_KEY = line.substr(equalPosition+2,equalPosition+36)
			
			
	print("The simple config path is: "+ str(wakatimeConfigPathSimple))
	var currentTime = Time.get_unix_time_from_system()
	var args = ["--key", API_KEY, "--entity", projectName, "--time", str(currentTime), "--write", "--plugin", "godot-wakatime/0.0.1", "--alternate-project", projectName, "--category", "designing", "--language", "Godot", "--is-unsaved-entity"]

	print(args)
	OS.execute(wakatimeExe, args, output, true)
	#print(output)
	print(wakatimeExePath)
	
	# print(currentTime)
	print("debug")



func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	sendHeartBeat()
	pass





func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
