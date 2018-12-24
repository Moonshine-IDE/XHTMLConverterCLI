package
{
    import flash.desktop.NativeApplication;
    import flash.display.Sprite;
    import flash.events.InvokeEvent;
    import flash.filesystem.File;
    
    import actionScripts.utils.FileUtils;
    import actionScripts.utils.Logger;
    
    import converter.Converter;
    
    import events.ConverterEvent;
    
    [SWF(frameRate=60, width=0, height=0, visible=false, showStatusBar=false)]
    public class XHTMLConverterCLI extends Sprite
	{
		private var isPublishToPrimefacesArg:Boolean;
		private var ifPublishToPrimefacesSource:String;
		private var ifPublishToPrimeFacesTarget:String;
		private var invokedFromDirectory:File;
		private var logger:Logger = new Logger();
		
		public function XHTMLConverterCLI()
		{
			super();
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvokeEvent);
		}
		
		private function onInvokeEvent(event:InvokeEvent):void
		{
			NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvokeEvent);
			logger.initLogger(onSuccessLoggerRead);
			
			/*
			 * @local
			 */
			function onSuccessLoggerRead():void
			{
				invokedFromDirectory = event.currentDirectory;
				readByInvokeArguments(event.arguments);
			}
		}
		
		private function readByInvokeArguments(args:Array):void
		{
			logger.generateTimeStamp();
			logger.updateLog("Started from: "+ invokedFromDirectory.nativePath);
			logger.updateLog("Arguments ("+ args.length +"):\n\n"+ args.join("\n") +"\n");
			
			if (args.length != 0)
			{
				for (var i:int = 0; i < args.length; i++)
				{
					// parsing if publish-to-primefaces exists
					if (!isPublishToPrimefacesArg && (args[i] == "--publish-to-primefaces"))
					{
						// next two parameters must be supplying
						// values against 'publish-to-primefaces'
						if ((i + 2) < args.length)
						{
							isPublishToPrimefacesArg = true;
							ifPublishToPrimefacesSource = args[i+1];
							ifPublishToPrimeFacesTarget = args[i+2];
						}
					}
					
					// parse any other arguments if requires
					// down this place
				}
			}
			else
			{
				// if no argument present, saveLogAndQuit
				exitWithReason("No Arguments Found", Logger.TYPE_WARNING);
			}
			
			// --publish-to-primefaces
			if (isPublishToPrimefacesArg)
			{
				initPublishRead();
			}
			else
			{
				exitWithReason("Missing parameters. Expected path details not found: --publish-to-primefaces\n", Logger.TYPE_WARNING);
			}
		}
		
		private function initPublishRead():void
		{
			var fromFile:File = convertIfRelativeToAbsolute(ifPublishToPrimefacesSource);
			if (!fromFile) return;
			
			if (fromFile.exists)
			{
				logger.updateLog("Source file read starts at: "+ ifPublishToPrimefacesSource);
				FileUtils.readFromFileAsync(fromFile, FileUtils.DATA_FORMAT_STRING, onSuccessRead, onErrorRead);
			}
			else
			{
				exitWithReason("Source file does not exists at: "+ ifPublishToPrimefacesSource, Logger.TYPE_ERROR);
			}
			
			/*
			* @local
			*/
			function onSuccessRead(value:Object):void
			{
				if (value) 
				{
					logger.updateLog("Source file read succeed.\n");
					try
					{
						sendForConversion(new XML(value));
					} catch (e:Error)
					{
						exitWithReason("Error while XML conversion: "+ e.getStackTrace(), Logger.TYPE_ERROR);
					}
				}
				else 
				{
					exitWithReason("Source file returned invalid data at: "+ ifPublishToPrimefacesSource, Logger.TYPE_ERROR);
				}
			}
			function onErrorRead(value:String):void
			{
				exitWithReason("Error reading source file at: "+ ifPublishToPrimefacesSource +"\n"+ value +"\n", Logger.TYPE_ERROR);
			}
		}
		
		private function sendForConversion(value:XML):void
		{
			logger.updateLog("Starting the conversion..");
			Converter.getInstance().addEventListener(ConverterEvent.CONVERSION_COMPLETED, onConversionCompleted);
			Converter.getInstance().addEventListener(ConverterEvent.UNKNOWN_CONVERSION_ITEM, onUnknownConversionItem);
			Converter.getInstance().fromXMLOnly(value);
		}
		
		private function onConversionCompleted(event:ConverterEvent):void
		{
			logger.updateLog("Conversion completed successfully");
			Converter.getInstance().removeEventListener(ConverterEvent.CONVERSION_COMPLETED, onConversionCompleted);
			Converter.getInstance().removeEventListener(ConverterEvent.UNKNOWN_CONVERSION_ITEM, onUnknownConversionItem);
			
			if (event.xHtmlOutput)
			{
				publishReadToPrimefaces(event.xHtmlOutput);
			}
			else
			{
				exitWithReason("Empty conversion data\n", Logger.TYPE_WARNING);
			}
		}
		
		private function onUnknownConversionItem(event:ConverterEvent):void
		{
			logger.updateLog("Unknown conversion item: " + event.itemName);	
		}
		
		private function publishReadToPrimefaces(value:Object):void
		{
			var toFile:File = convertIfRelativeToAbsolute(ifPublishToPrimeFacesTarget);
			if (!toFile) return;
			
			logger.updateLog("Saving results of conversion to: "+ ifPublishToPrimeFacesTarget);
			FileUtils.writeToFileAsync(toFile, value, onSuccessWrite, onErrorWrite);
			
			/*
			* @local
			*/
			function onSuccessWrite():void
			{
				// @note
				// Unfortunately, even the invoke event do fire 
				// multiple times when an application is already open,
				// its argument array do not re-generates except in
				// the first time; thus, let close it and re-open the
				// app again
				exitWithReason("Save file completes at: "+ ifPublishToPrimeFacesTarget, Logger.TYPE_INFO);
			}
			function onErrorWrite(value:String):void
			{
				exitWithReason("Error while file saving at: "+ ifPublishToPrimeFacesTarget +"\n"+ value, Logger.TYPE_ERROR);
			}
		}
		
		private function saveLogAndQuit():void
		{
			logger.updateLog("Application has been closed.");
			
			// save the the log file
			logger.saveLog(onSuccessWrite, onErrorWrite);
			
			/*
			* @local
			*/
			function onSuccessWrite():void
			{
				stage.nativeWindow.close();
			}
			function onErrorWrite(value:String):void
			{
				// ? should we simply quit 
				// or re-try the process for how many times?
				// @note - however failing to write to app storage 
				// is very rare case, but on Windows 10 this
				// may turn to error if the file is opened
				// by user or some service already.
				// for now - simply quit
				stage.nativeWindow.close();
			}
		}
		
		private function exitWithReason(reason:String, type:String):void
		{
			logger.updateLog(reason, type);
			saveLogAndQuit();
		}
		
		private function convertIfRelativeToAbsolute(path:String):File
		{
			var tmpFile:File;
			if (FileUtils.isRelativePath(path))
			{
				try
				{
					// convert to abolute path to use with File API
					tmpFile = invokedFromDirectory.resolvePath(path);
					return tmpFile;
				}
				catch (e:Error)
				{
					// if any bad data to treat as File
					exitWithReason("Unable to validate as file path: "+ path, Logger.TYPE_ERROR);
					return null;
				}
			}
			
			return convertToFile(path);
		}
		
		private function convertToFile(path:String):File
		{
			try
			{
				var tmpFile:File = new File(path);
				return tmpFile;
			}
			catch (e:Error)
			{
				// if any bad data to treat as File
				exitWithReason("Unable to validate as file path: "+ path, Logger.TYPE_ERROR);
			}
			
			return null;
		}
    }
}