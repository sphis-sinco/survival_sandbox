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
	?blocks:Array<String>,
	?tracks:Array<String>
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
			blocks: [],
			tracks: [],
		};
		ADD = {
			blocks: [],
			tracks: [],
		};
		trace('RELOADING');

		var requests:Array<String> = [];
		#if sys
		try
		{
			trace('getting requests');
			requests = ResourcePacks.readDirectory('data/requests/');
		}
		catch (e)
		{
			trace(e);
			return;
		}
		#end
		trace('found requests: ' + requests);
		if (requests.length > 0)
		{
			#if sys
			for (request in requests)
			{
				trace(request);
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
						for (track_id in parsed_request?.tracks)
							REMOVE.tracks.push(track_id);
					case 'add':
						for (block_path in parsed_request?.blocks)
							ADD.blocks.push(block_path);
						for (track_path in parsed_request?.tracks)
							ADD.tracks.push(track_path);
				}
			}
			#end
		}

		trace('REMOVE REQUESTS: ' + REMOVE);
		trace('ADD REQUESTS: ' + ADD);
	}
}
