package suvindo;

import sys.io.File;
import haxe.Json;

typedef Request =
{
	> RequestsFields,

	request:String,
}

typedef RequestsFields =
{
	?blocks:Array<String>
}

class RequestsManager
{
	public static var REMOVE:
		{
			> RequestsFields,
		};
	public static var ADD:
		{
			> RequestsFields,
		};

	public static function reload()
	{
		REMOVE = {
			blocks: []
		};
		ADD = {
			blocks: []
		};

		#if sys
		for (request in ResourcePacks.readDirectory('data/requests/'))
		{
			var parsed_request:Request = null;
			try
			{
				parsed_request = Json.parse(File.getContent(request));
			}
			catch (e)
			{
				trace(e);
				parsed_request = null;
			}

			if (parsed_request == null)
				continue;

			switch (parsed_request.request.toLowerCase())
			{
				case 'remove':
					for (block_id in parsed_request?.blocks)
						REMOVE.blocks.push(block_id);
				case 'add':
					for (block_path in parsed_request?.blocks)
						ADD.blocks.push(block_path);
			}
		}
		#end

		trace('REMOVE REQUESTS: ' + REMOVE);
		trace('ADD REQUESTS: ' + ADD);
	}
}
