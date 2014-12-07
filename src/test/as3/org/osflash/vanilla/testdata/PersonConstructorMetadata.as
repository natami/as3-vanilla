package org.osflash.vanilla.testdata
{

	/**
	 * This imultable model requires the fields to be set in the constructor, here we define Marshalling Metadata
	 * to define rules to map from the source object into constructor arguments.
	 */
	[Marshall(field="name", field="age", field="artists", field="gender")]
	public class PersonConstructorMetadata
	{
		public function PersonConstructorMetadata(name : String, age : uint, artists : Array, gender : PersonGenderEnum)
		{
			_name = name;
			_age = age;
			_artists = artists;
			_gender = gender;
		}


		private var _name : String;

		public function get name() : String
		{
			return _name;
		}


		private var _age : uint;

		public function get age() : uint
		{
			return _age;
		}


		private var _artists : Array;

		public function get artists() : Array
		{
			return _artists;
		}


		private var _gender : PersonGenderEnum;

		public function get gender() : PersonGenderEnum
		{
			return _gender;
		}
	}
}
