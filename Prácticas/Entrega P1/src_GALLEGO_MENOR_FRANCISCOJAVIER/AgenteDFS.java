package tracks.singlePlayer.evaluacion.src_GALLEGO_MENOR_FRANCISCOJAVIER; 

// Import EDs
import java.util.ArrayList;
import java.util.Deque;
import java.util.Hashtable;
import java.util.LinkedHashSet;
import java.util.ArrayDeque;
import tools.Vector2d;
import tools.ElapsedCpuTimer;

// Import GVGAI utils
import core.game.Observation;
import core.player.AbstractPlayer;
import ontology.Types;
import core.game.StateObservation;


public class AgenteDFS extends AbstractPlayer {	
	Vector2d scale;
	Nodo initial_node, objective_node;
	Hashtable<Double,Boolean> visitedNodes = new Hashtable<Double,Boolean>();
	int expandedNodes = 0, counter = 0;
	LinkedHashSet<Double> obstacles = new LinkedHashSet<>();
	Deque<Types.ACTIONS> path = new ArrayDeque<>();
	static boolean pathFound;	
	
	/**
     * Public constructor. We initialize both initial and final nodes, as well as scale and obstacles set.
     * @param stateObs state observation of the current game.
     * @param elapsedTimer Timer for the controller creation.
     */
    public AgenteDFS(StateObservation stateObs, ElapsedCpuTimer elapsedTimer)
    {
    	scale = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length ,
                stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);
		initial_node = new Nodo(new Vector2d(stateObs.getAvatarPosition().x / scale.x, stateObs.getAvatarPosition().y / scale.y), stateObs);
		objective_node = new Nodo(new Vector2d(stateObs.getPortalsPositions()[0].get(0).position.x/scale.x, stateObs.getPortalsPositions()[0].get(0).position.y / scale.y), stateObs);
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
    		if (current.posicion.x > parent.posicion.x) {
    			path.addFirst(Types.ACTIONS.ACTION_RIGHT);
    		} else if (current.posicion.x < parent.posicion.x) {
    			path.addFirst(Types.ACTIONS.ACTION_LEFT);	
    		} else if (current.posicion.y < parent.posicion.y) {
    			path.addFirst(Types.ACTIONS.ACTION_UP);
    		} else if(current.posicion.y > parent.posicion.y){
    			path.addFirst(Types.ACTIONS.ACTION_DOWN);
    		}
    		
    		current = parent;
    	}    	
    }
	
	/**
     * This function has the aim of finding the path to the final objective node. We follow the pseudocode given on the slides.
     * @param stateObs: state observation of the current game.
     * @param initial_node: initial node.
     * @param objective_node: final objective node. 
     */
	public void pathFinder(StateObservation stateObs, Nodo inicial, Nodo objetivo) {		
		long tInicio = System.nanoTime();
		boolean found;
		visitedNodes.put(inicial.ID, true);
		found = DFS_busqueda(stateObs, inicial, objetivo);
				
		if(found) {
			System.out.println("Cargando el plan...");
			System.out.println("Nodos expandidos DFS: " + expandedNodes);
			System.out.println("Consumo de Memoria DFS: " + visitedNodes.size());
			pathActions();
			long tFinal = System.nanoTime();
			long tiempoTotalEnSegundos = (tFinal - tInicio)/1000000;
			System.out.println("Tiempo Ejecución BFS: " + tiempoTotalEnSegundos);
		}
	}
	
	public boolean DFS_busqueda(StateObservation stateObs, Nodo u, Nodo objetivo) {		
		expandedNodes += 1;
		if(u.equals(objetivo)) {
			objetivo.parent = u.parent;
			return true; 
		}
		
		ArrayList<Nodo> neighbours = u.neighbours(stateObs);					
		for(Nodo vecino: neighbours) {
			if(isValid(stateObs, vecino) && !visitedNodes.containsKey(vecino.ID) && !obstacles.contains(vecino.ID)) {
				visitedNodes.put(vecino.ID, true);	
				if(DFS_busqueda(stateObs, vecino, objetivo)) {
					return true;
				}
			}
		}
		
		return false; 
	}
	
	/**
     * If we have not found the path yet, we find it. If this is not the case, we just return next action avatar's gonna make
     * @param stateObs state observation of the current game.
     * @param elapsedTimer timer.
     * @return next action to make
     */
	public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {    	
		if (!pathFound) {
    		pathFinder(stateObs, initial_node, objective_node);
    		pathFound = true;
    	}
    	return path.poll();        
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
    public boolean isValid(StateObservation stateObs, Nodo nodo) {
    	boolean valido;
    	
    	if(	nodo.posicion.x < stateObs.getObservationGrid().length && nodo.posicion.y < stateObs.getObservationGrid()[0].length ){
    		valido = true;
    	}
    	else {
    		valido = false;
    	}
    	return valido;
    }		
}