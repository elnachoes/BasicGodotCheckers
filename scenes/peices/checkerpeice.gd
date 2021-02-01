extends Node2D

#position variables
#select the starting position from the godot editor
export var startingPositionX : int = 0 
export var startingPositionY : int = 0
var currentPositionX : int
var currentPositionY : int
var possible_moves : Array = []

#variable that tracks if the piece is a king
export var king : bool = false

#variable that tracks if the piece is a player1 piece or if false player_2 piece
export var player1 : bool = true

#colors for if the piece is selected or not
#(UNSELECTED_COLOR) is a color that is white
#(SELECTED_COLOR) is a color that is light blue
const UNSELECTED_COLOR : Color = Color("ffffff")
const SELECTED_COLOR : Color = Color("58b8ff")

var white_pawn : Texture = preload("res://assets/gfx/WhitePawn.png")
var white_king : Texture = preload("res://assets/gfx/WhiteKing.png")
var grey_pawn : Texture = preload("res://assets/gfx/GreyPawn.png")
var grey_king : Texture = preload("res://assets/gfx/GreyKing.png")

#func sets the current positions equal to the starting positions
func _ready() -> void:
	change_sprite()
	move_current_positions(startingPositionX,startingPositionY)

#func that handles input if the piece is clicked on
#if the piece is left clicked on
#then it calls func change_color()
#then it calls func select_piece()
#(event) is an input event if the mouse clicks on the area 2d
#(_viewport) and (_shape_idx) are not used in this func
func _on_Area2D_input_event(_viewport,event,_shape_idx) -> void:
	if (event is InputEventMouseButton):
		if (event.button_index == BUTTON_LEFT and event.pressed == true):
			select_piece()

#func calls the Gamestate to move the piece
#it calls the Gamestate func set_positions()
#it passes in object id, and currentPositionX and y
func move_position() -> void:
	get_tree().call_group("Gamestate","setPositions", self, currentPositionX, currentPositionY)

#func calls Gamestate and tells the game state that this piece is the selected piece
func select_piece() -> void:
	get_tree().call_group("Gamestate","setSelectedPiece", self)

func change_sprite() -> void: 
	if (not player1 and not king):
		$Sprite.texture = grey_pawn
	elif (not player1 and king):
		$Sprite.texture = grey_king
	elif (player1 and not king):
		$Sprite.texture = white_pawn
	elif (player1 and king):
		$Sprite.texture = white_king

#func changes the color of the piece if it is selected or not
func toggleColor(toggleColor : bool) -> void:
	if (toggleColor):
		modulate = SELECTED_COLOR
	if (not toggleColor):
		modulate = UNSELECTED_COLOR

func move_current_positions(new_position_x : int, new_position_y : int) -> void:
	currentPositionX = new_position_x
	currentPositionY = new_position_y

#func that calculates possible moves
func possibleNormalMoves() -> Dictionary:
	var possible_normal_moves_dictionary : Dictionary = {}
	var move_x : int 
	var move_y : int
	if (not currentPositionX + 1 > 7 and not currentPositionY + 1 > 7):
		move_x = currentPositionY + 1
		move_y = currentPositionX + 1
		possible_normal_moves_dictionary["NorthEastNormal"] = [move_x, move_y]
	if (not currentPositionX - 1 < 0 and not currentPositionY + 1 > 7):
		move_x = currentPositionY + 1
		move_y = currentPositionX - 1
		possible_normal_moves_dictionary["NorthWestNormal"] = [move_x, move_y]
	if (not currentPositionX + 1 > 7 and not currentPositionY - 1 < 0):
		move_x = currentPositionY - 1
		move_y = currentPositionX + 1
		possible_normal_moves_dictionary["SouthEastNormal"] = [move_x, move_y]
	if (not currentPositionX - 1 < 0 and not currentPositionY - 1 < 0): 
		move_x = currentPositionY - 1
		move_y = currentPositionX - 1
		possible_normal_moves_dictionary["SouthWestNormal"] = [move_x, move_y]
	return possible_normal_moves_dictionary
 
func possible_combat_moves() -> Dictionary:
	var possible_combat_moves_dictionary : Dictionary = {}
	var move_x : int 
	var move_y : int
	if (not currentPositionX + 2 > 7 and not currentPositionY + 2 > 7):
		move_x = currentPositionY + 2
		move_y = currentPositionX + 2
		possible_combat_moves_dictionary["NorthEastCombat"] = [move_x, move_y]
	if (not currentPositionX - 2 < 0 and not currentPositionY + 2 > 7):
		move_x = currentPositionY + 2
		move_y = currentPositionX - 2
		possible_combat_moves_dictionary["NorthWestCombat"] = [move_x, move_y]
	if (not currentPositionX + 2 > 7 and not currentPositionY - 2 < 0):
		move_x = currentPositionY - 2
		move_y = currentPositionX + 2
		possible_combat_moves_dictionary["SouthEastCombat"] = [move_x, move_y]
	if (not currentPositionX - 2 < 0 and not currentPositionY - 2 < 0):
		move_x = currentPositionY - 2
		move_y = currentPositionX - 2
		possible_combat_moves_dictionary["SouthWestCombat"] = [move_x, move_y]
	return possible_combat_moves_dictionary
