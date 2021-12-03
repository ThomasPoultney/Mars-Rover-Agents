// Internal action code for project ia_submission

package ia_submission;

import jason.*;

import jason.asSemantics.*;
import jason.asSyntax.*;
import java.util.*;

public class astarsearch extends DefaultInternalAction {

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
        
    	for (Term innerListAsTerm : ListOfObstacles) {
    		
    		ListTerm innerListAsListTerm =  (ListTerm) innerListAsTerm;
    		
    		// Note, we did not need to do much for strings, we just called the toString method
    		String resourceType =  innerListAsListTerm.get(0).toString();
    		// log the itemName so we can see that we converted it successfully
    		System.out.println("Printing from an internal action :- " + resourceType);
    		
    		// Note we are still using NumberTerm for the number
    		NumberTerm resourceXPositionTerm =  (NumberTerm) innerListAsListTerm.get(1);
    		NumberTerm resourceYPositionTerm =  (NumberTerm) innerListAsListTerm.get(2);
    		
    		int resourceXPosition =  (int)resourceXPositionTerm.solve(); 
    		int resourceYPosition =   (int)resourceYPositionTerm.solve();
    		
    		if(resourceType == "Obstacle") {
        		System.out.println("IA: There is an obstacle at X: " + resourceXPosition + " Y: " + resourceYPosition);
        		map[resourceXPosition][resourceYPosition].obstacle = true;

    		}
    		
    	
    	}

        System.out.println("Implementing A* Search from position X: " + xPosition + " Y: " + yPosition + " Target is X: " + targetXPosition + " Y: " + targetYPosition);

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
                
                Node northEastNeighbour =  map[Math.floorMod(x + 1, mapWidth)][Math.floorMod(y + 1, mapHeight)];
                n.neighbours.add(northEastNeighbour);
                n.neighbourXOffsets.add(1);
                n.neighbourYOffsets.add(1);
                
                Node northWestNeighbour =  map[Math.floorMod(x - 1, mapWidth)][Math.floorMod(y - 1, mapHeight)];
                n.neighbours.add(northWestNeighbour);
                n.neighbourXOffsets.add(-1);
                n.neighbourYOffsets.add(-1);
                
                Node southEastNeighbour =  map[Math.floorMod(x + 1, mapWidth)][Math.floorMod(y - 1, mapHeight)];
                n.neighbours.add(southEastNeighbour);
                n.neighbourXOffsets.add(1);
                n.neighbourYOffsets.add(-1);
                
                Node southWestNeighbour =  map[Math.floorMod(x - 1, mapWidth)][Math.floorMod(y - 1, mapHeight)];
                n.neighbours.add(southWestNeighbour);
                n.neighbourXOffsets.add(-1);
                n.neighbourYOffsets.add(-1);
                
                // System.out.println("The position of north Neighbour is: " + northNeighbour.xPosition + " " + northNeighbour.yPosition);
                //System.out.println("The position of south Neighbour is: " + southNeighbour.xPosition + " " + southNeighbour.yPosition);
                //System.out.println("The position of north Neighbour is: " + northNeighbour.xPosition + " " + northNeighbour.yPosition);
                int count = 0;
                for (Node node : n.neighbours) {

                    if (node.obstacle == true) {
                        n.neighbours.remove(node);
                        n.neighbourXOffsets.remove(count);
                        n.neighbourYOffsets.remove(count);
                        
                    }
                    count++;
                }
            }
        }

        List<Node> endNode = aStar(map[xPosition][yPosition], map[targetXPosition][targetYPosition]);
        
        if (endNode != null) {
            System.out.println("Path to end takes " + endNode.size() + "Moves.");           
            for (Node n : endNode) {
                System.out.print(n.xPosition + " " + n.yPosition + '\t');
            }
            System.out.println('\n');

        } else {
            System.out.println("no Path found");
        }
        
        
        int xMoveOffset = 1;
        int yMoveOffset = 1;
        
        
        return un.unifies(new NumberTermImpl(xMoveOffset), args[7]) & un.unifies(new NumberTermImpl(yMoveOffset), args[8]);
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

                if (neighbour.obstacle == true || closedSet.contains(neighbour)) {
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
        return path;
    }
}
