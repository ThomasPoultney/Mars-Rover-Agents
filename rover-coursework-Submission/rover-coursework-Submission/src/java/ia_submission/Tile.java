package ia_submission;

public class Tile {
	int xPosition;
	int yPosition;
	boolean obstacle = true;
	boolean scanned = false;
	
	public Tile(int xPosition, int yPosition) {
		this.xPosition = xPosition;
		this.yPosition = yPosition;
		this.obstacle = true;
		this.scanned = false;
	}
	
}
