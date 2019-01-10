package actionScripts.events
{
	import flash.events.Event;
	
	public class PrimefacesConversionEvent extends Event
	{
		public static const CONVERSION_SUCCESS:String = "conversionSuccess";
		public static const CONVERSION_ERROR:String = "conversionError";
		
		public var message:String;
		
		public function PrimefacesConversionEvent(type:String, message:String=null, _bubble:Boolean=false, _cancelable:Boolean=true)
		{
			this.message = message;
			super(type, _bubble, _cancelable);
		}
	}
}