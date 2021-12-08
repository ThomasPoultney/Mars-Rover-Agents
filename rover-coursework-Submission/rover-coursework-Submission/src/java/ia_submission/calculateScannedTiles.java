// Internal action code for project ia_submission

package ia_submission;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class calculateScannedTiles extends DefaultInternalAction {

	  @Override
	    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
	      
	    	int xPosition = (int)((NumberTerm) args[0]).solve(); 
	    	int yPosition = (int)((NumberTerm) args[1]).solve(); 
	    	
	    	int scanRange = (int)((NumberTerm) args[2]).solve(); 
	    	
	    	int mapWidth = (int)((NumberTerm) args[3]).solve(); 
	    	int mapHeight = (int)((NumberTerm) args[4]).solve();
	    	
	    	
	    	List<ScannedTile> scanned = calcScannedTiles(xPosition, yPosition, scanRange, mapWidth, mapHeight);
	        
	    	
	    	ListTerm scannedOutput = new ListTermImpl();

	    	for(ScannedTile tile : scanned) {
	    		
	    		int XPos = tile.xPosition;
	    		int YPos = tile.yPosition;
	    		
	    		ListTerm innerList = new ListTermImpl();
	    		
	    		NumberTerm xAsTerm =  new NumberTermImpl(XPos);	    		
	    		NumberTerm yAsTerm =  new NumberTermImpl(YPos);	  

	    		innerList.add(xAsTerm);
	    		innerList.add(yAsTerm);
	    		
	    		scannedOutput.add(innerList);
	    		

	    	}
	    	
	    	//everything ok, so returns true
	    	return un.unifies(scannedOutput, args[5]);
	    }

	private List<ScannedTile> calcScannedTiles(int xPosition, int yPosition, int scanRange, int mapWidth, int mapHeight) {
		
		boolean DEBUG = false;
		System.out.println(scanRange);
		
		int tilesUnderConsideration = 0;
		boolean[][] willBeScanned = new boolean[scanRange*2 + 1][scanRange*2 + 1];
		List<ScannedTile> scannedTiles = new ArrayList<ScannedTile>();
		for (int x = -scanRange; x <= scanRange; x++) {
			for (int y = -scanRange; y <= scanRange; y++) {
				tilesUnderConsideration++;
				
				if (calcDistanceToRover(x, y) <= scanRange) {
					willBeScanned[x + scanRange][ y + scanRange] = true;
					int XRelativeToBase = Math.floorMod(x + xPosition, mapWidth);
					int YRelativeToBase = Math.floorMod(y + yPosition, mapHeight);
					
					ScannedTile tile = new ScannedTile(XRelativeToBase, YRelativeToBase);
					scannedTiles.add(tile);
					
					//System.out.println("Tile X: " + XRelativeToBase + " Y: " + YRelativeToBase + "Will Be Scanned");
				} else {
					willBeScanned[x + scanRange][y + scanRange] = false;
				} 
				
			}
		}
		
		
		if(DEBUG == true) {
			System.out.println("IA: Evaluating " + tilesUnderConsideration + " To see which have been scanned");
			
			
			for (boolean[] x : willBeScanned)
			{
			   for (boolean y : x)
			   {
			        System.out.print(y + "\t");
			   }
			   System.out.println();
			}
		}
		
		
		
		return scannedTiles;
	}

	private double calcDistanceToRover(int x, int y) {
		
		int x2 = x;
		int x1 = 0;
		
		int y2 = y;
		int y1 = 0;
		
		return Math.sqrt(((x2 - x1)*(x2 - x1)) + ((y2-y1) * (y2-y1)) );
		
		
	}

		
	  
	  
}




