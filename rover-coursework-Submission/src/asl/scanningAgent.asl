// Agent blank in project ia_submission

/* Initial beliefs and rules */

type(Scanning).
distanceTravelledX(0).
distanceTravelledY(0).
xPosition(0).
yPosition(0).
capacity(0).
scanRange(0).
resourceType("None").
mapWidth(0).
mapHeight(0).
numOfResourcesOnBoard(0).
/* Initial goals */

! check_configuaration.
!move_around(2,0).

@check_configuration[atomic]
+!check_configuaration :true <- .print("Checking and storing configuaration of agent and world");
			     rover.ia.check_config(Capacity,Scanrange,Resourcetype);
			     rover.ia.get_map_size(Width,Height);
			     -+capacity(Capacity);
			     -+scanRange(Scanrange);
			     -+resourceType(ResourceType);
			     -+mapWidth(Width);
			     -+mapHeight(Height);			     
			     ! print_configuration.

@print_configuration[atomic]			     
+! print_configuration : true <- 
						  ?capacity(CurrentCapacity);
	   					  ?scanRange(CurrentScanRange);
	   					  ?resourceType(CurrentResourceType);
	   					  ?mapWidth(Width);
	   					  ?mapHeight(Height);
						  .print("Robot configuration is: capacity: ",CurrentCapacity, " Scan Range: ",CurrentScanRange, " Resource to collect: ", CurrentResourceType);
						  .print("Map Width is: ", Width, " Map Height is: ", Height).
					
@move_around[atomic]		 
+! move_around(XDist, YDist) : true
	<- 
	   move(XDist,YDist);
	   ?distanceTravelledX(X);
	   ?distanceTravelledY(Y);
	   -+distanceTravelledX(X + XDist);
	   -+distanceTravelledY(Y + YDist);
	   ?distanceTravelledX(CheckDistanceTravelledX);
	   ?distanceTravelledY(CheckDistanceTravelledY);   
	   rover.ia.log_movement(XDist, YDist);
	   !update_Position
	   ?scanRange(ScanRange);
	   scan(ScanRange).
	   
-!move_around(XDist, YDist) : true <- .print("failed moving, waiting then trying again");
						.wait(5000);
						!move_around(XDist,YDist).
	   

	   
@update_Position[atomic]		   
//returns distance travelled relative to base.
+!update_Position : true <-	  
       ?mapWidth(MapWidth);
	   ?mapHeight(MapHeight);
	   ?distanceTravelledX(XPosition);
	   ?distanceTravelledY(YPosition);
	   ia_submission.returnModulus(XPosition,MapWidth, XResult);
	   ia_submission.returnModulus(YPosition,MapHeight, YResult);
	   .print("position of rover relative to base is x: ", XResult, " y: ",YResult);
	   -+xPosition(XResult);
	   -+yPosition(YResult).
	  
	   	      
	   
	   
-!move_around :true <- .print("Plan Error, resolve then continue");
						!move_around(2,0).
						
   	  
 // move around if nothing found  	  
 + resource_not_found: true
   <-  	.print("I found nothing, I am moving again....");
    		! move_around(2,0).
   
 // go to resource found
 @resource_found[atomic]
+ resource_found("Gold", Quantity, XDist, YDist):  true
	<-  
		 ?xPosition(X);
		 ?yPosition(Y);
		 ?mapWidth(MapWidth);
		 ?mapWidth(MapHeight);  
		 //converts Xdist to Ydist to distance releative to base
		 ia_submission.returnModulus(XDist,MapWidth, NewXDist);
		 ia_submission.returnModulus(YDist,MapHeight, NewYDist);	
		 .print("Distance away from rover is X: ",NewXDist);
		 .print("Distance away from rover is Y: ",NewYDist);
		 ia_submission.returnModulus(X+NewXDist,MapWidth, XResult);
	     ia_submission.returnModulus(Y+NewYDist,MapHeight, YResult);    
	     ia_submission.setUpMap(MapWidth,MapHeight);
	     +resourceAt("Gold",XResult,YResult);
	     .count(resourceAt(_,_,_),NumberOfResourcesFound);	   
	     .print(NumberOfResourcesFound);
	     .findall([ResourceKind,XPos,Ypos], resourceAt(ResourceKind,XPos,Ypos), ListOfDiscoveredResources);
		 .print(ListOfDiscoveredResources);
	     .print("The Position of the Gold resource relative to the base is X: ", XResult," Y: ",YResult);	 
	     .broadcast(tell,resourceAt("Gold",XResult,YResult));
	     !move_around(2,0). 
	   
	     
	     

+ resource_found("Obstacle", Quantity, XDist, YDist):  true
	<-  
		 ?xPosition(X);
		 ?yPosition(Y);
		 ?mapWidth(MapWidth);
		 ?mapWidth(MapHeight);  
		 //converts Xdist to Ydist to distance releative to base
		 ia_submission.returnModulus(XDist,MapWidth, NewXDist);
		 ia_submission.returnModulus(YDist,MapHeight, NewYDist);	
		 .print("Distance away from rover is X: ",NewXDist);
		 .print("Distance away from rover is Y: ",NewYDist);
		 ia_submission.returnModulus(X+NewXDist,MapWidth, XResult);
	     ia_submission.returnModulus(Y+NewYDist,MapHeight, YResult);    
	     ia_submission.setUpMap(MapWidth,MapHeight);
	     +obstacleAt("Obstacle",XResult,YResult);
	     .count(obstacleAt(_,_,_),NumberOfResourcesFound);	   
	     .print(NumberOfResourcesFound);
	     .findall([ResourceKind,XPos,Ypos], obstacleAt(ResourceKind,XPos,Ypos), ListOfDiscoveredResources);	    
		 .print(ListOfDiscoveredResources);
	     .print("The Position of the Obstacle resource relative to the base is X: ", XResult," Y: ",YResult);	 
	     .broadcast(tell,resourceAt("Obstacle",XResult,YResult));   
	     !move_around(2,0).
	
	



	    