@tool
extends EditorPlugin

var API_KEY = ""
var wakatimeExePath = ""
var currentUser = OS.get_user_data_dir()
var heartbeatInterval = 30
var inactiveTime = 30
var output = []
var activeTime = Time.get_unix_time_from_system()

func sendHeartBeat():
	var projectName = ProjectSettings.get_setting("application/config/name")
	# this goes all the way back to the user directory idk it was easier this way
	var wakatimeExe = wakatimeExePath.simplify_path()
	var wakatimeConfigPath = currentUser + "/../../../../../"
	var wakatimeConfigPathSimple = wakatimeConfigPath.simplify_path()
	var fileOpen = FileAccess.open(wakatimeConfigPath+".wakatime.cfg", FileAccess.READ)
	var fileContents = fileOpen.get_as_text()
	var splitFileContents = fileContents.split("\n")
	print(wakatimeExe)
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

func getCurrentCpuPlatform():
	var cpuArch = Engine.get_architecture_name()
	print("Debug Arcitecture " + cpuArch)
	var currentOs = OS.get_name()
	print("Debug OS: " + currentOs)
	if currentOs == "Windows":
		if cpuArch == "x86_64":
			wakatimeExePath = currentUser + "/../../../../../.wakatime/wakatime-cli-windows-amd64.exe"
		elif cpuArch == "arm64":
			wakatimeExePath = currentUser + "/../../../../../.wakatime/wakatime-cli-windows-arm64.exe"
	elif currentOs == "Darwin":
		print("darwin")
	elif currentUser == "Linux":
		print("Linux")

func detectActivity():
	activeTime = Time.get_unix_time_from_system()
	if activeTime > inactiveTime - activeTime:
		print("User is active")
	else:
		sendHeartBeat()
		detectActivity()

func _enter_tree() -> void:
	getCurrentCpuPlatform()
	detectActivity()
	pass



# i fucking hate godot what is this language

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
