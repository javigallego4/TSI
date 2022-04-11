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


public class AgenteBFS extends AbstractPlayer {	
	Deque<Types.ACTIONS> path = new ArrayDeque<>();
	static boolean pathIsCalculated = false;
	Vector2d fescala;
	Nodo initial, objective;
	int nodosExpandidos = 0; 
	
	/**
     * Public constructor with state observation and time due.
     * @param so state observation of the current game.
     * @param elapsedTimer Timer for the controller creation.
     */
    public AgenteBFS(StateObservation stateObs, ElapsedCpuTimer elapsedTimer){
    	fescala = new Vector2d(stateObs.getWorldDimension().width / stateObs.getObservationGrid().length ,
                stateObs.getWorldDimension().height / stateObs.getObservationGrid()[0].length);
		initial = new Nodo(new Vector2d(stateObs.getAvatarPosition().x / fescala.x, stateObs.getAvatarPosition().y / fescala.y), stateObs);		
		objective = new Nodo(new Vector2d(stateObs.getPortalsPositions()[0].get(0).position.x/fescala.x, stateObs.getPortalsPositions()[0].get(0).position.y / fescala.y), stateObs);		
    }
	
    /**
     * Getting obstacles set.
     * @param so state observation of the current game.
     * @return Hash Set with every obstacle in map.
     */
	public LinkedHashSet<Double> getObstacles(StateObservation stateObs) {
		LinkedHashSet<Double> obstaculos = new LinkedHashSet<>();
		ArrayList<Observation>[] immovablePositions = stateObs.getImmovablePositions();
		
		// Añadimos los IDs correspondientes a los obstaculos
	    for(Observation obs : immovablePositions[0])
	    	obstaculos.add( Math.floor(obs.position.x / fescala.x) + stateObs.getObservationGrid().length* Math.floor(obs.position.y / fescala.y));
	    
	    for(Observation obs : immovablePositions[1])
	    	obstaculos.add( Math.floor(obs.position.x / fescala.x) + stateObs.getObservationGrid().length* Math.floor(obs.position.y / fescala.y));
	    	    
	    return obstaculos;
	}	
	
	public boolean isValid(StateObservation stateObs, Nodo node) {
    	if(	node.posicion.x < stateObs.getObservationGrid().length 
    		&& node.posicion.y < stateObs.getObservationGrid()[0].length ){
    			return true;
    		}
    	return false;
    }
	
	/**
     * Getting the correct amount of actions avatar needs to make to achieve goal.    
     */
	void printPath() {
    	Nodo current = objective;
    	while (current.padre != null) {
    		Nodo parent = current.padre;
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
     * Path finder.
     * @param so state observation of the current game.
     * @param inicial, initial node.
     * @param objetivo, final objective node to reach.    
     */
	public void findPath(StateObservation stateObs, Nodo inicial, Nodo objetivo) {		 
		long tInicio = System.nanoTime();
		Deque<Nodo> cola = new ArrayDeque<Nodo>();		
		Hashtable<Double,Boolean> visitados = new Hashtable<Double,Boolean>();				
		ArrayList<Nodo> neighbours; 								        
		LinkedHashSet<Double> obstaculos = getObstacles(stateObs);

		Nodo u;
		
		cola.add(inicial);		
		visitados.put(inicial.ID, true);
				
		while(!cola.isEmpty()){
			u = cola.poll();
			nodosExpandidos = nodosExpandidos +1;

			if(u.equals(objetivo)) {
				objetivo.padre = u.padre;
				break;
			}			
			
			neighbours = u.neighbours(stateObs); 
			for(Nodo vecino: neighbours) 								
				if(isValid(stateObs, vecino) && !visitados.containsKey(vecino.ID))
					if(!obstaculos.contains(vecino.ID)) {					
						visitados.put(vecino.ID, true);
						cola.add(vecino); 
				}						
		}
				
		System.out.println("Cargando el plan...");
		System.out.println("Nodos expandidos BFS: " + nodosExpandidos);
		System.out.println("Consumo de Memoria BFS: " + visitados.size());
		printPath();
		long tFinal = System.nanoTime();
		long tiempoTotalEnSegundos = (tFinal - tInicio)/1000000;
		System.out.println("Tiempo Ejecución BFS: " + tiempoTotalEnSegundos);

	}
	
	/**
     * Picks next action avatar is gonna make.
     * @param stateObs state observation of the current game.
     * @param elapsedTimer Timer when the action returned is due.
     * @return An action for the current state
     */
	public Types.ACTIONS act(StateObservation stateObs, ElapsedCpuTimer elapsedTimer) {    	
		if (!pathIsCalculated) {
    		findPath(stateObs, initial, objective);
    		pathIsCalculated = true;
    	}
    	return path.poll();
        
    }
	
}