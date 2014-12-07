package org.osflash.vanilla.testdata
{

	[Marshall(field="name", field="address", field="gender")]
	public class PersonWithAddressConstructor
	{
		public function PersonWithAddressConstructor(name : String, address : Address, gender : PersonGenderEnum)
		{
			_name = name;
			_address = address;
			_gender = gender;
		}


		private var _name : String;

		public function get name() : String
		{
			return _name;
		}


		private var _address : Address;

		public function get address() : Address
		{
			return _address;
		}


		private var _gender : PersonGenderEnum;

		public function get gender() : PersonGenderEnum
		{
			return _gender;
		}
	}
}
