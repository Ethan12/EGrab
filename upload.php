<?php
$fileName = $_POST["fileName"];
$authKey = $_POST["AuthKey"];

$authKeys = array("Test" => "123456789ABCD");

if(in_array($authKey, $authKeys)){

$target_dir = "img";

	if(!file_exists($target_dir))
	{
		mkdir($target_dir, 0777, true);
	}

	$target_dir = $target_dir . "/" . basename($_FILES["file"]["name"]);

	if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_dir)) 
	{
		echo json_encode([
			"File" => "" . $_FILES["file"]["name"] . "",
			"Status" => "OK",
			"userId" => "" . array_search($authKey, $authKeys) . ""
		]);

	} else {

		echo json_encode([
			"Message" => "Sorry, there was an error uploading your file.",
			"Status" => "Error",
			"File" => "" . $_FILES["file"]["name"] . "",
			"userId" => "" . array_search($authKey, $authKeys) . ""
		]);

	}
}else{
	echo json_encode([
	"Message" => "Invalid Auth Code",
	"Status" => "Error",
	"File" => "" . $_FILES["file"]["name"] . ""
	]);
}

?>
