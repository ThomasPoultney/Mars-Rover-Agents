  
// Agent scanner in project ia_submission

/* Initial beliefs and rules */
type(hybrid).
xPosition(0).
yPosition(0).
distanceTravelledX(0).
distanceTravelledY(0).
finishedScanning(false).
maxCapacityOfCollectionRovers(2).
currentID(1).
numOfResourcesOnBoard(0).
dedicatedResourceType(null).
baseLocationX(0).
baseLocationY(0).
randomMovementValues([0,1,2]).

/* Initial goals */


!start.

/* Plans */


+!start : true <- .print("Agent Starting Up");					      	  				 
				  !check_configuaration;
				  !establish_comms;
				  .random(X);
				  .wait(X * 5000);
				  !rover_scan;
				  !get_next_action.
				  
	
	
+!establish_comms: true <-   .all_names(AgentNames);
					 		 .length(AgentNames, Length); 
					 		 .my_name(MyName); 					 		 
					 		 .print(X);	
					 		 ?type(MyType);			
					 		 ?resourceType(ResourceType);					 				 		 			  
					 		 for (.range(I,0,Length-1)) {
					      		.nth(I, AgentNames, AgentName);
					      		//.print(AgentName);						      						      	
					      	 	.send(AgentName, tell, agentData([MyName,MyType,ResourceType]));
					 		 }	
					 		 .wait(2000).
					 						 						 		 
@check_configuration[atomic]
+!check_configuaration :true <- .print("Checking and storing configuaration of agent and world");
			     rover.ia.check_config(Capacity,Scanrange,Resourcetype);
			     rover.ia.get_map_size(Width,Height);
			     -+capacity(Capacity);
			     -+scanRange(Scanrange);
			     -+resourceType(Resourcetype);
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

+agentData([Name,Type,ResourceType])[source(Ag)]: true <- .print("message received from ", Ag, " Whos type is  ", Type, " and Resource is ", ResourceType);
																if(Type == scanner | Type == hybrid) {																	
																	+scannerAgent(Ag,Type);
																} 
																
																if(Type == collector | Type == hybrid)	{																
																	+collectorAgent(Ag,Type,ResourceType,0);
																}
																.				 				  			 


+dedicatedResource(T)[source(Ag)]: true <- 	.print("message received from ", Ag, " Who's dedicated Resource is ", T);
											-+collectorAgent(Ag,T). 	

+!get_next_action : true <- .print("Calculating Next Action");																	
									.count(miningEvent(_,_,_,_,_), N)
									.print("There are currently ", N , " Mining Events");
									?numOfResourcesOnBoard(NumResourcesOnBoard);
																		
									if(NumResourcesOnBoard \== 0) {
										!return_to_base;
										
										?xPosition(CurrX);
										?yPosition(CurrY);
										?baseLocationX(BaseX);
										?baseLocationY(BaseY);										
										if(CurrX == BaseX & CurrY == BaseY) {
											?numOfResourcesOnBoard(R);
											?dedicatedResourceType(Q);
											!deposit_resource(R,Q);
											.abolish(activeMiningEvent(_,_,_,_,_));
										}	
										
									} else {
										
										.count(activeMiningEvent(_,_,_,_,_), NumActiveMiningEvents);
										if(NumActiveMiningEvents > 0) {
											?activeMiningEvent(ID, ResourceType, Quantity, XPos,YPos);
											!mine_resource(ID, ResourceType, Quantity, XPos, YPos);
										} else {
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
							      					+activeMiningEvent(ID, ResourceType, Quantity, XPos, YPos);
							      					.abolish(miningEvent(ID, ResourceType, Quantity, XPos, YPos))	
							      						
							      				} 
						      					
						      				
											} else {
												!get_next_scan_spot;
												?nextScanLocationX(ScanLocationX);
						   					    ?nextScanLocationY(ScanLocationY);
						   					    .abolish(nextScanLocationX(_));
						   					    .abolish(nextScanLocationY(_));						   					    
											    ?xPosition(XPosition);
											    ?yPosition(YPosition);
												!move_to_next_scan_spot(XPosition, YPosition, ScanLocationX, ScanLocationY);
												
											}
					      			}
					      				
									 
									}
									.wait(1000);																					
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

-!move_to_resource(X,Y, XPos, YPos): true <- .print("failed to move to resource from ", x , " " , y, " to " , XPos, " ", YPos);
											 
											 ?randomMovementValues(L);
											 .shuffle(L,ShuffledList);
											 .nth(0,ShuffledList, RandXMovement);
											 .shuffle(ShuffledList,ShuffledShuffledList);
											 .nth(0,ShuffledShuffledList, RandYMovement);											 
											 .print("Making random move: " , X ," , " , Y , " To try recover");
											 !move_rover(RandXMovement, RandYMovement).

@get_next_scan_spot[atomic]					  
+!get_next_scan_spot : true <- .print("Getting Next Scan Location");
							?xPosition(XPosition);
							?yPosition(YPosition);
							?mapWidth(Width);
	   					  	?mapHeight(Height);
	   					  	.findall([XPos,YPos], scanned(XPos,YPos), ListOfScannedTiles);	
	   					  	//.print(ListOfScannedTiles);
							.findall([ResourceKind,XPos,YPos], obstacleAt(ResourceKind,XPos,YPos), ListOfDiscoveredObstacles);	    																	  	
	   					  	//.print(ListOfDiscoveredObstacles);
	   					  	?scanRange(ScanRange);
						    ia_submission.getNextScanLocation(XPosition, YPosition, Width, Height, ListOfDiscoveredObstacles, ListOfScannedTiles, ScanRange, ScanLocationX, ScanLocationY);
						    -+nextScanLocationX(ScanLocationX);
						    -+nextScanLocationY(ScanLocationY).							    						    

				    
-!get_next_scan_spot : true <- .print("Error finding a scan Location, Trying again");
							   ?mapWidth(MapWidth);
	   						   ?mapHeight(MapHeight);	 
	   						   .findall([XPos,YPos], scanned(XPos,YPos), ListOfScanned);		   						   	
							   ia_submission.debug_print_all_scanned(ListOfScanned, MapWidth, MapHeight);
							   !return_to_base;							   
							   .wait(3000).										    


@move_to_next_scan_spot[atomic]
+!move_to_next_scan_spot(CurrentX, CurrentY, TargetXPos, TargetYPos) : not((CurrentX == TargetXPos) & (CurrentY == TargetYPos)) <- 
																			  .print("Moving to Next Scan Location X:", TargetXPos, " Y: ", TargetYPos);
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
																			  }																			  
																			  !rover_scan.


-!move_to_next_scan_spot(CurrentX, CurrentY, TargetXPos, TargetYPos) : (CurrentX == TargetXPos) & (CurrentY == TargetYPos) <- .print("Already at scan location").																	  
																			  

@rover_scan[atomic]
+!rover_scan : true <-   .print("Rover Scanning and then updating scanned Locations");
						 ?scanRange(ScanRange);
						 ?xPosition(X);
						 ?yPosition(Y);
						 ?mapWidth(MapWidth);
	   					 ?mapHeight(MapHeight);	 
						 scan(ScanRange);
					     ia_submission.calculateScannedTiles(X, Y, ScanRange, MapWidth, MapHeight,  ListOFScannedTiles);
					     //.print("The tiles that were scanned are", ListOFScannedTiles);	
					     .length(ListOFScannedTiles, Length);  
					     for (.range(I,0,Length-1)) {
					      	.nth(I, ListOFScannedTiles, InnerList);
					      	.nth(0, InnerList, XScannedPos);
					      	.nth(1, InnerList, YScannedPos);
					      	+scanned(XScannedPos, YScannedPos);
					      	.broadcast(tell,scanned(XScannedPos, YScannedPos));
					      }
					      .
					      
 // go to resource found
 @resource_found[atomic,priority(100000)]
 +resource_found(ResourceType, Quantity, XDist, YDist):  true
	<-   .print("Found Resource");
		 ?xPosition(X);
		 ?yPosition(Y);
		 ?mapWidth(MapWidth);
		 ?mapHeight(MapHeight);  
		 ia_submission.returnModulus(XDist,MapWidth, NewXDist);
		 ia_submission.returnModulus(YDist,MapHeight, NewYDist);	
		 ia_submission.returnModulus(X+NewXDist, MapWidth, XResult);
	     ia_submission.returnModulus(Y+NewYDist, MapHeight, YResult);
	     
	     .findall([Res,XRe,YRe], resourceAt(Res,XRe,YRe), ListOfResourcesFound);
		 .print("The List of resources found so far are: " ,ListOfResourcesFound);
	 
		 if(not(.member([ResourceType,XResult,YResult], ListOfResourcesFound))) {
		 	.print("We havent found this resource yet, creating a new mining event");
		 	
		     if(ResourceType == "Obstacle") {
		     	 .broadcast(tell, obstacleAt(ResourceType,XResult,YResult));	
		     	 +obstacleAt(ResourceType,XResult,YResult)
		     } else {
		     	 +resourceAt(ResourceType,XResult,YResult);
		     	  
		     	  ?dedicatedResourceType(MyType);
		     	  if(MyType == ResourceType | MyType == null) {
		     	  	.my_name(MyName);
		     	  	+viableAgentsForTrip(MyName);
		     	  } else {
		     	  	 .print("Checking if other agents are viable");
		     	  	 .findall([Ag,Type,DedicatedResource, NumAssignedTrips], collectorAgent(Ag,Type,DedicatedResource, NumAssignedTrips), ListOfCollectorAgent);
		     	  	 .print("THE LIST OF COLLECTORS ARE: " , ListOfCollectorAgent);	
		     		 .length(ListOfCollectorAgent, NumAgents);
		     		 for (.range(I,0,NumAgents-1)) {
		     	 		.nth(I, ListOfCollectorAgent, Agent);
			     	 	.print(Agent);
			     	 	.nth(0, Agent, AgName);	     	 	
			     	 	.nth(2, Agent, AgResourceType);
			     	 	.nth(3, Agent, NumAssignedTrips);
		     	 	
			     	 	.my_name(MyName);
			     	 	if((ResourceType == AgResourceType | AgResourceType == null)) {		     	 		 
			     	 		 +viableAgentsForTrip(AgName);
			     	 	}
		     		 }
		     	  }  	 
		     	
		     	 		     	
		     	.findall([AgName], viableAgentsForTrip(AgName), ListOFViableAgents);
		     	.shuffle(ListOFViableAgents, ShuffledListOFViableAgents);
				.print("The List of viable agents are: ",ShuffledListOFViableAgents);
		     	.nth(0, ShuffledListOFViableAgents, NameOfAgentMakingTheTrip);
		     	.nth(0, ShuffledListOFViableAgents, CapacityOfAgentMakingTheTrip);
		     	 
		     	.print(NameOfAgentMakingTheTrip);
		     	.abolish(viableAgentsForTrip(_));
		     	?maxCapacityOfCollectionRovers(MaxCap);     	 
		     	 if(Quantity > MaxCap) {
		     	 	
		     	 	ia_submission.calcNumTrips(MaxCap, Quantity, ListOfTrips);	     	 		     	 		     	 	
		     	 	.length(ListOfTrips, Length);
		     	 	.print("Collecting the Resource Takes ", Length ," Trips");
					for (.range(I,0,Length-1)) {
						?currentID(CurrID);											 								      	
						.nth(I, ListOfTrips, QuanForTrip);
						+miningEvent(CurrID, ResourceType, QuanForTrip, XResult, YResult);	
																														
						.my_name(MyName);
						if(NameOfAgentMakingTheTrip \== MyName) {							
							.send(NameOfAgentMakingTheTrip,tell,miningEvent(CurrID, ResourceType,QuanForTrip,XResult,YResult));								
						}
						-+currentID(CurrID + 1);				  										 
					 }   	     	 	
		     	 } else {
		     	 	 ?currentID(CurrID);	
		     	 	 +miningEvent(CurrID, ResourceType, Quantity, XResult, YResult);		     	 	 
		     	 	 .my_name(MyName);
					 if(NameOfAgentMakingTheTrip \== MyName) {
						.send(NameOfAgentMakingTheTrip,tell,miningEvent(CurrID, ResourceType,QuanForTrip,XResult,YResult));								
					 }
		     	 	 
		     	 }    		     	 

	    	 	.broadcast(tell,resourceAt(ResourceType,XResult,YResult))	
	     	}
	     }	     
	     .  					      																			  			

						  
@move_rover[atomic]	
+!move_rover(XDist,YDist) : true <- 
							move(XDist,YDist);
	   						?distanceTravelledX(X);
							?distanceTravelledY(Y);
							-+distanceTravelledX(X + XDist);
							-+distanceTravelledY(Y + YDist);							
							rover.ia.log_movement(XDist, YDist);
							!update_Position.
							
-!move_rover(XDist,YDist) : true <- .print("Failed to move, trying again").							
							
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
	   																		   																		  
																			  while((xPosition(X) & X \== TargetXPos) | (yPosition(Y) & Y \== TargetYPos))	{
																			    ?xPosition(X);
																			  	?yPosition(Y);																		  															  	  																			  	
																			  	.findall([ResourceKind,XPos,YPos], obstacleAt(ResourceKind,XPos,YPos), ListOfDiscoveredResources);	
																			  	//.print(ListOfDiscoveredResources);    			
																			  	.findall([XPos,YPos], scanned(XPos,YPos), ListOfScanned);															  	
																			  	ia_submission.astarsearch(X, Y, TargetXPos, TargetYPos, MapWidth, MapHeight, ListOfDiscoveredResources, ListOfScanned, XMoveOffSet, YMoveOffSet);
																			  	!move_rover(XMoveOffSet, YMoveOffSet);																			  	
																			  }.																		  

			 


+!move_to_resource(CurrentX, CurrentY, TargetXPos, TargetYPos) : (CurrentX == TargetXPos) & (CurrentY == TargetYPos) <- .print("Already at location").		
								  	
@return_to_base[atomic]	        
+!return_to_base: true <- .print("Returning to base");
						 ?xPosition(CurrentX);
						 ?yPosition(CurrentY);	 	
						 ?baseLocationX(BaseX);
						 ?baseLocationY(BaseY);
						 !move_to_resource(CurrentX,CurrentY,BaseX,BaseY).																			  			   
						          											     									    
						    						  			     	
			