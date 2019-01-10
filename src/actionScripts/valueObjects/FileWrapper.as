package actionScripts.valueObjects
{
	import flash.filesystem.File;
	
	[Bindable] dynamic public class FileWrapper
	{
		private var _file: File;
		private var _children: Array = [];
		
		protected var _isRoot: Boolean;
		protected var _shallUpdateChildren: Boolean;
		
		public function set shallUpdateChildren(value:Boolean):void {	_shallUpdateChildren = value;	}
		public function get shallUpdateChildren():Boolean {	return _shallUpdateChildren;	}
		
		public function FileWrapper(file:File, isRoot:Boolean=false, shallUpdateChildren:Boolean=true)
		{
			_file = file;
			_isRoot = isRoot;
			_shallUpdateChildren = shallUpdateChildren;
			
			// store filelocation reference for later
			// search through Find Resource menu option
			if (_file && _shallUpdateChildren)
			{
				updateChildren();
			}
		}
		
		public function updateChildren():void
		{
			if (!file.isDirectory) return;
			
			var directoryListing:Array = file.getDirectoryListing();
			if (directoryListing.length == 0 && !file.isDirectory)
			{
				_children = null;
				return;
			}
			else _children = [];
			var fw: FileWrapper;
			var directoryListingCount:int = directoryListing.length;
			
			for (var i:int = 0; i < directoryListingCount; i++)
			{
				var currentDirectory:Object = directoryListing[i];
				if (!currentDirectory.isHidden)
				{
					fw = new FileWrapper(new File(currentDirectory.nativePath), false, _shallUpdateChildren);
					_children.push(fw);
				}
			}
		}
		
		public function containsFile(file:File):Boolean
		{
			if (file.nativePath.indexOf(nativePath) == 0) return true;
			return false;
		}
		
		public function get file():File
		{
			return _file;
		}
		public function set file(v:File):void
		{
			_file = v;
		}
		
		public function get isRoot():Boolean
		{
			return _isRoot;
		}
		public function set isRoot(value:Boolean):void
		{
			_isRoot = value;
		}
		
		public function get children():Array
		{
			if (!_children && _shallUpdateChildren) updateChildren();
			
			return _children;
		}
		public function set children(value:Array):void
		{
			_children = value;
		}
		
		public function get nativePath():String
		{
			if (!file) return null;
			return file.nativePath;
		}
	}
}