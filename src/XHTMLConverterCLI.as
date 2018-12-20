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
				readByInvokeArguments(event.arguments);
			}
		}
		
		private function readByInvokeArguments(args:Array):void
		{
			logger.log = "Invoked by CLI Event::Arguments Count: "+ args.length;
			logger.log = "Arguments:\n"+ args.join("\n") +"\n";
			
			if (args.length != 0)
			{
				for (var i:int = 0; i < args.length; i++)
				{
					// parsing if publish-to-primefaces exists
					if (!isPublishToPrimefacesArg && (args[i] == "--publish-to-primefaces"))
					{
						logger.log = "Found PrimeFaces Argument::--publish-to-primefaces\n";
						
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
				exitWithReason("No Arguments Found");
			}
			
			// --publish-to-primefaces
			if (isPublishToPrimefacesArg)
			{
				initPublishRead();
			}
			else
			{
				exitWithReason("Not Enough Details::Expected Path Details Not Found: --publish-to-primefaces\n");
			}
		}
		
		private function initPublishRead():void
		{
			var fromFile:File = convertToFile(ifPublishToPrimefacesSource);
			if (fromFile.exists)
			{
				logger.log = "Read File::Starting the Process From: "+ ifPublishToPrimefacesSource;
				FileUtils.readFromFileAsync(fromFile, FileUtils.DATA_FORMAT_STRING, onSuccessRead, onErrorRead);
			}
			else
			{
				exitWithReason("Read File::Destination File Does Not Exists - terminates: "+ ifPublishToPrimefacesSource);
			}
			
			/*
			* @local
			*/
			function onSuccessRead(value:Object):void
			{
				if (value) 
				{
					logger.log = "Read Completes::Read Success From: "+ ifPublishToPrimefacesSource +"\n";
					try
					{
						sendForConversion(new XML(value));
					} catch (e:Error)
					{
						exitWithReason("Type Conversion::Error While XML Conversion: "+ e.getStackTrace());
					}
				}
				else 
				{
					exitWithReason("Read Completes::Bad Data From: "+ ifPublishToPrimefacesSource);
				}
			}
			function onErrorRead(value:String):void
			{
				exitWithReason("Read Failed::Error Reading From: "+ ifPublishToPrimefacesSource +"\n"+ value +"\n");
			}
		}
		
		private function sendForConversion(value:XML):void
		{
			logger.log = "Converter Called::Sending Data For Conversion";
			Converter.getInstance().addEventListener(ConverterEvent.CONVERSION_COMPLETED, onConversionCompletes);
			Converter.getInstance().fromXMLOnly(value);
		}
		
		private function onConversionCompletes(event:ConverterEvent):void
		{
			logger.log = "Converter Return::Callback From Converter";
			Converter.getInstance().removeEventListener(ConverterEvent.CONVERSION_COMPLETED, onConversionCompletes);
			if (event.xHtmlOutput)
			{
				logger.log = "\nPreparing Conversion Save::Received Conversion Data";
				publishReadToPrimefaces(event.xHtmlOutput);
			}
			else
			{
				exitWithReason("No Conversion Data Received From Converter\n");
			}
		}
		
		private function publishReadToPrimefaces(value:Object):void
		{
			logger.log = "Save File::Starting Process To Save At: "+ ifPublishToPrimeFacesTarget;
			
			var toFile:File = convertToFile(ifPublishToPrimeFacesTarget);
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
				exitWithReason("Save File::Process Completes At: "+ ifPublishToPrimeFacesTarget);
			}
			function onErrorWrite(value:String):void
			{
				exitWithReason("Save File::Write Error At: "+ ifPublishToPrimeFacesTarget +"\n"+ value);
			}
		}
		
		private function saveLogAndQuit():void
		{
			logger.log = "\nTerminating Application.";
			
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
		
		private function exitWithReason(reason:String):void
		{
			logger.log = reason;
			saveLogAndQuit();
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
				exitWithReason("File Path Has Invalid Data - terminates: "+ path);
			}
			
			return null;
		}
    }
}