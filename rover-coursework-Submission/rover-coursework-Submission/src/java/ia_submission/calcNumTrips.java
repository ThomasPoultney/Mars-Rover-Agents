// Internal action code for project ia_submission

package ia_submission;

import java.util.ArrayList;
import java.util.List;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class calcNumTrips extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
       
    	
    	int maxCapacity = (int)((NumberTerm) args[0]).solve(); 
    	int quantityOfResource = (int)((NumberTerm) args[1]).solve(); 
        
    
    	List<Integer> trips = new ArrayList<Integer>();
    	int count = 0;
    	while(count < quantityOfResource) {
    		
    		if(count + maxCapacity < quantityOfResource) {
    			trips.add(maxCapacity);
    			count += maxCapacity;
    		} else {
    			trips.add(quantityOfResource - count);
    			count += quantityOfResource - count;
    		}
    	   		
    	}
    	
    	
    	ListTerm tripOutput = new ListTermImpl();
    	
    	for(Integer trip : trips) {
    		NumberTerm tripTerm =  new NumberTermImpl(trip);	    		    		
    		tripOutput.add(tripTerm);
    	}
    	
    	//everything ok, so returns true
    	return un.unifies(tripOutput, args[2]);
    
    }
}
