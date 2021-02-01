extends Sprite

var white_pawn : Texture = preload("res://assets/gfx/WhitePawn.png")
var white_king : Texture = preload("res://assets/gfx/WhiteKing.png")
var grey_pawn : Texture = preload("res://assets/gfx/GreyPawn.png")
var grey_king : Texture = preload("res://assets/gfx/GreyKing.png")

# func _ready():
# 	texture = load("res://assets/gfx/GreyPawn.png")

func _on_checkerpiece_change_sprite(player1 : bool, king : bool) -> void: 
	if not player1 and not king:
		texture = load("res://assets/gfx/GreyPawn.png")
	if not player1 and king:
		texture = load("res://assets/gfx/GreyKing.png")
	if player1 and not king:
		texture = load("res://assets/gfx/WhitePawn.png")
	if player1 and king:
		texture = load("res://assets/gfx/WhiteKing.png")