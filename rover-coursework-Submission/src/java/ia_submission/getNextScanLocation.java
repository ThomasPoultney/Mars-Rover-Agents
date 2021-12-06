
// Internal action code for project ia_submission

package ia_submission;

import java.util.ArrayList;
import java.util.List;
import java.util.PriorityQueue;
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

		Node map[][] = new Node[mapWidth][mapHeight];
		for (int x = 0; x < mapWidth; x++) {
			for (int y = 0; y < mapHeight; y++) {
				Node newNode = new Node(x * y);
				newNode.xPosition = x;
				newNode.yPosition = y;
				map[x][y] = newNode;
			}
		}

		for (int x = 0; x < mapWidth; x++) {
			for (int y = 0; y < mapHeight; y++) {

				Node n = map[x][y];

				Node westNeighbour = map[Math.floorMod(x - 1, mapWidth)][y];
				n.neighbours.add(westNeighbour);
				n.neighbourXOffsets.add(-1);
				n.neighbourYOffsets.add(0);

				// System.out.println("The position of west Neighbour is: " +
				// westNeighbour.xPosition + " " + westNeighbour.yPosition);

				Node eastNeighbour = map[Math.floorMod(x + 1, mapWidth)][y];
				n.neighbours.add(eastNeighbour);
				n.neighbourXOffsets.add(1);
				n.neighbourYOffsets.add(0);
				// System.out.println("The position of east Neighbour is: " +
				// eastNeighbour.xPosition + " " + eastNeighbour.yPosition);

				Node southNeighbour = map[x][Math.floorMod(y - 1, mapHeight)];
				n.neighbours.add(southNeighbour);
				n.neighbourXOffsets.add(0);
				n.neighbourYOffsets.add(-1);
				// System.out.println("The position of south Neighbour is: " +
				// southNeighbour.xPosition + " " + southNeighbour.yPosition);

				Node northNeighbour = map[x][Math.floorMod(y + 1, mapHeight)];
				n.neighbours.add(northNeighbour);
				n.neighbourXOffsets.add(0);
				n.neighbourYOffsets.add(1);

				


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

		int xScanLocation = 0;
		int yScanLocation = 0;

		List<Node> nearestNodeToRover = new ArrayList<Node>();
		int minDist = Integer.MAX_VALUE;

		for (int x = 0; x < mapWidth; x++) {
			for (int y = 0; y < mapHeight; y++) {
				// need to find tile that is scanned but bordering an unscanned tile
				if (map[x][y].obstacle == false && map[x][y].scanned == true) {

					boolean borderingUnscanned = false;
					Node scanNode = map[x][y];

					for (Node neighbour : scanNode.neighbours) {
						if (neighbour.scanned == false ) {
							borderingUnscanned = true;
						}
					}
					Node roverNode = map[roverXPosition][roverYPosition];

					if (borderingUnscanned == true) {

						int dist = AStar(scanNode, roverNode);
						//System.out.println(dist);

						if (dist < minDist && dist != 0) {
							nearestNodeToRover.clear();
							minDist = dist;
							nearestNodeToRover.add(scanNode);

						} else if (dist == minDist && dist != 0) {
							nearestNodeToRover.add(scanNode);
						}
					}
				}
			}
		}

		if (!nearestNodeToRover.isEmpty()) {
			Random rand = new Random();
			int randInt = rand.nextInt(nearestNodeToRover.size());
			// System.out.println("There are " + nearestTilesToRover.size() + " Equidistant
			// apart");
			xScanLocation = nearestNodeToRover.get(randInt).xPosition;
			yScanLocation = nearestNodeToRover.get(randInt).yPosition;

		} else {
			return false;
		}

		return un.unifies(new NumberTermImpl(xScanLocation), args[7])
				& un.unifies(new NumberTermImpl(yScanLocation), args[8]);

	}

	public static int AStar(Node start, Node target) {

		PriorityQueue<Node> openSet = new PriorityQueue<Node>();

		List<Node> closedSet = new ArrayList<Node>();

		openSet.add(start);
		double gScore = Double.MAX_VALUE;
		start.g = 0;

		double fScore = Double.MAX_VALUE;
		start.h = start.calculateHeuristic(target);

		while (!openSet.isEmpty()) {

			Node current = openSet.peek();
			// System.out.println("Peeking at" + current.xPosition + " " +
			// current.yPosition);
			openSet.remove(current);
			closedSet.add(current);

			if (current == target) {
				return RetracePath(start, target);
			}

			for (Node neighbour : current.neighbours) {
				// double tentative_gScore = current.g + 1 ;

				if (neighbour.obstacle == true) {
					// System.out.println("not considering Neighbour because it is an obstacle");
				}

				if (neighbour.scanned == false) {
					// System.out.println("not considering Neighbour because it is not scanned");
				}

				if (neighbour.obstacle == true || neighbour.scanned == false || closedSet.contains(neighbour)) {
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

		return Integer.MAX_VALUE;
	}

	public static int RetracePath(Node startNode, Node endNode) {
		List<Node> path = new ArrayList<Node>();

		int distance = 0;
		Node current = endNode;

		while (current != startNode) {
			path.add(current);
			distance++;
			current = current.parent;
		}

		return distance;
	}


}
