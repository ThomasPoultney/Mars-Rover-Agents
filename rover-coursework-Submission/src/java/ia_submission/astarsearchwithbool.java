// Internal action code for project ia_submission

package ia_submission;

import jason.*;

import jason.asSemantics.*;
import jason.asSyntax.*;
import java.util.*;

public class astarsearchwithbool extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {

    	int xPosition = (int)((NumberTerm) args[0]).solve(); 
    	int yPosition = (int)((NumberTerm) args[1]).solve(); 
    	
    	int targetXPosition = (int)((NumberTerm) args[2]).solve(); 
    	int targetYPosition = (int)((NumberTerm) args[3]).solve(); 
    	
    	int mapWidth = (int)((NumberTerm) args[4]).solve(); 
    	int mapHeight = (int)((NumberTerm) args[5]).solve();
    	
    	
    	
    	
    
    	Node[][] map = new Node[mapWidth][mapHeight];

        for (int x = 0; x < mapWidth; x++) {
            for (int y = 0; y < mapHeight; y++) {
                Node newNode = new Node(x * y);
                newNode.xPosition = x;
                newNode.yPosition = y;
                map[x][y] = newNode;
            }
        }
        
        
        ListTerm ListOfObstacles =  (ListTerm) args[6];
    	ListTerm ListOfScanned =  (ListTerm) args[7];

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

				if (obstacleXPosition == scannedXPosition && obstacleYPosition == scannedYPosition) {
					scannedIsObstacle = true;
					
				}
			}

			if (scannedIsObstacle == false) {
				map[scannedXPosition][scannedYPosition].obstacle = false;
			}

			// System.out.println(map[scannedXPosition][scannedYPosition].xPosition + " " +
			// map[scannedXPosition][scannedYPosition].yPosition);
		}

        //System.out.println("IA: Implementing A* Search from position X: " + xPosition + " Y: " + yPosition + " Target is X: " + targetXPosition + " Y: " + targetYPosition);

        for (int x = 0; x < mapWidth; x++) {
            for (int y = 0; y < mapHeight; y++) {

                Node n = map[x][y];

                Node westNeighbour = map[Math.floorMod(x - 1, mapWidth)][y];
                n.neighbours.add(westNeighbour);
                n.neighbourXOffsets.add(-1);
                n.neighbourYOffsets.add(0);
                
                //System.out.println("The position of west Neighbour is: " + westNeighbour.xPosition + " " + westNeighbour.yPosition);

                Node eastNeighbour = map[Math.floorMod(x + 1, mapWidth)][y];
                n.neighbours.add(eastNeighbour);
                n.neighbourXOffsets.add(1);
                n.neighbourYOffsets.add(0);
                //System.out.println("The position of east Neighbour is: " + eastNeighbour.xPosition + " " + eastNeighbour.yPosition);

                Node southNeighbour = map[x][Math.floorMod(y - 1, mapHeight)];
                n.neighbours.add(southNeighbour);
                n.neighbourXOffsets.add(0);
                n.neighbourYOffsets.add(-1);
                //System.out.println("The position of south Neighbour is: " + southNeighbour.xPosition + " " + southNeighbour.yPosition);

                Node northNeighbour = map[x][Math.floorMod(y + 1, mapHeight)];
                n.neighbours.add(northNeighbour);
                n.neighbourXOffsets.add(0);
                n.neighbourYOffsets.add(1);
            
                
                // System.out.println("The position of north Neighbour is: " + northNeighbour.xPosition + " " + northNeighbour.yPosition);
                //System.out.println("The position of south Neighbour is: " + southNeighbour.xPosition + " " + southNeighbour.yPosition);
                //System.out.println("The position of north Neighbour is: " + northNeighbour.xPosition + " " + northNeighbour.yPosition);
            
                
            }
        }

        List<Node> endNode = aStar(map[xPosition][yPosition], map[targetXPosition][targetYPosition]);
        int wasSuccessful = 0;
        
        if (endNode != null) {
            //System.out.println("Path to end takes " + endNode.size() + "Moves.");           
            for (Node n : endNode) {
               // System.out.print(n.xPosition + " " + n.yPosition + '\t');
            }
            
            
            
           // System.out.println('\n');

        } else {
            //System.out.println("IA: no Path found");
        }
        
        if(endNode != null) {
        	 Node lastNode = endNode.get(endNode.size() -1);
             
             int count = 0;
             for(Node neighbour : map[xPosition][yPosition].neighbours) {
             	
             	if(neighbour == lastNode) {
             		break;
             	} else {
             		count++;
             	}
             	
             }
             
             int xMoveOffset = map[xPosition][yPosition].neighbourXOffsets.get(count);
             int yMoveOffset = map[xPosition][yPosition].neighbourYOffsets.get(count);
         
             return un.unifies(new NumberTermImpl(xMoveOffset), args[8]) & un.unifies(new NumberTermImpl(yMoveOffset), args[9]);
        } else {
        	int xMoveOffset = 0;
        	int yMoveOffset = 0;
            return un.unifies(new NumberTermImpl(xMoveOffset), args[8]) & un.unifies(new NumberTermImpl(yMoveOffset), args[9]);

        }
       
       
    
    }

    private static List<Node> reconstruct_path(List<Node> cameFrom, Node current) {
        List<Node> total_path = new ArrayList<Node>();
        total_path.add(current);
        while (cameFrom.contains(current)) {

        }

        return total_path;
    }

    public static List<Node> aStar(Node start, Node target) {

        PriorityQueue<Node> openSet = new PriorityQueue<Node>();

        List<Node> closedSet = new ArrayList<Node>();

        openSet.add(start);
        double gScore = Double.MAX_VALUE;
        start.g = 0;

        double fScore = Double.MAX_VALUE;
        start.h = start.calculateHeuristic(target);

        while (!openSet.isEmpty()) {

            Node current = openSet.peek();
            //System.out.println("Peeking at" + current.xPosition + " " + current.yPosition);
            openSet.remove(current);
            closedSet.add(current);

            if (current == target) {
                return RetracePath(start, target);
            }

            for (Node neighbour : current.neighbours) {
                //double tentative_gScore = current.g + 1 ;
            	
            	if (neighbour.obstacle == true ) {
            		//System.out.println("not considering Neighbour because it is an obstacle");
            	}
            	
            	if (neighbour.scanned == false ) {
            		//System.out.println("not considering Neighbour because it is not scanned");
            	}
            	
                if (neighbour.obstacle == true || neighbour.scanned == false ||  closedSet.contains(neighbour)) {
                    continue;
                }

                double fValueOfNewNode = current.g + current.calculateHeuristic(target);

                if (fValueOfNewNode < neighbour.g || !openSet.contains(neighbour)) {
                    neighbour.g = fValueOfNewNode;
                    neighbour.h = neighbour.calculateHeuristic(target);
                    neighbour.f = neighbour.g + neighbour.h;
                    neighbour.parent = current;

                    if (!openSet.contains(neighbour)) {
                        openSet.add(neighbour);
                    }
                }

            }
        }

        return null;
    }

    public static List<Node> RetracePath(Node startNode, Node endNode) {
        List<Node> path = new ArrayList<Node>();
        
        Node current = endNode;

        while (current != startNode) {
            path.add(current);
            current = current.parent;
        }
        
        if(path.isEmpty()) {
        	return null;
        } else {
            return path;

        }
    }
}
