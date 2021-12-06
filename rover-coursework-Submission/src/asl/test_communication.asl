// Agent test_communication in project ia_submission

/* Initial beliefs and rules */
type(scanner).
/* Initial goals */

!start.



+!start : true <- .all_names(L);
				  +agentNames(L);				  
				  !send_msg.
				  


+!send_msg: true <-   ?agentNames(L);
					  .length(L, Length);  					  
					  for (.range(I,0,Length-1)) {
					  		
					  		 
					      		.nth(I, L, AgentName);
					      		.print(AgentName);					      	
					      		.send(AgentName, tell, type(scanner));
					      	 
					  }
					   
					   .

+type(T)[source(Ag)]: true <- .print("message received from ", Ag, "Whos type is ", T).