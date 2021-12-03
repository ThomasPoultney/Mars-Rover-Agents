// Internal action code for project ia_submission

package ia_submission;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class returnModulus extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        
    	int xPosition = (int)((NumberTerm) args[0]).solve(); 
    	int width = (int)((NumberTerm) args[1]).solve(); 
    	int modulus;
    	modulus =  Math.floorMod(xPosition,width);	
    	
    
        return un.unifies(new NumberTermImpl(modulus), args[2]);
    }
      
}



