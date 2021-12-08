package ia_submission;

import java.util.ArrayList;
import java.util.List;
import java.math.*;
import java.lang.Comparable;
import java.util.PriorityQueue;

public class Node implements java.lang.Comparable<Node> {
	public List<Node> neighbours;
	public int xPosition = 0;
	public int yPosition = 0;
	public Node parent;
	public int id;
	
	public List<Integer> neighbourXOffsets = new ArrayList<Integer>();
	public List<Integer> neighbourYOffsets = new ArrayList<Integer>();;

	
	public double f = Double.MAX_VALUE;
	public double g = Double.MAX_VALUE;
	public boolean scanned = false;
	public boolean obstacle = true;

	
	public double h;

	Node(int id) {
		this.neighbours = new ArrayList<Node>();
		this.id = id;
	}

	
    
	 public int compareTo(Node n) {
           return Double.compare(this.f, n.f);
     }
        		
	
	 public double calculateHeuristic(Node target){
  		
			float dx = Math.abs(target.xPosition - this.xPosition);
			float dy = Math.abs(target.yPosition - this.yPosition);
	                //System.out.println("When the position is: " + this.xPosition + " " + this.yPosition + " The ED is " + Math.sqrt((dx*dx)+ (dy * dy)));
		        if(dx > dy) {
	                    return (14*dy + 10*( dx - dy));
	                } else {
	                    return (14*dx + 10*( dy - dx));

	                }
	             
	     }
}
