extends "res://src/ui/mods/mod_item.gd"

func _process(delta):
	pass

func createOptions():
	getValidConfig()
	if optionsCreated:
		return
	var schema:Dictionary = ModLoaderConfig.get_config_schema(modItem.mod_id)
	
	if not schema or not schema.properties:
		return
	
	Utils.removeChildren(options_list)
	
	var props = schema.properties
	options = {}
	
	for propName in props.keys():
		var prop = props[propName]
		
		var node = option_item_ref.duplicate()
		node.visible = true
		var controlContainer = node.get_node("controlContainer")
		
		var n = null
		
		if prop.type == "string":
			if prop.get("format", "") == "color":
				n = Utils.place(preload("res://src/ui/control/color_picker_button.tscn"), controlContainer)
				n.color_changed.connect(func(v):
					updateConfigValue(propName, v)
				)
				options[propName] = {
					node = n,
					setVal = (func(v):
						n.color = Color(v)
						),
					getVal = (func():
						return "#" + n.color.to_html()
						)
				}
			elif propName.begins_with("dynamic"):
				n = Utils.place(preload("res://src/ui/control/choiceButton.tscn"), controlContainer)
				n.item_selected.connect(func(v):
					updateConfigValue(propName, v)
				)
				Utils.runLater(1000, func(): n.setChoices.call_deferred(ModLoader.get_node(modItem.mod_id).get(prop.get("enum"))))
				options[propName] = {
					node = n,
					setVal = (func(v):
						n.select(v)
						),
					getVal = (func():
						return n.selected
						)
				}
			elif prop.has("enum"):
				n = Utils.place(preload("res://src/ui/control/choiceButton.tscn"), controlContainer)
				n.item_selected.connect(func(v):
					updateConfigValue(propName, v)
				)
				if propName.begins_with("dynamic"):
					n.setChoices.call_deferred(ModLoader.get_node(modItem.mod_id).get(propName))
				else:
					n.setChoices.call_deferred(prop.get("enum", ["[error]"]))
				options[propName] = {
					node = n,
					setVal = (func(v):
						n.select(v)
						),
					getVal = (func():
						return n.selected
						)
				}
			else:
				n = Utils.place(preload("res://src/ui/control/line_edit.tscn"), controlContainer)
				n.text_changed.connect(func(v):
					updateConfigValue(propName, v)
				)
				n.max_length = prop.get("maxLength", 0)
				options[propName] = {
					node = n,
					setVal = (func(v):
						n.text = v
						),
					getVal = (func():
						return n.text
						)
				}
		elif prop.type == "integer":
			n = Utils.place(preload("res://src/ui/control/spin_box.tscn"), controlContainer)
			n.value_changed.connect(func(v):
				updateConfigValue(propName, v)
			)
			n.step = 1
			if prop.has("minimum"):
				n.min_value = prop.get("minimum", 0)
				n.allow_lesser = false
			if prop.has("maximum"):
				n.max_value = prop.get("maximum", 0)
				n.allow_greater = false
			options[propName] = {
				node = n,
				setVal = (func(v):
					n.value = v
					),
				getVal = (func():
					return n.value
					)
			}
		elif prop.type == "number":
			if prop.has("minimum") and prop.has("maximum"):
				n = Utils.place(preload("res://src/ui/control/slider.tscn"), controlContainer)
				n.value_changed.connect(func(v):
					updateConfigValue(propName, v)
				)
				n.setMinValue.call_deferred(prop.get("minimum", 0))
				n.setMaxValue.call_deferred(prop.get("maximum", 0))
				n.setStep.call_deferred(prop.get("multipleOf", 0))
				if prop.has("multipleOf"):
					n.round = false
				options[propName] = {
					node = n,
					setVal = (func(v):
						n.setValue(v)
						),
					getVal = (func():
						return n.value
						)
				}
			else:
				n = Utils.place(preload("res://src/ui/control/spin_box.tscn"), controlContainer)
				n.value_changed.connect(func(v):
					updateConfigValue(propName, v)
				)
				n.step = prop.get("multipleOf", 0)
				if prop.has("minimum"):
					n.min_value = prop.get("minimum", 0)
					n.allow_lesser = false
				if prop.has("maximum"):
					n.max_value = prop.get("maximum", 0)
					n.allow_greater = false
				options[propName] = {
					node = n,
					setVal = (func(v):
						n.value = v
						),
					getVal = (func():
						return n.value
						)
				}
		elif prop.type == "boolean":
			n = Utils.place(preload("res://src/ui/control/toggleButton.tscn"), controlContainer)
			n.value_changed.connect(func(v):
				updateConfigValue(propName, v)
			)
			options[propName] = {
				node = n,
				setVal = (func(v):
					n.setValue(v)
					),
				getVal = (func():
					return n.button_pressed
					)
			}
		if n:
			var title = node.get_node("labelContainer/labelList/titleLabel")
			title.text = prop.get("title", "[error]")
			if not prop.get("description", "").is_empty():
				var desc = node.get_node("labelContainer/labelList/descLabel")
				desc.text = prop.get("description", "")
				desc.visible = true
			options_list.add_child(node)
	
	print_debug(schema)
	
	optionsCreated = true
