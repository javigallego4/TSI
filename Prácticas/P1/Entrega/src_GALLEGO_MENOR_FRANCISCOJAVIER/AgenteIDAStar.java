package tracks.singlePlayer.evaluacion.src_GALLEGO_MENOR_FRANCISCOJAVIER; 

//import java.util.ArrayList;
import java.util.Deque;
import java.util.ArrayDeque;
import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;
import java.util.Hashtable;
import java.util.LinkedHashSet;
import java.util.PriorityQueue;
import java.util.ArrayList;

public class AgenteIDAStar extends AbstractPlayer {
	Vector2d scale;
	Nodo initial_node, objective_node;
	double expandedNodes = 0;
	Hashtable<Double, Boolean> visited = new Hashtable<Double, Boolean>();
	LinkedHashSet<Double> obstacles = new LinkedHashSet<>();
	Deque<Types.ACTIONS> path = new ArrayDeque<>();
	static boolean pathFound = false;
    
	/**
     * Public constructor. We initialize both initial_node and final nodes, as well as scale and obstacles set.
     * @param stateObs state observation of the current game.
     * @param elapsedTimer Timer for the controller creation.
     */
    public AgenteIDAStar(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
    {
    	scale = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length ,
                stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);
		initial_node = new Nodo(new Vector2d(stateObs.getAvatarPosition().x / scale.x, stateObs.getAvatarPosition().y / scale.y), stateObs);
		objective_node = new Nodo(new Vector2d(stateObs.getPortalsPositions()[0].get(0).position.x/scale.x, stateObs.getPortalsPositions()[0].get(0).position.y / scale.y), stateObs);
		initial_node.heuristicValue = distManhattan(initial_node,objective_node);
		obstacles = getObstacles(stateObs);
    }

	/**
     * Respective actions, our avatar has to make in order to reach objective node. As we have saved parent attribute of each node, we just have to compare both
	 * current and parent node positions. Thus, we'll obtain which action has to be made. We start from the objective node. 
     */
    void pathActions() {
    	Nodo current = objective_node;    	        	
    	
    	while (current != initial_node) {
    		
			Nodo parent = current.parent;    		
    		if (current.posicion.x > parent.posicion.x) 
    			path.addFirst(Types.ACTIONS.ACTION_RIGHT);    		
    		 else if (current.posicion.x < parent.posicion.x) 
    			path.addFirst(Types.ACTIONS.ACTION_LEFT);    		
    		 else if (current.posicion.y < parent.posicion.y) 
    			path.addFirst(Types.ACTIONS.ACTION_UP);    		
    		 else if(current.posicion.y > parent.posicion.y)
    			path.addFirst(Types.ACTIONS.ACTION_DOWN);    		    		
    		current = parent;
    	}
    }    

	/**
     * This function has the aim of finding the path to the final objective node. We follow the pseudocode given on the slides.
     * @param stateObs: state observation of the current game. 
     */
    public void pathFinder(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
		long tInicio = System.nanoTime();
    	Deque<Nodo> ruta = new ArrayDeque<Nodo>();
    	double cota, t;
    	boolean error = false;
    	
    	cota = initial_node.heuristicValue;    	
    	ruta.add(initial_node);
		visited.put(initial_node.ID, true);
    	
    	do {
    		t = search(ruta, 0.0, cota, stateObs);    		
    		if(t == Double.MAX_VALUE) {	
    			error = true;
    			break; 
    		}      		
    		cota = t;    		    		
    	} while (t != 0.0); // El 0 va a ser nuestro ENCONTRADO del pseudocodigo
    			
		if(!error) {
			System.out.println("Cargando el plan...");
			System.out.println("Consumo de Memoria IDA: " + ruta.size());
			System.out.println("Nodos Expandidos IDA: " + expandedNodes);
			pathActions();
			long tFinal = System.nanoTime();
			long tiempoTotalEnSegundos = (tFinal - tInicio)/1000000;
			System.out.println("Tiempo Ejecución IDA*: " + tiempoTotalEnSegundos); 
		}
		else {
			System.out.println("Ha habido un error"); 
		}		    	    		
    }
    
    public double search(Deque<Nodo> ruta, double g, double cota, StateObservation stateObs) {    	    	
		Nodo nodo = ruta.peekLast();	
    	if(g + nodo.heuristicValue > cota)
    		return g + nodo.heuristicValue; 
    	
		expandedNodes++;
    	if(nodo.equals(objective_node)) {
    		objective_node.parent = nodo.parent;
    		return 0.0;	// limite
    	}
    	
    	double minimo = Double.MAX_VALUE;
    	double t;
    	PriorityQueue<Nodo> neighbours = new PriorityQueue<Nodo>();
    	neighbours = nodo.neighboursIDAStar(objective_node, stateObs);
    	
    	for(Nodo vecino :neighbours) {
    		if(isValid(stateObs, vecino) && !obstacles.contains(vecino.ID)) { 
    			if(!visited.containsKey(vecino.ID)) {
    				ruta.add(vecino);
    				visited.put(vecino.ID, true);
    				
    				t = search(ruta, g+1, cota, stateObs);
    				
    				if(t == 0.0) { 	// limite. Si hemos llegado al nodo objetivo.
    					return 0.0;
    				}
    				    					
    				if(t < minimo) { 
    					minimo = t; 
    				}
    				
    				visited.remove(ruta.pollLast().ID);    				
    			}
    		}
    	}
    	
    	return minimo;     	
    }

    /**
     * If we have not found the path yet, we find it. If this is not the case, we just return next action avatar's gonna make
     * @param stateObs state observation of the current game.
     * @param elapsedTimer timer.
     * @return next action to make
     */
    public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
    	if (!pathFound) {
    		pathFinder(stateObs, elapsedTimer);
    		pathFound = true;
        	//System.out.println(path.size());
    	}		
    	return path.poll();		        
    }
    
	/**
     * We are going to use Manhattan distance for heuristic values.
	 * @param n1 first node.
     * @param n2 second node. In our case, it's always going to be objective node
     */
	public double distManhattan(Nodo n1, Nodo n2){
    	return Math.abs(n1.posicion.x-n2.posicion.x) + Math.abs(n1.posicion.y-n2.posicion.y);
    }
    
	/**
     * Getting obstacles.
     * @param stateObs state observation of the current game.
     * @return LinkedHashSet with every obstacle in map, including both walls and spikes.
     */
    public LinkedHashSet<Double> getObstacles(StateObservation stateObs) {
		LinkedHashSet<Double> obstacles = new LinkedHashSet<>();
		ArrayList<Observation>[] immovablePositions = stateObs.getImmovablePositions();
		
		// Añadimos los IDs correspondientes a los obstacles
	    for(Observation obs : immovablePositions[0])
	    	obstacles.add( Math.floor(obs.position.x / scale.x) + stateObs.getObservationGrid().length * Math.floor(obs.position.y / scale.y));
	    
	    for(Observation obs : immovablePositions[1])
	    	obstacles.add( Math.floor(obs.position.x / scale.x) + stateObs.getObservationGrid().length * Math.floor(obs.position.y / scale.y));
	    	    
	    return obstacles;
	}
    
	/**
     * Check whether the given node is valid or not.
     * @param stateObs: state observation of the current game.
	 * @param node: node for which we are gonna check validity
     * @return Whether the given node is valid or not.
     */
    public boolean isValid(StateObservation stateObs, Nodo node) {
    	if(	node.posicion.x < stateObs.getObservationGrid().length 
    		&& node.posicion.y < stateObs.getObservationGrid()[0].length ){
    			return true;
    		}
    	return false;
    }	
}