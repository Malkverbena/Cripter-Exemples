extends Control

@export var in_chunk = false


# The class Cripter must be instatiated to use stream.
var cripter = Cripter.new()

const BUFFER_SIZE : int = 1024

var image_buffer := PackedByteArray()
var image_path := "res://cripter_white.png"
var encrypted_image := "res://encrypted_image.crypt"
var dencrypted_image := "res://dencrypted_image.png"


var password = "secret_key_128bit".sha1_text()   # ALWAYS HASH THE PASSWORD!!!!
var iv := Cripter.generate_iv(16, "IV iv IV iv")  # Unique IV for this operation (MUST HAVE 16 BYTES!)
var tag := PackedByteArray()
 

func _ready() -> void:
	tag.resize(BUFFER_SIZE)

	clear_files()
	gcm_encrypt_stream()
	gcm_decrypt_stream()
	get_tree().quit()


func clear_files() -> void:
	if FileAccess.file_exists(encrypted_image):
		DirAccess.remove_absolute(encrypted_image)
	if FileAccess.file_exists(dencrypted_image):
		DirAccess.remove_absolute(dencrypted_image)



func gcm_encrypt_stream()  -> void:
	
	var err = cripter.gcm_start_stream(password, iv, Cripter.ENCRYPT)
	assert(err == OK, "Failed to start encryption stream")
	image_buffer = PackedByteArray()
	var last_line
	
	var file = FileAccess.open(image_path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_buffer(BUFFER_SIZE)
			last_line = cripter.gcm_update_stream(line, in_chunk)
			image_buffer.append_array(last_line)
		file.close()
	tag = cripter.gcm_stop_stream(last_line)
	
	file = FileAccess.open(encrypted_image, FileAccess.WRITE)
	if file:
		file.store_buffer(image_buffer)
		file.close()




func gcm_decrypt_stream() -> void:
	
	var err = cripter.gcm_start_stream(password, iv, Cripter.DECRYPT)
	assert(err == OK, "Failed to start dencryption stream")
	image_buffer = PackedByteArray()
	print("TAG: ", tag)
	var last_line
	
	var file = FileAccess.open(encrypted_image, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_buffer(BUFFER_SIZE)
			last_line = cripter.gcm_update_stream(line, in_chunk)
			image_buffer.append_array(last_line)
		file.close()
	
	cripter.gcm_stop_stream(last_line, tag)
	
	file = FileAccess.open(dencrypted_image, FileAccess.WRITE)
	if file:
		file.store_buffer(image_buffer)
		file.close()
