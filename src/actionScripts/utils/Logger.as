package actionScripts.utils
{
	import flash.filesystem.File;
	
	import mx.formatters.DateFormatter;

	public class Logger
	{
		private static const LOG_EXTENSION:String = ".txt";
		
		private var logTitle:String;
		private var logFile:File;
		private var fileNameIncreamentalCount:int = 1;
		
		private var _log:String = "";
		public function set log(value:String):void
		{
			_log += value +"\n";
		}
		
		public function Logger()
		{
			var tmpDateFormat:DateFormatter = new DateFormatter("MM_DD_YYYY");
			logTitle = "log_"+ tmpDateFormat.format(new Date());
		}
		
		public function initLogger(onSuccess:Function):void
		{
			logFile = File.applicationStorageDirectory.resolvePath(logTitle + LOG_EXTENSION);
			if (logFile.exists) FileUtils.readFromFileAsync(logFile, FileUtils.DATA_FORMAT_STRING, onSuccessRead, onErrorRead);
			else onSuccess();
			
			/*
			* @local
			*/
			function onSuccessRead(value:Object):void
			{
				if (value is String) log = value as String;
				onSuccess();
			}
			function onErrorRead(value:String):void
			{
				var tmpLogTitle:String;
				// for any funny reason, specially on Windows
				// unable to read from the file exists
				// decide to create by new file name policy 
				// as does in OSX by increamenting count figure
				// and try to read by that file
				
				// if previously numbered
				if (logTitle.indexOf("-") != -1) logTitle = logTitle.substring(0, logTitle.indexOf("-"));
				tmpLogTitle = logTitle +"-"+ fileNameIncreamentalCount;
				if (File.applicationStorageDirectory.resolvePath(tmpLogTitle + LOG_EXTENSION).exists)
				{
					// try to read by new numbered file again
					// so we will updae everything to this file now
					fileNameIncreamentalCount++;
					initLogger(onSuccess);
				}
				else
				{
					onSuccess();
				}
			}
		}
		
		public function saveLog(onSuccess:Function, onFail:Function):void
		{
			// save the the log file
			_log += "======================================\n";
			FileUtils.writeToFileAsync(logFile, _log, onSuccessWrite, onErrorWrite);
			
			/*
			* @local
			*/
			function onSuccessWrite():void
			{
				if (onSuccess != null) onSuccess();
			}
			function onErrorWrite(value:String):void
			{
				if (onFail != null) onFail(value);
			}
		}
	}
}