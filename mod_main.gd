extends Node

const AUTHORNAME_MODNAME_DIR := "kr1v-dynamicoptions" # Name of the directory that this file is in
const AUTHORNAME_MODNAME_LOG_NAME := "kr1v-dynamicoptions:Main" # Full ID of the mod (AuthorName-ModName)

var mod_dir_path := ""
var extensions_dir_path := ""
var yourArrayInModMainHere = [] 

func _init() -> void:
	for i in randi_range(2, 10):
		yourArrayInModMainHere.append(str(i)) # note that the default value will be `[` or `[error]` or something if the default value doesn't exist
	ModLoaderLog.info("Init", AUTHORNAME_MODNAME_LOG_NAME)
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(AUTHORNAME_MODNAME_DIR)
	yourArrayInModMainHere.append("yourDefaultValueHere") # make sure the default value is always in the array
	extensions_dir_path = mod_dir_path.path_join("extensions")
	ModLoaderMod.install_script_extension(extensions_dir_path.path_join("src/ui/mods/mod_item.gd"))

func _ready() -> void:
	ModLoaderLog.info("Ready", AUTHORNAME_MODNAME_LOG_NAME)


