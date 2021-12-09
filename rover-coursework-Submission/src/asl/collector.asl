  
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
baseLocationX(0).
baseLocationY(0).
randomMovementValues([-1,0,1]).

/* Initial goals */

!start.


/* Plans */


@start[atomic]
+!start : true <- !check_configuaration;
				  !establish_comms;			
				  !get_next_action.
	
	
+!establish_comms: true <-   .all_names(AgentNames);
					 		 .length(AgentNames, Length); 
					 		 .my_name(MyName); 					 		 
					 		 //.print(X);	
					 		 ?type(MyType);			
					 		 ?resourceType(ResourceType);			 		 			  
					 		 for (.range(I,0,Length-1)) {
					      		.nth(I, AgentNames, AgentName);
					      		//.print(AgentName);						      						      	
					      	 	.send(AgentName, tell, agentData([MyName,MyType,ResourceType]));
					 		 }						 						 		 
					 		 .				

+agentData([Name,Type,ResourceType])[source(Ag)]: true <- .print("message received from ", Ag, " Whos type is  ", Type, " and Resource is ", ResourceType);
																if(Type == scanner | Type == hybrid) {																	
																	+scannerAgent(Ag,Type);
																} 
																
																if(Type == collector | Type == hybrid)	{																
																	+collectorAgent(Ag,Type,ResourceType,0);
																}
																.				 				  			 



+!get_next_action : true <- //.print("Calculating Next Action");																	
									.count(miningEvent(_,_,_,_,_), N)
									//.print("There are currently ", N , " Mining Events");
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
											//.print(P);
											//.print(ListOfMining);										
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
											 ?xPosition(CurrX);
											 ?yPosition(CurrY);
											 ?mapWidth(MapWidth);
	   					  				     ?mapHeight(MapHeight);	
											 ia_submission.returnModulus(CurrX + RandXMovement, MapWidth, XResult);
						    				 ia_submission.returnModulus(CurrY + RandYMovement, MapHeight, YResult);									 
											 .print("Making random move from current position(" , X ,"," , Y , ")  To random nearby position(",XResult,",", YResult,") to try recover");
											 !move_to_resource(CurrX,CurrY, XResult, YResult).
										    
	
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
	   					  .
						  //.print("Robot configuration is: capacity: ",CurrentCapacity, " Scan Range: ",CurrentScanRange, " Resource to collect: ", CurrentResourceType);
						  //.print("Map Width is: ", Width, " Map Height is: ", Height).	
						  
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
        		   !return_to_base;	       	 		   
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
+!return_to_base: true <- //.print("Returning to base");
						 ?xPosition(CurrentX);
						 ?yPosition(CurrentY);	 	
						 ?baseLocationX(BaseX);
						 ?baseLocationY(BaseY);
						 !move_to_resource(CurrentX,CurrentY,BaseX,BaseY).																			  			   
						          											     									    
						    						  			     	
			