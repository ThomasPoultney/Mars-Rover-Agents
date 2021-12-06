  
// Agent scanner in project ia_submission

/* Initial beliefs and rules */
type(collector).
xPosition(0).
yPosition(0).
distanceTravelledX(0).
distanceTravelledY(0).
finishedScanning(false).
maxCapacityOfCollectionRovers(6).
currentID(1).
numOfResourcesOnBoard(0).
dedicatedResourceType(null).

/* Initial goals */

!establish_comms.


/* Plans */


+!start : true <- .print("Agent Starting Up");				     	  
				  .all_names(L);
				  +agentNames(L);
				  .print(L);
				  !check_configuaration;
				  !print_agent_types;

				  !get_next_action.
	
	
+!establish_comms: true <-   .all_names(AgentNames);
					 		 .length(AgentNames, Length); 
					 		 .my_name(MyName); 	
					 		 ?type(MyType);						 		 			  
					 		 for (.range(I,0,Length-1)) {
					      		.nth(I, AgentNames, AgentName);
					      		//.print(AgentName);						      						      	
					      	 	.send(AgentName, tell, agentData([MyName,MyType,null]));
					 		 }	
					 		 !start					 		 
					 		 .				

+agentData([Name,Type,DedicatedResource])[source(Ag)]: true <- .print("message received from ", Ag, " Whos type is  ", Type, " and Resource is ", DedicatedResource);
																if(Type == scanner) {																	
																	+scannerAgent(Ag,Type);
																} else {																	
																	+collectorAgent(Ag,Type,DedicatedResource,0);
																}
																.				 				  			 
@print_agent_types[atomic]				
+!print_agent_types : true <- .findall(Ag, type(X,Ag), LAgs);
							  .print(Ag, " type is ", X).					  
				  


+!get_next_action : true <- .print("Calculating Next Action");																	
									.count(miningEvent(_,_,_,_,_), N)
									.print("There are currently ", N , " Mining Events");									
									if(N > 0) {
									 	.findall([ID, ResourceType, Quantity, XPos,YPos], miningEvent(ID,ResourceType,Quantity, XPos,YPos), ListOfMining);
										.length(ListOfMining,P);
										.print(P);
										.print(ListOfMining);										
										.nth(0, ListOfMining, InnerList);
					      			    .nth(0, InnerList, ID);
					      				.nth(1, InnerList, ResourceType);
					      				.nth(2, InnerList, Quantity);
					      				.nth(3, InnerList, XPos);
					      				.nth(4, InnerList, YPos);
					      				
					      				if(dedicatedResourceType(ResourceType) | dedicatedResourceType(null)) {
					      					!mine_resource(ID, ResourceType, Quantity, XPos, YPos);	
					      					.abolish(miningEvent(ID, ResourceType, Quantity, XPos, YPos))				      					
					      				} 
					      					
					      				
					      			}	
					      								
									!get_next_action.
																																							
									
@mine_resource[atomic]
+!mine_resource(ID, ResourceType, Quantity, XPos, YPos):  true
	<-  
		.print("Executing Mining Event"); 
		 ?xPosition(X);
		 ?yPosition(Y);
		 !move_to_resource(X,Y,XPos,YPos);
		 !collect_resource(ID, ResourceType, Quantity, XPos, YPos).
	
		 	
		
		       	
       	  
      	 									
-!mine_resource(ID, ResourceType, Quantity, XPos, YPos) : true <- .print("Failed to mine resource").

-!collect_resource(ID, ResourceType, Quantity, XPos, YPos): true <- .print("failed to collect").
									

-!deposit_resource(_,_): true <- .print("failed to deposit").	

-!move_to_resource(X,Y, XPos, YPos): true <- .print("failed to move to resource from ", x , " " , y, " to " , XPos, " ", YPos).
										    
	
@check_configuration[atomic]
+!check_configuaration :true <- .print("Checking and storing configuaration of agent and world");
			     rover.ia.check_config(Capacity,Scanrange,Resourcetype);
			     rover.ia.get_map_size(Width,Height);
			     -+capacity(Capacity);
			     -+scanRange(Scanrange);
			     -+resourceType(ResourceType);
			     -+mapWidth(Width);
			     -+mapHeight(Height);			     
			     !print_configuration.		

		     
+! print_configuration : true <- 
						  ?capacity(CurrentCapacity);
	   					  ?scanRange(CurrentScanRange);
	   					  ?resourceType(CurrentResourceType);
	   					  ?mapWidth(Width);
	   					  ?mapHeight(Height);
						  .print("Robot configuration is: capacity: ",CurrentCapacity, " Scan Range: ",CurrentScanRange, " Resource to collect: ", CurrentResourceType);
						  .print("Map Width is: ", Width, " Map Height is: ", Height).	
						  
@move_rover[atomic]	
+!move_rover(XDist,YDist) : true <- 
							move(XDist,YDist);
	   						?distanceTravelledX(X);
							?distanceTravelledY(Y);
							-+distanceTravelledX(X + XDist);
							-+distanceTravelledY(Y + YDist);							
							rover.ia.log_movement(XDist, YDist);
							!update_Position.
							
@update_Position[atomic]	
+!update_Position : true <- ?mapWidth(MapWidth);
						    ?mapHeight(MapHeight);
						    ?distanceTravelledX(XPosition);
						    ?distanceTravelledY(YPosition);
						    ia_submission.returnModulus(XPosition,MapWidth, XResult);
						    ia_submission.returnModulus(YPosition,MapHeight, YResult);
						    //.print("position of rover relative to base is x: ", XResult, " y: ",YResult);
						    -+xPosition(XResult);
						    -+yPosition(YResult).	
						    
+obstructed(_,_,_,_) : true <- .print("Obstructed by another agent").


@collect_resource[atomic]		 
+!collect_resource(ID, ResourceType, Quantity, XPos, YPos) :true <- ?capacity(Cap);	     		  
	     		  while(numOfResourcesOnBoard(R) & R <  Quantity) {    
        	      		 collect(ResourceType);
        	      		 -+dedicatedResourceType(ResourceType);
        	      		.findall([Ag,Type], scannerAgent(Ag,Type), ListOfScannerAgents);
        	      		 .length(ListOfScannerAgents, NumAgents);
	     	 			 for (.range(I,0,NumAgents-1)) {
	     	 			 	.nth(I, ListOfScannerAgents, Agent);
	     	 				.print(Agent);
	     	 				.nth(0, Agent, AgName);	
	     	 			 	.send(AgName,tell,dedicatedResource(ResourceType))	;					  					
	     	 			 	
	     	 			 }
       					-+numOfResourcesOnBoard(R+1);
        				 ?numOfResourcesOnBoard(Resources);        	
       					.print("numOfResourcesOnBoard is", Resources);       					     
        		  }
        		   .print("Removing Mining Event from belief base");
        		   !return_to_base;	
       	 		   !deposit_resource(ResourceType, Quantity);
        		  .

@deposit_resource[atomic]		 
+!deposit_resource(ResourceType, Quantity) : true <- 			 														
													 while(numOfResourcesOnBoard(R) & R >  0) { // where vl(X) is a belief     
											      		deposit(ResourceType);
											        	-+numOfResourcesOnBoard(R-1);
											       		 ?numOfResourcesOnBoard(Resources);
											        	.print("numOfResourcesOnBoard is", Resources);      
											     	 } 
											        .
											     	 
      											     	
      											     
@move_to_resource[atomic]
+!move_to_resource(CurrentX, CurrentY, TargetXPos, TargetYPos) : not((CurrentX == TargetXPos) & (CurrentY == TargetYPos)) <- 
																			  .print("Moving to Next Resource Location");
																		      ?mapWidth(MapWidth);
	   																		  ?mapHeight(MapHeight);	   																		  
																			  while((xPosition(X) & X \== TargetXPos) | (yPosition(Y) & Y \== TargetYPos)) {																			  															  	  
																			  	?xPosition(X);
																			  	?yPosition(Y);	
																			  	.findall([ResourceKind,XPos,YPos], obstacleAt(ResourceKind,XPos,YPos), ListOfDiscoveredResources);	
																			  	//.print(ListOfDiscoveredResources);    			
																			  	.findall([XPos,YPos], scanned(XPos,YPos), ListOfScanned);															  	
																			  	ia_submission.astarsearch(X, Y, TargetXPos, TargetYPos, MapWidth, MapHeight, ListOfDiscoveredResources, ListOfScanned, XMoveOffSet, YMoveOffSet);
																			  	!move_rover(XMoveOffSet, YMoveOffSet); 
																			  }.																		  

			 
																			  	
@return_to_base[atomic]	        
+!return_to_base: true <- .print("Returning to base");
						 ?xPosition(CurrentX);
						 ?yPosition(CurrentY);	 	
						 !move_to_resource(CurrentX,CurrentY,0,0).																			  			   
						          											     									    
						    						  			     	
			