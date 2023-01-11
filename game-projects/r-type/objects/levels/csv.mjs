let csvMapFormat = {
    name: "CSV with GIDs",
    extension: "csv",

    read: function(filename) {
        let file = new TextFile(filename, TextFile.ReadOnly);
        if(!file) return null; //Maybe show an error xP

        let map = new TileMap();
        map.tileWidth = 28; //or whatever it should be
        map.tileHeight = 14; //or whatever it should be
        map.width = 0; //We'll set it later, once we know
        map.height = 0; //We'll set it once we know

        let layer = new TileLayer(); //assuming each CSV encodes a single-layer map...
        let layerEdit = layer.edit();
        let tileset = tiled.open("C:/Users/bhrou/git/thomson-to8-game-engine/game-projects/r-type/objects/levels/01/map/tileset.tsx"); //assume the tiles all come from this tileset
        if(!tileset || !tileset.isTileset) return null; //show an error maybe xP

        while(!file.atEof) { //while the file still has lines...
            let line = file.readLine();
            line = line.split(";"); //line is now an array of values
            if(line.length > 0) { //if the line has some values in it
                map.width = Math.max(map.width, line.length);
                for(var x = 0; x < line.length; x++) {
                    let tileID = line[x];
                    //process the tileID as needed... This example assumes it's a local tileset ID, which is probably wrong.
                    let tile = tileset.tile(tileID); //get the Tile from the tileset that has this ID
                    layerEdit.setTile(x, map.height, tile);
                }
                map.height = map.height + 1;
            }
        }
        layerEdit.apply();
        map.addLayer(layer); //Don't forget to put the layer into the map :]
        file.close();
        return map; //Don't forget to return the map so Tiled can show it to the user
    }
}

tiled.registerMapFormat("customCSV", csvMapFormat);