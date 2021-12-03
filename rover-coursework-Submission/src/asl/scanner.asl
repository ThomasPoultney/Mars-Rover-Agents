// Agent scanner in project ia_submission

/* Initial beliefs and rules */
xPosition(0).
yPosition(0).
distanceTravelledX(0).
distanceTravelledY(0).

/* Initial goals */

!start.

/* Plans */

+!start : true <- .print("Agent Starting Up");
				  !check_configuaration;
				  !get_next_scan_spot.
				  
				  
				  

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
			     
@print_configuration[atomic]			     
+! print_configuration : true <- 
						  ?capacity(CurrentCapacity);
	   					  ?scanRange(CurrentScanRange);
	   					  ?resourceType(CurrentResourceType);
	   					  ?mapWidth(Width);
	   					  ?mapHeight(Height);
						  .print("Robot configuration is: capacity: ",CurrentCapacity, " Scan Range: ",CurrentScanRange, " Resource to collect: ", CurrentResourceType);
						  .print("Map Width is: ", Width, " Map Height is: ", Height).	

@scan_next_spot[atomic]						  
+!get_next_scan_spot : true <- .print("Getting Next Scan Location");
							?xPosition(XPosition);
							?yPosition(YPosition);
							?mapWidth(Width);
	   					  	?mapHeight(Height);
						    //.ia_submission.getNextScanLocation(XPosition, YPosition, Width, Height, ListOfScannedTiles, ScanLocationX, ScanLocationY);
						    !move_to_next_scan_spot(4, 4).

@move_to_next_scan_spot[atomic]
+!move_to_next_scan_spot(XPos, YPos) : not((X == XPos) & (Y == YPos)) <- .print("Moving to Next Scan Location");
																		      ?mapWidth(MapWidth);
	   																		  ?mapHeight(MapHeight);
	   																		  
																			  while((xPosition(X) & X \== XPos) | (yPosition(Y) & Y \== YPos)) {																			  															  	  
																			  	?xPosition(X);
																			  	?yPosition(Y);	
																			  	.findall([ResourceKind,XPos,Ypos], obstacleAt(ResourceKind,XPos,Ypos), ListOfDiscoveredResources);	    																	  	
																			  	ia_submission.astarsearch(X, Y, XPos, YPos, MapWidth, MapHeight, ListOfDiscoveredResources, XMoveOffSet, YMoveOffSet);
																			  	!move_rover(XMoveOffSet, YMoveOffSet); 
																			  }
																			
	
																			  .

+!move_to_next_scan_spot(X,Y, XPos, YPos) : (X == XPos) & (Y == YPos) <- .print("Already at Scan Location, Scanning!");
																		 !rover_scan.
																		  
				

@rover_scan[atomic]
+!rover_scan : true <- .print("Rover Scanning and then updating scanned Locations");
						 ?scanRange(ScanRange);
						 ?xPosition(X);
						 ?yPosition(Y).
					    // .ia_submission.retrieve_tiles_scanned(X,Y,ScanRange, ListOFScannedTiles).
					      
					     //add belief for each tileScanned

@move_rover[atomic]	
+!move_rover(XDist,YDist) : true <- move(XDist,YDist);
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