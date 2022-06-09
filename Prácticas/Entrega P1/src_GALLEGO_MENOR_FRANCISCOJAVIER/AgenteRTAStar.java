package tracks.singlePlayer.evaluacion.src_GALLEGO_MENOR_FRANCISCOJAVIER; 

import java.util.ArrayList;
import java.util.Deque;
import java.util.Hashtable;
import java.util.LinkedHashSet;
import java.util.ArrayDeque;
import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import ontology.Types.ACTIONS;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

public class AgenteRTAStar extends AbstractPlayer {
	Vector2d scale;
	Nodo initial_node, objective_node;
	int expandedNodes = 0;
	// Key: Node ID. Value: Heuristic value
	Hashtable<Double,Double> visited = new Hashtable<Double,Double>();
	Deque<Types.ACTIONS> path = new ArrayDeque<>();
	static boolean pathFound = false;	
	double executionTime = 0;
	boolean found = false;

   	/**
     * Public constructor. We initialize both initial_node and final nodes, as well as scale and obstacles set.
     * @param stateObs state observation of the current game.
     * @param elapsedTimer Timer for the controller creation.
     */
    public AgenteRTAStar(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
    {
    	scale = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length ,
                stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);
    	initial_node = new Nodo(new Vector2d(stateObs.getAvatarPosition().x / scale.x, stateObs.getAvatarPosition().y / scale.y), stateObs);
    	objective_node = new Nodo(new Vector2d(stateObs.getPortalsPositions()[0].get(0).position.x/scale.x, stateObs.getPortalsPositions()[0].get(0).position.y / scale.y), stateObs);    	
    }
    
    /**
     * This function has the aim of finding the path to the final objective node. We follow the instructions given on the slides.
     * @param stateObs: state observation of the current game. 
     */
	public Types.ACTIONS pathFinder(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {		
		Nodo current, nextNode = null; 
		ArrayList<Nodo> neighbours; 								        
		LinkedHashSet<Double> obstacles = getObstacles(stateObs);	
		double f, h_current, best = Double.MAX_VALUE, second_best = Double.MAX_VALUE;		 				
		
		current = new Nodo(new Vector2d(stateObs.getAvatarPosition().x / scale.x, stateObs.getAvatarPosition().y / scale.y), stateObs);		
		
		neighbours = current.neighboursAStar(objective_node, stateObs);
			

		// Buscamos el nodo vecino al que movernos en el siguiente movimiento
		for(Nodo vecino : neighbours)
			if(isValid(stateObs, vecino) && !obstacles.contains(vecino.ID)) {
				
				// Si ya hemos visitado el nodo, obtenemos su valor heuristico del hash
				if(visited.containsKey(vecino.ID))
					f = visited.get(vecino.ID);
				else
					// Todos los costes son 1. Solo importa valor heurístico
					f = vecino.heuristicValue;
				
				if(f < best) {
					second_best = best;
					best = f; 
					nextNode = vecino;
				}
				
				else {
					if(f < second_best)
						second_best = f;
				}
			}
						
		// Conseguimos el valor de h(x)
		if(visited.containsKey(current.ID)) 
			h_current = visited.get(current.ID);		
		else
			h_current = current.heuristicValue;
				
		// Buscamos el máximo. Primer caso: existe el 2º minimo
		if(second_best != Double.MAX_VALUE) {
			if(second_best+1 > h_current)
				h_current = second_best+1;
		}
		// No existe 2º minimo
		else {
			if(best+1 > h_current)
				h_current = best+1;
		}
		
		// actualizamos el valor heuristico en el hash
		visited.remove(current.ID);		
		visited.put(current.ID, h_current);

		expandedNodes++;
		if(nextNode.equals(objective_node)) {			
			found = true;
		}							
		
		// Accion correspondiente a realizar
		if (current.posicion.y > nextNode.posicion.y) {
			return Types.ACTIONS.ACTION_UP;	
		}
		else if (current.posicion.y < nextNode.posicion.y) {
			return Types.ACTIONS.ACTION_DOWN;	
		}
		else if (current.posicion.x > nextNode.posicion.x) {
			return Types.ACTIONS.ACTION_LEFT;	
		}
		else if (current.posicion.x < nextNode.posicion.x) {
			return Types.ACTIONS.ACTION_RIGHT;	
		}
		
		return ACTIONS.ACTION_NIL;		
	}

    /**
     * Picks an action. This function is called every game step to request an
     * action from the player.
     * @param stateObs Observation of the current state.
     * @param elapsedTimer Timer when the action returned is due.
     * @return An action for the current state
     */
    public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {
    	
    	long tInicio = System.nanoTime();
    	Types.ACTIONS accion;
		accion = pathFinder(stateObs, elapsedTimer);
		long tFinal = System.nanoTime();
		long tiempoTotalEnSegundos = (tFinal - tInicio);
		executionTime += tiempoTotalEnSegundos;
		
		if(found) {
			System.out.println("Consumo de Memoria RTA: " + visited.size());
			System.out.println("Nodos Expandidos RTA: " + expandedNodes);
			System.out.println("Tiempo RTA: " + executionTime/1000000);
		}
		
		return accion;  		    	        
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