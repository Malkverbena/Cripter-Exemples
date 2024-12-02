extends Node

var data_01 : Dictionary = {"AABBCC": 34535.35, 36:[3,"sdf"], true:{4.4:"9"} }



func _ready() -> void:
	test_gcm_encryption()
	
	get_tree().quit()



func test_gcm_encryption() -> void:
	var plaintext = var_to_bytes(data_01)
	var password = "secret_key_128bit".sha1_text() # ALWAYS HASH THE PASSWORD!!!!
	var iv = Cripter.generate_iv(Cripter.GCM_TAG_SIZE, "another IV") # Unique IV for this operation (MUST HAVE 16 BYTES!)
	var aad := "validation information"            # Additional data (AAD) that will not be encrypted but will be authenticated. May be NULL if there is no additional data.
	assert(iv.size() == 16, "IV must have 16 bytes.")
	print("\nplaintext:\n", plaintext, "\n\n")
	
	# Perform encryption
	var encrypted : Dictionary = Cripter.gcm_encrypt(plaintext, password, iv, aad, Cripter.BITS_256)
	assert(encrypted.Ciphertext != plaintext, "Encryption failed: ciphertext matches plaintext.")
	assert(encrypted.Ciphertext != null, "Encryption failed: returned null.")
	assert(encrypted.Tag != null, "Tagging failed: returned null.")
	print("Ciphertext: \n", encrypted.Ciphertext, "\n\n")


  # Perform decryption
	var decrypted : PackedByteArray = Cripter.gcm_decrypt(encrypted.Ciphertext, password, iv, encrypted.Tag, "", Cripter.BITS_256)
	print("decrypted:\n", decrypted)
	assert(not decrypted.is_empty(), "Decryption failed: returned null.")
	assert(decrypted == plaintext, "Decryption failed: decrypted text does not match the original.")
