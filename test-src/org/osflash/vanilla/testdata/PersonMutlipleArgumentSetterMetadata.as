package org.osflash.vanilla.testdata
{

	/**
	 * This class uses a single setter method to supply all the values to the object.
	 */
	public class PersonMutlipleArgumentSetterMetadata
	{
		private var _name : String;
		private var _age : uint;
		private var _artists : Array;
		private var _gender : PersonGenderEnum;


		[Marshall(field="name", field="age", field="artists", field="gender")]
		public function init(name : String, age : uint, artists : Array, gender : PersonGenderEnum) : void
		{
			_name = name;
			_age = age;
			_artists = artists;
			_gender = gender;
		}


		public function getName() : String
		{
			return _name;
		}


		public function getAge() : uint
		{
			return _age;
		}


		public function getArtists() : Array
		{
			return _artists;
		}


		public function getGender() : PersonGenderEnum
		{
			return _gender;
		}
	}
}
