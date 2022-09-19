import flixel.FlxG;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.tile.FlxTilemap;
import haxe.io.Path;

class TiledLevel extends TiledMap
{
	inline static var c_PATH_LEVEL_TILESHEETS = "assets/images/";

	public function new(Level:FlxTiledMapAsset, State:PlayState):Void
	{
		super(Level);

		loadObjects(State);
		loadTiles(State);
	}

	public function loadTiles(State:PlayState):Void
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE)
				continue;

			var tileLayer:TiledTileLayer = cast layer;

			var tileSheetName:String = tileLayer.properties.get("tileset");

			var tileSet:TiledTileSet = null;
			for (ts in tilesets)
			{
				if (ts.name == tileSheetName)
				{
					tileSet = ts;
					break;
				}
			}

			var imagePath = new Path(tileSet.imageSource);
			var processedPath = c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;

			var tilemap = new FlxTilemap();
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processedPath, tileSet.tileWidth, tileSet.tileHeight, OFF, tileSet.firstGID, 1, 1);

			State.mapLayer.add(State.mapA = tilemap);

			tilemap = new FlxTilemap();
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processedPath, tileSet.tileWidth, tileSet.tileHeight, OFF, tileSet.firstGID, 1, 1);

			State.mapLayer.add(State.mapB = tilemap);
		}
	}

	public function loadObjects(State:PlayState):Void
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.OBJECT || layer.name == "Topside")
				continue;

			var objectLayer:TiledObjectLayer = cast layer;

			if (layer.name == "enemies")
			{
				for (o in objectLayer.objects)
				{
					State.addEnemy(o.x, o.y - o.height,
						objectLayer.map.getTileSet("enemies").tileClasses[o.gid - objectLayer.map.getTileSet("enemies").firstGID]);
				}
			}
		}
	}
}
