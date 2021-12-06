
   
// Internal action code for project ia_submission

package ia_submission;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class getNextScanLocation extends DefaultInternalAction {

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		// execute the internal action
		int roverXPosition = (int) ((NumberTerm) args[0]).solve();
		int roverYPosition = (int) ((NumberTerm) args[1]).solve();

		int mapWidth = (int) ((NumberTerm) args[2]).solve();
		int mapHeight = (int) ((NumberTerm) args[3]).solve();

		ListTerm ListOfObstacles = (ListTerm) args[4];
		ListTerm ListOfScanned = (ListTerm) args[5];
		
		int scanRange = (int) ((NumberTerm) args[6]).solve();

		Tile map[][] = new Tile[mapWidth][mapHeight];

		for (int x = 0; x < mapWidth; x++) {
			for (int y = 0; y < mapHeight; y++) {
				map[x][y] = new Tile(x, y);
			}
		}

		
		for (Term innerListAsTerm : ListOfScanned) {

			ListTerm innerListAsListTerm = (ListTerm) innerListAsTerm;
			// Note we are still using NumberTerm for the number
			NumberTerm scannedXPositionTerm = (NumberTerm) innerListAsListTerm.get(0);
			NumberTerm scannedYPositionTerm = (NumberTerm) innerListAsListTerm.get(1);
		
			int scannedXPosition = (int) scannedXPositionTerm.solve();
			int scannedYPosition = (int) scannedYPositionTerm.solve();

			map[scannedXPosition][scannedYPosition].scanned = true;
			boolean scannedIsObstacle = false;
			
			for (Term innerListAsTermObs : ListOfObstacles) {

				ListTerm innerListAsListTermObs = (ListTerm) innerListAsTermObs;
				// Note we are still using NumberTerm for the number
				NumberTerm obstacleXPositionTerm = (NumberTerm) innerListAsListTermObs.get(1);
				NumberTerm obstacleYPositionTerm = (NumberTerm) innerListAsListTermObs.get(2);

				int obstacleXPosition = (int) obstacleXPositionTerm.solve();
				int obstacleYPosition = (int) obstacleYPositionTerm.solve();

				if(obstacleXPosition == scannedXPosition && obstacleYPosition == scannedYPosition ) {
					scannedIsObstacle = true;
					break;
				}
			}
			
			if(scannedIsObstacle == false) {
				map[scannedXPosition][scannedYPosition].obstacle = false;
			}
		

			
			//System.out.println(map[scannedXPosition][scannedYPosition].xPosition  + " " + map[scannedXPosition][scannedYPosition].yPosition);
		}

		int xScanLocation = 0;
		int yScanLocation = 0;

		List<Tile> nearestTilesToRover = new ArrayList<Tile>();
		double minDist = Double.MAX_VALUE;

		for (int x = 0; x < mapWidth; x++) {
			for (int y = 0; y < mapHeight; y++) {
				// need to find tile that is scanned but bordering an unscanned tile
				if (map[x][y].obstacle == false && map[x][y].scanned == true) {

					// N
					// NE
					// E
					// SE
					// S
					// SW
					// W
					// NW
					boolean borderingUnscanned = false;

					if (map[x][Math.floorMod(y + 1, mapHeight)].scanned == false) {
						borderingUnscanned = true;				
					} else if (map[Math.floorMod(x + 1, mapWidth)][y].scanned == false) {
						borderingUnscanned = true;					
					} else if (map[x][Math.floorMod(y - 1, mapHeight)].scanned == false) {
						borderingUnscanned = true;					
					} else if (map[Math.floorMod(x - 1, mapWidth)][y].scanned == false) {
						borderingUnscanned = true;
					}
				

					if(borderingUnscanned == true) {						
						
						
						//System.out.println("Tile X: " + map[x][y].xPosition + " Y: " + map[x][y].yPosition + " is Bordering an Unscanned tile");
						
						int xCalc = 0;
						int yCalc = 0;
						
						if (x > mapWidth/2) {
							xCalc  = mapWidth - x;
						} else {
							xCalc = x;
						}
						
						if (y > mapHeight/2) {
							yCalc  = mapHeight - y;
						} else {
							yCalc = y;
						}
						
						
						double dist = CalculateDistanceFromRover(x,y,roverXPosition,roverYPosition);
						if (dist == minDist && dist != 0) {
							nearestTilesToRover.add(map[x][y]);
						} else if (dist < minDist && dist != 0) {
							nearestTilesToRover.clear();
							nearestTilesToRover.add(map[x][y]);
							minDist = dist;
						}
					}
					
				}
			}
		}
		
		if (!nearestTilesToRover.isEmpty()) {
		    Random rand = new Random();
			int randInt = rand.nextInt(nearestTilesToRover.size());
			//System.out.println("There are " + nearestTilesToRover.size() + " Equidistant apart");
			xScanLocation = nearestTilesToRover.get(randInt).xPosition;
			yScanLocation = nearestTilesToRover.get(randInt).yPosition;
			
		} else {
			return false;
		}
		
		

		return un.unifies(new NumberTermImpl(xScanLocation), args[7]) & un.unifies(new NumberTermImpl(yScanLocation), args[8]);

	}

	private double CalculateDistanceFromRover(int x, int y, int roverXPosition, int roverYPosition) {

		return Math.sqrt(((roverXPosition - x) * (roverXPosition - x)) + ((roverYPosition - y) * (roverYPosition - y)));
	}

}
