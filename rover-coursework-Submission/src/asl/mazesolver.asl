  
// Agent scanner in project ia_submission

/* Initial beliefs and rules */
type(collector).
xPosition(0).
yPosition(0).
distanceTravelledX(0).
distanceTravelledY(0).
finishedScanning(false).
maxCapacityOfCollectionRovers(5).
currentID(1).
numOfResourcesOnBoard(0).
dedicatedResourceType(null).
baseXPosition(20).
baseYPosition(29).
randomMovementValues([-1,0,1]).



/* Initial goals */


!establish_comms.


/* Plans */


+!start : true <- .print("Agent Starting Up");					      	  				 
				 !check_configuaration;
				 
				 .random(R);
				  .all_names(AgentNames);
				  .length(AgentNames, Length); 
				  .my_name(MyName); 					  
				   for (.range(I,0,Length-1)) {
					    .nth(I, AgentNames, AgentName);
					   if(AgentName = MyName) {
					   	   .wait((I * 1.5) * 15000);
					   	   if(I == 0) {
					   	   	!rover_scan;					   	   	
					   	   }
					   }					      						      	
				  }					
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
					 		 .wait(2000);
					 		 !start					 		 
					 		 .
					 		 				 		 	  							   		
					   					 


+agentData([Name,Type,DedicatedResource])[source(Ag)]: true <- //.print("message received from ", Ag, " Whos type is  ", Type, " and Resource is ", DedicatedResource);
																if(Type == scanner) {																	
																	+scannerAgent(Ag,Type);
																} else {																	
																	+collectorAgent(Ag,Type,DedicatedResource,0);
																}
																.
+dedicatedResource(T)[source(Ag)]: true <- 	//.print("message received from ", Ag, " Who's dedicated Resource is ", T);
											-+collectorAgent(Ag,T). 					 
								

				  			 
@print_agent_types[atomic]				
+!print_agent_types : true <- .findall(Ag, type(X,Ag), LAgs).
							  //.print(Ag, " type is ", X).					  
				  


+!get_next_action : true <- //.print("Calculating Next Action");																	
									.count(miningEvent(_,_,_,_,_), N)
									//.print("There are currently ", N , " Mining Events");
									
									?xPosition(XLoc);
									?yPosition(YLoc);
									?baseXPosition(BaseXLoc);
									?baseYPosition(BaseYLoc);
									?numOfResourcesOnBoard(R);
									?mapWidth(MapWidth);
	   								?mapHeight(MapHeight);	
									.findall([XPos,YPos], scanned(XPos,YPos), ListOfScannedTiles);	
									.findall([ResourceKind,XPos,YPos], obstacleAt(ResourceKind,XPos,YPos), ListOfDiscoveredObstacles);	    													
									//.print(XMoveOffSet,YMoveOffSet);									
									 ia_submission.returnModulus(XLoc + 1, MapWidth, TileToRight);
									 ia_submission.returnModulus(XLoc - 1, MapWidth, TileToLeft);
						    		 ia_submission.returnModulus(YLoc + 1,  MapHeight, TileAbove);	
									 ia_submission.returnModulus(YLoc - 1,  MapHeight, TileBelow);																			
									if(not(.member([TileToRight, YLoc],ListOfScannedTiles)) | not(.member([TileToLeft, YLoc],ListOfScannedTiles)) | not(.member([XLoc, TileAbove],ListOfScannedTiles)) | not(.member([XLoc, TileBelow],ListOfScannedTiles))) {
										.print("Neighbour is unscanned, Scanning");
										!rover_scan;
									}
									
								
									
									if(XLoc == BaseXLoc & YLoc == BaseYLoc & R > 0) {
										.print("At Base");
										?dedicatedResourceType(Type)
										
										!deposit_resource(Type, R);
									} else {
										 ?scanRange(ScanRange);
										 ia_submission.astarsearchwithbool(XLoc, YLoc, BaseXLoc, BaseYLoc, MapWidth, MapHeight, ListOfDiscoveredObstacles,ListOfScannedTiles, XMoveOffSet, YMoveOffSet);							
										 ia_submission.getNextScanLocation(XLoc, YLoc, MapWidth, MapHeight, ListOfDiscoveredObstacles, ListOfScannedTiles, ScanRange, ScanLocationX, ScanLocationY);						    						    
						   				
										if(not(XMoveOffSet == 0 & YMoveOffSet == 0) & (ScanLocationX == 0 & ScanLocationY == 0)) {
											.print("Base Location is known and all tiles are scanned, returning to base now");
										
											!return_to_base;
										}
									
										if(N > 0) {
										 	.findall([ID, ResourceType, Quantity, XPos,YPos], miningEvent(ID,ResourceType,Quantity, XPos,YPos), ListOfMining);
											.length(ListOfMining,P);
											//.print(P);
											//.print(ListOfMining);	
											for (.range(I,0,P - 1)) {									
												.nth(I, ListOfMining, InnerList);
							      			    .nth(0, InnerList, ID);
							      				.nth(1, InnerList, ResourceType);
							      				.nth(2, InnerList, Quantity);
							      				.nth(3, InnerList, XPosOfResource);
							      				.nth(4, InnerList, YPosOfResource);		
							      				?maxCapacityOfCollectionRovers(MaxCap);
							      						      				
							      				if((dedicatedResourceType(ResourceType) | dedicatedResourceType(null)) & (XLoc == XPosOfResource & YLoc == YPosOfResource) & (R + Quantity) <= MaxCap) {
							      					!collect_resource(ID, ResourceType, Quantity, XPos, YPos);
							      					.abolish(miningEvent(ID, ResourceType, Quantity, XPos, YPos))				      					
							      				} 
						      				}
						      				
										} 											
											
																						
											!get_next_scan_spot;
																			
									}
									!get_next_action
									.				
									
@return_to_base[atomic]	        
+!return_to_base: true <- //.print("Returning to base");
						 ?xPosition(CurrentX);
						 ?yPosition(CurrentY);	 	
						 ?baseXPosition(BaseX);
						 ?baseYPosition(BaseY);
						 !move_to_resource(CurrentX,CurrentY,BaseX,BaseY).																																
									
									
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


@collect_resource[atomic]		 
+!collect_resource(ID, ResourceType, Quantity, XPos, YPos) :true <- ?capacity(Cap);	     		  
	     		  while(numOfResourcesOnBoard(R) & R <  Quantity) {    
        	      		 collect(ResourceType);
        	      		 -+dedicatedResourceType(ResourceType);
        	      		.findall([Ag,Type], scannerAgent(Ag,Type), ListOfScannerAgents);
        	      		 .length(ListOfScannerAgents, NumAgents);
	     	 			 for (.range(I,0,NumAgents-1)) {
	     	 			 	.nth(I, ListOfScannerAgents, Agent);
	     	 				//.print(Agent);
	     	 				.nth(0, Agent, AgName);	
	     	 			 	.send(AgName,tell,dedicatedResource(ResourceType))	;					  						     	 			 	
	     	 			 }
       					-+numOfResourcesOnBoard(R+1);
        				 ?numOfResourcesOnBoard(Resources);        	
       					//.print("numOfResourcesOnBoard is", Resources);       					     
        		  }
        		  // .print("Removing Mining Event from belief base");        		 
        		  .

@deposit_resource[atomic]		 
+!deposit_resource(ResourceType, Quantity) : true <- 			 														
													 while(numOfResourcesOnBoard(R) & R >  0) { // where vl(X) is a belief     
											      		deposit(ResourceType);
											        	-+numOfResourcesOnBoard(R-1);
											       		 ?numOfResourcesOnBoard(Resources);
											        	//.print("numOfResourcesOnBoard is", Resources);      
											     	 } 
											        .
											     	 
      											     	
      											     
@move_to_resource[atomic]
+!move_to_resource(CurrentX, CurrentY, TargetXPos, TargetYPos) : not((CurrentX == TargetXPos) & (CurrentY == TargetYPos)) <- 
																			  //.print("Moving to Next Resource Location");
																		      ?mapWidth(MapWidth);
	   																		  ?mapHeight(MapHeight);	   																		  
																			  	?xPosition(X);
																			  	?yPosition(Y);	
																			  	.findall([ResourceKind,XPos,YPos], obstacleAt(ResourceKind,XPos,YPos), ListOfDiscoveredResources);	
																			  	//.print(ListOfDiscoveredResources);    			
																			  	.findall([XPos,YPos], scanned(XPos,YPos), ListOfScanned);															  	
																			  	ia_submission.astarsearchwithbool(X, Y, TargetXPos, TargetYPos, MapWidth, MapHeight, ListOfDiscoveredResources, ListOfScanned, XMoveOffSet, YMoveOffSet);
																			  	if(not(XMoveOffSet == 0 &  YMoveOffSet == 0)) {
																			  		!move_rover(XMoveOffSet, YMoveOffSet); 
																	  		
																			  	}
																			    .																		  
-!move_rover(XDist,YDist) : true <- .print("failed to move");
									.wait(2000).											 
											
																												  

									
			 			  

@check_configuration[atomic]
+!check_configuaration :true <- //.print("Checking and storing configuaration of agent and world");
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
	   					  ?mapHeight(Height).
						  //.print("Robot configuration is: capacity: ",CurrentCapacity, " Scan Range: ",CurrentScanRange, " Resource to collect: ", CurrentResourceType);
						  //.print("Map Width is: ", Width, " Map Height is: ", Height).	

@get_next_scan_spot[atomic]					  
+!get_next_scan_spot : true <- //.print("Getting Next Scan Location");
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
						    if(not(ScanLocationX == 0 & ScanLocationY == 0)) {
						    	!move_to_next_scan_spot(XPosition, YPosition, ScanLocationX, ScanLocationY);						    							    							    	
						    }.

				    
-!get_next_scan_spot : true <- .print("Error finding a scan Location, Trying again");
							   .
							   

							 						   

@move_to_next_scan_spot[atomic]
+!move_to_next_scan_spot(CurrentX, CurrentY, TargetXPos, TargetYPos) : not((CurrentX == TargetXPos) & (CurrentY == TargetYPos)) <- 
																			  //.print("Moving to Next Scan Location X:", TargetXPos, " Y: ", TargetYPos);
																		      ?mapWidth(MapWidth);
	   																		  ?mapHeight(MapHeight);	   																		  
																			  ?xPosition(X);
																			  ?yPosition(Y);	
																			  .findall([ResourceKind,XPos,YPos], obstacleAt(ResourceKind,XPos,YPos), ListOfDiscoveredResources);	
																			  //.print(ListOfDiscoveredResources);    			
																			  .findall([XPos,YPos], scanned(XPos,YPos), ListOfScanned);															  	
																			  ia_submission.astarsearchwithbool(X, Y, TargetXPos, TargetYPos, MapWidth, MapHeight, ListOfDiscoveredResources, ListOfScanned, XMoveOffSet, YMoveOffSet);
																			  if(not(XMoveOffSet == 0 &  YMoveOffSet == 0)) {
																			  		!move_rover(XMoveOffSet, YMoveOffSet); 																	  		
																			   }
																			   .
																			    
															  																			    																	  																			  
																			    																				    																		
-!move_to_next_scan_spot(X,Y, XPos, YPos): true <- .print("failed to move to resource from ", x , " " , y, " to " , XPos, " ", YPos);											 
											 .																		  

																								
																								
-!move_to_next_scan_spot(_,_,_,_) : true <- .print("unable to move to scan location").																								  
																		 			   			 		

@rover_scan[atomic]
+!rover_scan : true <-   //.print("Rover Scanning and then updating scanned Locations");
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
	<-   //.print("Found Resource")
		 ?xPosition(X);
		 ?yPosition(Y);
		 ?mapWidth(MapWidth);
		 ?mapHeight(MapHeight);  
		 ia_submission.returnModulus(XDist,MapWidth, NewXDist);
		 ia_submission.returnModulus(YDist,MapHeight, NewYDist);	
		 ia_submission.returnModulus(X+NewXDist, MapWidth, XResult);
	     ia_submission.returnModulus(Y+NewYDist, MapHeight, YResult);
	     if(ResourceType == "Obstacle") {
	     	 .broadcast(tell, obstacleAt(ResourceType,XResult,YResult));	
	     	 +obstacleAt(ResourceType,XResult,YResult)
	     } else {
	     	 +resourceAt(ResourceType,Quantity,XResult,YResult);
	     	 ?maxCapacityOfCollectionRovers(MaxCap);	     	  	 	     	 
	     	 if(Quantity > MaxCap) {
	     	 	//.print("Collecting the Resource Takes Multiple Trips");
	     	 	ia_submission.calcNumTrips(MaxCap, Quantity, ListOfTrips);	     	 		     	 		     	 	
	     	 	.length(ListOfTrips, Length);
	     	 	
				for (.range(I,0,Length-1)) {
					 ?currentID(CurrID);								      	
					.nth(0, ListOfTrips, QuanForTrip);
					 +miningEvent(CurrID,ResourceType, QuanForTrip, XResult, YResult);
					 .broadcast(tell,miningEvent(CurrID,ResourceType, QuanForTrip, XResult, YResult));	
					 					 				  					
					 -+currentID(CurrID + I);
				 }   	     	 	
	     	 } else {
	     	 	 ?currentID(CurrID);	
	     	 	 +miningEvent(CurrID, ResourceType, Quantity, XResult, YResult); 
	     	 	 .broadcast(tell,miningEvent(CurrID, ResourceType, Quantity, XResult, YResult))	;
	     	 	 	 
	     	 }    		     	 
	    	 .broadcast(tell,resourceAt(ResourceType,Quantity,XResult,YResult))	
	     }
.  
	     	

 +resource_not_found: true
   <-  	.print("I found nothing, I am moving again....").

   



   
    		  
	     
	    

	
