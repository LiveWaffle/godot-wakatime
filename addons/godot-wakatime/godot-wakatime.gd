@tool
extends EditorPlugin

var API_KEY = ""
var wakatimeExePath = ""
var currentUser = OS.get_user_data_dir()
var heartbeatInterval = 30
var inactiveTime = 30
var output = []
var activeTime = Time.get_unix_time_from_system()
var timer: Timer = null
var scriptEditor = get_editor_interface().get_script_editor()
var currentCurPosition: String = ""
var lines = ""
func getCurrentCursorPosition() -> Array:
	var scriptEditor = get_editor_interface().get_script_editor()
	if not scriptEditor:
		return [0,0]
	var currentEditor = scriptEditor.get_current_editor()
	if not currentEditor:
		return [0,0]
	
	var textEdit = findTextEditRecursive(currentEditor)
	if textEdit:
		var line = textEdit.get_caret_line(0)
		var column = textEdit.get_caret_column(0)
		var lines = textEdit.get_line_count()
		return [line, column, lines]
	return [0,0]

func findTextEditRecursive(node: Node) -> TextEdit:
	if node is TextEdit:
		return node
	for child in node.get_children():
		var found = findTextEditRecursive(child)
		if found:
			return found
	return null

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
	var cursorPos = getCurrentCursorPosition()
	var lineNumber = cursorPos[0]
	var columnNumber = cursorPos[1]
	var totalLines = cursorPos[2]
	print("The Current cursor position is "+ currentCurPosition)
	var args = ["--key", API_KEY,
				"--entity", projectName, 
				"--time", str(currentTime), 
				"--write", "--plugin", 
				"godot-wakatime/0.0.1", 
				"--alternate-project", projectName, 
				"--category", "designing", 
				"--language", "Godot", 
				"--is-unsaved-entity", 
				"--cursorpos", str(columnNumber), 
				"--lineno", str(lineNumber), 
				"-lines", totalLines]

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
	elif currentOs == "macOS":
		if cpuArch == "x86_64":
			wakatimeExePath = currentUser + "/../../../../../.wakatime/wakatime-cli-darwin-amd64"
		elif cpuArch == "arm64":
			wakatimeExePath = currentUser + "/../../../../../.wakatime/wakatime-cli-darwin-arm64"
	elif currentOs == "Linux":
		print("Fuck Linux")

func detectActivity():
	if Time.get_unix_time_from_system() - activeTime < inactiveTime:
		sendHeartBeat()
	else:
		print("Skipping")


func updateCurrentTime():
	activeTime = Time.get_unix_time_from_system()


func startTimer():
	if timer == null:
		timer = Timer.new()
		timer.wait_time = heartbeatInterval
		timer.one_shot = false
		timer.autostart = true
		add_child(timer)
		timer.timeout.connect(detectActivity)

func sceneChangeLog():
	print("Scene Changed")


func _enter_tree() -> void:
	scene_changed.connect(updateCurrentTime)
	scene_saved.connect(updateCurrentTime)
	script_changed.connect(updateCurrentTime)
	project_settings_changed.connect(updateCurrentTime)
	resource_saved.connect(updateCurrentTime)
	main_screen_changed.connect(updateCurrentTime)
	getCurrentCpuPlatform()
	startTimer()
	detectActivity()
	pass

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	updateCurrentTime()
	return false
func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	updateCurrentTime()
	return 0
	


# i fucking hate godot what is this language

func _exit_tree() -> void:
	scene_changed.disconnect(updateCurrentTime)
	scene_saved.disconnect(updateCurrentTime)
	script_changed.disconnect(updateCurrentTime)
	project_settings_changed.disconnect(updateCurrentTime)
	resource_saved.disconnect(updateCurrentTime)
	main_screen_changed.disconnect(updateCurrentTime)
	if timer:
		timer.queue_free()
	# Clean-up of the plugin goes here.
	pass
