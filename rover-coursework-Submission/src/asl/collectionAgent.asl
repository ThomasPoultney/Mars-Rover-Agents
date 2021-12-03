// Agent blank in project ia_submission

/* Initial beliefs and rules */

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
	  
	   	      
	   
	   
@return_to_base[atomic]
+! return_to_base : true
   <- ?xPosition(X);
	  ?xPosition(Y);
	  ia_submission.astarsearch(X,Y,0,0,MapWidth,MapHeight, ListOfDiscoveredResources,X, Y);  	  	    
	  while(numOfResourcesOnBoard(R) & R >  0) { // where vl(X) is a belief     
      	deposit("Gold");
        -+numOfResourcesOnBoard(R-1);
        ?numOfResourcesOnBoard(Resources);
        .print("numOfResourcesOnBoard is", Resources);      
      } 
	  rover.ia.clear_movement_log;
	  ! move_around;
   	  .
   	  
 // move around if nothing found  	  
 + resource_not_found: true
   <-  	.print("I found nothing, I am moving again....");
    	! move_around.

	    
 @resource_found[atomic]
 + resource_found("Obstacle", Quantity, XDist, YDist): true
	<-  .print("I found ",Quantity," ", "obstacle", " At Distance X: ", XDist, " Y: ", YDist).
	   
	   
+ resource_found("Diamond", Quantity, XDist, YDist): true
	<-  .print("I found ",Quantity," ", ResourceType, " At Distance X: ", XDist, " Y: ", YDist);
	    move(XDist, YDist);
	    rover.ia.log_movement(XDist, YDist);
	    .print("I am at the resource!!!!!");
	    .print("There are ", Quantity, " resources here");  
	    ?capacity(X);
	    while(numOfResourcesOnBoard(R) & R <  X) { // where vl(X) is a belief     
        	collect("Diamond");
       		-+numOfResourcesOnBoard(R+1);
        	?numOfResourcesOnBoard(Resources);
       		.print("numOfResourcesOnBoard is", Resources);      
        }
        .print("Retruning to base");
	    !return_to_base.
	    
	    

+ resource_found("Gold", Quantity, XDist, YDist): true
	<-  .print("I found ",Quantity," ", "Gold", " At Distance X: ", XDist, " Y: ", YDist);
	    move(XDist, YDist);
	    rover.ia.log_movement(XDist, YDist);
	    .print("I am at the resource!!!!!");
	    .print("There are ", Quantity, " resources here");  
	    ?capacity(X);
	    while(numOfResourcesOnBoard(R) & R <  X) { // where vl(X) is a belief     
        	collect("Gold");
       		-+numOfResourcesOnBoard(R+1);
        	?numOfResourcesOnBoard(Resources);
       		.print("numOfResourcesOnBoard is", Resources);      
        }
        .print("Retruning to base");
	    !return_to_base.
	    
+resourceAt("Gold",XDist,YDist)[source(scanningAgent)]: true <- 
	   .print("Message received chief, On my way").
	   
	   
	    
+resourceAt(T) [source(Ag)]: true <- .print("Message Received from", Ag, "There is a resouce at ",T).





	    

	    
