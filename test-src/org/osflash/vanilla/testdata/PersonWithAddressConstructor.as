package org.osflash.vanilla.testdata
{

    [Marshall(field="name", field="address", field="gender")]
    public class PersonWithAddressConstructor
    {
        private var _name : String;
        private var _address : Address;
        private var _gender : PersonGenderEnum;


        public function PersonWithAddressConstructor(name : String, address : Address, gender : PersonGenderEnum)
        {
            _name = name;
            _address = address;
            _gender = gender;
        }


        public function get name() : String
        {
            return _name;
        }


        public function get address() : Address
        {
            return _address;
        }


        public function get gender() : PersonGenderEnum
        {
            return _gender;
        }
    }
}
