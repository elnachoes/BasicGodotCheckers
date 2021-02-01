extends Node

#array variables for pieces and position locations
var boardPositionLocations : Array 
onready var boardPieces : Array = $Pieces.get_children()
onready var boardPositions : Array = $Positions.get_children()

#variables for selected piece and selected position
var selectedPiece : Object
var selectedPosition : Object
var selectedPieceMoves : Array
var selectedPiecePossiblePositions : Array
var selectedPieceCombatants : Dictionary

#player turn variable
var player1Turn : bool = true

#func calls func boardSetup()
#calls func setStartingPositions()
func _ready() -> void:
	boardSetup()
	setStartingPositions()

func refreshBoardPieces() -> void:
	boardPieces = $Pieces.get_children()

#func transforms the array boardPositionLocations into a 8x8 array of positions
func boardSetup() -> void:
	var boardPositions : Array = $Positions.get_children()
	var row : Array = []
	for x in (boardPositions):
		row.append(x)
		if (row.size() == 8):
			boardPositionLocations.append(row)
			row = []
	positionVisibilityControl(true, false)

#func sets piece to selectedPiece
#(piece) is the object id of a piece
func setSelectedPiece(piece : Object) -> void:
	if(piece.player1 and player1Turn or not piece.player1 and not player1Turn):
		var toggleColor : bool
		selectedPiece = piece
		for piece in (boardPieces):
			toggleColor = false
			piece.toggleColor(toggleColor)
		toggleColor = true
		selectedPiece.toggleColor(toggleColor)
		selectedPieceCombatants =  calculateCombatantLocations()
		selectedPiecePossiblePositions = possibleMoves()
		positionVisibilityControl(true, true)

#func takes all the pieces in boardPieces and puts the pieces in their starting positions
#it calls func setPositions to set all board pieces where they need to start
func setStartingPositions() -> void:
	for piece in (boardPieces):
		setPositions(piece, piece.startingPositionX,piece.startingPositionY)

#func sets position_id to selectedPiece 
#(position_id) is the object id of a position 
func setSelectedPosition(position_id : Object) -> void:
	selectedPosition = position_id
	moveSelectedPieceToSelectedPosition(position_id)

#func moves piece to the selected position
func moveSelectedPieceToSelectedPosition(position_id : Object) -> void:
	var is_position_possible : bool = selectedPiecePossiblePositions.has(position_id)
	if (is_position_possible):
		selectedPiece.move_current_positions(position_id.position_x,position_id.position_y)
		selectedPiece.position = position_id.position
	calculateCombat()

	#NOTE: kindof works but doesn't 
	#this allows a piece to do a second combat jump but it works even if comebat didnt happen on the first jump
	# ---- FIX ----#
	if(checkIfDoubleJump()):
		setSelectedPiece(selectedPiece)
	else:
		finishTurn()

func checkIfDoubleJump() -> bool:
	var checkIfDoubleJump : bool 
	var extraCombatants : int = calculateCombatantLocations().size()
	if(extraCombatants > 0):
		checkIfDoubleJump = true
	else:
		checkIfDoubleJump = false
	return checkIfDoubleJump


func finishTurn() -> void:
	checkIfKing()
	positionVisibilityControl(true, false)
	selectedPiece.toggleColor(false)
	selectedPiece = null
	selectedPosition = null
	selectedPieceCombatants.clear()
	selectedPiecePossiblePositions.clear()
	selectedPieceMoves.clear()
	turnSwitch()

#func moves a piece to a desired position on the board
#(piece) is the object id of the piece you want to move
#(position_x) is an int for the x position in an array
#(position_y) is an int for the y position in an array
#(target_position) is the id of the position in boardPositionLocations indexed with position_y and position_x
func setPositions(piece : Object, position_x : int, position_y : int) -> void:
	var target_position : Object = boardPositionLocations[position_y][position_x]
	piece.position = target_position.position

func positionVisibilityControl(toggle_all_positions_visible : bool, toggle_possible_positions_visible : bool) -> void:
	var toggleVisible : bool 
	if (toggle_all_positions_visible):
		for row in (boardPositionLocations):
			for position in (row):
				toggleVisible = false
				position.toggleVisible(toggleVisible)
	if (toggle_possible_positions_visible):
		for move in (possibleMoves()):
			var possible_position : Object = boardPositionLocations[move[0]][move[1]]
			selectedPiecePossiblePositions.append(possible_position)
			toggleVisible = true
			possible_position.toggleVisible(toggleVisible)

func possibleMoves() -> Array:
	var moves : Array 
	if (selectedPiece.king):
		for move in (selectedPiece.possibleNormalMoves().keys()):
			moves.append(selectedPiece.possibleNormalMoves()[move])
	else:
		if (selectedPiece.player1):
			if (selectedPiece.possibleNormalMoves().has("NorthEastNormal")):
				moves.append(selectedPiece.possibleNormalMoves()["NorthEastNormal"])
			if (selectedPiece.possibleNormalMoves().has("NorthWestNormal")):
				moves.append(selectedPiece.possibleNormalMoves()["NorthWestNormal"])
		else:
			if (selectedPiece.possibleNormalMoves().has("SouthEastNormal")):
				moves.append(selectedPiece.possibleNormalMoves()["SouthEastNormal"])
			if (selectedPiece.possibleNormalMoves().has("SouthWestNormal")):
				moves.append(selectedPiece.possibleNormalMoves()["SouthWestNormal"])

	if (selectedPiece.player1 or selectedPiece.king):
		if (selectedPieceCombatants.has("NorthEastCombatant")):
			moves.append(selectedPiece.possible_combat_moves()["NorthEastCombat"])
		if (selectedPieceCombatants.has("NorthWestCombatant")):
			moves.append(selectedPiece.possible_combat_moves()["NorthWestCombat"])
	if (not selectedPiece.player1 or selectedPiece.king):
		if (selectedPieceCombatants.has("SouthWestCombatant")):
			moves.append(selectedPiece.possible_combat_moves()["SouthWestCombat"])
		if (selectedPieceCombatants.has("SouthEastCombatant")):
			moves.append(selectedPiece.possible_combat_moves()["SouthEastCombat"])
	return moves

func calculateCombatantLocations() -> Dictionary:
	var combatants : Dictionary
	var possibleCombatMoves : Dictionary = selectedPiece.possible_combat_moves()
	for piece in boardPieces:
		if (selectedPiece.currentPositionX + 1 == piece.currentPositionX):
			if (selectedPiece.currentPositionY + 1 == piece.currentPositionY and possibleCombatMoves.has("NorthEastCombat")):
				combatants["NorthEastCombatant"] = piece
			if (selectedPiece.currentPositionY - 1 == piece.currentPositionY and possibleCombatMoves.has("SouthEastCombat")):
				combatants["SouthEastCombatant"] = piece
		if (selectedPiece.currentPositionX - 1 == piece.currentPositionX):
			if (selectedPiece.currentPositionY + 1 == piece.currentPositionY and possibleCombatMoves.has("NorthWestCombat")):
				combatants["NorthWestCombatant"] = piece
			if (selectedPiece.currentPositionY - 1 == piece.currentPositionY and possibleCombatMoves.has("SouthWestCombat")):
				combatants["SouthWestCombatant"] = piece
	return combatants

func calculateCombat() -> void:
	if (selectedPieceCombatants.has("NorthEastCombatant")):
		var ne_piece : Object = selectedPieceCombatants["NorthEastCombatant"]
		if (ne_piece.currentPositionX + 1 == selectedPiece.currentPositionX and ne_piece.currentPositionY + 1 == selectedPiece.currentPositionY):
			removePiece(ne_piece)
	if (selectedPieceCombatants.has("NorthWestCombatant")):
		var nw_piece : Object = selectedPieceCombatants["NorthWestCombatant"]
		if (nw_piece.currentPositionX - 1 == selectedPiece.currentPositionX and nw_piece.currentPositionY + 1 == selectedPiece.currentPositionY):
			removePiece(nw_piece)
	if (selectedPieceCombatants.has("SouthWestCombatant")):
		var sw_piece : Object = selectedPieceCombatants["SouthWestCombatant"]
		if (sw_piece.currentPositionX - 1 == selectedPiece.currentPositionX and sw_piece.currentPositionY - 1 == selectedPiece.currentPositionY):
			removePiece(sw_piece)
	if (selectedPieceCombatants.has("SouthEastCombatant")):
		var se_piece : Object = selectedPieceCombatants["SouthEastCombatant"]
		if (se_piece.currentPositionX + 1 == selectedPiece.currentPositionX and se_piece.currentPositionY - 1 == selectedPiece.currentPositionY):
			removePiece(se_piece)

func removePiece(piece : Object) -> void:
	var location_in_boardPieces : int = boardPieces.bsearch(piece)
	boardPieces.remove(location_in_boardPieces)
	piece.free()
	refreshBoardPieces()

func checkIfKing() -> void:
	if (not selectedPiece.king):
		if (selectedPiece.player1):
			if (selectedPiece.currentPositionY== 7):
				selectedPiece.king = true
		elif (not selectedPiece.player1):
			if (selectedPiece.currentPositionY== 0):
				selectedPiece.king = true
	selectedPiece.change_sprite()

func turnSwitch():
	if (player1Turn):
		player1Turn = false
	else:
		player1Turn = true

func winCheck():
	pass
























