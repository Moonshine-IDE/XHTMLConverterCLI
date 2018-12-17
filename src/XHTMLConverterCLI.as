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
		public function XHTMLConverterCLI()
		{
			super();
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvokeEvent);
		}
		
		private function onInvokeEvent(event:InvokeEvent):void
		{
			NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvokeEvent);
			
			var arg:Array = event.arguments;
			var isPublishToPrimefacesArg:Boolean;
			var ifPublishToPrimefacesSource:String;
			var ifPublishToPrimeFacesTarget:String;
			
			if (arg.length != 0)
			{
				for (var i:int; i < arg.length; i++)
				{
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
				stage.nativeWindow.close();
			}
			
			// --publish-to-primefaces
			if (isPublishToPrimefacesArg)
			{
				publishToPrimefaces(ifPublishToPrimefacesSource, ifPublishToPrimeFacesTarget);
			}
		}
		
		private function publishToPrimefaces(source:String, target:String):void
		{
			var toFile:File = new File(target);
			FileUtils.writeToFileAsync(toFile, "No CONTENT", onSuccessWrite, onErrorWrite);
			
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
				stage.nativeWindow.close();
			}
			function onErrorWrite(value:String):void
			{
				stage.nativeWindow.close();
			}
		}
    }
}