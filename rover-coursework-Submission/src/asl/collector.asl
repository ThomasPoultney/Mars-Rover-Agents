// Agent collector in project ia_submission

/* Initial beliefs and rules */
xPosition(0).
yPosition(0).
type(collecter).
distanceTravelledX(0).
distanceTravelledY(0).
numOfResourcesOnBoard(0).
dedicatedResource(null).
/* Initial goals */

!start.

/* Plans */

+!start : true <- .print("Rover Starting Up");
				  !check_configuaration.
				




							

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
+!move_rover(XDist,YDist) : true <- move(XDist,YDist);
	   						?distanceTravelledX(X);
							?distanceTravelledY(Y);
							-+distanceTravelledX(X + XDist);
							-+distanceTravelledY(Y + YDist);							
							rover.ia.log_movement(XDist, YDist);
							!update_Position.
							

-!move_rover(XDist,YDist) : true <- .print("Error Moving, Waiting then trying again");
																		
									.					

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

@resourceAt[atomic]
+miningEvent(ID, ResourceType, Quantity, XPos, YPos):  true
	<-   .print("Executing Mining Event");
		 -+dedicatedResource(ResourceType);	 
		 ?xPosition(X);
		 ?yPosition(Y);
		 !move_to_resource(X,Y,XPos,YPos);
		 !collect_resource(ResourceType, Quantity);
       	 !return_to_base;	
       	 !deposit_resource(ResourceType, Quantity).	 		 	
		
-miningEvent(ID, ResourceType, Quantity, XPos, YPos):  true  <- .print("Mining Event Failed trying again");
																 !miningEvent(ID, ResourceType, Quantity, XPos, YPos).    


@collect_resource[atomic]		 
+!collect_resource(ResourceType, Quantity) :true <- ?capacity(Cap);
	     		  while(numOfResourcesOnBoard(R) & R <  Quantity) {    
        	      		 collect(ResourceType);
       					-+numOfResourcesOnBoard(R+1);
        				 ?numOfResourcesOnBoard(Resources);        	
       					.print("numOfResourcesOnBoard is", Resources);     
        		  }.

@deposit_resource[atomic]		 
+!deposit_resource(ResourceType, Quantity) : true <- 			 														
													 while(numOfResourcesOnBoard(R) & R >  0) { // where vl(X) is a belief     
											      		deposit(ResourceType);
											        	-+numOfResourcesOnBoard(R-1);
											       		 ?numOfResourcesOnBoard(Resources);
											        	.print("numOfResourcesOnBoard is", Resources);      
											     	 } 
      											     .															 

        	
@return_to_base[atomic]	        
+!return_to_base: true <- .print("Returning to base");
						 ?xPosition(CurrentX);
						 ?yPosition(CurrentY);	 	
						 !move_to_resource(CurrentX,CurrentY,0,0)
						 .        
        
+resourceAt(ResourceType, Quantity, XDist, YDist)[source(scanner)]: true <- 
	   .print("Message received chief, On my way").  

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
																			  }																			  
																			  .			   
						    
						    
					  
	    
	    
	    