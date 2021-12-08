// Internal action code for project ia_submission

package ia_submission;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class debug_print_all_scanned extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	ListTerm ListOfScanned = (ListTerm) args[0];
    	int mapWidth = (int) ((NumberTerm) args[1]).solve();
		int mapHeight = (int) ((NumberTerm) args[2]).solve();
    	
		Tile[][] map = new Tile[mapWidth][mapHeight];
		
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
		}
    	

    	
    	for (int x = 0; x < mapWidth; x++) {
			for (int y = 0; y < mapHeight; y++) {
				 System.out.print(map[x][y].scanned + "\t");
			}
			System.out.println();
		}

    	
    	
        return true;
    }
}
