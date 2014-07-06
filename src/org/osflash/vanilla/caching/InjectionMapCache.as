package org.osflash.vanilla.caching
{

	import flash.errors.IllegalOperationError;

	import org.as3commons.reflect.Type;
	import org.osflash.vanilla.InjectionMap;
	import org.osflash.vanilla.util.*;

	public class InjectionMapCache
	{

		private static var instance : InjectionMapCache;


		public static function getInstance() : InjectionMapCache
		{
			if (!instance)
			{
				instance = new InjectionMapCache(SingletonLock);
			}

			return instance;
		}


		private static function createInjectionMapForClass(targetType : Class) : InjectionMap
		{
			const injectionMap : InjectionMap = new InjectionMap();
			const reflectionMap : Type = Type.forClass(targetType);

			addReflectionRules(injectionMap, reflectionMap);

			return injectionMap;
		}


		private static function addReflectionRules(injectionMap : InjectionMap, reflectionMap : Type) : void
		{
			ReflectionRulesHelper.addReflectedConstructorRules(injectionMap, reflectionMap);
			ReflectionRulesHelper.addReflectedFieldRules(injectionMap, reflectionMap);
			ReflectionRulesHelper.addReflectedSetterRules(injectionMap, reflectionMap);
		}


		public function InjectionMapCache(key : Class)
		{
			if (key != SingletonLock)
			{
				throw new IllegalOperationError("InjectionMapCache can only be accessed through InjectionMapCache.getInstance()");
			}
		}


		private var _injectionCache : ICache = new CacheUtil();

		internal function get injectionCache() : ICache
		{
			return _injectionCache;
		}


		internal function set injectionCache(value : ICache) : void
		{
			_injectionCache = value;
		}


		public function getInjectionMapForClass(targetType : Class) : InjectionMap
		{
			if (injectionCache.hasElement(targetType))
			{
				return injectionCache.getElement(targetType);
			}

			const injectionMap : InjectionMap = createInjectionMapForClass(targetType);

			injectionCache.addElement(targetType, injectionMap);

			return injectionMap;
		}
	}
}

internal class SingletonLock
{

}