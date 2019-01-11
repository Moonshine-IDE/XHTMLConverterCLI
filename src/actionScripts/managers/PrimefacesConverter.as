package actionScripts.managers
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import actionScripts.events.PrimefacesConversionEvent;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.Logger;
	
	import converter.Converter;
	
	import events.ConverterEvent;

	[Event(name="CONVERSION_SUCCESS", type="actionScripts.events.PrimefacesConversionEvent")]
	[Event(name="CONVERSION_ERROR", type="actionScripts.events.PrimefacesConversionEvent")]
	public class PrimefacesConverter extends EventDispatcher
	{
		private var source:File;
		private var target:File;
		private var isOverwrite:Boolean;
		private var logger:Logger = Logger.getInstance();
		
		public function PrimefacesConverter(source:File, target:File, isOverwrite:Boolean=false)
		{
			this.source = source;
			this.target = target;
			this.isOverwrite = isOverwrite;
			
			start();
		}
		
		private function start():void
		{
			if (source.exists)
			{
				logger.update("Source file read starts at: "+ source.nativePath);
				FileUtils.readFromFileAsync(source, FileUtils.DATA_FORMAT_STRING, onSuccessRead, onErrorRead);
			}
			else
			{
				sendError("Source file does not exists at: "+ source.nativePath);
			}
			
			/*
			* @local
			*/
			function onSuccessRead(value:Object):void
			{
				if (value) 
				{
					logger.update("Source file read succeed.\n");
					try
					{
						convert(new XML(value));
					} catch (e:Error)
					{
						sendError("Error while XML conversion: "+ e.getStackTrace());
					}
				}
				else 
				{
					sendError("Source file returned invalid data at: "+ source.nativePath);
				}
			}
			function onErrorRead(value:String):void
			{
				sendError("Error reading source file at: "+ source.nativePath +"\n"+ value +"\n");
			}
		}
		
		private function convert(value:XML):void
		{
			logger.update("Starting the conversion..");
			Converter.getInstance().addEventListener(ConverterEvent.CONVERSION_COMPLETED, onConversionCompleted);
			Converter.getInstance().addEventListener(ConverterEvent.UNKNOWN_CONVERSION_ITEM, onUnknownConversionItem);
			Converter.getInstance().fromXMLOnly(value);
		}
		
		private function onConversionCompleted(event:ConverterEvent):void
		{
			logger.update("Conversion completed successfully");
			Converter.getInstance().removeEventListener(ConverterEvent.CONVERSION_COMPLETED, onConversionCompleted);
			Converter.getInstance().removeEventListener(ConverterEvent.UNKNOWN_CONVERSION_ITEM, onUnknownConversionItem);
			
			if (event.xHtmlOutput)
			{
				publish(event.xHtmlOutput);
			}
			else
			{
				sendError("Empty conversion data\n");
			}
		}
		
		private function onUnknownConversionItem(event:ConverterEvent):void
		{
			logger.update("Unknown conversion item: " + event.itemName);	
		}
		
		private function publish(value:Object):void
		{
			if (target.exists && !isOverwrite)
			{
				sendError("File aready exists at: "+ target.nativePath);
			}
			else
			{
				logger.update("Saving results of conversion to: "+ target.nativePath);
				FileUtils.writeToFileAsync(target, value, onSuccessWrite, onErrorWrite);
			}
			
			/*
			* @local
			*/
			function onSuccessWrite():void
			{
				dispatchEvent(new PrimefacesConversionEvent(
					PrimefacesConversionEvent.CONVERSION_SUCCESS,
					"Save file completes at: "+ target.nativePath +"\n"));
			}
			function onErrorWrite(value:String):void
			{
				sendError("Error while file saving at: "+ target.nativePath +"\n"+ value);
			}
		}
		
		private function sendError(message:String):void
		{
			this.dispatchEvent(new PrimefacesConversionEvent(
				PrimefacesConversionEvent.CONVERSION_ERROR,
				message +"\n"));
		}
	}
}