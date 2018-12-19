package
{
    import flash.desktop.NativeApplication;
    import flash.display.Sprite;
    import flash.events.InvokeEvent;
    import flash.filesystem.File;
    
    import actionScripts.utils.FileUtils;
    
    import converter.Converter;
    
    import events.ConverterEvent;
    
    [SWF(frameRate=60, width=0, height=0, visible=false, showStatusBar=false)]
    public class XHTMLConverterCLI extends Sprite
	{
		private var isPublishToPrimefacesArg:Boolean;
		private var ifPublishToPrimefacesSource:String;
		private var ifPublishToPrimeFacesTarget:String;
		private var log:String = "";
		
		public function XHTMLConverterCLI()
		{
			super();
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvokeEvent);
		}
		
		private function onInvokeEvent(event:InvokeEvent):void
		{
			NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvokeEvent);
			
			var arg:Array = event.arguments;
			logState("Invoked by CLI Event::Arguments Count: "+ arg.length);
			logState("Arguments:\n"+ event.arguments.join("\n"));
			
			if (arg.length != 0)
			{
				for (var i:int = 0; i < arg.length; i++)
				{
					// parsing if publish-to-primefaces exists
					if (!isPublishToPrimefacesArg && (arg[i] == "--publish-to-primefaces"))
					{
						logState("Found PrimeFaces Argument::--publish-to-primefaces");
						
						// next two parameters must be supplying
						// values against 'publish-to-primefaces'
						if ((i + 2) < arg.length)
						{
							isPublishToPrimefacesArg = true;
							ifPublishToPrimefacesSource = arg[i+1];
							ifPublishToPrimeFacesTarget = arg[i+2];
						}
					}
					
					// do any other arg check if requires,
					// at here ...
				}
			}
			else
			{
				// if no argument present, saveLogAndQuit
				exitWithReason("No Arguments Found - terminates");
			}
			
			// --publish-to-primefaces
			if (isPublishToPrimefacesArg)
			{
				initPublishRead();
			}
			else
			{
				exitWithReason("Not Enough Details::Expected Path Details Not Found: --publish-to-primefaces");
			}
		}
		
		private function initPublishRead():void
		{
			var fromFile:File = convertToFile(ifPublishToPrimefacesSource);
			if (fromFile.exists)
			{
				logState("Read File::Starting the Process From: "+ ifPublishToPrimefacesSource);
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
					logState("Read Completes::Read Success From: "+ ifPublishToPrimefacesSource);
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
				exitWithReason("Read Failed::Error Reading From: "+ ifPublishToPrimefacesSource +"\n"+ value);
			}
		}
		
		private function sendForConversion(value:XML):void
		{
			logState("Converter Called::Sending Data For Conversion:\n"+ value.toXMLString());
			Converter.getInstance().addEventListener(ConverterEvent.CONVERSION_COMPLETED, onConversionCompletes);
			Converter.getInstance().fromXMLOnly(value);
		}
		
		private function onConversionCompletes(event:ConverterEvent):void
		{
			logState("Converter Return::Callback From Converter");
			Converter.getInstance().removeEventListener(ConverterEvent.CONVERSION_COMPLETED, onConversionCompletes);
			if (event.xHtmlOutput)
			{
				logState("Preparing Conversion Save::Received Conversion Data:\n"+ event.xHtmlOutput.toXMLString());
				publishReadToPrimefaces(event.xHtmlOutput);
			}
			else
			{
				exitWithReason("No Conversion Data Received From Converter - terminates");
			}
		}
		
		private function publishReadToPrimefaces(value:Object):void
		{
			logState("Save File::Starting Process To Save At: "+ ifPublishToPrimeFacesTarget);
			
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
			logState("Terminating Application.");
			
			// save the the log file
			var logFile:File = File.applicationStorageDirectory.resolvePath("log.txt");
			FileUtils.writeToFileAsync(logFile, log, onSuccessWrite, onErrorWrite);
			
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
			logState(reason);
			saveLogAndQuit();
		}
		
		private function logState(value:String):void
		{
			log += value +"\n";
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