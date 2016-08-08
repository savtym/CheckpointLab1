<?php 

use Phalcon\Mvc\Model;

class Person extends Model
{
	public $id;
	public $name;
	public $surname;
	public $middle_name;
	public $gender_type;
	public $mother;
	public $father;
	public $tree_ID; 
}

?>