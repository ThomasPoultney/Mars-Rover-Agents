  
// Agent scanner in project ia_submission

/* Initial beliefs and rules */
type(scanner).
xPosition(0).
yPosition(0).
distanceTravelledX(0).
distanceTravelledY(0).
finishedScanning(false).
maxCapacityOfCollectionRovers(5).
currentID(1).

/* Initial goals */

!start.

/* Plans */


+!start : true <- .print("Agent Starting Up");				     	  
				  !check_configuaration;
				  !print_agent_types;
				  !rover_scan;
				  !get_next_action.
				
				 
				  			 
@print_agent_types[atomic]				
+!print_agent_types : true <- .findall(Ag, type(X,Ag), LAgs);
							  .print(Ag, " type is ", X).					  
				  


+!get_next_action : true <- .print("Calculating Next Action");																	
									if(finishedScanning(false)) {
										!get_next_scan_spot;
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
						    !move_to_next_scan_spot(XPosition, YPosition, ScanLocationX, ScanLocationY).

				    
-!get_next_scan_spot : true <- .print("Error finding a scan Location, Trying again").
							   

							 						   

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
																			  

																								
																								
-!move_to_next_scan_spot(_,_,_,_) : true <- .print("unable to move to scan location").																								  
																		 			   			 
																		  
				

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
							
@update_Position[atomic]	
+!update_Position : true <- ?mapWidth(MapWidth);
						    ?mapHeight(MapHeight);
						    ?distanceTravelledX(XPosition);
						    ?distanceTravelledY(YPosition);
						    ia_submission.returnModulus(XPosition,MapWidth, XResult);
						    ia_submission.returnModulus(YPosition,MapHeight, YResult);
						    .print("position of rover relative to base is x: ", XResult, " y: ",YResult);
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
	     if(ResourceType == "Obstacle") {
	     	 .broadcast(tell, obstacleAt(ResourceType,XResult,YResult));	
	     	 +obstacleAt(ResourceType,XResult,YResult)
	     } else {
	     	 +resourceAt(ResourceType,Quantity,XResult,YResult);
	     	 ?maxCapacityOfCollectionRovers(MaxCap);	     	 
	     	
	     	 if(Quantity > MaxCap) {
	     	 	.print("Collecting the Resource Takes Multiple Trips");
	     	 	ia_submission.calcNumTrips(MaxCap, Quantity, ListOfTrips);	     	 		     	 		     	 	
	     	 	.length(ListOfTrips, Length);  
				for (.range(I,0,Length-1)) {
					 ?currentID(CurrID);								      	
					.nth(0, ListOfTrips, QuanForTrip);
					 +miningEvent(ResourceType, QuanForTrip, XResult, YResult);
					 .broadcast(tell,miningEvent(CurrID, ResourceType,QuanForTrip,XResult,YResult))	;					  					
					  -+currentID(CurrID + I);
				 }   	     	 	
	     	 } else {
	     	 	 +miningEvent(ResourceType, Quantity, XResult, YResult);
	     	 	 .broadcast(tell,miningEvent(_,ResourceType,Quantity,XResult,YResult))	 	     	  
	     	 }    		     	 
	     	    
	    	 //.broadcast(tell,resourceAt(ResourceType,Quantity,XResult,YResult))	
	     }
	     .  
	     	

 +resource_not_found: true
   <-  	.print("I found nothing, I am moving again....").
   
+scanned(T) [source(Ag)]: true <- .print("Message Received from", Ag, T).
   
    		  
	     
	    

	
