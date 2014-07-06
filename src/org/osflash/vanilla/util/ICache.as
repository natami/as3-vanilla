package org.osflash.vanilla.util
{

    public interface ICache
    {

        function addElement(key : *, value : *) : void;


        function getElement(key : *) : *;


        function hasElement(key : *) : Boolean;

    }
}
