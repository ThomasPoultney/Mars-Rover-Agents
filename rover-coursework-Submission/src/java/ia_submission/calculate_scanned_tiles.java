// Internal action code for project ia_submission

package ia_submission;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class calculate_scanned_tiles extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        // execute the internal action
        ts.getAg().getLogger().info("executing internal action 'ia_submission.calculate_scanned_tiles'");
        if (true) { // just to show how to throw another kind of exception
            throw new JasonException("not implemented!");
        }

        // everything ok, so returns true
        return true;
    }
}
