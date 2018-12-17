package
{
    import flash.desktop.NativeApplication;
    import flash.display.Sprite;
    import flash.events.InvokeEvent;
    import flash.filesystem.File;
    
    import actionScripts.utils.FileUtils;
    
    [SWF(frameRate=60, width=0, height=0, visible=false, showStatusBar=false)]
    public class XHTMLConverterCLI extends Sprite
	{
		private var isPublishToPrimefacesArg:Boolean;
		private var ifPublishToPrimefacesSource:String;
		private var ifPublishToPrimeFacesTarget:String;

		public function XHTMLConverterCLI()
		{
			super();
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvokeEvent);
		}
		
		private function onInvokeEvent(event:InvokeEvent):void
		{
			NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvokeEvent);
			
			var arg:Array = event.arguments;
			if (arg.length != 0)
			{
				for (var i:int; i < arg.length; i++)
				{
					// parsing if publish-to-primefaces exists
					if (!isPublishToPrimefacesArg && (arg[i] == "--publish-to-primefaces"))
					{
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
				// if no argument present, quit
				this.quit();
			}
			
			// --publish-to-primefaces
			if (isPublishToPrimefacesArg)
			{
				initPublishRead();
			}
		}
		
		private function initPublishRead():void
		{
			var fromFile:File = new File(ifPublishToPrimefacesSource)
			if (fromFile.exists)
			{
				FileUtils.readFromFileAsync(fromFile, FileUtils.DATA_FORMAT_STRING, onSuccessRead, onErrorRead);
			}
			else
			{
				quit();
			}
			
			/*
			* @local
			*/
			function onSuccessRead(value:Object):void
			{
				// TEMP
				if (value is String) publishReadToPrimefaces(value);
				else quit();
			}
			function onErrorRead(value:String):void
			{
				quit();
			}
		}
		
		private function publishReadToPrimefaces(value:Object):void
		{
			var toFile:File = new File(ifPublishToPrimeFacesTarget);
			FileUtils.writeToFileAsync(toFile, value as String, onSuccessWrite, onErrorWrite);
			
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
				quit();
			}
			function onErrorWrite(value:String):void
			{
				quit();
			}
		}
		
		private function quit():void
		{
			stage.nativeWindow.close();
		}
    }
}