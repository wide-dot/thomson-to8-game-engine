package fr.bento8.to8.audio.SVGMTool.vgm;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.zip.GZIPInputStream;

public class VGMInputStream extends InputStream {
	private final InputStream input;
	private final int offsetEOF;
	private final int version;
	private final int psgClock;
	private final int fmClock;
	private final int offsetGD3;
	private final int totalSamples;
	private final int offsetLoop;
	private final int loopSamples;
	private final int rate;
	private int pos;

	public VGMInputStream(File paramFile) throws IOException {
		InputStream bufferedInputStream;
		this.pos = 0;
		try {
			bufferedInputStream = new GZIPInputStream(new FileInputStream(paramFile));
		} catch (IOException iOException) {
			bufferedInputStream = new BufferedInputStream(new FileInputStream(paramFile));
		} 
		this.input = bufferedInputStream;
		byte[] arrayOfByte = new byte[4];
		read(arrayOfByte);
		if (!"Vgm ".equals(new String(arrayOfByte))) {
			close();
			throw new IOException("Invalid vgm file. File identification missing.");
		} 
		this.offsetEOF = this.pos + readInt();
		this.version = readInt();
		this.psgClock = readInt();
		this.fmClock = readInt();
		this.offsetGD3 = this.pos + readInt();
		this.totalSamples = readInt();
		this.offsetLoop = this.pos + readInt();
		this.loopSamples = readInt();
		this.rate = readInt();
		if (this.version >= 336) {
			seekTo(52);
			int i = readInt();
			if (i > 0) {
				skip((i - 4));
			} else {
				seekTo(64);
			} 
		} else {
			seekTo(64);
		} 
	}

	public int getOffsetEOF() {
		return this.offsetEOF;
	}

	public int getVersion() {
		return this.version;
	}

	public int getPsgClock() {
		return this.psgClock;
	}

	public int getFmClock() {
		return this.fmClock;
	}

	public int getOffsetGD3() {
		return this.offsetGD3;
	}

	public int getTotalSamples() {
		return this.totalSamples;
	}

	public int getOffsetLoop() {
		return this.offsetLoop;
	}

	public int getLoopSamples() {
		return this.loopSamples;
	}

	public int getRate() {
		return this.rate;
	}

	public void seekTo(int paramInt) throws IOException {
		if (paramInt < this.pos)
			throw new IOException("Current position is beyond position to seek to."); 
		if (paramInt > this.pos)
			skip((paramInt - this.pos)); 
	}

	public boolean isLoopPoint() {
		return (this.pos == this.offsetLoop);
	}

	public int getPosition() {
		return this.pos;
	}

	public int read() throws IOException {
		this.pos++;
		return this.input.read();
	}

	public int readShort() throws IOException {
		return read() | read() << 8;
	}

	public int readInt() throws IOException {
		return read() | read() << 8 | read() << 16 | read() << 24;
	}

	public void close() throws IOException {
		this.input.close();
	}

	public int available() throws IOException {
		return this.input.available();
	}

	public synchronized void mark(int paramInt) {
		this.input.mark(paramInt);
	}

	public boolean markSupported() {
		return this.input.markSupported();
	}

	public synchronized void reset() throws IOException {
		this.input.reset();
	}
}
