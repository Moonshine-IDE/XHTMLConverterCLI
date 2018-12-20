package actionScripts.utils
{
	import flash.filesystem.File;
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.DateTimeStyle;
	
	public class Logger
	{
		public static const TYPE_WARNING:String = "warning";
		public static const TYPE_ERROR:String = "error";
		public static const TYPE_INFO:String = "info";
		
		private static const LOG_EXTENSION:String = ".txt";
		
		private var logTitle:String;
		private var logFile:File;
		private var fileNameIncreamentalCount:int = 1;
		private var log:String = "";
		private var conversionDate:Date;
		
		public function Logger()
		{
			conversionDate = new Date();
			var timeStamp:String = getDateTimeStamp(conversionDate, "MM_dd_yyyy");
			logTitle = "log_"+ timeStamp;
		}
		
		public function generateTimeStamp():void
		{
			var timeStamp:String = getDateTimeStamp(conversionDate, "MM/dd/yyyy hh:kk:SSS A");
			updateLog("Conversion started: "+ timeStamp);
		}
		
		public function updateLog(message:String, type:String=TYPE_INFO):void
		{
			log += "["+ type +"] "+ message +"\n";
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
			log += "\n======================================\n\n";
			FileUtils.writeToFileAsync(logFile, log, onSuccessWrite, onErrorWrite);
			
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
		
		private function getDateTimeStamp(date:Date, format:String):String
		{
			var tmpFormatter:DateTimeFormatter = new DateTimeFormatter("en_US", DateTimeStyle.SHORT, DateTimeStyle.LONG);
			tmpFormatter.setDateTimePattern(format);
			
			return tmpFormatter.format(date);
		}
	}
}