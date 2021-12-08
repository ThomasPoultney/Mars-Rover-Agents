  
// Agent scanner in project ia_submission

/* Initial beliefs and rules */
type(scanner).
xPosition(0).
yPosition(0).
distanceTravelledX(0).
distanceTravelledY(0).
finishedScanning(false).
maxCapacityOfCollectionRovers(6).
currentID(1).
baseLocationX(0).
baseLocationY(0).
randomMovementValues([0,1,2]).

/* Initial goals */


!establish_comms.


/* Plans */


+!start : true <- .print("Agent Starting Up");					      	  				 
				  !check_configuaration;
				  !print_agent_types;
				  !rover_scan;
				  !get_next_action.
				


+!establish_comms: true <-   .all_names(AgentNames);
					 		 .length(AgentNames, Length); 
					 		 .my_name(MyName); 	
					 		 ?type(MyType);						 		 			  
					 		 for (.range(I,0,Length-1)) {
					      		.nth(I, AgentNames, AgentName);
					      		.print(AgentName);						      						      	
					      	 	.send(AgentName, tell, agentData([MyName,MyType,null]));
					 		 }	
					 		 .wait(2000);
					 		 !start					 		 
					 		 .
					 		 				 		 	  							   		
					   					 


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
								

				  			 
@print_agent_types[atomic]				
+!print_agent_types : true <- .findall(Ag, type(X,Ag), LAgs);
							  .print(Ag, " type is ", X).					  
				  


+!get_next_action : true <- .print("Calculating Next Action");																	
									if(finishedScanning(false)) {
										!get_next_scan_spot;
										?nextScanLocationX(ScanLocationX);
						   				?nextScanLocationY(ScanLocationY);
						   				.abolish(nextScanLocationX);
						   				.abolish(nextScanLocationY);
						   										   										   					    
										?xPosition(XPosition);
										?yPosition(YPosition);
										!move_to_next_scan_spot(XPosition, YPosition, ScanLocationX, ScanLocationY);
										
									}else {
										.print("We have scanned all tiles :)");
										.findall([XPos,YPos], scanned(XPos,YPos), ListOfScanned);
										 ?mapWidth(MapWidth);
	   									 ?mapHeight(MapHeight);	 															  											
										 ia_submission.debug_print_all_scanned(ListOfScanned, MapWidth, MapHeight);
										.wait(40000);										
									}
									!get_next_action
									.																																	
									
									
			  

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
							   .wait(10000).
							   
@return_to_base[atomic]	        
+!return_to_base: true <- .print("Returning to base");
						 ?xPosition(CurrentX);
						 ?yPosition(CurrentY);						 	
						 ?baseLocationX(BaseX);
						 ?baseLocationY(BaseY);
						 !move_to_next_scan_spot(CurrentX,CurrentY,BaseX,BaseY).		
							 						   

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
																			  !rover_scan;
																			  .																		
																			  

																								
																								
-!move_to_next_scan_spot(X,Y, XPos, YPos): true <- .print("failed to move to scan spot from ", x , " " , y, " to " , XPos, " ", YPos);											 
											 ?randomMovementValues(L);
											 .shuffle(L,ShuffledList);
											 .nth(0,ShuffledList, RandXMovement);
											 .shuffle(ShuffledList,ShuffledShuffledList);
											 .nth(0,ShuffledShuffledList, RandYMovement);											 
											 .print("Making random move: " , X ," , " , Y , " To try recover");
											 !move_rover(RandXMovement, RandYMovement). 
																		  
				

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
					      
	
					      
@move_rover[atomic]	
+!move_rover(XDist,YDist) : true <- 
							move(XDist,YDist);
	   						?distanceTravelledX(X);
							?distanceTravelledY(Y);
							-+distanceTravelledX(X + XDist);
							-+distanceTravelledY(Y + YDist);							
							rover.ia.log_movement(XDist, YDist);
							!update_Position.
							
-!move_rover(_,_): true <- .print("Failed to move, waiting then trying again...").


-!move_rover: true <- .print("Failed to move, waiting then trying again...").							
							
							
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

 // go to resource found
 @resource_found[atomic,priority(100000)]
 +resource_found(ResourceType, Quantity, XDist, YDist):  true
	<-   .print("Found Resource")
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
		     	     	 
		     	 .findall([Ag,Type,DedicatedResource, NumAssignedTrips], collectorAgent(Ag,Type,DedicatedResource, NumAssignedTrips), ListOfCollectorAgent);
		     	 .print("THE LIST OF COLLECTORS ARE: " , ListOfCollectorAgent);	
		     	 .length(ListOfCollectorAgent, NumAgents);
		     	 for (.range(I,0,NumAgents-1)) {
		     	 	.nth(I, ListOfCollectorAgent, Agent);
		     	 	.print(Agent);
		     	 	.nth(0, Agent, AgName);	     	 	
		     	 	.nth(2, Agent, AgResourceType);
		     	 	.nth(3, Agent, NumAssignedTrips);
		     	 	if(ResourceType == AgResourceType | AgResourceType == null) {		     	 		 
		     	 		 +viableAgentsForTrip(AgName);
		     	 		 .print("Adding Viable Agent ", AgName);
		     	 	}
		     	 }
		     	 		     	
		     	.findall([AgName], viableAgentsForTrip(AgName), ListOFViableAgents);
		     	.shuffle(ListOFViableAgents, ShuffledListOFViableAgents);
				.print("The List of viable agents are: ",ListOFViableAgents);
		     	.nth(0, ShuffledListOFViableAgents, NameOfAgentMakingTheTrip); 
		     	.print(NameOfAgentMakingTheTrip);
		     	.abolish(viableAgentsForTrip(_));
		     	 ?maxCapacityOfCollectionRovers(MaxCap);		     	 
		     	 if(Quantity > MaxCap) {
		     	 	.print("Collecting the Resource Takes Multiple Trips");
		     	 	ia_submission.calcNumTrips(MaxCap, Quantity, ListOfTrips);	     	 		     	 		     	 	
		     	 	.length(ListOfTrips, Length);
		     	 	?currentID(CurrID);
					for (.range(I,0,Length-1)) {										 								      	
						.nth(I, ListOfTrips, QuanForTrip);
						.print(QuanForTrip);
						+miningEvent(CurrID, ResourceType, QuanForTrip, XResult, YResult);				
						.send(NameOfAgentMakingTheTrip,tell,miningEvent(CurrID, ResourceType,QuanForTrip,XResult,YResult));	
						-+currentID(CurrID + I);				  										 
					 }   	     	 	
		     	 } else {
		     	 	 ?currentID(CurrID);	
		     	 	 +miningEvent(CurrID, ResourceType, Quantity, XResult, YResult);
		     	 	 .send(NameOfAgentMakingTheTrip,tell,miningEvent(CurrID, ResourceType,Quantity,XResult,YResult))	;					  					
		     	 	 
		     	 }    		     	 

	    	 	.broadcast(tell,resourceAt(ResourceType,XResult,YResult))	
	     	}
	     }
	     
	     .  
	     	

 +resource_not_found: true
   <-  	.print("I found nothing, I am moving again....").

   



   
    		  
	     
	    

	
