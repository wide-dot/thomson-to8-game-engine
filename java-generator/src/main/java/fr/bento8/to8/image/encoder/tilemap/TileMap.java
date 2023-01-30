package fr.bento8.to8.image.encoder.tilemap;

import java.awt.image.BufferedImage;
import java.awt.image.IndexColorModel;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

public class TileMap {

	Png tilesetPng;
	public byte[][] tiles;	
	public int tileWidth;
	public int tileHeight;
	
	public int[] mapData;
	public int mapWidth;
	public int mapHeight;
	
	BufferedImage image;
	int imgWidth;
	int imgHeight;
	
	public TileMap(File tileset, int tileWidth, int tileHeight, int tilesetWidth, File map, int mapWidth, int mapBitDepth, boolean bigEndian) throws Exception {

		readTileSet(tileset, tileWidth, tileHeight, tilesetWidth);
		readMap(map, mapWidth, mapBitDepth, bigEndian);
		buildImage();
	}
	
	private void readTileSet(File file, int tileWidth, int tileHeight, int tilesetWidth) throws Exception {		
		
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		tilesetPng = new Png(file);
		
		// read png and extract each tile
		int tileSize = tileWidth*tileHeight;
		int nbTiles = tilesetPng.dataBuffer.getSize();
		tiles = new byte[nbTiles][tileSize];
		
		for (int t = 0; t < nbTiles; t++) {
			for (int y = 0; y < tileHeight; y++) {
				for (int x = 0; x < tileWidth; x++) {
					tiles[t][x+y*tileWidth] = (byte) tilesetPng.dataBuffer.getElem(x*(t%tilesetWidth) + y*tileWidth*tilesetWidth + (t/tilesetWidth)*tileHeight);
				}
			}
		}
	}
	
	private void readMap(File map, int mapWidth, int mapBitDepth, boolean bigEndian) throws IOException {
		
		this.mapWidth = mapWidth;
		this.mapHeight = mapData.length/mapWidth;
		
		// read map data
		byte[] raw = Files.readAllBytes(map.toPath());
		int bytes = (mapBitDepth/8);
		mapData = new int[raw.length/bytes];
		int k = 0;
		
		if (bigEndian) {
			for (int i = 0; i < raw.length; i += bytes) {
				for (int j = 0; j < bytes; j++) {
					mapData[k] = (mapData[k] << 8) | (raw[i+j] & 0xFF);
				}
			}
		} else {
			for (int i = 0; i < raw.length; i += bytes) {
				for (int j = bytes; j > 0; j--) {
					mapData[k] = (mapData[k] << 8) | (raw[i+j] & 0xFF);
				}
			}
		}
	}
	
	private void buildImage() {
		imgWidth = mapWidth*tileWidth;
		imgHeight = mapHeight*tileHeight;
		image = new BufferedImage(imgWidth, imgHeight, BufferedImage.TYPE_BYTE_INDEXED, (IndexColorModel)tilesetPng.colorModel);
		
		for (int ty = 0; ty < mapHeight; ty++) {
			for (int tx = 0; tx < mapWidth; tx++) {
				for (int y = 0; y < tileHeight; y++) {
					for (int x = 0; x < tileWidth; x++) {
						image.getRaster().getDataBuffer().setElem((tx*tileWidth+ty*mapWidth*tileHeight) + (x+y*tileWidth*mapWidth), tiles[tx+ty*mapWidth][x+y*tileWidth]);
					}
				}
			}
		}
	}
	
}
